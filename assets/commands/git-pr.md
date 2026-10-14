---
description: schematize-git — abre PR pequeno com a descrição das 4 perguntas, gate verde e revisão de code owner.
argument-hint: "[branch base, padrão main]"
---

# /git-pr — PR que se revisa em 15 minutos

1. `git fetch && git rebase origin/<base>` na SUA branch (nunca merge da base dentro dela).
2. **Tamanho:** `git diff --stat origin/<base>...HEAD`. Acima de ~400 linhas úteis, proponha empilhar
   PRs ou separar o refactor mecânico antes de seguir.
3. **Gate:** `bash .claude/skills/schematize-git/scripts/check-git.sh . --range origin/<base>..HEAD --linear`
   — verde antes de abrir. `fixup!`/`squash!` saem por `git rebase -i --autosquash`.
4. **Descrição** (use `assets/github/pull_request_template.md`): o que muda e por quê (link); como foi
   testado (comando + resultado); risco e rollback; onde olhar com atenção.
5. `gh pr create --base <base> --title "<tipo(escopo): descrição>" --body-file <descrição>` (o título
   vira a mensagem do squash: precisa estar em Conventional Commits). Rascunho (`--draft`) enquanto o CI
   está vermelho.
6. Revisão vira commit novo na branch; ao final o squash limpa. Quem abriu não aprova o próprio PR.
