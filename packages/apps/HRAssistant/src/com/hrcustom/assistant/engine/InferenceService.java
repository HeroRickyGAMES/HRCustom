package com.hrcustom.assistant.engine;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.util.Log;

/**
 * InferenceService - roda o modelo de IA local em foreground.
 *
 * Este é o esqueleto. A inferência real depende da engine escolhida
 * (llama.cpp via JNI, MediaPipe LLM Inference API, ONNX Runtime, etc.).
 * Veja src/.../engine/README sobre como plugar o modelo.
 */
public class InferenceService extends Service {

    private static final String TAG = "HRAssistant";
    private static final String CHANNEL_ID = "hrassistant_inference";
    private static final int NOTIF_ID = 1001;

    // Substituir por um wrapper real da engine (ex.: LlamaEngine).
    private LocalEngine engine;

    @Override
    public void onCreate() {
        super.onCreate();
        createChannel();
        startForeground(NOTIF_ID, buildNotification("HRAssistant ativo"));

        // Carrega o modelo de forma assíncrona pra não travar o boot.
        new Thread(() -> {
            engine = new LocalEngine(this);
            boolean ok = engine.load();
            Log.i(TAG, "Modelo Qwen2.5 carregado: " + ok);
        }, "hrassistant-load").start();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        // START_NOT_STICKY: NÃO recria sozinho. A IA só vive enquanto o
        // usuário está usando o assistente (build leve, sem consumo ocioso).
        return START_NOT_STICKY;
    }

    /**
     * Gera uma resposta a partir de um prompt. Chamado pela UI/assistente.
     */
    public String generate(String prompt) {
        if (engine == null || !engine.isReady()) {
            return "Modelo ainda carregando…";
        }
        return engine.infer(prompt);
    }

    @Override
    public void onDestroy() {
        if (engine != null) engine.release();
        super.onDestroy();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null; // TODO: expor Binder local pra UI conversar com o serviço.
    }

    private void createChannel() {
        NotificationChannel ch = new NotificationChannel(
                CHANNEL_ID, "HRAssistant", NotificationManager.IMPORTANCE_LOW);
        getSystemService(NotificationManager.class).createNotificationChannel(ch);
    }

    private Notification buildNotification(String text) {
        return new Notification.Builder(this, CHANNEL_ID)
                .setContentTitle("HRAssistant")
                .setContentText(text)
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setOngoing(true)
                .build();
    }
}
