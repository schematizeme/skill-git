# Segredo commitado: rotacionar primeiro

> Parte da `schematize-git`. Segredo que tocou um repositório remoto deve ser tratado como **público
> a partir do push** (bots varrem commits novos em segundos; forks e caches guardam cópia). Reescrever
> histórico NÃO desfaz o vazamento. A política geral de segredo é da `schematize-infra → references/segredos.md`.

## 1. Ordem do rito (não inverta)

1. **Revogar/rotacionar a credencial agora.** Antes de discutir histórico, antes de apagar commit, antes
   de avisar no chat. A credencial velha tem que parar de funcionar; o resto é limpeza.
2. **Medir o estrago:** onde a credencial vale, quem a usou desde o commit (logs do provedor), se o
   repo é público, se houve fork/clone. Dado pessoal envolvido = acione `schematize-incident`
   (gatilho LGPD).
3. **Remover do código:** o valor sai do arquivo e passa a vir de cofre/variável de ambiente
   (`schematize-infra → references/segredos.md`), num commit normal.
4. **Decidir sobre o histórico** (§3): com a credencial já morta, reescrever é higiene opcional, não
   remédio. Faça só se há motivo (dado pessoal, chave que não dá para rotacionar, exigência legal).
5. **Registrar:** incidente em `<projeto>_archive/` e, por regra da casa, o incidente recorrente vira
   ADR + piso + gate (aqui: regra no `check-git.sh` e hook).

## 2. Prevenção em camadas

| Camada | Ferramenta | Pega |
|---|---|---|
| Editor/máquina | `.gitignore` forte (`higiene.md`), cofre local | arquivo sensível nem entra no `git add` |
| pre-commit | `assets/hooks/pre-commit` (regex da casa) + **gitleaks** se instalado | índice com credencial conhecida |
| CI | `scripts/check-git.sh` no range do PR + gitleaks/trufflehog no histórico | o que passou do hook (hook é opt-in e `--no-verify` existe) |
| Servidor | **secret scanning + push protection** do GitHub (ligar por repo/organização) | push com credencial reconhecida, mesmo sem hook local |

Nenhuma camada sozinha basta: hook local é contornável, scanner de servidor só conhece formatos de
provedores parceiros. O gate da casa reprova inclusive o segredo **adicionado e removido em commits
diferentes do mesmo range** (ele continua no histórico).

Waivers rastreáveis, nunca silenciosos: `git-ok: <motivo>` na linha (fixture, exemplo de formato) ou
`Git-Ok: segredo <motivo>` no corpo do commit. Em teste, **monte o valor falso em tempo de execução**
(concatenação), nunca literal: o push protection do GitHub bloqueia o push do próprio repo de testes.

## 3. Rito de reescrita de histórico (exceção única)

Só com a credencial já rotacionada (ou dado pessoal a eliminar) e **com aviso prévio a quem tem clone**.

```bash
# 1. clone espelho novo (nunca no clone de trabalho) e backup do original
git clone --mirror git@github.com:org/repo.git repo-limpo.git && cp -r repo-limpo.git repo-backup.git
cd repo-limpo.git
# 2. remover o arquivo de todo o histórico (git-filter-repo; não use filter-branch)
git filter-repo --invert-paths --path caminho/do/segredo.env
#    ou substituir texto: git filter-repo --replace-text expressoes.txt
# 3. conferir que sumiu (sem imprimir o valor)
git log --all --oneline -S'prefixo-do-valor' | wc -l        # esperado: 0
# 4. publicar com janela combinada (ruleset: bypass temporário e auditado para o admin)
git push --force --mirror origin
```

Depois: (a) **todo mundo reclona** (clone antigo reintroduz o segredo no próximo push); (b) PRs abertos
são refeitos; (c) o GitHub mantém objetos órfãos acessíveis por SHA em caches e forks até um pedido ao
suporte para expurgo (cached views) — para segredo vivo isso reforça: a rotação (passo 1) é a defesa
real; (d) tags e releases que apontam para commits antigos são recriadas; (e) encerre a janela de bypass
do ruleset e registre o que foi feito. `git-filter-repo` é ferramenta externa (`stack-versoes.md`).

## 4. O que NÃO fazer

- Apagar o arquivo num commit novo e achar que resolveu (continua no histórico e nos clones).
- Force push "para sumir" sem rotacionar (a credencial já foi copiada).
- Colar o valor do segredo em issue, PR, chat ou no relatório do gate (o gate imprime só trecho
  truncado e o caminho; trate a saída como sensível mesmo assim).
- `git commit --no-verify` para passar por cima do hook. Hook barrando é o hook funcionando.

Token de bot de chat (Discord, Telegram, Slack) commitado: rotacione primeiro no painel da plataforma; ver `schematize-bots → references/credenciais-e-token.md`.
