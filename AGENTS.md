<!-- BEGIN PROJECTCLEANUP HANDOFF -->

# ChatCleanup Handoff

## Init

Continue the work in `C:\Users\manec\Documents\Codex Skill`.

This is the active root for the local ChatCleanup plugin. Read this file before
editing, confirm the root in the response, and keep this project and thread
separate from every other workspace.

## Project Scope

The active project is the `ChatCleanup/` plugin, the root `README.md`, the
root `LICENSE`, and the root `AGENTS.md` handoff. The plugin is intentionally
small and local-first: global chat skills, automatic compaction hooks, a
native Windows checkpoint window, local translations, and a bundled handoff
validator.

There is no MCP, in-chat Home, inline HTML resource, local server, remote
service, or external runtime dependency. The native window is a command
reference only. Its buttons copy text so the user can paste and send it in the
correct Codex chat. It does not submit messages, inject keyboard input, or
modify project files by itself.

Never mix this root with L2Precious, FarmaControl, Drogaluz, GeoEditor,
Lineage2 reverse-engineering work, or any other project. Do not restore the
removed MCP/Home tree, old proposal workflow, permission helper, or obsolete
package layout unless the user explicitly changes the design.

## Language Settings

Respond and think in Portuguese, briefly and directly. Keep slash commands,
paths, function names, classes, code, and logs in English when that is clearer.
The desktop catalog covers English, Brazilian Portuguese, Spanish, French,
German, Italian, Simplified Chinese, Traditional Chinese, Japanese, Korean,
Russian, and Arabic. Arabic uses the native right-to-left form layout.

## Commands

All commands are global when the plugin is installed:

- `/chat-cleanup` opens the guided chooser and may open the native command
  window on Windows.
- `/chat-cleanup check` diagnoses the current chat without changing files.
- `/chat-cleanup preview` drafts the current handoff in chat only.
- `/chat-cleanup status` reports `AGENTS.md` presence, size, age, and freshness.
- `/chat-cleanup refresh` directly updates the managed block in the active
  root `AGENTS.md`.
- `/chat-cleanup now` refreshes when necessary, prepares the `/init` prompt,
  and creates a new project thread when the host exposes that capability.

The normal sequence is `check`, optional `preview` or `status`, `refresh`, and
then `now`. `refresh` preserves every byte outside the two handoff markers.
`now` never uses `fork_thread` as a fallback and never archives the old chat.

## Quality Targets

Keep the managed block between 800 and 1500 words, factual, current, and
operationally useful. Never include secrets, private data, or full chat
transcripts.

## Current State

The manifest is `ChatCleanup/.codex-plugin/plugin.json`, currently version
`0.4.0+codex.20260810034500`. It declares only Skills and Hooks, lists all
six global command forms in its interface, and contains no MCP server entry.
The package currently contains 23 files, including the README checkpoint
image at `ChatCleanup/assets/chatcleanup-checkpoint.png`.

`ChatCleanup/hooks/hooks.json` configures `PostCompact`. Windows uses
`post_compact.ps1`; other environments use `post_compact.py`. The hook stores
one counter per session under `PLUGIN_DATA/compactions`, reports milestones at
3, 5, and 10 automatic compactions, and continues safely when its environment
is incomplete.

On Windows, `show_checkpoint.ps1` opens a fixed native WinForms window. It
shows the current count, the `LIGHT`, `MEDIUM`, and `HEAVY` progression, the
recommended actions, an all-commands tab, and copy buttons. The level labels
use adaptive sizing so they remain visible in the supported languages. The
window uses a Codex-style knot icon in the title bar, header, and taskbar,
hides the PowerShell console from the taskbar, and sets a dedicated app
identity. The localized catalog is
`ChatCleanup/hooks/checkpoint-locales.json`.

The root README was modernized with Markdown-only rendering, a command table,
flow overview, safety rules, development instructions, and the native window
hero image. HTML tags were removed because the Codex README preview displayed
them as raw text. The image is stored inside the plugin source at
`ChatCleanup/assets/chatcleanup-checkpoint.png`.

