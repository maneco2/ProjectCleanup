---
name: chat-cleanup-status
description: Report the active project's AGENTS.md handoff status without modifying files.
---

# ChatCleanup Status

Use Portuguese and inspect only the active project. Confirm the absolute root,
then report:

- whether `AGENTS.md` exists;
- whether the managed ChatCleanup markers are valid;
- approximate word count and last-write time;
- whether the handoff appears fresh, stale, or missing;
- whether `/chat-cleanup preview`, `/chat-cleanup refresh`, or
  `/chat-cleanup now` is the most useful next action.

Do not modify files, create threads, archive chats, or use a local service. The
command is global and status-only.
