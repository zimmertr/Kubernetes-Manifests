# llama-swap

[llama-swap](https://github.com/mostlygeek/llama-swap) serves OpenAI and Anthropic compatible APIs on `http://192.168.40.140:8080` from the GPU worker. It starts `llama-server` or `sd-server` for whichever model a request names, swapping the previous one out of VRAM.

1. Create the zvol and the API key secret from the root README's [Secrets and Volumes](../../README.md#secrets-and-volumes).

2. Download models onto the volume. A file's download link is its Hugging Face page with `blob` changed to `resolve`:

   ```bash
   kubectl exec -n llama-swap-system deploy/llama-swap -- \
     curl -fL -o /models/Qwen3-0.6B-Q8_0.gguf \
     https://huggingface.co/Qwen/Qwen3-0.6B-GGUF/resolve/main/Qwen3-0.6B-Q8_0.gguf
   ```

3. Add the model to [configs/config.yaml](configs/config.yaml).

4. Test it:

   ```bash
   curl http://192.168.40.140:8080/v1/chat/completions \
     -H "Authorization: Bearer $LLAMA_SWAP_API_KEY" -H 'Content-Type: application/json' \
     -d '{"model": "qwen3-0.6b", "messages": [{"role": "user", "content": "Hello"}]}'
   ```
