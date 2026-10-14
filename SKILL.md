---
name: schematize-git
metadata:
  version: 0.1.0
description: >-
  Fluxo git: trunk-based, Conventional Commits, commits assinados, PR pequeno, segredo commitado. Use ao commitar, abrir PR ou tocar .gitignore. Release de skill: schematize-skill-dev.
---
<!-- cross-skill: precedencia.md, orquestracao.md -> schematize-engineering -->

# Fluxo git (schematize-git)

Disciplina normativa para **como o código entra e permanece no repositório**. A tese: **o histórico é
permanente, público e a fonte da verdade** — o que se commita fica nos clones, nos forks e nos caches
para sempre. Por isso o erro se corrige **à frente** (commit novo, `revert`), nunca reescrevendo atrás;
segredo que tocou o remoto é tratado como público; e a cópia local nunca diverge do publicado. Esta
skill põe o gate na mão de quem commita, antes do push.

**Versão:** skill `schematize-git` v0.1.0. Changelog em `CHANGELOG.md`.

## Precedência e herança (leia antes de divergir)

<!-- herdado:engineering/precedencia:dominio intro="Esta skill é o recorte **fluxo de versionamento (git/GitHub)** das disciplinas de **domínio** (não de linguagem): como mudança entra, é revisada, assinada e publicada. Ferramenta de quem entrega, nunca serviço de produto." cmd="git" -->Esta skill é o recorte **fluxo de versionamento (git/GitHub)** das disciplinas de **domínio** (não de linguagem): como mudança entra, é revisada, assinada e publicada. Ferramenta de quem entrega, nunca serviço de produto.

1. **Onde esta skill divergir da base, a BASE MANDA.** Aqui mora a especialização do domínio ou da
   ferramenta — o como, o padrão, o gate. Divergência de *piso* é defeito desta skill, não variante local.
2. **O que não está repetido aqui é HERDADO, não dispensado.** Esta skill herda os pisos da base e
   os comandos dela cobrem o **domínio**, não o piso geral. Valem integralmente, sem cópia local:
   - **§28 Archive** — `<projeto>/<projeto>_archive/` é **repositório git próprio, PRIVADO e
     obrigatório**, criticidade 0 (`schematize-archive`).
   - **§35 Definition of Done** e a lista de anti-padrões (citada por **título**, nunca por número).
   - **§39 Índice/MAPA** — enumeração exaustiva (uma entrada por unidade chamável, `M == N`) e grafo
     com arestas em ASCII (`A -> B`), nunca a seta unicode.
   - **IAM** (`schematize-engineering` → `references/iam.md`): identidade ≠ email, ≥2 fatores, ReBAC
     multi-tenant, argon2id-only para senha nova, sessão longa e logout irreversível.
   - **Efeito externo** nunca sai de não-produção (`schematize-engineering` →
     `references/efeitos-externos.md`).
   - **Orquestração** (`schematize-engineering` → `references/orquestracao.md` §9): o principal não
     desenvolve (é Claude Opus); executor mais barato que resolve — `haiku`/`sonnet` → Codex Terra → Cursor → `opus` só após falha; visual direto ao Codex; imagem nunca pelo Claude: detecta Codex/Gemini e pergunta ao usuário qual usar (Codex é a sugestão, não automática), nunca API paga.
3. **QA, ops, IAM e índice não têm comando próprio aqui:** vêm da base `/eng-*`. Para trabalho
   contínuo use `/eng-overdev`; para planejar `/eng-plan`; para varrer a base `/eng-scan`; para
   revisão geral `/eng-review` (e `/eng-ops`, `/eng-iam`, `/eng-index`). Os comandos
   `/git-*` cobrem o domínio desta skill; o piso geral é o da base.<!-- /herdado -->

## Fronteira com as outras skills

