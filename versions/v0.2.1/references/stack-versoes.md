# Anexo volátil: versões e fatos de terceiros (schematize-git)

> Parte da `schematize-git`. **Verificado em: 2026-10-14.** O corpo normativo diz princípio; número e
> comportamento de ferramenta de terceiros mora aqui, com fonte e data. Revisão trimestral e a cada release.

| Fato | Valor verificado | Fonte / método |
|---|---|---|
| Git local desta verificação | 2.47.3 | `git --version` na máquina |
| Assinatura SSH exige Git | 2.34 ou superior | docs.github.com, "Telling Git about your signing key" |
| Verificação SSH local exige `gpg.ssh.allowedSignersFile` | sem o arquivo: erro e `%G?` = `N`; com ele: `G` | executado nesta máquina (chave efêmera), coberto por `check-git.test.sh` |
| Conventional Commits | 1.0.0; `feat`=MINOR, `fix`=PATCH, `!` ou `BREAKING CHANGE` = MAJOR; a especificação permite outros tipos, a lista fixa é da casa | conventionalcommits.org/en/v1.0.0 |
| Regras de ruleset do GitHub | restringir criar/atualizar/excluir, bloquear force push, histórico linear, commits assinados, PR (aprovações, code owner), status checks, deploys, code scanning, restringir caminho/extensão/tamanho (push rulesets), alertas de secret scanning resolvidos (preview) | docs.github.com, "Available rules for rulesets" |
| Push protection | por repositório vem desligado e o admin liga; no nível do usuário é ligado por padrão para repos públicos; bypass exige motivo, gera alerta e auditoria | docs.github.com, "About push protection" |
| gitleaks | v8.30.1 (2026-03-21), licença MIT | `gh api repos/gitleaks/gitleaks/releases/latest` |
| gitsign (Sigstore) | v0.17.1 (2026-08-05), 0.x | `gh api repos/sigstore/gitsign/releases/latest` |
| git-filter-repo | v2.47.0 (2024-12-04) | `gh api repos/newren/git-filter-repo/releases/latest` |
| trufflehog | v3.99.2 (2026-10-08) | `gh api repos/trufflesecurity/trufflehog/releases/latest` |
| commitizen | v4.19.2 (2026-10-07) | `gh api repos/commitizen-tools/commitizen/releases/latest` |
| git-cliff | v2.14.2 (2026-09-18) | `gh api repos/orhun/git-cliff/releases/latest` |
| `actions/checkout` | v7.0.1 = `3d3c42e5aac5ba805825da76410c181273ba90b1` | `gh api repos/actions/checkout/git/ref/tags/v7.0.1` (commit, tag leve) |
| Limite de arquivo do GitHub | aviso em 50 MiB, bloqueio em 100 MiB <!-- reverificar --> | conhecimento anterior; não reconfirmado nesta sessão |
| Prazo de expurgo de objetos órfãos/caches no GitHub | depende de pedido ao suporte <!-- reverificar --> | não confirmado |

## O que foi executado (prova)

`bash scripts/check-git.test.sh`: 51 casos em repositórios temporários (mktemp), com vermelhos
plantados por regra (mensagem, segredo de 7 formatos montado em runtime, arquivo proibido, arquivo
grande, merge em branch linear, não assinado, waiver sem motivo ou da regra errada), verdes (waivers,
ponteiro LFS, assinatura SSH real com chave efêmera), exit 2 (não-repo, sem commits, range vazio ou
inválido) e os três hooks de `assets/hooks/` instalados e exercitados (inclui push para remoto bare).

## Não verificado

- gitleaks e gitsign não estão instalados nesta máquina: o hook `pre-commit` trata gitleaks como
  opcional (aviso, não falso verde) e os trechos de gitsign vêm da documentação do projeto, não de execução.
- O `ruleset-main.json` segue o esquema da API de rulesets; não foi aplicado a um repositório real.
