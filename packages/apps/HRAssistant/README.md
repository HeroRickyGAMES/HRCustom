# HRAssistant — IA local nativa da HRCustom

App de sistema (privilegiado, assinado com a chave da plataforma) que roda
um modelo de linguagem **100% no dispositivo, sem nuvem**.

## Estrutura

```
HRAssistant/
├── Android.bp                         # build (platform_apis, privileged)
├── AndroidManifest.xml                # registra como assistente + FGS
├── res/
│   ├── layout/activity_assistant.xml  # UI mínima
│   └── values/strings.xml
└── src/com/hrcustom/assistant/
    ├── ui/AssistantActivity.java      # tela do assistente
    └── engine/
        ├── InferenceService.java      # foreground service (carrega/roda o modelo)
        ├── LocalEngine.java           # STUB da engine — plugue aqui o modelo real
        └── BootReceiver.java          # sobe o serviço no boot
```

## ⚠️ Falta: ícone

O manifest referencia `@mipmap/ic_launcher`. Adicione um:
`res/mipmap-xxhdpi/ic_launcher.png` (ou use um adaptive icon). Sem ele o build falha.

## Escolher a engine de IA (o ponto principal)

`LocalEngine.java` é um stub. Plugue uma destas (todas offline/on-device):

| Engine | Quando usar | Formato |
|--------|-------------|---------|
| **MediaPipe LLM Inference** | mais fácil, suporta Gemma | `.task` / `.bin` |
| **llama.cpp (JNI)** | mais flexível, leve | `.gguf` |
| **ONNX Runtime Mobile** | modelos quantizados | `.onnx` |

### Recomendação para "build leve"
- Modelo **pequeno e quantizado**: 1B–3B em Q4 (ex.: Gemma 2 2B, Qwen2.5 1.5B, Phi-3-mini).
- **Carregar sob demanda** (download na 1ª execução) em vez de embutir o modelo
  na system partition — senão a ROM incha vários GB.
- Liberar o modelo da RAM quando ocioso (`LocalEngine.release()`).

### Passos para integrar llama.cpp (exemplo)
1. Adicionar o source do llama.cpp como `cc_library` no `Android.bp`.
2. Criar `LlamaEngine` com `native` methods (JNI) e carregar o `.so`.
3. Implementar `load()` / `infer()` / `release()` chamando o nativo.
4. Descomentar o `prebuilt_etc` do modelo no `Android.bp` (ou baixar on-demand).

## Como entra na ROM

Já está em `vendor/hrcustom/config/common.mk`:

```make
PRODUCT_PACKAGES += HRAssistant
```

Vai pra `/system/priv-app/HRAssistant/` no build.
