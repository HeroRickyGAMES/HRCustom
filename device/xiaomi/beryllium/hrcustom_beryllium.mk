# HRCustom - product do beryllium (Poco F1)
# Lunch: brunch hrcustom_beryllium

# Base AOSP (64-bit + telefonia)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Config do dispositivo
$(call inherit-product, device/xiaomi/beryllium/device.mk)

# Base comum do LineageOS
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Branding + configs da HRCustom
$(call inherit-product, vendor/hrcustom/build/target/product/hrcustom.mk)

# Identificação do produto
PRODUCT_NAME := hrcustom_beryllium
PRODUCT_DEVICE := beryllium
PRODUCT_BRAND := HRCustom
PRODUCT_MODEL := POCO F1
PRODUCT_MANUFACTURER := Xiaomi

# Props "system" espelhando a Xiaomi (necessário pros blobs)
PRODUCT_SYSTEM_NAME := beryllium
PRODUCT_SYSTEM_DEVICE := beryllium
PRODUCT_SYSTEM_BRAND := Xiaomi
PRODUCT_SYSTEM_MODEL := POCO F1
PRODUCT_SYSTEM_MANUFACTURER := Xiaomi

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi

BUILD_FINGERPRINT := $(PRODUCT_OVERRIDE_FINGERPRINT)
