---
name: project-cleanup
description: Use when a Codex project chat is long, slow, repeatedly compacted, or needs a clean handoff, performance checkpoint, preview, status check, review, validation, or new thread without mixing projects, roots, or unrelated conversation history.
---

# ProjectCleanup

## Overview

Prepare a clean, low-token handoff for the current Codex thread and its current project only. The goal is continuity without dragging old chat noise into the next thread.

## Credits

Created by Odair Devalier - L2JServer Junior Developer.

## Non-Negotiables

- Work only from the current thread and current `cwd`/project.
- Never merge context from other projects, roots, old chats, or memories unless the user explicitly asks.
- For explicit subcommands, do not pause just to ask for confirmation before writing `agent.md`; state the active project path and continue. Ask only if the project path is missing, ambiguous, outside the current workspace, or conflicts with the requested project.
- Do not create or edit the project's `AGENTS.md`; read an existing `AGENTS.md` only as input context.
- Do not use `fork_thread` as a fallback because it can carry old history.
- Do not say `create_thread` is unavailable until both the exact and fallback thread-tool searches have been attempted and the returned tool names have been checked.
- If `tool_search` exposes `codex_app.create_thread`, treat thread creation as available. Do not say the tool did not appear.
- For `codex_app.create_thread`, `target.project.projectId` may be the current saved project id or the current workspace root path.
- A new thread counts as created only when the current `/project-cleanup now` run successfully calls `create_thread` and receives a `threadId` or `pendingWorktreeId`.
- Treat ProjectCleanup as a global installed skill: the same `/project-cleanup` commands apply in every project chat where this skill is available. Do not require per-project activation beyond the installed skill being loaded by Codex.
- Distinguish global command availability from session tool availability: `/project-cleanup now` can run in any loaded skill session, but automatic new-thread creation still depends on that session exposing `codex_app.create_thread`.
- Treat explicit subcommands as authoritative: `/project-cleanup`, `/project-cleanup check`, `/project-cleanup preview`, `/project-cleanup status`, `/project-cleanup refresh`, `/project-cleanup now`, and chip/path forms with those suffixes must continue immediately without waiting for a separate `Sim`.
- Never archive the old thread before the new thread exists and the user confirms archival.
- Never save secrets: passwords, tokens, API keys, private keys, CAPTCHA secrets, DB credentials, cookies, session data, or long private dumps.

## Command

Primary trigger:

```text
/project-cleanup
```

Command dispatch rules:

- Apply these dispatch rules in every Codex project chat where the installed skill is available; they are not project-local commands.
- Execute actions only when the user gives the canonical slash command `/project-cleanup` or a clear subcommand such as `/project-cleanup check`, `/project-cleanup preview`, `/project-cleanup status`, `/project-cleanup refresh`, or `/project-cleanup now`.
- If the user references the skill chip/path only, for example `[$project-cleanup](...)`, do not run the full cleanup flow automatically. Briefly list the valid commands and ask which one they want.
- If the user references the skill chip/path plus a known subcommand, for example `[$project-cleanup](...) refresh`, treat it as the equivalent canonical command `/project-cleanup refresh` and execute only that subcommand.
- A bare chip/path reference never overrides an explicit appended subcommand.
- Use natural-language triggers like `ProjectCleanup`, "limpar este chat", "preparar novo chat limpo", "criar handoff deste projeto", or "este chat ficou lento" to offer or route to the matching canonical command, not to silently run `/project-cleanup now`.

Subcommands:

| Command | Behavior |
| --- | --- |
| `/project-cleanup check` | Diagnose whether the current chat feels light, medium, or heavy. Do not write files, create threads, or archive anything. |
| `/project-cleanup preview` | Draft the proposed `agent.md` in chat only. Do not write files, create threads, or archive anything. |
| `/project-cleanup status` | Report whether `docs/codex/project-cleanup/agent.md` exists, its approximate word count, age, and likely freshness. Do not modify anything. |
| `/project-cleanup refresh` | Review and refresh the current project's existing `agent.md` immediately. State the active project path, but do not ask for a separate confirmation unless the root is ambiguous or conflicting. Do not create a new thread. |
| `/project-cleanup now` | Run the full approved handoff flow immediately: state the project path, generate `agent.md`, validate it, prepare the next-thread init prompt, create the new thread when `create_thread` is exposed, then ask separately before archival. |

