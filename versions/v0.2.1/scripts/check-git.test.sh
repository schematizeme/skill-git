#!/usr/bin/env bash
# Vermelho primeiro do gate check-git.sh. Cada caso é um repo git TEMPORÁRIO isolado (mktemp);
# nunca toca o repo real. Segredos falsos são montados em tempo de execução (push protection).
#
# EXCEÇÃO DECLARADA (piso da schematize-shell, strict mode): harness roda `set -u` sem `-e`,
# para continuar após um caso vermelho e reportar todos.
set -u
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
G="$AQUI/check-git.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "${TMP:?}"' EXIT INT TERM
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null HOME="$TMP/home"
mkdir -p "$HOME"
ok=0; fail=0; D=""; NOME=""

novo() { # novo <nome>: repo com commit-base válido
  NOME="$1"; D="$TMP/$1"; mkdir -p "$D"
  git -C "$D" init -q -b main
  git -C "$D" config user.name teste; git -C "$D" config user.email t@example.invalid
  git -C "$D" config commit.gpgsign false
  printf 'node_modules/\n' >"$D/.gitignore"
  git -C "$D" add .gitignore; git -C "$D" commit -q -m "chore: base"
}
c() { git -C "$D" add -A; git -C "$D" commit -q -m "$1" ${2:+-m "$2"}; } # c <assunto> [corpo]
w() { mkdir -p "$(dirname "$D/$1")"; printf '%s\n' "$2" >"$D/$1"; } # w <arq> <conteudo>
# base de comparação: tudo depois do commit-base
R() { echo "$(git -C "$D" rev-list --max-parents=0 HEAD)..HEAD"; }
esperar() { # esperar <exit> <agulha> [args do gate...]
  local esp="$1" ag="$2" saida rc; shift 2
  saida="$(bash "$G" "$D" "$@" 2>&1)"; rc=$?
  if [ "$rc" != "$esp" ]; then echo "  ✖ $NOME: exit $rc, esperado $esp"; printf '      %s\n' "${saida//$'\n'/$'\n      '}"; fail=$((fail+1)); return; fi
  if [ -n "$ag" ] && ! grep -qF -- "$ag" <<<"$saida"; then echo "  ✖ $NOME: sem \"$ag\""; printf '      %s\n' "${saida//$'\n'/$'\n      '}"; fail=$((fail+1)); return; fi
  echo "  ✔ $NOME"; ok=$((ok+1))
}

# segredos falsos montados em runtime
AWS="AKIA$(printf 'Q%.0s' {1..16})"
GHT="ghp_$(printf 'a1B2%.0s' {1..9})"
SLK="xoxb-$(printf '1234567890-%.0s' 1 2)abcdef"
PEM="-----BEGIN RSA PRIV""ATE KEY-----"
STR="sk_li""ve_$(printf 'Z9%.0s' {1..10})"
GEN="password = \"$(printf 'xK7%.0s' {1..5})\""

echo "== VERDES"
novo verde-limpo; w a.txt oi; c "feat(api): adiciona rota de saude"; w b.txt oi2; c "fix!: remove campo legado"
esperar 0 "ok (2 commit" --range "$(R)"
novo verde-escopo-composto; w a.txt x; c "refactor(core,db): separa camadas"; esperar 0 "ok" --range "$(R)"
novo verde-revert-default; w a.txt x; c "feat: algo"; git -C "$D" revert --no-edit HEAD >/dev/null 2>&1; esperar 0 "ok" --range "$(R)"
novo verde-env-example; w .env.example "CHAVE="; c "chore: adiciona env de exemplo"; esperar 0 "ok" --range "$(R)"
novo verde-senha-por-env; w app.py 'senha = os.environ["SENHA_DB"]'; c "feat: le senha do ambiente"; esperar 0 "ok" --range "$(R)"
novo verde-waiver-linha; w doc.md "exemplo $AWS # git-ok: fixture de teste publica"; c "docs: exemplo"; esperar 0 "ok" --range "$(R)"
novo verde-waiver-commit; w doc.md "$AWS"; c "docs: exemplo de formato" "Git-Ok: segredo valor de documentacao, inerte"; esperar 0 "ok" --range "$(R)"
novo verde-lfs-ponteiro; w g.bin $'version https://git-lfs.github.com/spec/v1\noid sha256:abc\nsize 99999999'; c "chore: ponteiro lfs"; esperar 0 "ok" --range "$(R)"
novo verde-merge-sem-linear; git -C "$D" checkout -q -b f; w f.txt 1; c "feat: f"; git -C "$D" checkout -q main; w m.txt 1; c "feat: m"; git -C "$D" merge -q --no-ff f -m "Merge branch f" ; esperar 0 "ok" --range "$(R)"
novo verde-linear-rebase; git -C "$D" checkout -q -b f; w f.txt 1; c "feat: f"; git -C "$D" checkout -q main; git -C "$D" merge -q --ff-only f; esperar 0 "ok" --range "$(R)" --linear
novo verde-staged-limpo; w a.txt oi; git -C "$D" add a.txt; esperar 0 "ok" --staged
novo verde-aviso-assunto-longo; w a.txt x; c "feat: $(printf 'palavra %.0s' {1..12})"; esperar 0 "(> 72)" --range "$(R)"
novo verde-range-padrao-sem-upstream; w a.txt x; c "feat: x"; esperar 0 "ok"

