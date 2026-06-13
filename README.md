# ProjectCleanup

> A Codex skill for turning long, slow project chats into clean handoffs and fast new-thread continuity.

![Codex Skill](https://img.shields.io/badge/Codex-Skill-58A6FF)
![Plugin Ready](https://img.shields.io/badge/Plugin-Ready-2F855A)
![Version](https://img.shields.io/badge/version-0.2.0-2F855A)
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
| Check scoring | Classifies a chat as `light`, `medium`, or `heavy`. |
| Preview mode | Drafts the handoff without writing files or creating threads. |
| Status mode | Reports whether `agent.md` exists, its size, age, and freshness. |
| Agent validation | Checks required sections, word count, and common secret patterns. |
| Size target | Keeps `agent.md` around 800-1500 words when practical. |
| Language settings | Separates user response language from operational prompt language. |
| Memory candidate flow | Suggests memory notes but never saves them without approval. |
| New-thread `/init` prompt | Starts the next thread with a short, focused prompt. |
| Manual approval gates | Asks before creating a new thread and asks separately before archiving the old one. |
| Secret-safe rules | Avoids passwords, tokens, credentials, private keys, cookies, and long private dumps. |

## Commands

| Command | Purpose |
| --- | --- |
| `/project-cleanup` | Start the guided cleanup flow. |
| `/project-cleanup check` | Diagnose whether the current chat feels light, medium, or heavy. No files or threads are changed. |
| `/project-cleanup preview` | Draft the proposed `agent.md` in chat only. |
| `/project-cleanup status` | Report whether `agent.md` exists and whether it looks fresh or stale. |
| `/project-cleanup revisar` | Refresh the current project's `agent.md` without creating a new thread. |
| `/project-cleanup agora` | Run the full handoff flow with validation and confirmation gates. |

## Performance Checkpoint

When the chat appears long, slow, repeatedly compacted, or at risk of context loss, the skill should ask:

```text
This chat appears heavy or at risk of context loss. Would you like to create a handoff and start a clean new thread now?

1. Yes, prepare ProjectCleanup now.
2. Wait and continue in this chat.
3. Update agent.md only.
```

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
skills/project-cleanup/SKILL.md
skills/project-cleanup/agents/openai.yaml
skills/project-cleanup/references/agent-template.md
skills/project-cleanup/scripts/validate_agent_md.py
```

## Safety Model

- Never mix roots, chats, memories, or unrelated projects.
- Never save secrets, credentials, tokens, or long private dumps.
- Never use `fork_thread` as fallback.
- Never archive the old thread before the new thread exists and the user confirms.
- Do not edit the project's `AGENTS.md` by default.
- Treat memory as a candidate note until the user explicitly approves saving it.

## Credits

Created by **Odair Devalier - L2JServer Junior Developer**.
