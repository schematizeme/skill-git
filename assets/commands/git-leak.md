---
description: schematize-git — rito de segredo commitado: rotacionar primeiro, medir, limpar o código e só então decidir sobre o histórico.
argument-hint: "<o que vazou, sem colar o valor>"
---

# /git-leak — a credencial é pública a partir do push

**Ordem fixa** (`references/segredos.md`): não pule o passo 1 para ir direto ao `filter-repo`.

1. **Rotacione/revogue AGORA** (peça ao humano se a credencial não está ao seu alcance; marque
   `[H ]` no checklist). Sem isso nada do resto resolve.
2. **Meça:** onde a credencial vale, o que ela acessou desde o commit (logs do provedor), se o repo é
   público, forks/clones. Dado pessoal envolvido: abra incidente (`schematize-incident`, gatilho LGPD).
3. **Tire do código:** valor vai para o cofre/ambiente; `.gitignore` do arquivo; `git rm --cached`.
   Commit normal (`fix: remove credencial versionada`), push.
4. **Histórico:** com a credencial morta, reescrever é opcional. Se for o caso (dado pessoal, chave
   não rotacionável): rito de `references/segredos.md` §3 (espelho, `git filter-repo`, janela
   combinada com o ruleset, reclone geral, tags recriadas). Nunca no clone de trabalho.
5. **Feche o ciclo:** registre no `<projeto>_archive/`; incidente recorrente vira ADR + piso + gate.
   Verifique que `scripts/check-git.sh` e o secret scanning/push protection estão ligados.

Não cole o valor em chat, issue, PR ou relatório. O gate imprime só o caminho e um trecho truncado.

Token de bot de chat vazado: revogue/rotacione na plataforma antes de limpar o histórico (`schematize-bots → references/credenciais-e-token.md`).
