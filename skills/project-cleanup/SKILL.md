---
name: project-cleanup
description: Use when a Codex project chat is long, slow, repeatedly compacted, or needs a clean handoff, performance checkpoint, review, or new thread without mixing projects, roots, or unrelated conversation history.
---

# ProjectCleanup

## Overview

Prepare a clean, low-token handoff for the current Codex thread and its current project only. The goal is continuity without dragging old chat noise into the next thread.

## Credits

Created by Odair Devalier - L2JServer Junior Developer.

## Non-Negotiables

- Work only from the current thread and current `cwd`/project.
- Never merge context from other projects, roots, old chats, or memories unless the user explicitly asks.
- Confirm the active project path before writing `agent.md`.
- Do not edit the project's `AGENTS.md` by default.
- Do not use `fork_thread` as a fallback because it can carry old history.
- Never archive the old thread before the new thread exists and the user confirms archival.
- Never save secrets: passwords, tokens, API keys, private keys, CAPTCHA secrets, DB credentials, cookies, session data, or long private dumps.

## Command

Primary trigger:

```text
/project-cleanup
```

Also use this skill for phrases like `ProjectCleanup`, "limpar este chat", "preparar novo chat limpo", "criar handoff deste projeto", or "este chat ficou lento".

Subcommands:

| Command | Behavior |
| --- | --- |
| `/project-cleanup check` | Diagnose whether the current chat feels light, medium, or heavy. Do not write files, create threads, or archive anything. |
| `/project-cleanup revisar` | Review and refresh the current project's existing `agent.md`. Ask before writing if the active project has not been confirmed in this turn. Do not create a new thread. |
| `/project-cleanup agora` | Run the full approved handoff flow: confirm project, generate `agent.md`, prepare init prompt, ask before `create_thread`, then ask separately before archival. |

## Workflow

1. Identify the current thread title when available and the current `cwd`.
2. State the active project path and ask for confirmation before writing files.
3. Inspect only current-project sources needed to understand the handoff: `AGENTS.md`, project docs, recent plans, relevant logs, and the current conversation summary available in context.
4. Generate or replace `docs/codex/project-cleanup/agent.md` using `references/agent-template.md`.
5. Keep the handoff concise: preserve stable facts, decisions, validated commands, relevant files, current state, next actions, and risks.
6. Remove noise: repeated conversation, abandoned attempts, long logs, generated dumps, stale guesses, and unrelated project context.
7. Show the user a short handoff summary and the exact init prompt for the next thread.
8. Ask for confirmation before calling `create_thread`.
9. Create the new thread with title `<current title> NEW` when the platform supports titles, using the init prompt from `agent.md`.
10. If `create_thread` fails, retry once. If it fails again, provide the manual prompt and do not archive anything.
11. After the new thread is created, ask for separate confirmation before calling `set_thread_archived` on the old thread.

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

- Option 1 maps to `/project-cleanup agora`.
- Option 2 continues normally and does not ask again in the same turn.
- Option 3 maps to `/project-cleanup revisar`.

## Output File

Write the handoff to:

```text
docs/codex/project-cleanup/agent.md
```

Replace stale content instead of appending forever. Keep the file useful as the single source for the next clean chat.

## New Thread Init Prompt

The prompt should stay short and point to the handoff file:

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

Primeira resposta esperada:
- Contexto carregado para <current cwd>.
- Projeto ativo confirmado.
- Aguardando o proximo comando.
```

## Memory Policy

Memory is optional. If the chat contains stable, reusable knowledge, propose a short memory note to the user. Save it only after explicit approval and only through the platform's memory workflow.

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

## Fallback

If thread tools are unavailable or `create_thread` fails twice:

1. Keep the old thread active.
2. Report the failure briefly.
3. Provide the path to `agent.md`.
4. Provide the manual init prompt ready for a new chat.

Do not call `fork_thread`. Do not archive the old thread.

## Review Mode

When the user asks to review or refresh ProjectCleanup, update the existing `agent.md` for the current project only:

- Remove stale context.
- Merge duplicate decisions.
- Update current state and next actions.
- Shorten wording without losing operational detail.
- Keep project boundaries explicit.

## Common Mistakes

| Mistake | Correct behavior |
| --- | --- |
| Reading another project because it looks related | Stay in current `cwd` unless user explicitly names another root |
| Archiving immediately after writing `agent.md` | Archive only after new thread exists and user confirms |
| Using `fork_thread` for convenience | Use only `create_thread`; otherwise provide manual prompt |
| Saving all chat text | Save decisions and state, not transcript noise |
| Putting everything in memory | Propose only stable memory, then wait for approval |
| Continuing silently when the user reports slowness | Offer the Performance Checkpoint prompt before doing more work |
