# Higiene do repositório: ignore, attributes, hooks, arquivos grandes

> Parte da `schematize-git`. O repo é distribuído a cada clone: o que entra, fica (e pesa) para sempre.

## 1. `.gitignore`

- Existe **na raiz desde o primeiro commit** (o gate avisa se faltar). Modelo: `assets/github/gitignore.base`.
- Ignore por classe: segredo e ambiente local (`.env*` exceto `.env.example`, `*.pem`, `*.key`, `*.tfstate*`,
  `*.tfplan`), artefato de build e dependência (`node_modules/`, `target/`, `dist/`, `__pycache__/`),
  lixo de editor/SO, `*.zip` de release.
- Ignore específico da sua máquina vai em `.git/info/exclude` ou no `core.excludesFile` global, não no
  `.gitignore` do projeto.
- `.gitignore` não desfaz arquivo já rastreado: `git rm --cached <arquivo>` e, se tinha segredo,
  `segredos.md`.
- Lockfile (`Cargo.lock`, `package-lock.json`, `go.sum`, `.terraform.lock.hcl`) **é commitado** em
  aplicação; em biblioteca, siga a convenção da linguagem (skill da linguagem).

## 2. `.gitattributes`

Modelo: `assets/github/gitattributes.base`. Pontos que importam:

- `* text=auto eol=lf` e `*.sh text eol=lf` (script com CRLF quebra no Linux), `*.bat text eol=crlf`.
- Binários declarados (`*.png binary`, `*.pdf binary`) para o Git não tentar diff/merge de texto.
- `*.lock -diff` / `linguist-generated` para lockfile não poluir a revisão.
- `merge=union` só para arquivos de lista append-only (ex.: `CHANGELOG` não; um `.gitignore` sim).
- Git LFS (`*.psd filter=lfs diff=lfs merge=lfs -text`) para binário versionado inevitável.

## 3. Arquivo grande

- Limite do gate: **5 MiB por blob novo** (`GIT_GATE_MAX_MB`). Acima disso: Git LFS, armazenamento de
  objetos com referência por URL/hash, ou fora do repo. O GitHub recusa arquivo > 100 MiB e avisa a
  partir de 50 MiB (`stack-versoes.md`).
- Binário gerado (build, dump, vídeo) não é código-fonte: gere no CI, publique como artefato de release.
- Clone gigante já existente: `git clone --filter=blob:none` (partial) e `sparse-checkout` para
  monorepo; remover blob do histórico é o rito de `segredos.md` §3.

## 4. Hooks

- Hooks de cliente (`.git/hooks`) **não são versionados nem forçados**: servem de conforto, a barreira
  é o CI + ruleset. Compartilhe via `core.hooksPath` apontando para uma pasta versionada
  (`git config core.hooksPath .githooks`) ou pelo framework `pre-commit`.
- Hooks da casa em `assets/hooks/`: `commit-msg` (Conventional Commits), `pre-commit` (segredo e
  arquivo proibido no índice; gitleaks se existir), `pre-push` (sem push direto/force/exclusão em
  `main`/`release/*`). Todos delegam ao `scripts/check-git.sh`: uma só regra, não duas.
- Hook rápido (< 2 s) ou o time o desliga. Verificação cara fica no CI.
- `--no-verify` é exceção que se explica no PR, nunca hábito.

## 5. Estrutura do repo (arquivos que todo repo tem)

`README.md` (o que é, como rodar, como contribuir) · `LICENSE` · `.gitignore` · `.gitattributes` ·
`CHANGELOG.md` (quando há release) · `.github/CODEOWNERS` · `.github/pull_request_template.md` ·
`SECURITY.md` (como reportar vulnerabilidade). Formato de cada documento: `schematize-docs`.

## 6. Git no dia a dia (comandos que evitam acidente)

- `git switch -c feat/x` (não `checkout`), `git restore` para descartar, `git stash push -m "motivo"`.
- `git push --force-with-lease` só em branch própria; nunca `--force`.
- `git reflog` é a rede de segurança local: rebase errado se desfaz com `git reset --hard HEAD@{n}`
  (só no seu clone, nunca em branch compartilhada).
- Antes de apagar branch local: `git branch --merged main`. Branch remota mergeada: apagar
  automaticamente no merge (config do repo no GitHub).
- `git bisect` só funciona se cada commit compila: por isso "um commit = uma mudança lógica".
