<!-- BEGIN PROJECTCLEANUP HANDOFF -->

# ChatCleanup Handoff

## Init

Use this prompt only in the new thread created by `/chat-cleanup now`:

```text
/init

Chat limpo criado por ChatCleanup.

Projeto ativo:
<active project root>

Leia primeiro:
AGENTS.md

Regras iniciais:
- Responder em portugues, curto e direto.
- Confirmar a pasta/projeto ativo antes de editar.
- Usar somente o contexto deste projeto e thread.
- Nao misturar outros roots ou chats.
- Usar o AGENTS.md como contexto principal.
- Pedir somente o detalhe minimo quando faltar contexto.
```

## Project Scope

- Active root: `<active project root>`
- Source thread: `<current thread title/id when available>`
- Handoff date: `<yyyy-mm-dd>`
- Boundary: only this project, this thread, and files under the active root.

## Language Settings

- Preferred response language: `<Portuguese | English | user preference>`
- Technical terms, code, logs, commands, and paths may retain their original language.

## Quality Targets

- Target size: `800-3000 words`
- Approximate word count: `<fill after writing>`
- No secrets, credentials, cookies, tokens, private dumps, or transcript noise.

## Current State

Describe the real current state in short operational bullets.

## Important Decisions

List stable decisions the next chat must preserve.

## Relevant Files

List only files the next chat will probably need, with their purpose.

## Validated Commands

List commands that were actually run and worked, with their working directory.

## Next Actions

List concrete next steps in order.

## Risks And Guardrails

List boundaries, hazards, files not to touch, and mistakes to avoid.

## Suggested Memory Note

Include one short candidate only when stable reusable knowledge exists.

## Validation Checklist

- [ ] Active root is present and correct.
- [ ] Project boundary is explicit.
- [ ] Current state is factual and current.
- [ ] Relevant files and validated commands are listed.
- [ ] Next actions and risks are concrete.
- [ ] No private data or transcript noise is included.
- [ ] Approximate word count is within target when a full handoff is needed.

<!-- END PROJECTCLEANUP HANDOFF -->
