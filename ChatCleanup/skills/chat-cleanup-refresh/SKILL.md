---
name: chat-cleanup-refresh
description: Directly refresh the active project's AGENTS.md handoff.
---

# ChatCleanup Refresh

Use Portuguese for the response and keep the active project root as the
current workspace root supplied by the host. This command is global and must
never mix another project or chat.

When the user sends `/chat-cleanup refresh`:

1. Confirm the absolute active project root.
2. Read the current project files needed to understand its scope and state.
3. Read the current root `AGENTS.md` when it exists.
4. Generate a current, concise handoff between exactly these markers:

   `<!-- BEGIN PROJECTCLEANUP HANDOFF -->`

   `<!-- END PROJECTCLEANUP HANDOFF -->`

5. Include only useful operational facts: project scope, current state,
   important decisions, relevant files, validated commands, next actions, and
   risks. Do not include secrets, credentials, cookies, tokens, private dumps,
   or old chat transcripts. Keep the managed block between 800 and 1500 words
   when the project needs a full handoff.
6. Validate the complete resulting file with
   `ChatCleanup/references/chat-cleanup-shared/scripts/validate_agent_md.py`
   when that validator is available.
7. Write the refreshed block immediately to `<active root>/AGENTS.md`,
   preserving every byte outside the managed markers. Use an atomic write when
   possible. Create the file only when it is missing.
8. Report the root, whether the file changed, the resulting word count, and
   validation status in a short final response.

This command never calls a local service, renders an in-chat panel, opens a confirmation
dialog, creates a thread, archives a chat, commits, pushes, or
publishes. The direct write is limited to the active root's `AGENTS.md`.
