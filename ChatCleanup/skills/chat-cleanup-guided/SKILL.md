---
name: chat-cleanup-guided
description: Show the simple ChatCleanup command choices for the active project.
---

# ChatCleanup Guided Flow

Use Portuguese for the response and keep command names, paths, and technical
identifiers in English. Treat ChatCleanup as a global skill: the same commands
work in every project chat where the skill is installed.

When the user invokes `/chat-cleanup` without a subcommand:

1. Confirm the current project root in one short sentence.
2. Show the six global choices: `/chat-cleanup`, `/chat-cleanup check`,
   `/chat-cleanup preview`, `/chat-cleanup status`,
   `/chat-cleanup refresh`, and `/chat-cleanup now`.
3. On Windows, when the local helper exists, open
   `ChatCleanup/hooks/show_checkpoint.ps1 -Guided`. The window is only a
   visual command chooser. Its buttons copy a command and tell the user to
   paste and send it; they never submit a message or modify a file.
4. If a desktop window cannot be opened, show the same six commands in chat.

Do not call a local service, render an in-chat panel, use a clipboard to submit a
command, or modify `AGENTS.md` from the guided chooser.