## Approval Policy

Do not ask for a separate `Sim` or approval before executing these explicit commands:

- `/project-cleanup`
- `/project-cleanup check`
- `/project-cleanup preview`
- `/project-cleanup status`
- `/project-cleanup refresh`
- `/project-cleanup now`
- `[$project-cleanup](...) check`
- `[$project-cleanup](...) preview`
- `[$project-cleanup](...) status`
- `[$project-cleanup](...) refresh`
- `[$project-cleanup](...) now`

For these commands, state the active project path and proceed. Ask only if the active root is missing, ambiguous, outside the current workspace, or conflicts with the requested project.

For `/project-cleanup now`, automatic thread creation is part of the command. If `codex_app.create_thread` is exposed and the project root is clear, call it without asking for another approval. Archiving the old thread remains a separate action and still requires explicit user confirmation after the new thread exists.

## Global Skill Behavior

ProjectCleanup is intended to be installed once under the user's Codex skills directory and then used from any project chat with the same commands. Do not treat each project as needing its own activation, copied command list, or local configuration file.

If a chat does not load the `project-cleanup` skill at all, report that the installed global skill was not exposed in that session and ask the user to restart/reload Codex or reinstall/sync the skill. Do not rewrite the project or create unrelated local command files as a workaround.

If the skill is loaded but `codex_app.create_thread` is not exposed after `tool_search`, the command still worked; only automatic thread creation is blocked by the current session's tool availability. In that case, finish with the manual prompt and explicitly say `No new thread was created by this run`.

## Workflow

1. Identify the current thread title when available and the current `cwd`.
2. State the active project path. For explicit `/project-cleanup refresh` and `/project-cleanup now`, continue without asking for a separate write confirmation. Ask only if the path is missing, ambiguous, outside the current workspace, or conflicts with the requested project.
3. Inspect only current-project sources needed to understand the handoff: existing `AGENTS.md`, project docs, recent plans, relevant logs, and the current conversation summary available in context. Do not create or modify `AGENTS.md`.
4. Generate a structured handoff using `references/agent-template.md`.
5. Apply the quality gates: required sections, target size, current-project boundary, no secrets, validated commands, risks, and concrete next actions.
6. For `/project-cleanup preview`, show the proposed handoff in chat and stop without writing.
7. For `/project-cleanup refresh` or `/project-cleanup now`, generate or replace `docs/codex/project-cleanup/agent.md`.
8. Validate `agent.md` with `scripts/validate_agent_md.py` when Python is available; otherwise perform the manual checklist in this skill.
9. Show the user a short handoff summary, validation result, and the exact init prompt for the next thread. Keep that prompt separate from the current-thread reply to `/project-cleanup now`.
10. Before any manual new-thread fallback, actually call `tool_search.tool_search_tool`; do not just reason from the visible tools list. First search exactly for `create_thread set_thread_archived list_threads Codex thread tools`. If that does not expose `create_thread`, run a second fallback search for `Codex thread create archive tools create_thread set_thread_archived`.
11. Inspect the returned tool names. If the result includes `codex_app.create_thread`, `create_thread` is available. Do not write "the tool did not appear" or similar. If the result includes `codex_app.set_thread_archived`, archival is available too.
12. If both searches fail to expose `create_thread`, say precisely: `This session does not expose Codex thread creation tools after tool_search.` Then provide the manual prompt and do not archive anything.
13. If `codex_app.create_thread` is available, prepare a call to it instead of falling back manually. Use `target: { type: "project", projectId: <current workspace root>, environment: { type: "local" } }` when the current workspace root is a saved Codex project. The schema accepts a saved project id or workspace root path here.
14. Do not pass the thread id as `projectId`. If the handoff's active path is a subdirectory inside the saved project, still use the saved workspace root as `projectId` and put the exact subdirectory in the init prompt's `Projeto ativo`.
15. If the workspace root is unclear, call `list_threads` to inspect the current/recent thread `cwd`, or use the environment `cwd` when it is the saved project root. If this is still ambiguous, say precisely: `create_thread is available, but this session did not expose a clear saved project root for an automatic project thread.` Provide the manual prompt and keep the old thread active.
16. Do not use a `projectless` `create_thread` target for a project handoff unless the user explicitly approves that tradeoff after being told it may not attach to the active saved project/root.
17. When the required target data is available, call `create_thread` without asking for another approval because `/project-cleanup now` is the approval for new-thread creation. Create the new thread with the init prompt from `agent.md`. If supported, rename it to `<current title> NEW` with `set_thread_title` after creation.
18. If `create_thread` fails because the workspace root was rejected, retry once with the best confirmed saved project root. If it fails again, report the concrete failure, provide the manual prompt, and do not archive anything.
19. Report `New thread created` only if this run received a fresh `threadId` or `pendingWorktreeId` from `create_thread`. Existing sidebar threads, previous test threads, similarly named `NEW` threads, or manual prompts do not count.
20. After the new thread is created, ask for separate confirmation before calling `set_thread_archived` on the old thread.