echo "== VERMELHOS"
novo v-cc-sem-tipo; w a.txt x; c "ajustes diversos"; esperar 1 "cc-mensagem" --range "$(R)"
novo v-cc-tipo-invalido; w a.txt x; c "update: mexe em coisa"; esperar 1 "cc-mensagem" --range "$(R)"
novo v-cc-maiuscula; w a.txt x; c "Feat: algo"; esperar 1 "cc-mensagem" --range "$(R)"
novo v-cc-sem-espaco; w a.txt x; c "feat:algo"; esperar 1 "cc-mensagem" --range "$(R)"
novo v-cc-fixup; w a.txt x; c "fixup! feat: base"; esperar 1 "autosquash" --range "$(R)"
novo v-segredo-aws; w cfg.txt "chave=$AWS"; c "chore: config"; esperar 1 "segredo" --range "$(R)"
novo v-segredo-github; w cfg.txt "t=$GHT"; c "chore: config"; esperar 1 "segredo" --range "$(R)"
novo v-segredo-slack; w cfg.txt "t=$SLK"; c "chore: config"; esperar 1 "segredo" --range "$(R)"
novo v-segredo-pem; w k.txt "$PEM"; c "chore: chave"; esperar 1 "segredo" --range "$(R)"
novo v-segredo-stripe; w cfg.txt "k=$STR"; c "chore: config"; esperar 1 "segredo" --range "$(R)"
novo v-segredo-generico; w cfg.py "$GEN"; c "chore: config"; esperar 1 "segredo" --range "$(R)"
novo v-segredo-removido-depois; w cfg.txt "k=$AWS"; c "chore: config"; w cfg.txt "k=removido"; c "fix: tira a chave"; esperar 1 "segredo" --range "$(R)"
novo v-segredo-staged; w cfg.txt "k=$AWS"; git -C "$D" add cfg.txt; esperar 1 "segredo" --staged
novo v-env-versionado; w .env "A=1"; c "chore: ambiente"; esperar 1 "arquivo-proibido" --range "$(R)"
novo v-tfstate; w infra/terraform.tfstate "{}"; c "chore: state"; esperar 1 "arquivo-proibido" --range "$(R)"
novo v-chave-id-rsa; w .ssh/id_rsa "x"; c "chore: chave"; esperar 1 "arquivo-proibido" --range "$(R)"
novo v-arquivo-grande; head -c 2097152 /dev/urandom >"$D/g.bin"; c "feat: binario"; GIT_GATE_MAX_MB=1 esperar 1 "arquivo-grande" --range "$(R)"
novo v-merge-linear; git -C "$D" checkout -q -b f; w f.txt 1; c "feat: f"; git -C "$D" checkout -q main; w m.txt 1; c "feat: m"; git -C "$D" merge -q --no-ff f -m "Merge branch f"; esperar 1 "merge-linear" --range "$(R)" --linear
novo v-merge-linear-config; git -C "$D" config schematize.linear true; git -C "$D" checkout -q -b f; w f.txt 1; c "feat: f"; git -C "$D" checkout -q main; w m.txt 1; c "feat: m"; git -C "$D" merge -q --no-ff f -m "Merge branch f"; esperar 1 "merge-linear" --range "$(R)"
novo v-nao-assinado; w a.txt x; c "feat: x"; esperar 1 "nao-assinado" --range "$(R)" --require-signed
# assinado de verdade (chave SSH efêmera + allowed_signers): verde com --require-signed
novo verde-assinado-ssh
ssh-keygen -q -t ed25519 -N '' -f "$TMP/chave" -C teste
echo "t@example.invalid $(cat "$TMP/chave.pub")" >"$TMP/allowed"
git -C "$D" config gpg.format ssh; git -C "$D" config user.signingkey "$TMP/chave.pub"
git -C "$D" config gpg.ssh.allowedSignersFile "$TMP/allowed"; git -C "$D" config commit.gpgsign true
w a.txt x; c "feat: assinado"; esperar 0 "ok" --range "$(git -C "$D" rev-parse HEAD~1)..HEAD" --require-signed
novo v-waiver-sem-motivo; w doc.md "$AWS"; c "docs: exemplo" "Git-Ok: segredo"; esperar 1 "segredo" --range "$(R)"
novo v-waiver-regra-errada; w doc.md "$AWS"; c "docs: exemplo" "Git-Ok: arquivo-grande motivo qualquer"; esperar 1 "segredo" --range "$(R)"