| Assunto | Dono | Ponteiro |
|---|---|---|
| **Fluxo de branch, Conventional Commits, PR, assinatura de commit/tag, ruleset, CODEOWNERS, segredo commitado, hooks, `.gitignore`/`.gitattributes`, tags SemVer** | **esta skill** | `references/*.md` abaixo |
| Entrega: ambientes, DoD, CI/CD como política, o que é "pronto" | `schematize-engineering` | `schematize-engineering → references/operacao.md`; aqui só o git |
| Supply chain: assinar artefato (imagem, zip), SBOM, pin de Action, pipeline gated | `schematize-infra` | `schematize-infra → references/entrega.md`; aqui só o histórico git |
| Política geral de segredo e cofre | `schematize-infra` | `schematize-infra → references/segredos.md`; aqui o que fazer quando o segredo foi commitado |
| Formato do CHANGELOG, README, ADR | `schematize-docs` | `schematize-docs → SKILL.md`; aqui o conteúdo vem dos commits e a tag |
| Release de skill do catálogo (bump nos 4 lugares, snapshot, zip, grafo) | `schematize-skill-dev` | `schematize-skill-dev → references/release.md`; **o rito `/git-release` NÃO se aplica a skill** |
| Segredo vazado com dado pessoal (LGPD/ANPD, postmortem) | `schematize-incident` | acionar no passo 2 de `/git-leak` |
| Imagem de container e Dockerfile | `schematize-docker` | fora de escopo |
| Onde o handoff/ADR mora (`<projeto>_archive/`, repo privado próprio) | `schematize-archive` | `schematize-archive → SKILL.md` |

## Comandos (Claude Code)

| Comando | O que faz |
|---|---|
| `/git-help` | lista os comandos |
| `/git-load` | carrega à força o corpo normativo (fluxo, assinatura, proteção, segredos, higiene) |
| `/git-review` | roda o gate no range e lê o que a máquina não lê (atomicidade, tamanho de PR, ruleset, divergência local) |
| `/git-commit` | commit atômico em Conventional Commits, gate do índice, push na hora |
| `/git-pr` | PR pequeno, rebase, gate verde, descrição das 4 perguntas |
| `/git-leak` | segredo commitado: rotacionar primeiro; histórico só depois e só se preciso |
| `/git-release` | SemVer calculado pelos commits, CHANGELOG, tag anotada/assinada |
| `/git-claude` | cria/mescla o `CLAUDE.md` sempre-on do fluxo git na raiz do repo |
| `/git-cc` · `/git-handoff` | context compact / handoff arquivado |

## Como usar

1. **Rode o gate antes de discutir estilo:** `bash scripts/check-git.sh .` — `0` passa · `1` reprova ·
   `2` **nada para verificar** (que não é aprovação). Opções: `--range A..B` (padrão `@{u}..HEAD`),
   `--staged` (hook pre-commit), `--linear` (branch que exige histórico linear), `--require-signed`,
   `--msg-file ARQ` (hook commit-msg). Funciona só com `git` e `awk`; gitleaks é opcional.
2. **Fluxo e mensagem** (`references/fluxo.md`): branch curta, Conventional Commits, PR pequeno.
3. **Assine** (`references/assinatura.md`) e **proteja a `main` no servidor** (`references/protecao.md`).
4. **Segredo e higiene** (`references/segredos.md`, `references/higiene.md`): hooks, ignore, arquivo grande.
5. **Tag e changelog** (`references/fluxo.md` §5, `/git-release`).

Mapa de references:

| Tarefa | Reference |
|---|---|
| Trunk-based, branch curta, Conventional Commits (tipos e SemVer), PR pequeno, GitHub como fonte da verdade, tags e changelog | `references/fluxo.md` |
| SSH x gitsign x GPG, configuração, `allowed_signers`, onde cobrar assinatura | `references/assinatura.md` |
| Ruleset mínimo da `main`, dono solo, nunca reescrever publicado, CODEOWNERS, monorepo x multirrepo | `references/protecao.md` |
| Segredo commitado: ordem do rito, camadas de prevenção, reescrita com `git filter-repo` | `references/segredos.md` |
| `.gitignore`, `.gitattributes`, arquivo grande/LFS, hooks, comandos que evitam acidente | `references/higiene.md` |
| Versões e fatos de terceiros, fontes, o que foi executado (anexo volátil) | `references/stack-versoes.md` |

Assets prontos: `assets/hooks/` (`commit-msg`, `pre-commit`, `pre-push`) · `assets/github/`
(`ruleset-main.json`, `CODEOWNERS.example`, `pull_request_template.md`, `gitignore.base`,
`gitattributes.base`) · `assets/ci/github-actions-git.yml` (job `check-git`, Action pinada por SHA).

## Pisos inegociáveis (vetam o atalho)

1. **GitHub é a fonte da verdade: commit + push na hora.** A cópia local nunca diverge do publicado.
2. **Trunk-based:** `main` sempre verde e liberável, branches curtas (horas a 1-2 dias), rebase sobre
   `main`, integração por squash ou rebase (**histórico linear**). Sem `develop`.
