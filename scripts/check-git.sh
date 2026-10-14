#!/usr/bin/env bash
# check-git.sh — gate do fluxo git da casa (schematize-git).
#
# Motivo: o histórico é permanente e público; mensagem fora do padrão quebra changelog/SemVer
# automáticos, segredo commitado vira rotação obrigatória, blob grande incha todo clone para sempre
# e merge commit furado em branch linear quebra o bisect. Pega isso ANTES do push, na máquina.
# Como funciona: lê um range de commits (ou o índice, com --staged) e aplica 6 regras:
#   cc-mensagem      assunto fora de Conventional Commits 1.0.0 (ou fixup!/squash!/amend! publicável)
#   segredo          padrão de credencial em linha ADICIONADA (mesmo que removida num commit seguinte)
#   arquivo-grande   blob novo acima de GIT_GATE_MAX_MB (padrão 5) que não é ponteiro LFS
#   arquivo-proibido .env, chave privada, *.tfstate, *.pem etc. versionados
#   merge-linear     merge commit no range quando a branch exige histórico linear (--linear)
#   nao-assinado     commit sem assinatura válida, só com --require-signed
# Aviso (não reprova): assunto > 72 colunas; .gitignore ausente.
# Waiver: `git-ok: <motivo>` na própria linha (segredo/arquivo-proibido no conteúdo) ou
# `Git-Ok: <regra> <motivo>` no corpo do commit (qualquer regra daquele commit). Sem motivo não vale.
# Entrada: check-git.sh [dir] [--range A..B] [--staged] [--linear] [--require-signed]
#          [--msg-file ARQ]   (valida só a mensagem de ARQ: uso do hook commit-msg)
#          dir padrão = "."; range padrão = @{u}..HEAD, senão merge-base com origin/main|main, senão tudo.
# Saída: 0 passa · 1 reprova · 2 nada para verificar (repo sem commits, range vazio) — NÃO é aprovação.
# Env: GIT_GATE_MAX_MB, GIT_GATE_LINEAR=1, GIT_GATE_SIGNED=1; `git config schematize.linear true`.
set -euo pipefail

DIR="."; RANGE=""; STAGED=0; LINEAR="${GIT_GATE_LINEAR:-0}"; SIGNED="${GIT_GATE_SIGNED:-0}"; MSGFILE=""
MAXMB="${GIT_GATE_MAX_MB:-5}"
while [ $# -gt 0 ]; do
  case "$1" in
    --range) RANGE="${2:?--range exige A..B}"; shift 2 ;;
    --staged) STAGED=1; shift ;;
    --linear) LINEAR=1; shift ;;
    --require-signed) SIGNED=1; shift ;;
    --msg-file) MSGFILE="${2:?--msg-file exige arquivo}"; shift 2 ;;
    -h|--help) sed -n '2,24p' "$0"; exit 0 ;;
    -*) echo "opção desconhecida: $1" >&2; exit 2 ;;
    *) DIR="$1"; shift ;;
  esac
done

CC_RE='^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([A-Za-z0-9._/,-]+\))?!?: [^ ].*$'
fail=0; warn=0
reprova() { echo "  ✖ [$1] $2"; fail=$((fail+1)); }
avisa() { echo "  ! [$1] $2"; warn=$((warn+1)); }

# valida_assunto <assunto> <rotulo>: devolve 0 se ok.
valida_assunto() {
  local s="$1" rot="$2"
  case "$s" in
    "Merge "*|"Revert \""*) return 0 ;;
    "fixup! "*|"squash! "*|"amend! "*) reprova cc-mensagem "$rot: '$s' é commit de autosquash; faça o rebase --autosquash antes de publicar"; return 1 ;;
  esac
  if ! [[ "$s" =~ $CC_RE ]]; then
    reprova cc-mensagem "$rot: '$s' não segue Conventional Commits (tipo(escopo)!: descrição)"; return 1
  fi
  [ "${#s}" -gt 72 ] && avisa cc-mensagem "$rot: assunto com ${#s} colunas (> 72)"
  return 0
}

