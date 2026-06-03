package com.hrcustom.assistant.ui;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import com.hrcustom.assistant.R;
import com.hrcustom.assistant.engine.InferenceService;

/**
 * AssistantActivity - UI mínima do HRAssistant.
 * Campo de texto -> envia o prompt -> mostra a resposta do modelo local.
 *
 * Esqueleto: a ligação com o InferenceService via Binder ainda é TODO.
 */
public class AssistantActivity extends Activity {

    private EditText input;
    private TextView output;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_assistant);

        input = findViewById(R.id.input);
        output = findViewById(R.id.output);
        Button send = findViewById(R.id.send);

        // Garante que o serviço de inferência está rodando.
        startForegroundService(new Intent(this, InferenceService.class));

        send.setOnClickListener(v -> {
            String prompt = input.getText().toString().trim();
            if (prompt.isEmpty()) return;
            // TODO: chamar InferenceService.generate() via Binder e
            //       atualizar o output de forma assíncrona.
            output.setText("Processando localmente: " + prompt);
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        // Usuário saiu do assistente: encerra o serviço e libera o modelo da RAM.
        if (isFinishing()) {
            stopService(new Intent(this, InferenceService.class));
        }
    }
}
