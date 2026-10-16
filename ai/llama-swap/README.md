# llama-swap

[llama-swap](https://github.com/mostlygeek/llama-swap) runs language models with `llama-server` and image models with `sd-server` on the GPU node, loading whichever model a request names and unloading the previous one. Only one model is loaded at a time. The coding model is preloaded at startup, and loads again about ten seconds after a request for it follows an image request.

It serves `http://192.168.40.140:8080`:

| Path | What it is |
|---|---|
| `/v1/chat/completions`, `/v1/models` | OpenAI API, with streaming and tool calls |
| `/v1/messages`, `/v1/messages/count_tokens` | Anthropic API, so Claude Code can use it |
| `/v1/images/generations`, `/v1/images/edits` | OpenAI images API, served by `sd-server` |
| `/ui/` | Playground, logs, and GPU performance graphs |
| `/metrics`, `/upstream/<model>/metrics` | Prometheus metrics: host and GPU stats from llama-swap, tokens and requests from the loaded model's `llama-server` |

Every request needs `Authorization: Bearer <key>`, with the key from the `llama-swap-api-key` Secret. Open WebUI and [LiteLLM](../litellm) each have their own key so they can be revoked on their own.

1. Create the `FlashPool/vm-9999-AI-Models` volume and the Secrets, see [Secrets and Volumes](../../README.md#secrets-and-volumes) in the root README. The Hugging Face token is only needed for gated repos.

2. Models are declared in [configs/config.yaml](configs/config.yaml). A language model names its Hugging Face repo and quant with `-hf user/repo:QUANT` on its own line. An image model gives `sd-server` file paths under `/models/hf/user/repo/`, which map to files in that Hugging Face repo. The `model-downloader` sidecar fetches whatever the config names into `/models`, verifies each file's SHA-256, and logs each download's progress and where it put it. llama-swap starts straight away; a model still downloading fails until it's there.

   Ideogram 4 only reads its JSON caption schema; a plain sentence comes back as a "blocked by safety filter" banner. Ideogram's [prompting guide](https://github.com/ideogram-oss/ideogram4/blob/main/docs/prompting.md) has the schema and the system prompt that turns a sentence into a caption, which any chat model here can run.

3. Models I don't want in Git go in an optional ConfigMap, which the downloader and llama-swap both watch:

   ```bash
   kubectl create configmap llama-swap-extra-config -n llama-swap-system --from-file=extra.yaml
   ```

   `extra.yaml` uses the same format and macros as `config.yaml`:

   ```yaml
   models:
     "some-model":
       cmd: |
         ${llama-server-coding}
         -hf user/repo:Q4_K_M
   ```

4. A model removed from both configs is deleted from `/models` once it has been unused for 72 hours. The downloader's log names each unused file and the date it goes, and a model declared again before then is kept.

5. Grafana's `llama-swap` dashboard shows the loaded model, requests, prompt and generation speed, and the GPU's VRAM, activity, temperature, power and clocks. The model numbers come from `llama-server`, scraped through `/upstream/<model>/metrics` by the [ServiceMonitor](resources/serviceMonitor.yml), so a language model added to `config.yaml` also needs an endpoint there. Only the loaded model answers; the others show as down in Prometheus, which is expected.

6. To use it from Claude Code, point it at llama-swap and map every model name to the one you want, since llama-swap rejects names it doesn't know. All requests in that session go to the local model:

   ```bash
   export ANTHROPIC_BASE_URL=http://192.168.40.140:8080
   export ANTHROPIC_AUTH_TOKEN=$(kubectl -n llama-swap-system get secret llama-swap-api-key -o jsonpath='{.data.api-key}' | base64 -d)
   export ANTHROPIC_MODEL=qwen3.6-35b-a3b ANTHROPIC_DEFAULT_OPUS_MODEL=qwen3.6-27b ANTHROPIC_DEFAULT_SONNET_MODEL=qwen3.6-35b-a3b ANTHROPIC_DEFAULT_HAIKU_MODEL=qwen3.6-35b-a3b ANTHROPIC_DEFAULT_FABLE_MODEL=qwen3.6-35b-a3b CLAUDE_CODE_SUBAGENT_MODEL=qwen3.6-35b-a3b
   export CLAUDE_CODE_ATTRIBUTION_HEADER=0 CLAUDE_CODE_MAX_CONTEXT_TOKENS=262144 CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
   claude
   ```

   With those mappings, `/model sonnet` is the 35B and `/model opus` is the 27B.

   To keep Claude in the same session and hand work to a local model as a subagent, go through [LiteLLM](../litellm) instead.