echo "== EXIT 2 (nada para verificar nao e aprovacao)"
mkdir -p "$TMP/nao-repo"; D="$TMP/nao-repo"; NOME="nao-e-repo"; esperar 2 "não é repositório"
mkdir -p "$TMP/sem-commits"; git -C "$TMP/sem-commits" init -q -b main; D="$TMP/sem-commits"; NOME="sem-commits"; esperar 2 "sem commits"
novo range-vazio; esperar 2 "range vazio" --range "HEAD..HEAD"
novo range-invalido; esperar 2 "range inválido" --range "naoexiste..HEAD"

echo "== MODO --msg-file (hook commit-msg)"
NOME=msg-ok; D="$TMP/home"; printf 'feat(x): boa\n\ncorpo\n' >"$TMP/m1"; esperar 0 "mensagem ok" --msg-file "$TMP/m1"
NOME=msg-ruim; printf 'arrumei tudo\n' >"$TMP/m2"; esperar 1 "cc-mensagem" --msg-file "$TMP/m2"
NOME=msg-comentario-ignorado; printf '# comentario\nfix: certo\n' >"$TMP/m3"; esperar 0 "mensagem ok" --msg-file "$TMP/m3"

echo "== HOOKS de assets/hooks (instalados num repo temporário)"
HK="$AQUI/../assets/hooks"
if [ -d "$HK" ]; then
  novo hook-commit-msg; cp "$HK/commit-msg" "$D/.git/hooks/commit-msg"; chmod +x "$D/.git/hooks/commit-msg"
  export GIT_GATE_SCRIPT="$G"
  w a.txt x; git -C "$D" add a.txt
  if git -C "$D" commit -q -m "bagunca sem tipo" 2>/dev/null; then echo "  ✖ hook commit-msg deixou passar"; fail=$((fail+1)); else echo "  ✔ hook commit-msg barra mensagem ruim"; ok=$((ok+1)); fi
  if git -C "$D" commit -q -m "feat: com tipo" 2>/dev/null; then echo "  ✔ hook commit-msg aceita mensagem boa"; ok=$((ok+1)); else echo "  ✖ hook commit-msg barrou mensagem boa"; fail=$((fail+1)); fi
  novo hook-pre-commit; cp "$HK/pre-commit" "$D/.git/hooks/pre-commit"; chmod +x "$D/.git/hooks/pre-commit"
  w cfg.txt "k=$AWS"; git -C "$D" add cfg.txt
  if git -C "$D" commit -q -m "chore: x" 2>/dev/null; then echo "  ✖ hook pre-commit deixou segredo passar"; fail=$((fail+1)); else echo "  ✔ hook pre-commit barra segredo"; ok=$((ok+1)); fi
  git -C "$D" reset -q; w cfg.txt "ok"; git -C "$D" add cfg.txt
  if git -C "$D" commit -q -m "chore: x" 2>/dev/null; then echo "  ✔ hook pre-commit aceita limpo"; ok=$((ok+1)); else echo "  ✖ hook pre-commit barrou limpo"; fail=$((fail+1)); fi
  # pre-push: recusa push direto na main protegida
  novo hook-pre-push; cp "$HK/pre-push" "$D/.git/hooks/pre-push"; chmod +x "$D/.git/hooks/pre-push"
  git init -q --bare -b main "$TMP/remoto.git"; git -C "$D" remote add origin "$TMP/remoto.git"
  w a.txt x; c "feat: x"
  if git -C "$D" push -q origin main 2>/dev/null; then echo "  ✖ hook pre-push deixou push direto na main"; fail=$((fail+1)); else echo "  ✔ hook pre-push barra push direto na main"; ok=$((ok+1)); fi
  if GIT_ALLOW_PUSH_MAIN=1 git -C "$D" push -q origin main 2>/dev/null; then echo "  ✔ pre-push libera com GIT_ALLOW_PUSH_MAIN=1 (dono solo)"; ok=$((ok+1)); else echo "  ✖ pre-push não liberou com a variável"; fail=$((fail+1)); fi
  git -C "$D" checkout -q -b feat/x; w b.txt y; c "feat: y"
  if git -C "$D" push -q origin feat/x 2>/dev/null; then echo "  ✔ pre-push libera branch curta"; ok=$((ok+1)); else echo "  ✖ pre-push barrou branch curta"; fail=$((fail+1)); fi
  if git -C "$D" push -q --force origin feat/x:main 2>/dev/null; then echo "  ✖ pre-push deixou force na main"; fail=$((fail+1)); else echo "  ✔ pre-push barra force/non-ff na main"; ok=$((ok+1)); fi
else echo "  ✖ assets/hooks ausente"; fail=$((fail+1)); fi

echo
echo "check-git.test: $ok ok, $fail falha(s)"
[ "$fail" -eq 0 ]
