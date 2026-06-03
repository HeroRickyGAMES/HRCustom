# Build da HRCustom

## Pré-requisitos (uma vez)

Antes do 1º build, garanta que estes itens estão no lugar:

| Item | Onde | Status |
|------|------|--------|
| Device tree marble | `device/xiaomi/marble` (fork) | forkar |
| sm8450-common | `device/xiaomi/sm8450-common` (fork) | forkar |
| Kernel sm8450 | `kernel/xiaomi/sm8450` (fork) | forkar |
| Blobs marble | `vendor/xiaomi/marble` (fork) | forkar |
| **Hardware Xiaomi (comum)** | `hardware/xiaomi` (fork) | **forkar — obrigatório p/ os 2** |
| llama.cpp | `external/llama.cpp` (+ Android.bp `libllama`) | ver `packages/apps/HRAssistant/jni/README.md` |
| Ícone HRAssistant | `res/mipmap-*/ic_launcher.png` | adicionar |

> Os arquivos `hrcustom_marble.mk` e `AndroidProducts.mk` deste repo vão
> **dentro do fork do device tree** (`device/xiaomi/marble/`).

## 1. Preparar o source

```bash
cd ~/android/hrcustom
source build/envsetup.sh
```

## 2. Escolher o device (lunch)

```bash
# Poco F5
breakfast hrcustom_marble

# Poco F1
breakfast hrcustom_beryllium
```

O `breakfast` baixa as dependências do device tree (lineage.dependencies)
e configura o ambiente.

## 3. Buildar (comece leve!)

```bash
# Comece com 4 jobs (máquina aguenta, menos risco de travar)
brunch hrcustom_marble -j4
```

Quando estabilizar e quiser mais velocidade:

```bash
brunch hrcustom_marble -j6     # depois
brunch hrcustom_marble -j12    # se a RAM/CPU aguentarem
```

> Regra prática: `-j` ≈ nº de núcleos, mas cada job usa ~1.5–2 GB de RAM.
> 12 jobs ≈ 24 GB de RAM. Se faltar RAM, o build trava — baixe o `-j`.

## 4. Resultado

```
out/target/product/marble/HRCustom-1.0-Genesis-marble-UNOFFICIAL.zip
```

## 5. Fluxo de teste que você quer

1. Buildar `hrcustom_marble` (Poco F5).
2. Flashar o `.zip` no **Poco F5** via recovery (NÃO no F1 — SoC diferente!).
3. Validar boot, bootanimation, branding e o HRAssistant.
4. Build separado `hrcustom_beryllium` pra testar no Poco F1.

## Dicas de build leve

```bash
export USE_CCACHE=1
ccache -M 50G                 # cache acelera rebuilds
export WITH_GMS=false         # sem Google apps (mais leve)
```

## Limpeza

```bash
make clean        # limpa tudo
make installclean # limpa só o device atual (rebuild mais rápido)
```
