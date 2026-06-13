# ProjectCleanup

Codex skill/plugin for clean project handoffs and new-thread continuity.

Created by Odair Devalier - L2JServer Junior Developer.

## What It Does

ProjectCleanup helps when a Codex project chat gets long, slow, repeatedly compacted, or hard to continue. It prepares a concise `agent.md` handoff for the current project only, then guides creation of a new clean thread with a short `/init` prompt.

It can also offer a performance checkpoint when a chat appears heavy or the user reports slowness.

Core rules:

- Use only the current chat and current project.
- Never mix unrelated roots, projects, old chats, or memories.
- Do not edit `AGENTS.md` by default.
- Do not use `fork_thread` as fallback.
- Archive the old thread only after the new thread exists and the user confirms.
- Do not save secrets, credentials, tokens, or long private dumps.

## Main Command

```text
/project-cleanup
```

Other useful prompts:

```text
ProjectCleanup
limpar este chat
preparar novo chat limpo
criar handoff deste projeto
este chat ficou lento
```

## Subcommands

```text
/project-cleanup check
```

Diagnoses whether the current chat feels light, medium, or heavy. It does not write files, create threads, or archive anything.

```text
/project-cleanup revisar
```

Refreshes the current project's existing `docs/codex/project-cleanup/agent.md` without creating a new thread.

```text
/project-cleanup agora
```

Runs the full handoff flow: confirm project, generate `agent.md`, prepare `/init`, ask before creating the new thread, then ask separately before archiving the old one.

## Performance Checkpoint

When the chat appears long, slow, repeatedly compacted, or at risk of context loss, the skill should ask:

```text
O chat parece pesado ou com risco de perda de contexto. Deseja criar um handoff e iniciar uma nova thread limpa agora?

1. Sim, preparar ProjectCleanup agora.
2. Aguardar mais e continuar neste chat.
3. Atualizar somente agent.md.
```

## Install As A Skill

Install from this repository by using the Codex skill installer with the skill path:

```text
repo: maneco2/ProjectCleanup
path: skills/project-cleanup
```

After installing, restart Codex so the skill is picked up.

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

## Plugin Layout

This repository also includes a Codex plugin manifest:

```text
.codex-plugin/plugin.json
skills/project-cleanup/
```

The skill remains the primary reusable component. The plugin manifest exists so this repository can evolve into a marketplace/plugin package later.
