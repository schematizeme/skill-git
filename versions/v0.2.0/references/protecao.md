# Proteção de branch, rulesets e CODEOWNERS

> Parte da `schematize-git`. Regra que só existe na cabeça das pessoas é erro esperando acontecer: a
> proteção mora no servidor, onde ninguém a contorna por cansaço às 23h.

## 1. Ruleset em vez de branch protection clássica

Os **rulesets** do GitHub (repo ou organização) substituem a proteção de branch antiga: são
empilháveis, valem para tags também, têm modo `evaluate` (ensaio sem bloquear) e permitem lista de
bypass auditável. Regras disponíveis (verificado, `stack-versoes.md`): restringir criação/atualização/
exclusão, **bloquear force push**, **exigir histórico linear**, **exigir commits assinados**, exigir
PR (aprovações, revisão de code owner, método de merge), exigir status checks, exigir deploys,
exigir code scanning, restringir caminhos/extensões/tamanho (push rulesets), exigir alertas de secret
scanning resolvidos.

## 2. Ruleset mínimo da `main` (piso)

| Regra | Valor |
|---|---|
| Restringir exclusão | ligado |
| Bloquear force push | ligado (vale também para admin: sem bypass) |
| Exigir histórico linear | ligado (squash ou rebase, nunca merge commit) |
| Exigir PR | ligado, 1 aprovação, descartar aprovação velha ao novo push, resolver conversas |
| Revisão de code owner | ligado onde há `CODEOWNERS` |
| Status checks obrigatórios | o job do gate (`check-git`) + testes + lint; branch atualizada antes do merge |
| Commits assinados | ligado quando a política de `assinatura.md` está adotada |
| Tags `v*` | restringir exclusão e atualização (tag publicada é imutável) |

Modelo importável: `assets/github/ruleset-main.json` (use `gh api -X POST repos/<org>/<repo>/rulesets
--input ruleset-main.json`; ajuste o nome do status check e comece em `enforcement: "evaluate"`).

Secret scanning e **push protection** do repositório ligados (Settings, Code security): bloqueiam o
push com credencial reconhecida; o bypass exige motivo e gera alerta e auditoria. É a rede de baixo; o
`pre-commit` (`assets/hooks`) e o gitleaks são a rede de cima, na máquina.

## 3. Dono solo

Em repo mantido por uma pessoa, exigir 1 aprovação trava o próprio dono. Escolha explícita, em ADR curto:

- manter **PR obrigatório sem aprovação** (o PR serve de ponto de CI e de histórico) e deixar o dono
  como bypass **auditável**; ou
- sem PR, push direto em `main` com `GIT_ALLOW_PUSH_MAIN=1` (hook `pre-push`) e o ruleset só com
  force-push bloqueado, histórico linear e exclusão restrita.
Nunca desligar "bloquear force push" por conveniência.

## 4. Nunca reescrever histórico publicado

- Histórico publicado (qualquer commit que alguém pode ter clonado) é **imutável**: sem `push --force`
  em `main`/`release/*`/tag, sem `rebase` de commit já mergeado, sem `commit --amend` depois do push.
  Erro em commit publicado se corrige com **commit novo** (`git revert`).
- Em SUA branch de trabalho ainda sem outros colaboradores, force push é permitido e normal, com
  `--force-with-lease` (nunca `--force` cru).
- **Única exceção: remoção de segredo ou dado pessoal.** Reescrever só depois de **rotacionar** a
  credencial, com o rito de `segredos.md` §3 (aviso a todos, `git filter-repo`, force push com
  janela combinada, invalidar caches e forks, reclone obrigatório). Fora disso, é vetado.
- Hook `pre-push` (`assets/hooks/pre-push`) barra non-fast-forward e exclusão em `main`/`master`/`release/*`
  no cliente; o ruleset barra no servidor.

## 5. CODEOWNERS

`.github/CODEOWNERS` liga caminho a dono; com "revisão de code owner" ligada, PR que toca o caminho
precisa da aprovação dele.

- **Último padrão que casa vence**: ponha o genérico primeiro, os específicos depois.
- Dono é **time** (`@org/seguranca`), não pessoa isolada (férias, saída). Mínimo de 2 pessoas no time.
- Caminhos sensíveis sempre com dono: `.github/` (workflows), `CODEOWNERS`, migrations, IaC, `auth/`,
  `SECURITY.md`, ruleset/automação.
- Exemplo em `assets/github/CODEOWNERS.example`. Arquivo inválido (time inexistente) é ignorado em
  silêncio pelo GitHub: confira a aba de erros do arquivo.

## 6. Monorepo x multirrepo

| | Monorepo | Multirrepo |
|---|---|---|
| Bom quando | mudança cruza vários módulos ao mesmo tempo; um time só; versão única | ciclos de release e donos independentes; superfície de permissão diferente; contrato estável entre eles |
| Custo | CI que sabe rodar só o afetado (path filters), clone grande (sparse-checkout/partial clone), CODEOWNERS por pasta | mudança que cruza repos é N PRs coordenados; deriva de versão entre repos; ferramenta de lote |
| Piso | tags por pacote (`pacote/v1.2.0`), CI por caminho, nada de `node_modules`/build commitado | contrato versionado (`schematize-api`), automação de bump de dependência, mesmo ruleset em todos (organização) |

Decisão por fit, registrada em ADR; **não migre por moda**. Serviços da casa seguem o isolamento por
serviço (`schematize-infra → references/isolamento.md`): repo por serviço de runtime, com bibliotecas
partilhadas versionadas, é o ponto de partida; o monorepo é escolha deliberada.
