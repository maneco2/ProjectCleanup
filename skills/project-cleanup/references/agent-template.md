# ProjectCleanup Agent

## Init

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

## Project Scope

- Active root: `<current cwd>`
- Source thread: `<current thread title/id if available>`
- Handoff date: `<yyyy-mm-dd>`
- Boundary: use only this project, this thread, and files under the active root unless the user explicitly approves another source.

## Language Settings

- Preferred response language: `<Portuguese | English | user preference>`
- Prompt/instruction language: `<English or project default>`
- Technical terms, code, logs, commands, and file paths may stay in their original language.

## Quality Targets

- Target size: `800-1500 words`
- Approximate word count: `<fill after writing>`
- If below 800 words: verify that no important state, decision, command, risk, or next action is missing.
- If above 1500 words: compress stale details, duplicated decisions, long logs, and transcript noise.

## Current State

Describe the real current state in short operational bullets. Include only facts that matter for the next thread.

## Important Decisions

List stable decisions the next chat must preserve. Merge duplicates and remove abandoned choices.

## Relevant Files

List only files the next chat will probably need to open. Include why each file matters.

## Validated Commands

List commands that were actually run and worked. Include the reason they matter and any required working directory.

## Next Actions

List concrete next steps in order. Each item should be actionable without reading the old chat.

## Risks And Guardrails

List operational risks, project boundaries, things not to touch, and mistakes to avoid.

## Suggested Memory Note

Include one short memory candidate only if there is stable reusable knowledge worth saving permanently. Otherwise write:

```text
No memory candidate.
```

Do not save memory automatically. Ask the user for separate approval.

## Validation Checklist

- [ ] Active root is present and correct.
- [ ] Project boundary is explicit.
- [ ] Preferred response language is stated.
- [ ] Current state is factual and current.
- [ ] Important decisions are preserved.
- [ ] Relevant files are listed with purpose.
- [ ] Validated commands are included or explicitly marked as none.
- [ ] Next actions are concrete and ordered.
- [ ] Risks and guardrails are included.
- [ ] No secrets, credentials, tokens, cookies, or long private dumps are included.
- [ ] Approximate word count is checked against the 800-1500 target.
