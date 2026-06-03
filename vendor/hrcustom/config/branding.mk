# HRCustom - Branding
# Nome, versão, build type e identidade da ROM.

# ---- Versão ----
HRCUSTOM_VERSION_MAJOR := 1
HRCUSTOM_VERSION_MINOR := 0
HRCUSTOM_BUILD_TYPE    := UNOFFICIAL
HRCUSTOM_CODENAME      := Genesis

# String final de versão: ex. HRCustom-1.0-Genesis-marble-UNOFFICIAL
HRCUSTOM_VERSION := HRCustom-$(HRCUSTOM_VERSION_MAJOR).$(HRCUSTOM_VERSION_MINOR)-$(HRCUSTOM_CODENAME)-$(TARGET_DEVICE)-$(HRCUSTOM_BUILD_TYPE)

# Nome do arquivo de saída
HRCUSTOM_BUILD := $(HRCUSTOM_VERSION)

# ---- Identidade do produto ----
PRODUCT_PROPERTY_OVERRIDES += \
    ro.product.brand=HRCustom \
    ro.product.manufacturer=HRCustom \
    ro.hrcustom.version=$(HRCUSTOM_VERSION) \
    ro.hrcustom.build.type=$(HRCUSTOM_BUILD_TYPE) \
    ro.modversion=$(HRCUSTOM_VERSION)

# Sobrescreve o display id (substitui o do LineageOS)
PRODUCT_BUILD_PROP_OVERRIDES += \
    BUILD_DISPLAY_ID="$(HRCUSTOM_VERSION)"

# ---- Build fingerprint customizado ----
# Mantém formato Android válido para passar SafetyNet/Play Integrity básico.
# Ajuste BUILD_ID/incremental conforme o dispositivo certificado que quer espelhar.
PRODUCT_OVERRIDE_FINGERPRINT := HRCustom/$(TARGET_DEVICE)/$(TARGET_DEVICE):16/BP1A.250505.005/$(shell date +%Y%m%d):user/release-keys

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_NAME=$(TARGET_DEVICE) \
    PRIVATE_BUILD_DESC="$(TARGET_DEVICE)-user 16 BP1A.250505.005 $(shell date +%Y%m%d) release-keys"

BUILD_FINGERPRINT := $(PRODUCT_OVERRIDE_FINGERPRINT)
