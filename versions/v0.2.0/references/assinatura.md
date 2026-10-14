# Commits e tags assinados

> Parte da `schematize-git`. Assinatura prova QUEM publicou; não prova que o conteúdo é bom. Sem ela,
> o campo `author` é texto livre: qualquer um escreve o e-mail de outro.

## 1. Escolha do método

| Método | Quando | Custo |
|---|---|---|
| **SSH** (`gpg.format ssh`) | padrão da casa para pessoas: usa a chave SSH que já existe, sem keyring GPG, Git 2.34+ | baixo |
| **gitsign** (Sigstore, keyless, OIDC) | CI e equipes que não querem chave de longa duração; assina com identidade OIDC e registra no log de transparência | médio (depende do Fulcio/Rekor; verificação exige a cadeia) |
| GPG/OpenPGP | só onde já é obrigatório (política externa, distro) | alto: keyring, expiração, revogação |

Chave de assinatura é **separada da chave de autenticação** sempre que der (`ssh-keygen -t ed25519 -f
~/.ssh/id_assinatura`), e passphrase ou chave em hardware (FIDO2 `ed25519-sk`) para máquina de pessoa.

## 2. SSH, passo a passo

```bash
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_assinatura.pub
git config --global commit.gpgsign true
git config --global tag.gpgSign true
# verificação LOCAL: arquivo de signatários permitidos (e-mail + chave pública)
git config --global gpg.ssh.allowedSignersFile ~/.config/git/allowed_signers
echo "voce@exemplo.com $(cat ~/.ssh/id_assinatura.pub)" >> ~/.config/git/allowed_signers
git log --show-signature -1        # G = boa, N = sem assinatura, B/E/X/Y/R = ruim
```

Cadastre a mesma chave pública no GitHub como **chave de assinatura** (Settings, SSH and GPG keys,
tipo "Signing Key"); sem isso o commit sai "Unverified" na interface.

- Para equipe, o `allowed_signers` versionado no repo (ou num repo de política) é a lista de quem pode
  assinar; revogar = remover a linha (ou marcar `valid-before`).
- O gate `check-git.sh --require-signed` reprova commit cujo status `%G?` não seja `G`/`U`. **Sem o
  `allowed_signers` configurado o Git não consegue verificar assinatura SSH** (verificado nesta máquina:
  erro e status `N`), então em CI monte o arquivo antes de rodar o gate, ou todo commit assinado
  parecerá "não assinado".

## 3. gitsign (keyless)

Verifique o estado atual antes de adotar (`stack-versoes.md`): é projeto Sigstore, com versão 0.x.

```bash
gitsign --version
git config --local commit.gpgsign true
git config --local tag.gpgsign true
git config --local gpg.x509.program gitsign
git config --local gpg.format x509
```

Cada assinatura exige login OIDC no momento (navegador ou token de CI). Bom para pipeline que cria
tag/commit (bot); para pessoa em dia a dia, SSH é mais simples. Verificação independente com
`gitsign verify --certificate-identity=... --certificate-oidc-issuer=...`.

## 4. Onde cobrar

- **Ruleset do GitHub: "Require signed commits"** na `main` — é o único lugar onde a regra é
  inviolável. Squash pela interface web é assinado pelo GitHub (a chave dele), então o commit de
  squash sai "Verified" mesmo que os commits da branch não tenham sido assinados; decida se isso basta
  para a classe de risco do repo.
- **Local:** `commit.gpgsign true` no `~/.gitconfig`; o gate `--require-signed` na CI como segunda barreira.
- **Vigilant mode** do GitHub marca como "Unverified" tudo que não é assinado em seu nome; ligue-o.

## 5. Pisos

1. Repo com release público ou código de produção: **tag de release assinada** (mínimo) e commits de
   `main` assinados (alvo).
2. Chave comprometida ou máquina perdida: remova do `allowed_signers`/GitHub, **revogue** e reassine as
   tags de release recentes com a chave nova (tag nova de patch; não mova a antiga).
3. Assinar artefato binário (imagem, zip) é supply chain: `schematize-infra → references/entrega.md`
   e `schematize-docker`. Aqui é só o histórico git.
