# ProjectCleanup Agent

## Init

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

## Projeto Ativo

- Root: `<current cwd>`
- Thread origem: `<current thread title/id if available>`
- Data do handoff: `<yyyy-mm-dd>`
- Idioma padrao: Portugues curto e direto.

## Regras Essenciais

- Usar somente este projeto e esta thread como fonte do handoff.
- Confirmar o projeto ativo antes de editar.
- Nao misturar roots, chats, memorias ou projetos parecidos.
- Nao salvar segredos, credenciais ou dumps longos.
- Nao editar `AGENTS.md` por padrao.

## Estado Atual

Descrever o estado real do projeto em poucos paragrafos ou bullets curtos.

## Decisoes Importantes

Listar decisoes estaveis que o proximo chat deve preservar.

## Arquivos Relevantes

Listar apenas arquivos que o proximo chat provavelmente deve abrir.

## Comandos Validados

Listar comandos que foram executados e funcionaram, com contexto curto.

## Proximos Passos

Listar as proximas acoes concretas, em ordem.

## Riscos E Cuidados

Listar riscos operacionais, limites de escopo e coisas que nao devem ser feitas.

## Memoria Candidata

Incluir somente uma nota curta se houver fato estavel que mereca memoria permanente. Caso contrario, escrever: `Nenhuma memoria candidata.`