## Important Decisions

- Work only in `C:\Users\manec\Documents\Codex Skill` unless the user names
  another root explicitly.
- Keep commands global; command names must not depend on the active project.
- Use only the current project root and current chat as context sources.
- Limit `refresh` writes to the marked block in the active root `AGENTS.md`.
- Keep the native window copy-and-paste only; never automate sending commands.
- Keep the README and image asset inside this repository.
- Do not expose credentials, tokens, cookies, private keys, or chat transcripts.
- Do not commit, push, publish, or edit marketplace configuration without
  explicit authorization. The user has now explicitly authorized sending this
  complete project to the configured private GitHub remote.

## Relevant Files

- `ChatCleanup/.codex-plugin/plugin.json`: manifest, capabilities, command
  prompts, and cachebuster version.
- `ChatCleanup/hooks/hooks.json`: post-compaction hook registration.
- `ChatCleanup/hooks/post_compact.ps1` and `post_compact.py`: counter and
  checkpoint fallback logic.
- `ChatCleanup/hooks/show_checkpoint.ps1`: native translated command window,
  adaptive level labels, and Codex-style icon.
- `ChatCleanup/hooks/checkpoint-locales.json`: 12 local translations.
- `ChatCleanup/skills/`: guided, check, preview, status, refresh, and now
  global skills.
- `ChatCleanup/references/chat-cleanup-shared/`: workflow, template, and
  validator resources.
- `ChatCleanup/assets/chatcleanup-checkpoint.png`: README hero image.
- `README.md`: user-facing documentation and installation guide.

## Validated Commands

- `validate_plugin.py ChatCleanup` passed after the manifest update.
- `validate_agent_md.py AGENTS.md --strict-size` passed before this refresh.
- JSON parsing passed for the manifest, hooks configuration, and locale catalog.
- PowerShell parser validation passed for both hook scripts.
- Python compilation passed for the hook and bundled validator.
- The native window was launched in Portuguese and English during visual
  checks; the icon and adaptive level labels were verified in the desktop UI.
- The guided skill and all per-skill prompts now reference the six global slash
  commands consistently.
- The locale catalog contains a translated copy label for all 12 supported
  languages, including the fallback path when the catalog is unavailable.
- The GitHub remote authentication was verified with `git ls-remote` without
  exposing credentials.

## Next Actions

1. Validate this refreshed `AGENTS.md` and the final plugin once more.
2. Stage the complete working tree, including the migration, README, plugin,
   and image asset.
3. Create one commit and push it to the configured private `origin` on `main`,
   as explicitly requested by the user.
4. Verify the pushed commit and clean working tree with a remote check.
5. Reinstall the local plugin and open a fresh Codex chat for runtime testing.

## Risks And Guardrails

The native window requires Windows Forms and a desktop session. If unavailable,
the hook must fall back to a short chat message. Clipboard access is limited
to explicit copy buttons. Do not launch the helper as a replacement for the
active chat command. Do not claim a new thread exists without a fresh
`threadId` or `pendingWorktreeId` from the host. Preserve unrelated migration
changes already present in the working tree and do not use destructive Git
commands.

## Suggested Memory Note

The current ChatCleanup design is a local global-command plugin with a native
copy-only checkpoint window, 12 local catalogs, direct managed-block refresh,
and no MCP or service layer.

## Validation Checklist

- [x] Active root confirmed and isolated.
- [x] Simple Skills and Hooks design retained without MCP.
- [x] Six global command skills present.
- [x] Native checkpoint window and 12 local translations present.
- [x] Codex-style icon and adaptive level labels implemented.
- [x] Modern Markdown README and source asset added.
- [x] Manifest updated with all global command forms and new cachebuster.
- [x] Plugin, handoff, JSON, PowerShell, and Python checks passed.
- [x] Private GitHub remote authentication verified.
- [ ] Final commit, push, and post-push remote verification pending.

<!-- END PROJECTCLEANUP HANDOFF -->
