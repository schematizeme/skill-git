---
description: schematize-git — calcula o SemVer pelos commits, escreve o CHANGELOG e cria a tag anotada (assinada se a política exige).
argument-hint: "[versão, vazio = calcular]"
---

# /git-release — a tag é imutável

1. Árvore limpa, em `main` sincronizada com `origin` (`git fetch && git status -sb`), CI verde.
2. **Calcule** pelos commits desde a última tag (`git log $(git describe --tags --abbrev=0)..HEAD --format=%s`):
   qualquer `!`/`BREAKING CHANGE` = MAJOR; senão qualquer `feat` = MINOR; senão PATCH. Divergiu do que
   você queria publicar: leia os commits antes de forçar o número.
3. **CHANGELOG.md** (Keep a Changelog): entrada nova no topo, escrita para humanos, com o PORQUÊ
   (rascunho por git-cliff/commitizen, se houver; formato do documento: `schematize-docs`).
   Commit `docs: changelog da vX.Y.Z`; push.
4. **Tag anotada** no commit de `main`: `git tag -a vX.Y.Z -m "vX.Y.Z"` (`-s` se há assinatura);
   `git push origin vX.Y.Z`. Depois `gh release create vX.Y.Z --notes-file <trecho do changelog>`.
5. Errou? **Não mova nem apague tag publicada**: publique `vX.Y.(Z+1)`.

Skill do catálogo schematize NÃO usa este rito: é `schematize-skill-dev → references/release.md`
(`/skill-release`), que cuida de bump nos 4 lugares, snapshot e zip.
