# ProjectCleanup Agent

## Init

```text
/init

Chat limpo criado por ProjectCleanup.

Projeto ativo:
C:\Users\manec\Documents\Codex Skill

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
- Contexto carregado para C:\Users\manec\Documents\Codex Skill.
- Projeto ativo confirmado.
- Handoff carregado para continuar deste ponto.
```

## Project Scope

- Active root: `C:\Users\manec\Documents\Codex Skill`.
- Source thread: current ProjectCleanup development thread.
- Handoff date: `2026-08-05`.
- Boundary: use only this workspace and its current Git repository. Do not mix Drogaluz, L2Precious, L2Tower, Lineage2, FarmaControl, or other roots.
- Public repository: `https://github.com/maneco2/ProjectCleanup`.

## Language Settings

- Respond in Portuguese, short and direct.
- Code, logs, commands, paths, manifest fields, and public UI strings may remain in English.
- All canonical ProjectCleanup commands must remain in English.

## Quality Targets

- Target size: `800-1500 words` when practical.
- Keep verified operational facts and remove transcript noise.
- Prefer local filesystem, Git, validator, and runtime evidence over assumptions.

## Current State

ProjectCleanup is now a complete personal Codex plugin with a global skill and a trusted `PostCompact` hook. The public source version is `0.3.0`. Commit `726b3e8` was pushed successfully to `origin/main` with the automatic checkpoint popup implementation.

The public repository contains only the required source: manifest, README, LICENSE, skill files, and hook files. Local-only directories `.local-tools/`, `docs/`, and `outputs/` are excluded through `.git/info/exclude` and must not be published. Release ZIP files must not be committed. No release was created during the latest update.

The Windows checkpoint popup was tested visually. It opens without a visible PowerShell console and contains two tabs: `Recommended Actions` and `All Commands`. Recommended actions copy `check`, `refresh`, or `now`. The command tab lists all six canonical commands with descriptions and copy buttons. Buttons only copy commands; they do not submit messages automatically. `Copy Check` was validated as exactly `/project-cleanup check`.

Automatic thresholds are: `3` compactions for light/check, `5` for medium/checkpoint, and `10+` for heavy/now. At 10 and every later compaction, the heavy popup should appear again and display the current count dynamically. The hook runs only after an automatic compaction finishes.

The installed personal plugin is cached as `0.3.0+codex.20260805232622`. Existing chats created before installation or reload may retain the old hook configuration and do not hot-reload the new plugin. A new chat after plugin installation is the reliable test boundary, and its per-session counter starts at zero.

Git status after publication had one unstaged local-only difference in `LICENSE`: a final newline with no content change. It was deliberately not included in commit `726b3e8`.

## Important Decisions

- Canonical commands are `/project-cleanup`, `check`, `preview`, `status`, `refresh`, and `now`; Portuguese aliases were removed completely.
- Explicit subcommands execute immediately without a separate `Sim`.
- `/project-cleanup now` authorizes automatic new-thread creation when `create_thread` is exposed.
- Never use `fork_thread` as fallback.
- Never archive the old chat before a new chat exists and the user separately confirms archival.
- Thread tools are platform capabilities, not commands implemented by the skill. Search for them before reporting session limitations.
- Popup buttons copy commands only. Do not use keyboard or mouse automation to submit commands into Codex.
- When the user explicitly authorizes a GitHub update, include the refreshed `docs/codex/project-cleanup/agent.md` in the reviewed commit and push the intended current-project changes to `origin/main`; never push without that explicit authorization.
- Create releases only with explicit user authorization. Release packages contain the complete `project-cleanup/` skill/plugin payload but never local docs, outputs, Git tools, or private handoffs.

## Relevant Files

- `.codex-plugin/plugin.json`: public metadata and version `0.3.0`.
- `README.md`: public features, commands, checkpoint rules, and installation behavior.
- `skills/project-cleanup/SKILL.md`: authoritative workflow and safety rules.
- `skills/project-cleanup/references/agent-template.md`: handoff structure.
- `skills/project-cleanup/scripts/validate_agent_md.py`: handoff validator.
- `hooks/hooks.json`: `PostCompact` registration.
- `hooks/post_compact.ps1`: Windows counter, thresholds, and popup launcher.
- `hooks/post_compact.py`: non-Windows checkpoint implementation.
- `hooks/show_checkpoint.ps1`: final WinForms popup.
- `docs/codex/project-cleanup/agent.md`: local handoff; never publish.

## Validated Commands

Run from `C:\Users\manec\Documents\Codex Skill`:

```text
python C:\Users\manec\.codex\skills\.system\skill-creator\scripts\quick_validate.py skills\project-cleanup
python C:\Users\manec\.codex\skills\.system\plugin-creator\scripts\validate_plugin.py .
python C:\Users\manec\.codex\skills\project-cleanup\scripts\validate_agent_md.py docs\codex\project-cleanup\agent.md
.local-tools\mingit\cmd\git.exe -c safe.directory='C:/Users/manec/Documents/Codex Skill' status --short
.local-tools\mingit\cmd\git.exe -c safe.directory='C:/Users/manec/Documents/Codex Skill' fetch origin main
```

The popup PowerShell scripts passed syntax parsing. Plugin and skill validators passed. The source and installed popup hashes matched after synchronization.

## Next Actions

1. Continue from a clean chat using this handoff.
2. Confirm the active root before any edit.
3. Test automatic checkpoints only in a chat created after the current plugin installation.
4. If a popup does not appear, inspect the session JSON under the ProjectCleanup plugin data directory and compare its timestamp with the active cache version.
5. Keep the local `LICENSE` newline difference out of future commits unless intentionally normalized.
6. Before another GitHub push, fetch `origin/main`, review the exact staged file list, scan public files for secrets, and stage only intended source files.
7. When explicitly authorized, review and push the complete intended update to GitHub, including this `agent.md` when it is part of the requested handoff update.
8. Create the next release only after explicit approval and final user testing.

## Risks And Guardrails

- Do not publish `docs/`, `outputs/`, `.local-tools/`, handoff files, screenshots, test logs, or release ZIPs.
- Do not assume old open chats load newly installed hooks.
- Do not claim a popup fires while compacting; it runs after `PostCompact`.
- Do not treat an existing sidebar chat as newly created. Success requires a fresh ID returned by the current `create_thread` call.
- Do not alter marketplace configuration manually during plugin updates.
- Do not overwrite unrelated dirty Git changes.
- Never include credentials, tokens, cookies, private keys, or private dumps.

## Suggested Memory Note

No memory candidate. The stable ProjectCleanup behavior is already documented in the public skill and README.

## Validation Checklist

- [x] Active root and boundary are explicit.
- [x] Language policy is present.
- [x] Current version, commit, plugin state, and popup behavior are current.
- [x] Canonical commands and approval behavior are preserved.
- [x] Relevant files and validated commands are included.
- [x] Next actions and guardrails are concrete.
- [x] Local-only and public artifacts are separated.
- [x] No secrets or private dumps are included.
- [x] Final word count is `1019`; validator result is `OK`.
