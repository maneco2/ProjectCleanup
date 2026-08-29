<!-- BEGIN PROJECTCLEANUP HANDOFF -->

# ChatCleanup Handoff

## Init

Continue in `C:\Users\manec\Documents\Codex Skill`. This is the active root
for the local ChatCleanup plugin. Read this handoff before editing, confirm the
root in the response, and keep this project and thread isolated from every
other workspace.

## Project Scope

The scope is the `ChatCleanup/` plugin, root `README.md`, root `LICENSE`, and
root `AGENTS.md`. The design is intentionally small and local-first: global
chat skills, automatic compaction hooks, a native Windows checkpoint window,
local translations, and a bundled handoff validator.

There is no MCP, in-chat Home, inline HTML resource, local server, remote
service, or external runtime dependency. The native window is a copy-only
command reference. Its buttons copy text for the user to paste and send in the
correct Codex chat; they do not submit messages, inject keyboard input, or
modify project files by themselves.

## Global Commands

When installed, all commands work independently of the active project:

- `/chat-cleanup` opens the guided chooser and may open the Windows UI.
- `/chat-cleanup check` diagnoses the current chat without writing files.
- `/chat-cleanup preview` drafts the handoff in chat only.
- `/chat-cleanup status` reports `AGENTS.md` presence, size, age, and freshness.
- `/chat-cleanup refresh` updates only the managed block in this handoff.
- `/chat-cleanup now` refreshes when needed, prepares `/init`, and creates a
  project thread for registered roots or a projectless chat with the absolute
  root in the prompt for unregistered local roots.

`refresh` preserves every byte outside the two markers. `now` does not use
`fork_thread` as a fallback and does not archive the old chat. The normal
sequence is `check`, optional `preview` or `status`, `refresh`, then `now`.

## Language Settings

Respond and think in Portuguese, briefly and directly. Keep commands, paths,
function names, classes, and logs in English when clearer. The native catalog
covers English, Brazilian Portuguese, Spanish, French, German, Italian,
Simplified Chinese, Traditional Chinese, Japanese, Korean, Russian, and
Arabic; Arabic uses right-to-left layout. Never include secrets, credentials,
cookies, private keys, tokens, or chat transcripts in the handoff.

## Quality Targets

Keep this managed block between 800 and 3000 words, factual, current, and
operationally useful. Do not include private dumps, full transcripts, or
credentials.

## Current State

`ChatCleanup/.codex-plugin/plugin.json` is version
`0.4.0+codex.20260824125942`. It declares Skills and Hooks only, lists the six
global command forms, and has no MCP server entry. The package contains 23
files, including `ChatCleanup/assets/chatcleanup-checkpoint.png`.

`ChatCleanup/hooks/hooks.json` registers `PostCompact`. Windows uses
`post_compact.ps1`; other environments use `post_compact.py`. The hook keeps
one versioned counter per main chat under `PLUGIN_DATA/compactions-v4`, keyed
only by `session_id`; the project and `cwd` do not affect it. New main chats
start at zero; sub-agent events are ignored when Codex provides `subagent`,
`agent_id`, or `agent_type` metadata. The hook reports 3 and 5 once and every automatic compaction from 10
onward, and falls back safely when its environment is incomplete. The v4 state
ignores older project/session counts so they do not contaminate a new chat.

The Windows helper is `ChatCleanup/hooks/show_checkpoint.ps1`. It uses a fixed
WinForms window, Codex-style knot icon, dark title bar, dark surfaces, a
custom dark tab strip, visible tab borders, and outlined level rows for
`LIGHT`, `MEDIUM`, and `HEAVY`. It shows the current chat name and project
presence in the summary panel, recommended actions, and all six commands;
buttons only copy commands. The hook reads title/name variants from the event
or the local `session_index.jsonl` entry for the `session_id`, then falls back
to a short chat ID; an absent `cwd` is shown as no project detected. The helper
uses the 12-entry catalog in
`ChatCleanup/hooks/checkpoint-locales.json` and adaptive text sizing for long
translations. The latest source is also installed manually in the personal
cache under `0.4.0+codex.20260824125942` because the `codex plugin add` CLI was
blocked by Windows with “Access denied”. A fresh Codex chat is required to
load the updated cache. The `now` skill now supports an unregistered local root
through the host's projectless target and never selects another root.

