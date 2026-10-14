# Open WebUI

[Open WebUI](https://github.com/open-webui/open-webui) is the chat interface for [llama-swap](../llama-swap). It runs on the general workers at `http://192.168.40.141`, talks to llama-swap with its own API key, and uses `z-image-turbo` to generate images and `qwen-image-2.1` to edit them.

Its settings come from [values.yml](values.yml) and apply on every start, so Git is the source of truth. Changes made in the admin panel last until the next restart.

1. Create the `FlashPool/vm-9999-Open-WebUI-Data` volume and the Secrets, see [Secrets and Volumes](../../README.md#secrets-and-volumes) in the root README. The `open-webui-admin` Secret is the admin account; nobody else can sign up.

2. To generate an image, ask for one in a chat. To edit one, attach a photo and say what to change. Both come out at 1024x1024 unless you name a size; a phone photo's own resolution is more than the GPU can edit.
