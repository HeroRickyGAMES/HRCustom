# HRCustom - Product base
# Herde este arquivo no lineage_<device>.mk do device tree:
#   $(call inherit-product, vendor/hrcustom/build/target/product/hrcustom.mk)

# Configs comuns da HRCustom
$(call inherit-product, vendor/hrcustom/config/common.mk)

# Nome/descrição do produto que aparece no build
PRODUCT_NAME    := hrcustom
PRODUCT_BRAND   := HRCustom
PRODUCT_MANUFACTURER := HRCustom

# Marca os builds como HRCustom para os scripts de empacotamento
TARGET_PRODUCT_HRCUSTOM := true

# Nome do zip de saída: HRCustom-<versao>-<device>.zip
PRODUCT_SYSTEM_NAME := hrcustom