## Check Mode

For `/project-cleanup check`, classify the current chat:

| Level | Signals | Recommendation |
| --- | --- | --- |
| `light` | Short chat, few decisions, no context risk, fast responses | Continue normally. |
| `medium` | Long chat, one compaction, many decisions or files discussed, but still comfortable to continue and no clear context loss | Offer `/project-cleanup preview`, `/project-cleanup status`, or `/project-cleanup refresh`. |
| `heavy` | Clear slowdown, repeated compactions, user or agent notices context loss, quality drops, decisions are being forgotten, or handoff is needed now | Recommend `/project-cleanup now`. |

Classify as `medium`, not `heavy`, when the chat is long but still feels comfortable and the user reports no real loss of quality.

When the result is `heavy`, notify the user that the cleanup may take longer and may use more context/tokens because an extended chat requires more careful reading and synthesis. This extra token use is acceptable for diagnosing, summarizing, and validating the handoff, but the final response should remain concise.

Use this output shape:

```text
ProjectCleanup check
- Status: light | medium | heavy
- Why: <short evidence>
- Recommendation: <continue | preview | refresh | now>
- Note: <only for heavy: analysis may take longer and use more context/tokens because the chat is large>
- No files changed.
```

## Performance Checkpoint

If the chat appears long, slow, repeatedly compacted, or the user mentions performance, context loss, token load, or sluggish responses, pause before continuing and offer ProjectCleanup.

Use this prompt:

```text
This chat appears heavy or at risk of context loss. Would you like to create a handoff and start a clean new thread now?

1. Yes, prepare ProjectCleanup now.
2. Wait and continue in this chat.
3. Update agent.md only.
```

Respect the answer:

- Option 1 maps to `/project-cleanup now`.
- Option 2 continues normally and does not ask again in the same turn.
- Option 3 maps to `/project-cleanup refresh`.

## Output File

Write the handoff to:

```text
docs/codex/project-cleanup/agent.md
```

Replace stale content instead of appending forever. Keep the file useful as the single source for the next clean chat.

## Handoff Size Policy

Target size for `agent.md`: **800-1500 words**.

- If it is below 800 words, verify that project scope, current state, decisions, validated commands, risks, and next actions are still covered.
- If it is above 1500 words, compress wording, remove stale details, merge duplicate decisions, summarize long logs, and keep only operational facts needed by the next thread.
- Do not pad with filler to reach the lower target. Completeness matters more than word count.

## Required Agent Sections

Every generated or refreshed `agent.md` should include:

- Init prompt.
- Project scope and boundary.
- Language settings.
- Current state.
- Important decisions.
- Relevant files.
- Validated commands.
- Next actions.
- Risks and guardrails.
- Suggested memory note.
- Validation checklist.

## Language Policy

Separate the user's preferred response language from operational prompt language:

- Preserve the user's preferred response language when known.
- Default to Portuguese for this user's local projects unless the project or user says otherwise.
- Keep code, logs, command names, file paths, and technical identifiers in their natural language.
- It is acceptable for ProjectCleanup's own checkpoint prompt to be in English while the new thread response style remains Portuguese.

## Agent Validation

Prefer the bundled validator:

```text
python scripts/validate_agent_md.py docs/codex/project-cleanup/agent.md
```

Validation should check:

- Required sections exist.
- Approximate word count is reported.
- `agent.md` stays in the 800-1500 word target when practical.
- No common secret patterns appear.
- The file names the active project/root.
- Next actions and risks are present.

