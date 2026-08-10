#!/usr/bin/env python3
"""Track automatic compactions and show a simple ChatCleanup checkpoint."""

from __future__ import annotations

import base64
import json
import os
import re
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


def show_window(message: str, milestone: int, count: int) -> None:
    if os.name != "nt":
        return
    script = Path(os.environ.get("PLUGIN_ROOT", "")) / "hooks" / "show_checkpoint.ps1"
    if not script.exists():
        return
    encoded = base64.b64encode(message.encode("utf-8")).decode("ascii")
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

        data_root = os.environ.get("PLUGIN_DATA")
        if not data_root:
            return 0

        state_dir = Path(data_root) / "compactions"
        state_dir.mkdir(parents=True, exist_ok=True)
        safe_session_id = re.sub(r"[^A-Za-z0-9._-]", "_", session_id)
        state_path = state_dir / f"{safe_session_id}.json"

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
        if should_notify:
            last_notified = milestone

        state_path.write_text(
            json.dumps(
                {
                    "count": count,
                    "notified": last_notified,
                    "cwd": str(event.get("cwd", "")),
                    "updated_at": datetime.now(timezone.utc).isoformat(),
                },
                indent=2,
            ),
            encoding="utf-8",
        )

        if should_notify and message:
            show_window(message, milestone, count)
            print(json.dumps({"systemMessage": f"{message} The window copies commands; paste and send them in chat."}))
    except Exception:
        return 0
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
