# Piso do fluxo git (schematize-git) — sempre-on

O histórico é permanente, público e a fonte da verdade. Corrija à frente, nunca reescreva atrás.

1. **Commit + push na hora.** A cópia local nunca diverge do publicado; trabalho só local não existe.
2. **Trunk-based:** `main` sempre verde; branch curta (`tipo/assunto`, horas a 1-2 dias), rebase sobre `main`,
   integração por squash/rebase (histórico linear). Sem `develop`.
3. **Conventional Commits 1.0.0** (`tipo(escopo)!: descrição`, imperativo, ≤ 72 col., porquê no corpo).
   Tipos: feat fix perf refactor docs test build ci style chore revert. Um commit = uma mudança lógica.
4. **PR pequeno** (~15 min de revisão), descrição com o quê/porquê, como testou, risco/rollback, onde olhar.
   `fixup!`/`squash!` nunca chegam ao remoto.
5. **Nunca reescrever histórico publicado** (sem `push --force` em `main`/`release/*`/tag, sem amend após
   push). Erro publicado se corrige com `git revert`. Na sua branch própria: `--force-with-lease`.
   Única exceção: remoção de segredo/dado pessoal, pelo rito de `references/segredos.md`.
6. **Segredo commitado = rotacionar PRIMEIRO**, depois limpar. Nunca `--no-verify`. Secret scanning e push
   protection ligados; hook `pre-commit` instalado.
7. **Commits e tags de release assinados** (SSH por padrão) onde a política está adotada; ruleset da
   `main`: force push bloqueado, linear, PR, status check, code owner.
8. **Tags SemVer anotadas e imutáveis** (`vX.Y.Z`); tag errada se corrige com a próxima versão.
   CHANGELOG escrito para humanos. Release de skill do catálogo: `schematize-skill-dev`.
9. Arquivo > 5 MiB, `.env`, chave e `*.tfstate` não entram no repo; `.gitignore` e `.gitattributes` desde o
   primeiro commit.
10. <!-- herdado:engineering/orquestracao:curto -->**Orquestrador não desenvolve; subagent barato executa.** O agent principal só planeja, despacha e revisa; ação onerosa vira micro-tasks para o executor mais barato que resolve: `haiku` (mecânico) / `sonnet` (código; falhou → mesmo subagent corrige, até 2 rodadas) → Codex `gpt-5.6-terra` → Cursor → subagent `opus` (motivo) → `park`; **visual vai direto ao Codex**; **imagem nunca pelo Claude: detectar Codex/Gemini e perguntar ao usuário qual usar (Codex é a sugestão), nunca API de imagem paga**; papéis em `agentes.toml`. No overdev, cada item do checklist vai a um subagent e o principal revisa antes do `- [x]`. **Sem frota ociosa:** idle com pendência volta ao trabalho; dependente de outro agent → mata e enfileira com gatilho; terminou → mata (§9.6). Detalhe: `schematize-engineering` → `references/orquestracao.md` §9.<!-- /herdado -->

Mídia: imagem/visual gerado nunca por modelo Claude; detecte Codex/Gemini e pergunte qual usar.

Gate: `bash .claude/skills/schematize-git/scripts/check-git.sh . --linear` — waiver rastreável
`git-ok: <motivo>` (linha) ou `Git-Ok: <regra> <motivo>` (corpo do commit).
