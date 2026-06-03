# HRCustom - lista de produtos do marble (Poco F5)
# Substitui o lineage_marble.mk original pelo hrcustom_marble.mk.

PRODUCT_MAKEFILES := \
    $(LOCAL_DIR)/hrcustom_marble.mk

COMMON_LUNCH_CHOICES := \
    hrcustom_marble-user \
    hrcustom_marble-userdebug \
    hrcustom_marble-eng
