# ProjectCleanup

> A Codex skill for turning long, slow project chats into clean handoffs and fast new-thread continuity.

![Codex Skill](https://img.shields.io/badge/Codex-Skill-58A6FF)
![Plugin Ready](https://img.shields.io/badge/Plugin-Ready-2F855A)
![Version](https://img.shields.io/badge/version-0.2.1-2F855A)
![Status](https://img.shields.io/badge/status-active-brightgreen)

ProjectCleanup helps when a Codex project chat gets long, slow, repeatedly compacted, or hard to continue. It preserves the important context, removes conversation noise, and prepares a concise `agent.md` handoff for the current project only.

Created by **Odair Devalier - L2JServer Junior Developer**.

## Why It Exists

Long Codex chats can become slow, noisy, repeatedly compacted, and risky to continue. ProjectCleanup gives you a controlled way to move from a heavy thread into a clean thread without losing decisions, commands, risks, or next steps.

## Features

| Feature | Purpose |
| --- | --- |
| Clean handoff generation | Creates `docs/codex/project-cleanup/agent.md` for the current project. |
| Current-project boundary | Uses only the current chat and current project context. |
| Performance checkpoint | Offers cleanup when the chat feels heavy or context loss is likely. |
| Comfort-aware check scoring | Classifies a chat as `light`, `medium`, or `heavy` without treating length alone as heavy. |
| Preview mode | Drafts the handoff without writing files or creating threads. |
| Status mode | Reports whether `agent.md` exists, its size, age, and freshness. |
| Agent validation | Checks required sections, word count, and common secret patterns. |
| Size target | Keeps `agent.md` around 800-1500 words when practical. |
| Language settings | Separates user response language from operational prompt language. |
| Thread tool discovery | Calls exact and fallback `tool_search` queries, then distinguishes missing tools from missing target data. |
| Memory candidate flow | Suggests memory notes but never saves them without approval. |
| New-thread `/init` prompt | Starts the next thread with a short, focused prompt. |
| Manual approval gates | Asks before creating a new thread and asks separately before archiving the old one. |
| Secret-safe rules | Avoids passwords, tokens, credentials, private keys, cookies, and long private dumps. |

## Commands

Use the canonical slash commands below. If the skill is selected from a chip/path such as `[$project-cleanup](...)`, append a known subcommand or choose one of these slash commands; the skill reference alone should not run the full cleanup flow or the next-thread init prompt.

Explicit subcommands always win. `now` executes the full handoff flow immediately.

| Command | Purpose |
| --- | --- |
| `/project-cleanup` | Start the guided cleanup flow. |
| `/project-cleanup check` | Diagnose whether the current chat feels light, medium, or heavy. No files or threads are changed. |
| `/project-cleanup preview` | Draft the proposed `agent.md` in chat only. |
| `/project-cleanup status` | Report whether `agent.md` exists and whether it looks fresh or stale. |
| `/project-cleanup refresh` | Refresh the current project's `agent.md` without creating a new thread. |
| `/project-cleanup now` | Run the full handoff flow immediately with validation and confirmation gates. |

## Check Scoring

`heavy` is reserved for real impact: clear slowdown, repeated compactions, context loss, quality drops, forgotten decisions, or a handoff needed now.

When the result is `heavy`, ProjectCleanup should say that analysis may take longer and use more context/tokens because the chat is large. That extra use is expected for careful diagnosis, synthesis, and validation; the final response should still stay concise.

Long chats that still feel comfortable should be classified as `medium`, with `preview`, `status`, or `refresh` recommended before forcing a full new-thread handoff.

## Performance Checkpoint

When the chat appears long, slow, repeatedly compacted, or at risk of context loss, the skill should ask:

```text
This chat appears heavy or at risk of context loss. Would you like to create a handoff and start a clean new thread now?

1. Yes, prepare ProjectCleanup now.
2. Wait and continue in this chat.
3. Update agent.md only.
```

## Thread Tool Discovery

Before falling back to the manual init prompt, ProjectCleanup searches for thread tools with:

```text
create_thread set_thread_archived list_threads Codex thread tools
```

If that does not expose `create_thread`, it retries with a broader fallback search. Only after both searches fail should it report that the current session does not expose thread tools.

If `tool_search` returns `codex_app.create_thread`, the tool is available. ProjectCleanup must not say the tool did not appear. For project threads, `target.project.projectId` may be the saved project id or the saved workspace root path. If the active handoff path is a subdirectory, use the saved workspace root for `projectId` and keep the exact active subdirectory in the init prompt.

## Handoff Quality

`agent.md` should include:

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

Target size: **800-1500 words**. Shorter handoffs must still cover the operational state. Longer handoffs should be compressed before creating a new thread.

## Validate agent.md

The skill includes a small validator:

```text
python skills/project-cleanup/scripts/validate_agent_md.py docs/codex/project-cleanup/agent.md
```

The validator reports word count, required section gaps, and common secret patterns.

## Install As A Skill

Install from this repository by using the Codex skill installer with the skill path:

```text
repo: maneco2/ProjectCleanup
path: skills/project-cleanup
```

Restart Codex after installing so the skill is picked up.

## Install Manually

Copy this folder:

```text
skills/project-cleanup
```

To your Codex skills directory:

```text
~/.codex/skills/project-cleanup
```

On Windows:

```text
C:\Users\<your-user>\.codex\skills\project-cleanup
```

Restart Codex after copying.

## Repository Layout

```text
.codex-plugin/plugin.json
LICENSE
skills/project-cleanup/SKILL.md
skills/project-cleanup/agents/openai.yaml
skills/project-cleanup/references/agent-template.md
skills/project-cleanup/scripts/validate_agent_md.py
```

## License

MIT License. See `LICENSE`.

## Safety Model

- Never mix roots, chats, memories, or unrelated projects.
- Never save secrets, credentials, tokens, or long private dumps.
- Never use `fork_thread` as fallback.
- Never say `create_thread` is unavailable without first checking thread tools with exact and fallback `tool_search` queries.
- Never say the tool did not appear when `tool_search` returned `codex_app.create_thread`; use the saved workspace root as `projectId` or report the real blocker instead.
- Never archive the old thread before the new thread exists and the user confirms.
- Do not create or edit the project's `AGENTS.md`; read an existing file as input only.
- Treat memory as a candidate note until the user explicitly approves saving it.

## Credits

Created by **Odair Devalier - L2JServer Junior Developer**.
