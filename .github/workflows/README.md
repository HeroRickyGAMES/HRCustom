# Auto-sync HRCustom (GitHub Actions)

Dois workflows mantêm a ROM atualizada sozinha:

| Workflow                     | O que faz                                          | Frequência |
|------------------------------|----------------------------------------------------|------------|
| `sync-upstream.yml`          | Mergeia novidades do LineageOS nos seus forks      | a cada 12h |
| `watch-android-version.yml`  | Avisa (abre issue) quando sai nova versão Android  | 1x/dia     |

## Setup obrigatório: token (HRCUSTOM_PAT)

O `sync-upstream` precisa dar **push em vários repos** (device, kernel, vendor),
então o `GITHUB_TOKEN` padrão não basta. Crie um Personal Access Token:

1. GitHub → **Settings → Developer settings → Personal access tokens → Fine-grained**
2. Repository access: **todos os repos da HRCustom** (forks + manifest)
3. Permissões: **Contents = Read/Write** e **Issues = Read/Write**
4. Copie o token.
5. No repo `HRCustom`: **Settings → Secrets and variables → Actions → New repository secret**
   - Nome: `HRCUSTOM_PAT`
   - Valor: o token

## Como funciona o sync

```
LineageOS (upstream)  ──fetch──>  Action  ──merge──>  seu fork (hrcustom-16)  ──push──>  GitHub
```

- Se o merge for **limpo**: faz push automático. Você nem percebe.
- Se houver **conflito**: aborta o merge e **abre uma issue** no fork avisando
  exatamente como resolver. Nada quebra silenciosamente.

## Adicionar mais repos ao sync

Edite a `matrix.include` em `sync-upstream.yml` e adicione uma linha:

```yaml
- { repo: "HeroRickyGAMES/SEU_FORK", upstream: "https://github.com/LineageOS/ORIGINAL.git", up_branch: "lineage-23.2", branch: "hrcustom-16" }
```

## Ajustar a frequência

No topo de cada workflow, mude o `cron`:
- `'0 */6 * * *'`  → a cada 6h
- `'0 0 * * *'`    → 1x por dia à meia-noite UTC
- `'0 0 * * 0'`    → 1x por semana (domingo)

## Migração de versão (quando o watcher avisar)

Quando sair Android novo, o `watch-android-version` abre uma issue com o
passo-a-passo. Resumo: trocar `lineage-23.2` → nova branch nos 3 lugares
(`repo init`, `up_branch` do sync, `revision` do manifest) e rebasear os forks.
