# HRCustom - product do marble (Poco F5)
#
# Equivale ao lineage_marble.mk, mas herda o branding/configs da HRCustom.
# Lunch: brunch hrcustom_marble  (ou breakfast hrcustom_marble)

# Base AOSP (64-bit + telefonia)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Config do dispositivo (BoardConfig, blobs, HALs do marble)
$(call inherit-product, device/xiaomi/marble/device.mk)

# Base comum do LineageOS (mantém a stack do Lineage por baixo)
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Branding + configs da HRCustom (brand, fingerprint, bootanim, IA, keybox)
$(call inherit-product, vendor/hrcustom/build/target/product/hrcustom.mk)

# Identificação do produto
PRODUCT_NAME := hrcustom_marble
PRODUCT_DEVICE := marble
PRODUCT_BRAND := HRCustom
PRODUCT_MODEL := 23013RK75C
PRODUCT_MANUFACTURER := Xiaomi

# Espelha a identidade da Xiaomi nas props "system" (necessário para
# os blobs/sensores funcionarem), mas a marca visível é HRCustom.
PRODUCT_SYSTEM_NAME := marble
PRODUCT_SYSTEM_DEVICE := marble
PRODUCT_SYSTEM_BRAND := Xiaomi
PRODUCT_SYSTEM_MODEL := 23013RK75C
PRODUCT_SYSTEM_MANUFACTURER := Xiaomi

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi

# Build info (o fingerprint final vem do branding.mk da HRCustom)
BUILD_FINGERPRINT := $(PRODUCT_OVERRIDE_FINGERPRINT)
