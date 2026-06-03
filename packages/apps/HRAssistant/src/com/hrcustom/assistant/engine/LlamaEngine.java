package com.hrcustom.assistant.engine;

import android.util.Log;

/**
 * LlamaEngine - binding JNI para o llama.cpp rodando o Qwen2.5 (GGUF).
 *
 * Os métodos native são implementados em jni/llama_jni.cpp e linkados
 * na lib nativa "hrassistant_llama" (ver Android.bp).
 *
 * Modelo padrão: Qwen2.5-1.5B-Instruct, quantização Q4_K_M (~1 GB).
 * Para aparelhos mais fracos, troque por Qwen2.5-0.5B-Instruct (~400 MB).
 */
public class LlamaEngine {

    private static final String TAG = "HRAssistant";

    static {
        try {
            System.loadLibrary("hrassistant_llama");
        } catch (UnsatisfiedLinkError e) {
            Log.e(TAG, "Falha ao carregar libhrassistant_llama.so", e);
        }
    }

    // Ponteiro nativo (handle) para o contexto do modelo. 0 = não carregado.
    private long ctx = 0;

    /** Carrega o GGUF do caminho informado. Retorna true se OK. */
    public boolean load(String modelPath, int nThreads, int nCtx) {
        ctx = nativeInit(modelPath, nThreads, nCtx);
        boolean ok = ctx != 0;
        Log.i(TAG, "Qwen2.5 carregado=" + ok + " (" + modelPath + ")");
        return ok;
    }

    public boolean isReady() {
        return ctx != 0;
    }

    /**
     * Gera uma resposta. Aplica o chat template do Qwen2.5 internamente.
     * @param maxTokens limite de tokens gerados (ex.: 256)
     */
    public String infer(String prompt, int maxTokens) {
        if (ctx == 0) return null;
        String formatted = applyChatTemplate(prompt);
        return nativeInfer(ctx, formatted, maxTokens);
    }

    public void release() {
        if (ctx != 0) {
            nativeFree(ctx);
            ctx = 0;
        }
    }

    /** Chat template do Qwen2.5 (ChatML). */
    private String applyChatTemplate(String userMsg) {
        return "<|im_start|>system\nVocê é o HRAssistant, a IA local da HRCustom. "
             + "Responda em português, de forma direta.<|im_end|>\n"
             + "<|im_start|>user\n" + userMsg + "<|im_end|>\n"
             + "<|im_start|>assistant\n";
    }

    // ---- métodos nativos (jni/llama_jni.cpp) ----
    private native long   nativeInit(String modelPath, int nThreads, int nCtx);
    private native String nativeInfer(long ctx, String prompt, int maxTokens);
    private native void   nativeFree(long ctx);
}
