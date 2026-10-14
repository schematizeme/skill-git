# schematize-git — o fluxo git da casa

> **O histórico é permanente, público e a fonte da verdade.** Trunk-based com branches curtas,
> Conventional Commits, PR pequeno, commits assinados, ruleset no servidor, nunca reescrever histórico
> publicado, segredo commitado se rotaciona primeiro, tags SemVer imutáveis, e um gate executável.

Pacote de **skill normativa para [Claude Code](https://claude.com/claude-code)**.
Parte do catálogo **schematize skills**.

## Por que ela existe

O fluxo git da casa vivia em regras soltas. O erro típico é caro e irreversível: segredo que foi para o
remoto, `force push` em `main`, mensagem que quebra o changelog, blob de 200 MiB para sempre em todo
clone, cópia local que diverge do publicado. Aqui as regras têm dono, rito e gate.

## Instalar

### Pelo app schematize (recomendado)

```bash
schematize install git    # requer o CLI schematize instalado
```

### Manual

```bash
git clone https://github.com/schematizeme/skill-git.git /tmp/skill-git
bash /tmp/skill-git/install.sh .        # instala em .claude/ do projeto atual
```

## O que tem dentro

- **SKILL.md** — o contrato: 13 pisos, a fronteira com as outras skills e o mapa de references.
- **references/** — `fluxo`, `assinatura`, `protecao`, `segredos`, `higiene`, `stack-versoes`.
- **scripts/** — `check-git.sh` (gate) e `check-git.test.sh` (51 casos em repos temporários).
- **assets/** — `hooks/` (commit-msg, pre-commit, pre-push), `github/` (ruleset, CODEOWNERS, template
  de PR, gitignore/gitattributes base), `ci/` (workflow do gate), `commands/`, `CLAUDE.md`.

## Comandos

| Comando | O que faz |
|---|---|
| `/git-help` | lista os comandos |
| `/git-load` | carrega à força o corpo normativo |
| `/git-review` | gate no range + leitura humana |
| `/git-commit` | commit atômico em Conventional Commits, push na hora |
| `/git-pr` | PR pequeno com gate verde |
| `/git-leak` | segredo commitado: rotacionar primeiro |
| `/git-release` | SemVer pelos commits, CHANGELOG, tag |
| `/git-claude` | `CLAUDE.md` sempre-on do fluxo git |
| `/git-cc` · `/git-handoff` | context compact / handoff |

## Verificação

```bash
bash scripts/check-git.test.sh        # vermelho primeiro do gate
bash scripts/check-git.sh .           # o gate no próprio repo
```

## Licença

MIT. Ver `LICENSE` (inclui avisos de marcas de terceiros).