If the validator is unavailable, perform the checklist manually and report any gaps before creating a new thread.

## Status Mode

For `/project-cleanup status`, inspect only the current project and report:

- Whether `docs/codex/project-cleanup/agent.md` exists.
- Approximate word count.
- Last modified time when available.
- Whether it appears fresh, stale, or missing.
- Recommended action: `preview`, `refresh`, or `now`.

Do not write files in status mode.

## New Thread Init Prompt

The prompt should stay short and point to the handoff file:

The prompt below is for the new thread only, after `create_thread` succeeds. Do not use it as the current-thread reply to `/project-cleanup now`.

```text
/init

Chat limpo criado por ProjectCleanup.

Projeto ativo:
<current cwd>

Leia primeiro:
docs/codex/project-cleanup/agent.md

Regras iniciais:
- Responder em portugues, curto e direto.
- Codigo, logs e nomes tecnicos podem ficar em ingles.
- Confirmar pasta/projeto ativo antes de editar.
- Usar somente o contexto deste projeto/thread.
- Nao misturar com outros roots ou chats.
- Usar o agent.md como contexto principal.
- Se faltar detalhe, pedir o minimo necessario.

Primeira resposta esperada no novo chat:
- Contexto carregado para <current cwd>.
- Projeto ativo confirmado.
- Handoff carregado para continuar deste ponto.
```

## Memory Policy

Memory is optional. If the chat contains stable, reusable knowledge, add a `Suggested Memory Note` section to `agent.md` and ask the user for separate approval.

Good memory candidates:

- Stable project rules.
- Validated commands.
- Important decisions.
- Known hazards.
- Next-step handoff facts that will matter in future chats.

Bad memory candidates:

- Secrets or credentials.
- Long logs.
- Temporary debugging guesses.
- One-off implementation details.
- Context from another project.

Do not save memory automatically.

## Fallback

If thread tools are unavailable after both `tool_search` queries, if `create_thread` is available but the saved workspace root cannot be determined, or if `create_thread` fails twice:

1. Keep the old thread active.
2. Report the failure briefly and explicitly say `No new thread was created by this run`.
3. Provide the path to `agent.md`.
4. Provide the manual init prompt ready for a new chat.
5. If the user reports that another `NEW` thread exists, do not treat it as this run's result unless its `threadId` came from the current `create_thread` call.

Do not call `fork_thread`. Do not archive the old thread.

## Review Mode

When the user asks to review or refresh ProjectCleanup, update the existing `agent.md` for the current project only:

- Remove stale context.
- Merge duplicate decisions.
- Update current state and next actions.
- Shorten wording without losing operational detail.
- Keep project boundaries explicit.
- Re-check the 800-1500 word target.
- Keep `Suggested Memory Note` separate from saved memory.

## Common Mistakes

| Mistake | Correct behavior |
| --- | --- |
| Reading another project because it looks related | Stay in current `cwd` unless user explicitly names another root |
| Archiving immediately after writing `agent.md` | Archive only after new thread exists and user confirms |
| Using `fork_thread` for convenience | Use only `create_thread`; otherwise provide manual prompt |
| Saying `create_thread` is unavailable without checking thread tools | Run the exact `tool_search` query first, retry with the fallback query, inspect returned tool names, and use precise wording about missing tools versus missing workspace root |
| Saying the tool did not appear when `tool_search` returned `codex_app.create_thread` | Treat `create_thread` as available; if blocked, name the real blocker such as unclear saved workspace root |
| Refusing to use the current workspace root as `projectId` | Use the saved workspace root path for `target.project.projectId`; the schema allows saved project id or workspace root |
| Treating an existing `NEW` sidebar item as success | Only a fresh `threadId` or `pendingWorktreeId` returned by this run's `create_thread` call counts |
| Creating or editing `AGENTS.md` during cleanup | Read existing `AGENTS.md` as context only; ProjectCleanup writes `docs/codex/project-cleanup/agent.md` |
| Saving all chat text | Save decisions and state, not transcript noise |
| Ignoring size | Aim for 800-1500 words, but do not add filler |
| Putting everything in memory | Propose only stable memory, then require approval |
| Continuing silently when the user reports slowness | Offer the Performance Checkpoint prompt before doing more work |
