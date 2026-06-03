# Keybox (attestation) - estilo crDroid

O keybox é usado para **Hardware-backed Key Attestation** / Play Integrity.
Ele NÃO vai versionado no GitHub (é secreto e geralmente revogado se vazar).

## Como funciona aqui

`vendor/hrcustom/config/common.mk` copia o arquivo **apenas se existir**:

```make
ifneq ($(wildcard vendor/hrcustom/prebuilt/keybox.xml),)
PRODUCT_COPY_FILES += \
    vendor/hrcustom/prebuilt/keybox.xml:$(TARGET_COPY_OUT_VENDOR)/etc/keybox.xml
endif
```

Ou seja: o build funciona **sem** o keybox. Você adiciona quando tiver.

## Adicionar seu keybox

1. Obtenha um `keybox.xml` válido (formato AOSP keybox).
2. Salve como `vendor/hrcustom/prebuilt/keybox.xml`.
3. Rebuild.

## Formato esperado (keybox.xml)

```xml
<?xml version="1.0"?>
<AndroidAttestation>
  <NumberOfKeyboxes>1</NumberOfKeyboxes>
  <Keybox DeviceID="...">
    <Key algorithm="ecdsa">
      <PrivateKey format="pem">...</PrivateKey>
      <CertificateChain>
        <NumberOfCertificates>...</NumberOfCertificates>
        <Certificate format="pem">...</Certificate>
      </CertificateChain>
    </Key>
    <Key algorithm="rsa">...</Key>
  </Keybox>
</AndroidAttestation>
```

## .gitignore (IMPORTANTE)

Garanta que o repo `vendor_hrcustom` tenha:

```
prebuilt/keybox.xml
```

> ⚠️ Nunca commite um keybox real. Se vazar, é revogado pelo Google e para de funcionar.
