# Como subir o HRCustom para o GitHub

Conta: **github.com/HeroRickyGAMES**

## 1. Repositórios a criar (vazios, sem README) no GitHub

| Repo no GitHub                          | Conteúdo                          |
|-----------------------------------------|-----------------------------------|
| `HRCustom`                              | manifest + docs (este projeto)    |
| `vendor_hrcustom`                       | `vendor/hrcustom/`                |
| `android_device_xiaomi_marble`          | device tree Poco F5               |
| `android_device_xiaomi_sm8450-common`   | common tree                       |
| `android_kernel_xiaomi_sm8450`          | kernel                            |
| `proprietary_vendor_xiaomi_marble`      | blobs                             |
| `android_hardware_xiaomi`               | HALs comuns Xiaomi (os 2 devices) |
| `android_device_xiaomi_beryllium`       | device tree Poco F1               |
| `android_device_xiaomi_sdm845-common`   | common tree Poco F1               |
| `proprietary_vendor_xiaomi_beryllium`   | blobs Poco F1                     |

## 2. Subir o repo do manifest (HRCustom)

```bash
cd ~/aosp/aosp
git init -b main
git add .repo/manifests/default.xml README.md IMPORT_GITHUB.md
git commit -m "HRCustom: manifest inicial"
git remote add origin https://github.com/HeroRickyGAMES/HRCustom.git
git push -u origin main
```

## 3. Subir o vendor_hrcustom

```bash
cd vendor/hrcustom
git init -b main
git add .
git commit -m "vendor_hrcustom: branding, configs, bootanimation, keybox"
git remote add origin https://github.com/HeroRickyGAMES/vendor_hrcustom.git
git push -u origin main
```

## 4. Forkar os device/kernel trees do marble (Poco F5)

Use os repos do Chaitanyakm / LineageOS como base:

```bash
# Exemplo: device tree marble
git clone -b lineage-23.2 \
  https://github.com/Chaitanyakm/android_device_xiaomi_marble.git
cd android_device_xiaomi_marble
git remote add hrcustom https://github.com/HeroRickyGAMES/android_device_xiaomi_marble.git
git push hrcustom HEAD:hrcustom-16
```

Repita para `sm8450-common`, `kernel_xiaomi_sm8450` e `proprietary_vendor_xiaomi_marble`.
Se algum não existir no Chaitanyakm, procure em **github.com/LineageOS**.

## 5. Integrar o branding no device tree

No `lineage_marble.mk` (vira `hrcustom_marble.mk`), adicione:

```make
$(call inherit-product, vendor/hrcustom/build/target/product/hrcustom.mk)
```

E renomeie/aponte o `AndroidProducts.mk` para o novo nome de produto.

## 6. Sync + build

```bash
cd ~/aosp/aosp
repo sync -c -j4 --force-sync --no-clone-bundle --no-tags
source build/envsetup.sh
brunch marble        # comece com j4: brunch marble -j4
```
