---
name: chat-cleanup-preview
description: Draft the active project's handoff in chat without writing files.
---

# ChatCleanup Preview

Use Portuguese and inspect only the active project and current chat. Confirm
the active root before reporting the preview.

When the user sends `/chat-cleanup preview`:

- read the current project and `AGENTS.md` when it exists;
- generate a current marked ChatCleanup handoff in the response;
- include scope, state, decisions, relevant files, validated commands, next
  actions, and risks;
- validate the structure with the bundled validator when available;
- do not write `AGENTS.md`, create threads, archive chats, commit, push, or
  open a local service.

The command is global and is preview-only.
