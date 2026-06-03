#!/bin/bash
#
# HRCustom - setup.sh
# Integra o branding HRCustom na árvore de build APÓS o `repo sync`,
# sem versionar nada no device tree. Idempotente: pode rodar quantas vezes quiser.
#
# Uso (da RAIZ da árvore de build, ex: ~/aosp/hrcustom):
#   bash <(curl -s https://raw.githubusercontent.com/HeroRickyGAMES/HRCustom/main/vendor/hrcustom/setup.sh)
#
# Opcional, incluir a IA local (Qwen2.5) — precisa do llama.cpp + ícone:
#   WITH_AI=1 bash <(curl -s .../setup.sh)
#
set -e

HRCUSTOM_REPO="${HRCUSTOM_REPO:-https://github.com/HeroRickyGAMES/HRCustom.git}"
HRCUSTOM_REF="${HRCUSTOM_REF:-main}"
TREE="$(pwd)"
DEVICE_DIR="device/xiaomi/marble"

# Sanidade: precisa estar na raiz de uma árvore sincada
if [ ! -d "$TREE/.repo" ]; then
  echo "ERRO: rode este script da raiz da árvore de build (onde está .repo/)."
  exit 1
fi
if [ ! -d "$TREE/$DEVICE_DIR" ]; then
  echo "ERRO: $DEVICE_DIR não existe. Rode 'repo sync' primeiro."
  exit 1
fi

echo ">> Baixando peças do HRCustom ($HRCUSTOM_REF)..."
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
git clone --depth 1 -b "$HRCUSTOM_REF" "$HRCUSTOM_REPO" "$TMP/hrcustom" >/dev/null 2>&1

echo ">> Copiando vendor/hrcustom (branding, bootanimation, configs)..."
mkdir -p "$TREE/vendor/hrcustom"
rsync -a --delete \
  --exclude '.git' --exclude 'setup.sh' \
  "$TMP/hrcustom/vendor/hrcustom/" "$TREE/vendor/hrcustom/"

# IA local é opcional (quebra o build sem llama.cpp + ícone)
if [ "${WITH_AI:-0}" = "1" ]; then
  echo ">> Incluindo HRAssistant (IA local Qwen2.5)..."
  mkdir -p "$TREE/packages/apps"
  rsync -a "$TMP/hrcustom/packages/apps/HRAssistant/" "$TREE/packages/apps/HRAssistant/"
  export HRCUSTOM_WITH_AI=true
else
  echo ">> Pulando HRAssistant (use WITH_AI=1 pra incluir)."
fi

echo ">> Injetando produto hrcustom_marble no device tree..."
cp "$TMP/hrcustom/$DEVICE_DIR/hrcustom_marble.mk" "$TREE/$DEVICE_DIR/hrcustom_marble.mk"

AP="$TREE/$DEVICE_DIR/AndroidProducts.mk"
if ! grep -q "hrcustom_marble.mk" "$AP"; then
  cat >> "$AP" <<'EOF'

# --- HRCustom (injetado por setup.sh; não comitar no DT) ---
PRODUCT_MAKEFILES += $(LOCAL_DIR)/hrcustom_marble.mk
COMMON_LUNCH_CHOICES += hrcustom_marble-userdebug hrcustom_marble-user
EOF
  echo "   registrado em AndroidProducts.mk"
else
  echo "   já registrado (idempotente)"
fi

echo ""
echo "OK! Branding HRCustom integrado. Agora builde:"
echo "  source build/envsetup.sh"
echo "  brunch hrcustom_marble"
