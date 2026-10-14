---
description: Mapa da skill schematize-git (fluxo git da casa — trunk-based, Conventional Commits, assinatura, proteção, segredo, tags).
---
**schematize-git** — o fluxo git da casa. O histórico é permanente e público: o gate pega o erro antes do push.

| Comando | O que faz |
|---|---|
| `/git-help` | esta lista |
| `/git-load` | carrega à força TODO o corpo normativo (fluxo, assinatura, proteção, segredos, higiene) e passa a aplicá-lo |
| `/git-review` | roda `scripts/check-git.sh` no range e lê o que a máquina não lê (PR grande, commit misturado, ruleset) |
| `/git-commit` | monta o(s) commit(s) em Conventional Commits, atômicos, sem segredo, e dá push na hora |
| `/git-pr` | abre PR pequeno com a descrição das 4 perguntas e o gate verde |
| `/git-leak` | rito de segredo commitado: rotacionar primeiro, depois limpar (com ou sem reescrita) |
| `/git-release` | calcula o SemVer pelos commits, escreve o CHANGELOG, cria a tag anotada/assinada |
| `/git-claude` | cria ou mescla o `CLAUDE.md` sempre-on do fluxo git na raiz do repo |
| `/git-cc` · `/git-handoff` | context compact / handoff no archive |

Pareia com: `schematize-engineering` (entrega), `schematize-infra` (supply chain e assinatura de
artefato), `schematize-docs` (formato do CHANGELOG), `schematize-skill-dev` (release de skill do catálogo),
`schematize-incident` (segredo com dado pessoal).
