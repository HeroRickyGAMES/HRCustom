# HRCustom - Configurações gerais (comuns a todos os dispositivos)

# Puxa o branding/versão
include vendor/hrcustom/config/branding.mk

# ---- Identificação do produto ----
PRODUCT_PRODUCT_PROPERTIES += \
    ro.hrcustom.maintainer=HeroRickyGAMES

# ---- Build leve ----
# Remove apps/pacotes pesados herdados; mantém a ROM enxuta.
# (Sobrescreva PRODUCT_PACKAGES nos device trees se precisar add algo.)
WITH_GMS ?= false
TARGET_CORE_JARS_ONLY ?= false

# ---- Bootanimation customizado ----
# A integração real está em vendor/hrcustom/bootanimation/Android.bp
PRODUCT_PACKAGES += \
    bootanimation_hrcustom

# ---- Keybox (attestation, estilo crDroid) ----
# Copiado apenas se o arquivo existir (build não quebra sem ele).
ifneq ($(wildcard vendor/hrcustom/prebuilt/keybox.xml),)
PRODUCT_COPY_FILES += \
    vendor/hrcustom/prebuilt/keybox.xml:$(TARGET_COPY_OUT_VENDOR)/etc/keybox.xml
endif

# ---- IA local nativa ----
PRODUCT_PACKAGES += \
    HRAssistant

# ---- Overlays de identidade ----
PRODUCT_PACKAGE_OVERLAYS += vendor/hrcustom/overlay/common
DEVICE_PACKAGE_OVERLAYS  += vendor/hrcustom/overlay/common
