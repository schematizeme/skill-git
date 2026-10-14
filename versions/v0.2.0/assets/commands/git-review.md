---
description: schematize-git — revisa o histórico/PR contra o piso: roda o gate e lê o que a máquina não lê
argument-hint: "[range A..B | vazio = @{u}..HEAD]"
---

# /git-review — o histórico é o produto que dura mais que o código

## 1. A máquina primeiro

```bash
bash .claude/skills/schematize-git/scripts/check-git.sh . ${ARGUMENTS:+--range "$ARGUMENTS"} --linear
```
`0` passa · `1` reprova · `2` **nada para verificar** — que não é aprovação. Acrescente
`--require-signed` se o repo adota assinatura (`references/assinatura.md`).

O gate cobre: assunto fora de Conventional Commits (e `fixup!`/`squash!`), segredo em linha adicionada
(mesmo removida depois), `.env`/chave/`*.tfstate` versionado, blob novo acima de 5 MiB, merge commit
em branch linear, commit não assinado. Waiver: `git-ok: <motivo>` na linha ou `Git-Ok: <regra> <motivo>`
no corpo do commit.

## 2. Depois, o que a máquina não lê

- **Atomicidade:** cada commit é UMA mudança lógica e compila? (refactor misturado com feature = pedir divisão)
- **Porquê no corpo:** o commit explica a decisão, não repete o diff?
- **PR pequeno:** revisável em ~15 min? Senão, proponha fatiamento (`references/fluxo.md` §3).
- **Descrição do PR** responde as 4 perguntas (o quê/porquê, como testou, risco/rollback, onde olhar)?
- **BREAKING:** há mudança de contrato sem `!`/`BREAKING CHANGE`? O SemVer calculado bate?
- **Ruleset da `main`:** force push bloqueado, linear, PR, status check, assinatura? (`gh api repos/<o>/<r>/rulesets`)
- **CODEOWNERS** cobre `.github/`, auth, migrations, IaC, e aponta para time?
- **Histórico publicado reescrito?** Qualquer force push em `main`/tag é achado crítico.
- **Local diverge do publicado?** (`git status -sb`; commits só locais) — regra GitHub-é-a-fonte.

## 3. Feche

Achado vira correção no mesmo PR (novo commit, nunca reescrita de publicado) ou item de checklist
com dono. O vermelho do próprio gate: `bash scripts/check-git.test.sh`.