# --- modo hook commit-msg: só a mensagem ---
if [ -n "$MSGFILE" ]; then
  [ -f "$MSGFILE" ] || { echo "arquivo de mensagem não existe: $MSGFILE" >&2; exit 2; }
  s="$(grep -v '^#' "$MSGFILE" | sed -n '/./{p;q}')"
  [ -n "$s" ] || { echo "mensagem vazia" >&2; exit 2; }
  if grep -qiE '^Git-Ok: cc-mensagem +[^ ]' "$MSGFILE"; then echo "check-git: waiver cc-mensagem no corpo"; exit 0; fi
  valida_assunto "$s" "mensagem" || exit 1
  echo "check-git: mensagem ok"; exit 0
fi

cd "$DIR" 2>/dev/null || { echo "diretório inexistente: $DIR" >&2; exit 2; }
git rev-parse --git-dir >/dev/null 2>&1 || { echo "check-git: $DIR não é repositório git — nada a verificar" >&2; exit 2; }
git rev-parse -q --verify HEAD >/dev/null 2>&1 || [ "$STAGED" = 1 ] || { echo "check-git: repositório sem commits — nada a verificar" >&2; exit 2; }
[ "$(git config --get schematize.linear 2>/dev/null || true)" = "true" ] && LINEAR=1
case "$MAXMB" in ''|*[!0-9]*) echo "GIT_GATE_MAX_MB inválido: $MAXMB" >&2; exit 2 ;; esac

# Regexes de credencial. Montadas por partes para a própria fonte não parecer segredo ao scanner.
PRE_AWS='AKIA[0-9A-Z]{16}'
PRE_GH='(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9]{36,}|github_pat_[A-Za-z0-9_]{50,}'
PRE_SLACK='xox[abprs]-[A-Za-z0-9-]{10,}'
PRE_STRIPE='(sk|rk)_live_[A-Za-z0-9]{16,}'
PRE_KEY='-----BEGIN ([A-Z]+ )?PRIVATE KEY'
PRE_GOOG='AIza[0-9A-Za-z_-]{35}'
PRE_GENERIC='(password|passwd|secret|api[_-]?key|token|senha)[A-Za-z0-9_]*["'"'"']?[[:space:]]*[:=][[:space:]]*["'"'"'][^"'"'"'$<{ ]{12,}["'"'"']'
SEG_RE="($PRE_AWS|$PRE_GH|$PRE_SLACK|$PRE_STRIPE|$PRE_KEY|$PRE_GOOG|$PRE_GENERIC)"
PROIBIDO_RE='(^|/)(\.env(\.[A-Za-z0-9_-]+)?|id_(rsa|dsa|ecdsa|ed25519)|[^/]+\.(pem|p12|pfx|jks|keystore)|[^/]+\.tfstate(\.backup)?|[^/]+\.tfplan|credentials\.json|\.npmrc|\.netrc)$'
PROIBIDO_OK_RE='(^|/)\.env\.(example|sample|template)$'

# varre_diff: lê `git ... -p -U0` com marcadores e aplica segredo + arquivo-proibido.
varre_diff() {
  SEG_RE="$SEG_RE" PRO_RE="$PROIBIDO_RE" PROOK_RE="$PROIBIDO_OK_RE" awk '
    BEGIN { seg=ENVIRON["SEG_RE"]; pro=ENVIRON["PRO_RE"]; prook=ENVIRON["PROOK_RE"] }
    /^@@C / { c=$2; arq=""; skip=0; next }
    /^\+\+\+ b\// { arq=substr($0,7); skip=0
        if (arq ~ pro && arq !~ prook && !(c SUBSEP arq in vistoP)) { vistoP[c SUBSEP arq]=1; print "PRO\t" c "\t" arq }
        next }
    /^\+\+\+ / { arq=""; next }
    /^\+/ { l=substr($0,2); if (arq=="") next
        if (l ~ "git-ok: *[^ ]") next
        if (l ~ seg) { n=l; if (length(n)>90) n=substr(n,1,90) "..."; gsub(/\t/," ",n); print "SEG\t" c "\t" arq "\t" n } }
  '
}

