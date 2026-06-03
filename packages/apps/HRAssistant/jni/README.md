# HRAssistant JNI — llama.cpp (Qwen2.5)

`llama_jni.cpp` é a ponte entre `LlamaEngine.java` e o **llama.cpp**.
Para compilar, o `libllama` precisa existir como módulo Soong na árvore.

## Opção 1 (recomendada): llama.cpp no manifest

1. Adicione ao `.repo/manifests/default.xml` (ou local_manifest):

```xml
<project path="external/llama.cpp"
         name="ggml-org/llama.cpp"
         remote="github" revision="master"
         clone-depth="1" />
```

> Dica: fixe um commit estável em `revision` para builds reproduzíveis,
> já que a API do llama.cpp muda com frequência.

2. Crie `external/llama.cpp/Android.bp` compilando o ggml + llama como
   `cc_library_shared` chamado **`libllama`**, exportando os headers
   (`llama.h`, `ggml.h`). O `Android.bp` do HRAssistant já depende dele.

## Opção 2: prebuilt .so

Se preferir não compilar na árvore, gere `libllama.so` (arm64-v8a) com o NDK
e adicione como prebuilt:

```
cc_prebuilt_library_shared {
    name: "libllama",
    srcs: ["prebuilt/arm64-v8a/libllama.so"],
    export_include_dirs: ["prebuilt/include"],
    compile_multilib: "64",
}
```

## API do llama.cpp

`llama_jni.cpp` usa a API nova (`llama_model_load_from_file`,
`llama_init_from_model`, `llama_sampler_*`). Se você fixar um commit antigo,
ajuste os nomes das funções conforme a versão.

## Modelo

O GGUF **não** é compilado aqui. O `ModelManager.java` baixa o
`qwen2.5-1.5b-instruct-q4_k_m.gguf` do Hugging Face na 1ª execução,
para `files/`. Aparelho fraco → troque pela variante 0.5B no `ModelManager`.

## Aceleração por GPU (opcional)

Em `llama_jni.cpp`, `n_gpu_layers = 0` (CPU). O Poco F5 tem Adreno 725;
para usar GPU, compile o llama.cpp com backend OpenCL/Vulkan e suba esse valor.
