# HRCustom — Sincronizar e buildar numa máquina

Guia completo pra clonar a ROM numa máquina nova (Linux), sincronizar o
source e gerar o `.zip`.

> Repo deste guia: https://github.com/HeroRickyGAMES/HRCustom

## Requisitos da máquina

- Ubuntu 22.04+ (ou Debian)
- **16 GB RAM** (mínimo; 32 GB recomendado)
- **~300 GB** de disco livre (source + out)
- Boa conexão (o 1º sync baixa dezenas de GB)

## 1. Instalar dependências

```bash
sudo apt update && sudo apt install -y \
  git-core git-lfs gnupg flex bison build-essential zip curl zlib1g-dev \
  libc6-dev-i386 libncurses-dev x11proto-core-dev libx11-dev lib32z1-dev \
  libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig python3 \
  python-is-python3 ccache rsync openjdk-21-jdk

# Habilita o git LFS (necessário pro --git-lfs do repo init)
git lfs install
```

> Nota: o Ubuntu 22.04+ removeu `libncurses5`/`lib32ncurses5-dev`.
> Use `libncurses-dev` (já incluso acima).

## 2. Instalar o `repo`

```bash
mkdir -p ~/bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
echo 'export PATH=~/bin:$PATH' >> ~/.bashrc
export PATH=~/bin:$PATH
```

## 3. Configurar git (uma vez)

```bash
git config --global user.name  "Seu Nome"
git config --global user.email "ricojn9@gmail.com"
```

## 4. Inicializar a árvore com a base do LineageOS

```bash
mkdir -p ~/android/hrcustom && cd ~/android/hrcustom

repo init -u https://github.com/LineageOS/android.git -b lineage-23.2 --git-lfs
```

## 5. Adicionar os repos da HRCustom (local_manifest)

```bash
mkdir -p .repo/local_manifests
curl -o .repo/local_manifests/hrcustom.xml \
  https://raw.githubusercontent.com/HeroRickyGAMES/HRCustom/main/.repo/manifests/default.xml
```

## 6. Sincronizar (1ª vez — demorado)

```bash
repo sync -c -j4 --force-sync --no-clone-bundle --no-tags
```

- `-c` = só a branch atual (mais leve)
- `-j4` = 4 downloads paralelos (suba pra j8/j12 se a net/CPU aguentar)

## 7. Buildar

```bash
source build/envsetup.sh

# Poco F5
breakfast hrcustom_marble
brunch hrcustom_marble -j4        # comece leve; depois -j6 / -j12
```

Saída: `out/target/product/marble/HRCustom-*.zip`

> Detalhes de build (jobs, ccache, limpeza) em **BUILD.md**.

---

## Re-sincronizar depois (atualizar o source)

Sempre que quiser pegar as novidades (do LineageOS e dos seus forks):

```bash
cd ~/android/hrcustom
repo sync -c -j8 --force-sync --no-clone-bundle --no-tags
```

Depois é só rebuildar:

```bash
source build/envsetup.sh
brunch hrcustom_marble -j6
```

Pra rebuild rápido só do device (sem limpar tudo):

```bash
make installclean && brunch hrcustom_marble -j6
```

## Acelerar rebuilds (ccache)

```bash
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
ccache -M 50G          # uma vez
```

Adicione os dois `export` no `~/.bashrc` pra ficar permanente.

## Problemas comuns

| Erro | Causa | Solução |
|------|-------|---------|
| Build trava/morre | RAM insuficiente | baixe o `-j` (ex.: `-j4`) |
| `device tree not found` | forks não sincados | confira o `local_manifests/hrcustom.xml` |
| `libllama not found` | llama.cpp ausente | ver `packages/apps/HRAssistant/jni/README.md` |
| `resource ic_launcher` | ícone do app faltando | adicione `res/mipmap-*/ic_launcher.png` |
