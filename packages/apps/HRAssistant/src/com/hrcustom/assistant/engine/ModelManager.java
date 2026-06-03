package com.hrcustom.assistant.engine;

import android.content.Context;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;

/**
 * ModelManager - baixa o modelo Qwen2.5 sob demanda (build leve: o GGUF
 * não vai embutido na ROM, é baixado na 1ª execução e fica em files/).
 */
public class ModelManager {

    private static final String TAG = "HRAssistant";

    // Qwen2.5-1.5B-Instruct Q4_K_M (~1 GB). Para aparelho fraco, troque
    // pela variante 0.5B (~400 MB).
    public static final String MODEL_FILE = "qwen2.5-1.5b-instruct-q4_k_m.gguf";
    private static final String MODEL_URL =
        "https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/"
        + "qwen2.5-1.5b-instruct-q4_k_m.gguf";

    /** Caminho local do modelo (exista ou não). */
    public static File modelPath(Context ctx) {
        return new File(ctx.getFilesDir(), MODEL_FILE);
    }

    public static boolean isDownloaded(Context ctx) {
        File f = modelPath(ctx);
        return f.exists() && f.length() > 0;
    }

    /**
     * Baixa o modelo (bloqueante — chame numa thread). Retorna true se OK.
     * @param progress callback opcional de progresso (0..100), pode ser null.
     */
    public static boolean download(Context ctx, ProgressCallback progress) {
        File out = modelPath(ctx);
        File tmp = new File(out.getPath() + ".part");
        try {
            HttpURLConnection conn = (HttpURLConnection) new URL(MODEL_URL).openConnection();
            conn.setConnectTimeout(15000);
            conn.connect();
            int total = conn.getContentLength();

            try (InputStream in = conn.getInputStream();
                 FileOutputStream fos = new FileOutputStream(tmp)) {
                byte[] buf = new byte[1 << 16];
                long done = 0;
                int n;
                while ((n = in.read(buf)) != -1) {
                    fos.write(buf, 0, n);
                    done += n;
                    if (progress != null && total > 0) {
                        progress.onProgress((int) (done * 100 / total));
                    }
                }
            }
            // move atômico só ao terminar (evita arquivo corrompido)
            if (!tmp.renameTo(out)) {
                Log.e(TAG, "Falha ao mover o modelo baixado");
                return false;
            }
            Log.i(TAG, "Modelo Qwen2.5 baixado: " + out.length() + " bytes");
            return true;
        } catch (Exception e) {
            Log.e(TAG, "Erro no download do modelo", e);
            tmp.delete();
            return false;
        }
    }

    public interface ProgressCallback {
        void onProgress(int percent);
    }
}
