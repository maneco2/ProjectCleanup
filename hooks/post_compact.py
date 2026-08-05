#!/usr/bin/env python3
"""Emit ProjectCleanup checkpoints after automatic Codex compactions."""

from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path


MESSAGES = {
    3: "Light: 3 automatic compactions. Run /project-cleanup check?",
    5: "Medium: 5 automatic compactions. Review the Performance Checkpoint.",
    10: "Heavy: 10 automatic compactions. Run /project-cleanup now.",
}
TEST_EVERY_COMPACTION = False


def show_notification(message: str) -> None:
    """Best-effort desktop notification for non-Windows hook execution."""
    try:
        if sys.platform == "darwin":
            escaped = message.replace("\\", "\\\\").replace('"', '\\"')
            subprocess.Popen(
                ["osascript", "-e", f'display notification "{escaped}" with title "ProjectCleanup"'],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
        elif shutil.which("notify-send"):
            subprocess.Popen(
                ["notify-send", "ProjectCleanup", message],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
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
            except (KeyError, TypeError, ValueError, json.JSONDecodeError, OSError):
                count = 0
                last_notified = 0

        count += 1
        milestone = 10 if count >= 10 else 5 if count >= 5 else 3 if count >= 3 else 0
        message = (
            f"Heavy: {count} automatic compactions. Run /project-cleanup now."
            if milestone == 10
            else MESSAGES.get(milestone)
        )
        if TEST_EVERY_COMPACTION:
            message = f"TEST: automatic compaction #{count} detected."

        should_notify = TEST_EVERY_COMPACTION or bool(
            message and (milestone > last_notified or milestone == 10)
        )
        if should_notify and not TEST_EVERY_COMPACTION:
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
            show_notification(message)
            print(json.dumps({"systemMessage": f"ProjectCleanup checkpoint - {message} Reply yes or no."}))
    except Exception:
        return 0

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
