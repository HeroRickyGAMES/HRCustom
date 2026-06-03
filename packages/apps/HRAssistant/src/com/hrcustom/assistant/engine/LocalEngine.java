package com.hrcustom.assistant.engine;

import android.content.Context;
import android.util.Log;

/**
 * LocalEngine - orquestra a IA local do HRCustom.
 * Garante que o modelo Qwen2.5 está baixado e delega a inferência
 * para a LlamaEngine (llama.cpp via JNI).
 */
public class LocalEngine {

    private static final String TAG = "HRAssistant";

    private final Context ctx;
    private final LlamaEngine llama = new LlamaEngine();

    public LocalEngine(Context ctx) {
        this.ctx = ctx.getApplicationContext();
    }

    /** Baixa (se preciso) e carrega o modelo. Bloqueante: chame numa thread. */
    public boolean load() {
        if (!ModelManager.isDownloaded(ctx)) {
            Log.i(TAG, "Modelo ausente, baixando Qwen2.5…");
            boolean ok = ModelManager.download(ctx,
                    p -> Log.i(TAG, "Download: " + p + "%"));
            if (!ok) return false;
        }

        String path = ModelManager.modelPath(ctx).getAbsolutePath();
        // 4 threads e contexto de 2048 tokens: equilíbrio leveza/qualidade.
        int threads = Math.max(2, Runtime.getRuntime().availableProcessors() / 2);
        return llama.load(path, threads, 2048);
    }

    public boolean isReady() {
        return llama.isReady();
    }

    public String infer(String prompt) {
        if (!llama.isReady()) return "Modelo ainda carregando…";
        String resp = llama.infer(prompt, 256);
        return resp != null ? resp.trim() : "(sem resposta)";
    }

    public void release() {
        llama.release();
    }
}
