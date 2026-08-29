#!/usr/bin/env python3
"""Track automatic compactions and show a simple ChatCleanup checkpoint."""

from __future__ import annotations

import base64
import hashlib
import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path


def checkpoint_message(count: int, milestone: int) -> str | None:
    if milestone == 3:
        return "ChatCleanup: 3 automatic compactions. Consider /chat-cleanup refresh."
    if milestone == 5:
        return "ChatCleanup: 5 automatic compactions. Run /chat-cleanup refresh."
    if milestone == 10:
        return f"ChatCleanup: {count} automatic compactions. Run /chat-cleanup now."
    return None


def is_subagent_event(event: dict) -> bool:
    """Ignore child-agent compactions when Codex exposes subagent metadata."""
    if event.get("subagent") is not None:
        return True
    if event.get("is_subagent") or event.get("isSubagent"):
        return True
    for key in (
        "parent_session_id",
        "parentSessionId",
        "agent_path",
        "agentPath",
        "agent_id",
        "agent_type",
    ):
        if str(event.get(key, "")).strip():
            return True
    return "subagent" in str(event.get("session_source", "")).lower()


def session_key(session_id: str) -> str:
    return hashlib.sha256(session_id.lower().encode("utf-8")).hexdigest()


def event_text(event: dict, names: tuple[str, ...]) -> str:
    for name in names:
        value = event.get(name)
        if str(value or "").strip():
            return str(value).strip()
    for container_name in ("chat", "thread", "conversation"):
        container = event.get(container_name)
        if not isinstance(container, dict):
            continue
        for name in names:
            value = container.get(name)
            if str(value or "").strip():
                return str(value).strip()
    return ""


def codex_home(event: dict) -> Path | None:
    configured_home = os.environ.get("CODEX_HOME", "").strip()
    if configured_home:
        candidate = Path(configured_home) / "session_index.jsonl"
        if candidate.is_file():
            return Path(configured_home)

    for user_root in (os.environ.get("USERPROFILE", "").strip(), os.environ.get("HOME", "").strip()):
        if not user_root:
            continue
        base = Path(user_root)
        candidates = (base, base / ".codex") if base.name.lower() == ".codex" else (base / ".codex",)
        for candidate_home in candidates:
            if (candidate_home / "session_index.jsonl").is_file():
                return candidate_home

    transcript_path = str(event.get("transcript_path", "")).strip()
    if not transcript_path:
        return None
    directory = Path(transcript_path).parent
    for _ in range(4):
        directory = directory.parent
    if (directory / "session_index.jsonl").is_file():
        return directory
    return None


def indexed_chat_name(event: dict, session_id: str) -> str:
    home = codex_home(event)
    if home is None:
        return ""
    index_path = home / "session_index.jsonl"
    try:
        with index_path.open("r", encoding="utf-8-sig") as index_file:
            for line in index_file:
                if not line.strip():
                    continue
                try:
                    entry = json.loads(line)
                except json.JSONDecodeError:
                    continue
                if str(entry.get("id", "")) != session_id:
                    continue
                for key in ("thread_name", "title", "name"):
                    value = str(entry.get(key, "")).strip()
                    if value:
                        return value
                break
    except (OSError, UnicodeError):
        pass
    return ""


def project_name(event: dict) -> str:
    cwd = str(event.get("cwd", "")).strip()
    if not cwd:
        return ""
    try:
        root = Path(cwd).resolve()
        return root.name or str(root)
    except OSError:
        return Path(cwd).name


def show_window(message: str, milestone: int, count: int, chat_name: str, project: str) -> None:
    if os.name != "nt":
        return
    script = Path(os.environ.get("PLUGIN_ROOT", "")) / "hooks" / "show_checkpoint.ps1"
    if not script.exists():
        return
    encoded = base64.b64encode(message.encode("utf-8")).decode("ascii")
    encoded_chat_name = base64.b64encode(chat_name.encode("utf-8")).decode("ascii")
    encoded_project = base64.b64encode(project.encode("utf-8")).decode("ascii")
    try:
        subprocess.Popen(
            [
                "powershell.exe",
                "-NoProfile",
                "-Sta",
                "-ExecutionPolicy",
                "Bypass",
                "-File",
                str(script),
                "-MessageBase64",
                encoded,
                "-ChatNameBase64",
                encoded_chat_name,
                "-ProjectNameBase64",
                encoded_project,
                "-Level",
                str(milestone),
                "-Count",
                str(count),
            ],
            creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0),
        )
    except OSError:
        pass


def main() -> int:
    try:
        event = json.load(sys.stdin)
        session_id = str(event.get("session_id", ""))
        if event.get("trigger") != "auto" or not session_id:
            return 0
        if is_subagent_event(event):
            return 0

        chat_name = event_text(
            event,
            (
                "chat_name",
                "chatName",
                "chat_title",
                "chatTitle",
                "conversation_name",
                "conversationName",
                "conversation_title",
                "conversationTitle",
                "thread_name",
                "threadName",
                "thread_title",
                "threadTitle",
                "title",
                "name",
            ),
        )
        if not chat_name:
            chat_name = indexed_chat_name(event, session_id)
        if not chat_name:
            chat_name = f"Chat {session_id[:8]}"
        project = project_name(event)

        data_root = os.environ.get("PLUGIN_DATA")
        if not data_root:
            return 0

        state_dir = Path(data_root) / "compactions-v4"
        state_dir.mkdir(parents=True, exist_ok=True)
        state_path = state_dir / f"session-{session_key(session_id)}.json"

        count = 0
        last_notified = 0
        if state_path.exists():
            try:
                state = json.loads(state_path.read_text(encoding="utf-8"))
                count = int(state["count"])
                last_notified = int(state.get("notified", 0))
            except (OSError, KeyError, TypeError, ValueError, json.JSONDecodeError):
                pass

        count += 1
        milestone = 10 if count >= 10 else 5 if count >= 5 else 3 if count >= 3 else 0
        message = checkpoint_message(count, milestone)
        should_notify = bool(message and (milestone > last_notified or milestone == 10))
        if should_notify and milestone > last_notified:
            last_notified = milestone

        state_path.write_text(
            json.dumps(
                {
                    "schema_version": 4,
                    "count": count,
                    "notified": last_notified,
                    "main_session_id": session_id,
                    "chat_name": chat_name,
                    "project_name": project,
                    "updated_at": datetime.now(timezone.utc).isoformat(),
                },
                indent=2,
            ),
            encoding="utf-8",
        )

        if should_notify and message:
            show_window(message, milestone, count, chat_name, project)
            print(json.dumps({"systemMessage": f"{message} The window copies commands; paste and send them in chat."}))
    except Exception:
        return 0
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
