# HRCustom ROM

Custom ROM Android baseada no **LineageOS 23.2 (Android 16)**, com identidade própria e IA local nativa integrada ao sistema.

> Migração planejada para Android 17 após estabilizar a base.

## Dispositivos suportados

| Dispositivo   | Codename     | SoC      | Status     |
|---------------|--------------|----------|------------|
| Poco F5       | `marble`     | SM7475   | Em dev     |
| Poco F1       | `beryllium`  | SD845    | Teste base |

> ⚠️ Cada SoC tem build próprio. O `.zip` do Poco F5 **não** instala no Poco F1.

## Setup do ambiente

```bash
# Dependências (Ubuntu 22.04+/Debian)
sudo apt install -y git-core git-lfs gnupg flex bison build-essential zip curl \
  zlib1g-dev libc6-dev-i386 libncurses-dev x11proto-core-dev \
  libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig

# Habilita o git LFS (necessário pro --git-lfs do repo init)
git lfs install

# repo tool
mkdir -p ~/bin && curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo && export PATH=~/bin:$PATH
```

## Baixar o source

```bash
mkdir -p ~/android/hrcustom && cd ~/android/hrcustom

repo init -u https://github.com/LineageOS/android.git -b lineage-23.2 --git-lfs

# Adiciona os repos da HRCustom
mkdir -p .repo/local_manifests
curl -o .repo/local_manifests/hrcustom.xml \
  https://raw.githubusercontent.com/HeroRickyGAMES/HRCustom/main/.repo/manifests/default.xml

# Sync leve (comece com j4)
repo sync -c -j4 --force-sync --no-clone-bundle --no-tags
```

## Buildar

```bash
source build/envsetup.sh

# Poco F5
breakfast marble && brunch marble

# Poco F1
breakfast beryllium && brunch beryllium
```

Ajuste o paralelismo conforme a máquina: comece com `-j4`, depois `-j6`/`-j12`.
O output sai em `out/target/product/<codename>/HRCustom-*.zip`.

## Estrutura dos repositórios (no GitHub `HeroRickyGAMES`)

| Path local                      | Repositório                          |
|---------------------------------|--------------------------------------|
| `vendor/hrcustom`               | `vendor_hrcustom`                    |
| `device/xiaomi/marble`          | `android_device_xiaomi_marble`       |
| `device/xiaomi/sm8450-common`   | `android_device_xiaomi_sm8450-common`|
| `kernel/xiaomi/sm8450`          | `android_kernel_xiaomi_sm8450`       |
| `vendor/xiaomi/marble`          | `proprietary_vendor_xiaomi_marble`   |

## Identidade

- `ro.product.brand=HRCustom`
- `ro.product.manufacturer=HRCustom`
- Build fingerprint customizado
- Bootanimation externo (`vendor/hrcustom/bootanimation/bootanimation.zip`)
- Integração de keybox (estilo crDroid) para attestation

## Licença

Mantém as licenças dos projetos upstream (Apache 2.0 / LineageOS).
