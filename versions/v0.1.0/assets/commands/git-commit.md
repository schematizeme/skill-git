---
description: schematize-git — monta o(s) commit(s) em Conventional Commits, atômicos e sem segredo, e publica na hora.
argument-hint: "[assunto opcional]"
---

# /git-commit — um commit = uma mudança lógica

1. `git status -sb` e `git diff` (e `--cached`). Se há duas mudanças lógicas, **divida** com
   `git add -p`/caminhos explícitos. Nunca `git add -A` às cegas: confira cada arquivo (nada de `.env`,
   chave, dump, binário grande, arquivo de outra tarefa).
2. **Gate do índice:** `bash .claude/skills/schematize-git/scripts/check-git.sh . --staged`. Reprovou, pare:
   se for segredo, o fluxo é `/git-leak`, não "commita assim mesmo".
3. **Mensagem:** `tipo(escopo)!: descrição` (imperativo, minúscula, sem ponto, até 72 col.); corpo com o
   PORQUÊ; rodapé `BREAKING CHANGE:`/`Refs:` quando couber. Tipos: feat, fix, perf, refactor, docs,
   test, build, ci, style, chore, revert (`references/fluxo.md` §2). Trailer de coautoria quando o
   projeto o pede.
4. Commit (assinado se a política está ligada). **Nunca `--no-verify`.** Hook barrou, conserte a causa.
5. **Push na hora** em branch curta (`git push -u origin <branch>`); push direto em `main` só no repo
   de dono solo com `GIT_ALLOW_PUSH_MAIN=1`. Nunca `--force`; na sua própria branch, `--force-with-lease`.
