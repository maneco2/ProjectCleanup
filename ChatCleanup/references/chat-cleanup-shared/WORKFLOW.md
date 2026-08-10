---
name: chat-cleanup
description: Use the global ChatCleanup commands to refresh a project handoff or start a clean chat without mixing roots.
---

# ChatCleanup Shared Workflow

## Purpose

ChatCleanup moves a long project conversation into a small, factual handoff.
The workflow is global: the same commands work in every project chat where
the skill is available. The active project root and current chat are the only
sources of project context.

## Commands

```text
/chat-cleanup
/chat-cleanup check
/chat-cleanup preview
/chat-cleanup status
/chat-cleanup refresh
/chat-cleanup now
```

`/chat-cleanup` is the guided chooser. On Windows it may open the native
`hooks/show_checkpoint.ps1` command window when the helper is available. The
window is informational: its buttons copy commands only, and the user pastes
and sends the selected command in the correct Codex chat.

`/chat-cleanup check` diagnoses the current chat level without changing files.
`/chat-cleanup preview` drafts the current handoff in chat only. `/chat-cleanup
status` reports the active `AGENTS.md` presence, markers, size, age, and
freshness. These three commands never write files or create threads.

`/chat-cleanup refresh` is the direct handoff action. It confirms the absolute
active root, reads the current project and `AGENTS.md`, generates a current
managed block, validates it, and writes it directly to the root `AGENTS.md`.
Only the text between the two ChatCleanup markers may change. If the file is
missing, create it with the managed block.

`/chat-cleanup now` runs the refresh behavior when the handoff is missing or
stale, validates the result, prepares the next-thread `/init` prompt, and uses
`create_thread` when that host capability is exposed. If thread creation is
unavailable, show the exact prompt for manual use. Do not use `fork_thread` as a
fallback and do not archive the old chat automatically.

## Handoff format

Every generated block must use exactly one pair of markers:

```html
<!-- BEGIN PROJECTCLEANUP HANDOFF -->
<!-- current ChatCleanup handoff -->
<!-- END PROJECTCLEANUP HANDOFF -->
```

The managed block should contain, when relevant:

- `Init`, with the active root and new-thread continuation prompt;
- project scope and boundaries;
- language settings;
- factual current state;
- important decisions;
- relevant files and their purpose;
- commands that were actually validated;
- ordered next actions;
- risks and guardrails;
- a short optional memory candidate;
- a validation checklist.

Aim for 800-1500 words for a full handoff. Compress stale details and never
copy an old handoff blindly. Do not include passwords, tokens, API keys,
private keys, cookies, database credentials, session data, private dumps, or
full chat transcripts.

## Direct-write rules

- Confirm the root before editing.
- Preserve every byte outside the managed block where practical.
- Use an atomic replacement when writing an existing file.
- Run the bundled validator after generating the complete file.
- Report whether the file changed, its resulting word count, and validation.
- Do not modify files in another root.
- Do not use a local service, an in-chat panel, a permission dialog, clipboard submission,
  keyboard automation, mouse automation, or a remote service.

## Checkpoints

The `PostCompact` hook stores a per-session count under `PLUGIN_DATA` and may
open the native checkpoint window at 3, 5, 10, and later automatic
compactions. A missing desktop helper must fall back to a short chat message;
checkpoint failures must never interrupt the current work.

## Thread safety

Use only the active project root in the init prompt. Treat a new thread as
created only after the host returns a fresh `threadId` or `pendingWorktreeId`.
Never report success based on an existing sidebar item. Keep the old thread
unarchived until the user separately asks for archival.

## Global behavior

These commands belong to the installed global skill, not to a project-local
configuration. If a project chat does not load ChatCleanup, reload or
reinstall the plugin and start a new chat. The command names remain stable even
when the project root changes.