3. **Conventional Commits 1.0.0** em todo commit que chega a `main` (tipos fixos da casa, `!` ou
   `BREAKING CHANGE` para MAJOR). Um commit = uma mudança lógica que compila.
4. **PR pequeno** (~15 min de revisão), com descrição que responde o quê/porquê, como testou,
   risco/rollback e onde olhar. `fixup!`/`squash!` não chegam ao remoto.
5. **Nunca reescrever histórico publicado.** Sem `push --force` em `main`/`release/*`/tags, sem amend
   após push; erro publicado se corrige com `git revert`. Na branch própria, `--force-with-lease`.
   **Única exceção:** remoção de segredo ou dado pessoal, pelo rito de `references/segredos.md` §3.
6. **Segredo commitado = rotacionar primeiro**, limpar depois. Reescrever histórico não desfaz vazamento.
   Nunca `--no-verify`; secret scanning e push protection ligados, `pre-commit` instalado.
7. **Assinatura:** tag de release assinada e commits de `main` assinados (SSH por padrão) quando a
   política está adotada; cobrança no ruleset, não só no cliente.
8. **A `main` é protegida no servidor:** ruleset com force push bloqueado, exclusão restrita, linear,
   PR, status check do gate e revisão de code owner. Regra só no cliente não conta.
9. **Tags SemVer anotadas e imutáveis.** Tag errada se corrige com a versão seguinte, nunca movida.
10. **Higiene desde o primeiro commit:** `.gitignore`, `.gitattributes`, CODEOWNERS por time; arquivo
    > 5 MiB, `.env`, chave e `*.tfstate` fora do repo (LFS ou artefato).
11. **Monorepo x multirrepo é decisão por fit com ADR**, não moda; serviços de runtime seguem o
    isolamento da `schematize-infra`.
12. **Efeito externo** (e-mail, cobrança, webhook de saída) disparado por hook ou CI de git nunca sai de
    não-produção: push em branch curta não pode ter efeito real.
13. <!-- herdado:engineering/orquestracao:curto -->**Orquestrador não desenvolve; subagent barato executa.** O agent principal só planeja, despacha e revisa; ação onerosa vira micro-tasks para o executor mais barato que resolve: `haiku` (mecânico) / `sonnet` (código; falhou → mesmo subagent corrige, até 2 rodadas) → Codex `gpt-5.6-terra` → Cursor → subagent `opus` (motivo) → `park`; **visual vai direto ao Codex**; **imagem nunca pelo Claude: detectar Codex/Gemini e perguntar ao usuário qual usar (Codex é a sugestão), nunca API de imagem paga**; papéis em `agentes.toml`. No overdev, cada item do checklist vai a um subagent e o principal revisa antes do `- [x]`. **Sem frota ociosa:** idle com pendência volta ao trabalho; dependente de outro agent → mata e enfileira com gatilho; terminou → mata (§9.6). Detalhe: `schematize-engineering` → `references/orquestracao.md` §9.<!-- /herdado -->

## Regra de mídia

Imagem ou mídia gerada (ex.: capa de README, social preview do repositório) **nunca** por modelo
Claude: detecte Codex e Gemini disponíveis e **pergunte ao usuário qual usar**. Nenhum disponível:
avise sem rodeio que visual gerado pelo Claude tem qualidade inversamente proporcional à de código (sai
ruim de verdade) e ofereça alternativas — instalar Codex ou Gemini, imagem de banco com licença
comercial, ou asset do cliente. Claude é o melhor em código.

## Relação com as outras skills

- **`schematize-engineering`** — a base: DoD, archive, IAM, efeito externo e a política de entrega que
  este fluxo implementa no nível do git.
- **`schematize-infra`** — supply chain e segredos: assinar o artefato, pinar Action por SHA, cofre. O
  git guarda o histórico; a infra guarda o que sai dele.
- **`schematize-skill-dev`** — o release de skill do catálogo (4 lugares de versão, snapshot, zip). Aqui
  é o fluxo geral de qualquer repositório.
- **`schematize-docs`** — o formato do CHANGELOG e do README; esta skill fornece a matéria (commits, tags).
- **`schematize-incident`** — segredo vazado com dado pessoal vira incidente com prazo legal.
- **`schematize-archive`** — o repo `<projeto>_archive/` é git privado próprio; as mesmas regras valem lá.
