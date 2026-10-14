---
description: schematize-git — context compact: grava o handoff no archive e roda /compact.
---
Antes de compactar, **grave o handoff** em `<projeto>/<projeto>_archive/context/` no par
**context + checklist** do padrão da `schematize-archive` (prefixo `AAAA-MM-DD-<slug>-`), FEITO vs
ABERTO. Inclua: branches/PRs abertos e seu estado, achados do `scripts/check-git.sh` ainda abertos,
waivers (`git-ok`/`Git-Ok`) declarados com o motivo, tags criadas e commits locais ainda não
publicados (que devem ser zero, pela regra GitHub-é-a-fonte). Nunca inclua segredo. Só então rode
`/compact`.
