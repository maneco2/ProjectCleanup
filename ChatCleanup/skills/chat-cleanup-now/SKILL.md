---
name: chat-cleanup-now
description: Refresh the active project's handoff and prepare a clean new Codex chat.
---

# ChatCleanup Now

Use Portuguese for the response and confirm the active project root before
editing. This is the complete handoff command for the current project.

Run these actions in order:

1. Inspect the current project and its `AGENTS.md` using only the active root
   and current chat.
2. If the managed ChatCleanup block is missing or stale, perform the same
   direct refresh described by `/chat-cleanup refresh`. Update only the marked
   block and preserve all content outside it.
3. Validate the resulting `AGENTS.md` with the bundled validator when the file
   contains the managed block.
4. Prepare the new-thread init prompt from the resulting handoff. Include the
   active project root, `AGENTS.md`, the project boundary, and concise rules.
5. If the host exposes `create_thread`, create a new chat with that prompt.
   Prefer a project thread when the active root is registered by the host. If
   the active root is local but not registered, use the host's projectless
   target with a directory name derived from the active root and keep the
   absolute root in the init prompt. Never select another project's ID and
   never use `fork_thread` as a fallback. If no thread-creation target is
   available, show the exact init prompt so the user can open a new chat
   manually.

The write to `AGENTS.md` is direct and does not use an intermediate review
step, confirmation dialog, local service, or in-chat panel. Never archive the old chat
automatically. Ask separately before archival if the user requests it.

Never mix roots, copy an old handoff blindly, save secrets, commit, push, or
publish without explicit authorization.
