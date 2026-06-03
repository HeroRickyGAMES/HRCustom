// HRAssistant - ponte JNI para o llama.cpp (Qwen2.5 GGUF)
//
// Implementa os native methods de LlamaEngine.java.
// Linka contra a libllama (llama.cpp) compilada como cc_library no Android.bp.

#include <jni.h>
#include <string>
#include <vector>
#include <android/log.h>

#include "llama.h"

#define LOG_TAG "HRAssistant-JNI"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

// Estado de um modelo carregado.
struct LlamaCtx {
    llama_model*   model = nullptr;
    llama_context* lctx  = nullptr;
};

extern "C" {

JNIEXPORT jlong JNICALL
Java_com_hrcustom_assistant_engine_LlamaEngine_nativeInit(
        JNIEnv* env, jobject, jstring jPath, jint nThreads, jint nCtx) {

    const char* path = env->GetStringUTFChars(jPath, nullptr);

    llama_backend_init();

    llama_model_params mparams = llama_model_default_params();
    // n_gpu_layers = 0 -> CPU. Para acelerar via GPU (Adreno/OpenCL),
    // compile o llama.cpp com backend adequado e ajuste aqui.
    mparams.n_gpu_layers = 0;

    llama_model* model = llama_model_load_from_file(path, mparams);
    env->ReleaseStringUTFChars(jPath, path);
    if (!model) {
        LOGE("Falha ao carregar o modelo");
        return 0;
    }

    llama_context_params cparams = llama_context_default_params();
    cparams.n_ctx     = (uint32_t) nCtx;
    cparams.n_threads = nThreads;

    llama_context* lctx = llama_init_from_model(model, cparams);
    if (!lctx) {
        LOGE("Falha ao criar o contexto");
        llama_model_free(model);
        return 0;
    }

    auto* c = new LlamaCtx{model, lctx};
    LOGI("Modelo Qwen2.5 inicializado (n_ctx=%d, threads=%d)", nCtx, nThreads);
    return reinterpret_cast<jlong>(c);
}

JNIEXPORT jstring JNICALL
Java_com_hrcustom_assistant_engine_LlamaEngine_nativeInfer(
        JNIEnv* env, jobject, jlong handle, jstring jPrompt, jint maxTokens) {

    auto* c = reinterpret_cast<LlamaCtx*>(handle);
    if (!c) return env->NewStringUTF("");

    const char* prompt = env->GetStringUTFChars(jPrompt, nullptr);
    const llama_vocab* vocab = llama_model_get_vocab(c->model);

    // Tokeniza o prompt.
    int n_prompt = -llama_tokenize(vocab, prompt, strlen(prompt), nullptr, 0, true, true);
    std::vector<llama_token> tokens(n_prompt);
    llama_tokenize(vocab, prompt, strlen(prompt), tokens.data(), tokens.size(), true, true);
    env->ReleaseStringUTFChars(jPrompt, prompt);

    // Sampler simples (greedy + temperatura). Ajuste pra qualidade.
    llama_sampler* smpl = llama_sampler_chain_init(llama_sampler_chain_default_params());
    llama_sampler_chain_add(smpl, llama_sampler_init_temp(0.7f));
    llama_sampler_chain_add(smpl, llama_sampler_init_dist(LLAMA_DEFAULT_SEED));

    std::string out;
    llama_batch batch = llama_batch_get_one(tokens.data(), tokens.size());

    for (int i = 0; i < maxTokens; i++) {
        if (llama_decode(c->lctx, batch)) {
            LOGE("llama_decode falhou");
            break;
        }
        llama_token tok = llama_sampler_sample(smpl, c->lctx, -1);
        if (llama_vocab_is_eog(vocab, tok)) break; // fim de geração

        char buf[256];
        int n = llama_token_to_piece(vocab, tok, buf, sizeof(buf), 0, true);
        if (n > 0) out.append(buf, n);

        batch = llama_batch_get_one(&tok, 1);
    }

    llama_sampler_free(smpl);
    return env->NewStringUTF(out.c_str());
}

JNIEXPORT void JNICALL
Java_com_hrcustom_assistant_engine_LlamaEngine_nativeFree(
        JNIEnv*, jobject, jlong handle) {
    auto* c = reinterpret_cast<LlamaCtx*>(handle);
    if (!c) return;
    if (c->lctx)  llama_free(c->lctx);
    if (c->model) llama_model_free(c->model);
    delete c;
}

} // extern "C"