The README is Markdown-only and contains the modern command table, workflow,
safety rules, development notes, and the cropped native-window image at
`ChatCleanup/assets/chatcleanup-checkpoint.png`. HTML tags were removed because
the Codex README preview rendered them as raw text.

## Important Decisions

- Work only in this root unless the user explicitly names another root.
- Keep commands global and independent of project names.
- Do not restore the removed MCP/Home tree, old proposal workflow, permission
  helper, or obsolete package layout.
- Keep the native helper copy-and-paste only; never automate sending commands.
- Keep the README and image asset inside this repository.
- Preserve unrelated working-tree changes and never use destructive Git reset
  or checkout operations.
- The current counter-isolation changes are not committed or pushed. Do not
  publish them until explicitly requested again.

## Relevant Files

- `ChatCleanup/.codex-plugin/plugin.json`: manifest and cachebuster.
- `ChatCleanup/hooks/hooks.json`: post-compaction registration.
- `ChatCleanup/hooks/post_compact.ps1` and `post_compact.py`: counter logic.
- `ChatCleanup/hooks/show_checkpoint.ps1`: native translated UI and icon.
- `ChatCleanup/hooks/checkpoint-locales.json`: 12 local catalogs.
- `ChatCleanup/skills/`: guided, check, preview, status, refresh, and now,
  including the unregistered-local-root thread fallback.
- `ChatCleanup/references/chat-cleanup-shared/`: workflow and validators.
- `ChatCleanup/assets/chatcleanup-checkpoint.png`: README image.
- `README.md`: user-facing documentation.

## Validated Commands

PowerShell syntax parsing, Python bytecode compilation, handoff validation,
chat-ID isolation tests, sub-agent exclusion tests, metadata rendering tests,
null-transcript title lookup tests, milestone tests, and a real WinForms preview
passed. The source and manually
installed cache copies of `post_compact.ps1`, `post_compact.py`, and
`show_checkpoint.ps1` have matching SHA256 hashes. The current worktree has
uncommitted changes in the handoff, hooks, workflow reference, README, and
preview asset; no commit or push was made for these changes.

## Worktree State

The managed handoff itself is refreshed locally. The global hook cache was
updated manually. No commit, push, publication, or marketplace edit was
performed.

## Next Actions

1. Start a fresh Codex chat so the updated global hook cache is loaded.
2. Trigger the main chat and a sub-agent; confirm only main-chat events
   increment the current chat ID's counter.
3. If the user explicitly requests publication, review the complete diff,
   create one commit, push to the configured private remote, and verify it.

## Risks And Guardrails

The native window requires Windows Forms, a desktop session, and a fresh chat
after plugin reinstall. If the host cannot surface a desktop window, the hook
must fall back to a short chat message. Clipboard access is limited to explicit
copy buttons. Do not claim that a new thread exists without a fresh
`threadId` or `pendingWorktreeId`. Do not mix this root with L2Precious,
FarmaControl, Drogaluz, GeoEditor, or Lineage2 reverse-engineering work.

## Suggested Memory Note

ChatCleanup is a local global-command plugin with a native copy-only checkpoint
window, 12 local catalogs, direct managed-block refresh, and no MCP or service
layer. The current UI source uses a dark theme and explicit borders for the
three compaction levels.

## Validation Checklist

- [x] Active root isolated and global command design retained.
- [x] Six global command skills and 12 local catalogs present.
- [x] Native UI uses Codex icon, dark theme, tab coverage, and level borders.
- [x] Modern Markdown README and source image asset present.
- [x] Plugin validation and PowerShell parser validation passed.
- [x] Updated cache copy matches the current UI source.
- [ ] Fresh-chat visual test completed.
- [ ] Latest UI changes committed and pushed only if explicitly requested.

<!-- END PROJECTCLEANUP HANDOFF -->