# commit tem waiver Git-Ok para a regra?
waiver_commit() { # waiver_commit <sha> <regra>
  [ "$1" = "INDEX" ] && return 1
  git log -1 --format=%B "$1" 2>/dev/null | grep -qiE "^Git-Ok: $2 +[^ ]"
}

if [ "$STAGED" = 1 ]; then
  echo "check-git: índice (--staged)"
  saida="$( { echo "@@C INDEX"; git diff --cached -U0 --no-color --no-ext-diff; } | varre_diff )"
  commits_n=0
else
  if [ -z "$RANGE" ]; then
    if git rev-parse -q --verify '@{u}' >/dev/null 2>&1; then RANGE='@{u}..HEAD'
    else
      base=""
      for b in origin/main origin/master main master; do
        if git rev-parse -q --verify "$b" >/dev/null 2>&1 && [ "$(git rev-parse "$b")" != "$(git rev-parse HEAD)" ]; then
          base="$(git merge-base "$b" HEAD 2>/dev/null || true)"; [ -n "$base" ] && [ "$base" != "$(git rev-parse HEAD)" ] && break || base=""
        fi
      done
      if [ -n "$base" ]; then RANGE="$base..HEAD"; else RANGE="HEAD"; fi
    fi
  fi
  echo "check-git: range $RANGE"
  commits_n="$(git rev-list --count "$RANGE" 2>/dev/null)" || { echo "range inválido: $RANGE" >&2; exit 2; }
  [ "$commits_n" -gt 0 ] || { echo "check-git: range vazio — nada a verificar" >&2; exit 2; }

  # 1) mensagens
  while IFS=$'\t' read -r sha subj; do
    waiver_commit "$sha" cc-mensagem && continue
    valida_assunto "$subj" "${sha:0:9}" || true
  done < <(git log --no-merges --format='%H%x09%s' "$RANGE")

  # 2) merge linear
  if [ "$LINEAR" = 1 ]; then
    while read -r sha; do
      waiver_commit "$sha" merge-linear && continue
      reprova merge-linear "${sha:0:9}: merge commit em branch que exige histórico linear (use rebase ou squash)"
    done < <(git rev-list --merges "$RANGE")
  fi

  # 3) assinatura
  if [ "$SIGNED" = 1 ]; then
    while IFS=$'\t' read -r sha st; do
      case "$st" in G|U) ;; *) waiver_commit "$sha" nao-assinado || reprova nao-assinado "${sha:0:9}: sem assinatura válida (status '$st')" ;; esac
    done < <(git log --format='%H%x09%G?' "$RANGE")
  fi

  # 4) arquivo grande (blobs novos do range)
  limite=$((MAXMB*1024*1024))
  while read -r tipo tam caminho; do
    [ "$tipo" = blob ] || continue
    [ "$tam" -gt "$limite" ] || continue
    reprova arquivo-grande "$caminho: $((tam/1024/1024)) MiB (limite ${MAXMB} MiB) — use Git LFS ou tire do repo"
  done < <(git rev-list --objects "$RANGE" | git cat-file --batch-check='%(objecttype) %(objectsize) %(rest)' 2>/dev/null)

  saida="$(git log -p -U0 --no-merges --no-color --no-ext-diff --format='@@C %H' "$RANGE" | varre_diff)"
fi

# 5) resultados de segredo / arquivo proibido
if [ -n "$saida" ]; then
  while IFS=$'\t' read -r tipo c arq resto; do
    if [ "$tipo" = SEG ]; then
      waiver_commit "$c" segredo && continue
      reprova segredo "${c:0:9} $arq: padrão de credencial — '${resto}'. Rotacione ANTES de qualquer limpeza (references/segredos.md)"
    elif [ "$tipo" = PRO ]; then
      waiver_commit "$c" arquivo-proibido && continue
      reprova arquivo-proibido "${c:0:9}: $arq não pode ser versionado (ignore e rotacione se tinha segredo)"
    fi
  done <<<"$saida"
fi

[ -f .gitignore ] || avisa gitignore ".gitignore ausente na raiz"

if [ "$fail" -gt 0 ]; then echo "check-git: REPROVADO ($fail violação(ões), $warn aviso(s))"; exit 1; fi
echo "check-git: ok ($commits_n commit(s), $warn aviso(s))"
