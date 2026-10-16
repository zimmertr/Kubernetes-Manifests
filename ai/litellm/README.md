# LiteLLM

[LiteLLM](https://github.com/BerriAI/litellm) is a gateway between Claude Code and the models. It routes each request by its model id: Claude models go to Anthropic on the caller's own claude.ai login, and local models go to [llama-swap](../llama-swap). One Claude Code session can then keep Claude as its main model and hand work to a local model as a subagent.

It serves `http://192.168.40.142:4000`. Every request needs `x-litellm-api-key: Bearer <key>`, with the key from the `litellm-master-key` Secret.

Its dashboard at `http://192.168.40.142:4000/ui` shows every request, with its model, latency and tokens. Sign in as `admin` with the master key. The dashboard and the request logs live in a PostgreSQL instance beside it, on a static volume.

1. Create the volume and the Secrets, see [Secrets and Volumes](../../README.md#secrets-and-volumes) in the root README.

2. Routes are declared in [configs/config.yaml](configs/config.yaml). A local model is an `openai/` route to llama-swap with LiteLLM's llama-swap key. Never make it an `anthropic/` route: LiteLLM would forward the caller's claude.ai login to llama-swap in place of that key.

3. Point Claude Code at it. Don't set `ANTHROPIC_API_KEY` or `ANTHROPIC_AUTH_TOKEN`: either replaces the claude.ai login, and Claude usage is then billed per token to that key.

   ```bash
   export ANTHROPIC_BASE_URL=http://192.168.40.142:4000
   export ANTHROPIC_CUSTOM_HEADERS="x-litellm-api-key: Bearer $(kubectl -n litellm-system get secret litellm-master-key -o jsonpath='{.data.master-key}' | base64 -d)"
   export CLAUDE_CODE_MAX_CONTEXT_TOKENS=262144
   claude
   ```

   `CLAUDE_CODE_MAX_CONTEXT_TOKENS` applies only to models whose ids don't start with `claude-`, so Claude keeps its own context size.

4. Give a subagent a local model by its llama-swap name, for example `~/.claude/agents/qwen-coder.md`:

   ```markdown
   ---
   name: qwen-coder
   description: Local Qwen coding worker. Give it a precise plan; it edits files, runs the tests and reports back.
   model: qwen3.6-35b-a3b
   tools: Read, Edit, Write, Bash, Grep, Glob
   ---

   Carry out exactly the plan you're given, run the tests, and report the files you changed and the test results.
   ```

   Claude starts it like any other subagent and sends it follow-ups with `SendMessage`. Claude Code logs `unrecognized_model` for the local model id, which is harmless. Remote Control is unavailable while `ANTHROPIC_BASE_URL` points here.

llama-swap loads one model at a time with one slot, so local subagents queue rather than run side by side.
