---
description: schematize-git — carrega à força TODO o corpo normativo do fluxo git e passa a aplicá-lo nesta sessão.
---
Carregue **agora** o corpo normativo da skill `schematize-git`. A partir daqui, nesta sessão, isto
**não é opcional**.

1. **Leia na íntegra, sem trabalhar de memória.** Caminho:
   `.claude/skills/schematize-git/references/*.md` (projeto) ou
   `~/.claude/skills/schematize-git/references/*.md` (global):
   - `fluxo.md` — trunk-based, branch curta, Conventional Commits 1.0.0, PR pequeno, GitHub como fonte
     da verdade (commit+push na hora), tags SemVer e changelog.
   - `assinatura.md` — commits/tags assinados: SSH (padrão), gitsign, `allowed_signers`, onde cobrar.
   - `protecao.md` — rulesets, ruleset mínimo da `main`, dono solo, nunca reescrever histórico
     publicado, CODEOWNERS, monorepo x multirrepo.
   - `segredos.md` — segredo commitado: rotacionar primeiro, camadas de prevenção, rito de reescrita.
   - `higiene.md` — `.gitignore`, `.gitattributes`, arquivo grande/LFS, hooks, comandos seguros.
   - `stack-versoes.md` — anexo volátil: versões, fontes, o que foi executado.
2. **Rode o gate no repo atual** antes de opinar:
   `bash .claude/skills/schematize-git/scripts/check-git.sh .`
3. **Aplique daqui em diante** a todo commit, branch, PR e tag que você fizer, e diga qual piso está
   aplicando quando ele mudar o que você ia fazer. **Nunca** `push --force` em histórico publicado,
   `--no-verify` ou commit de segredo.
