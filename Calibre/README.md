# Calibre Web

This application is meant to be deployed to Kubernetes using Kustomize.

* **Calibre Website**: https://calibre-ebook.com/
* **Calibre Web Website**: https://github.com/janeczku/calibre-web

* **Calibre Container Image:** https://hub.docker.com/r/linuxserver/calibre
* **Calibre Web Container Image:** https://hub.docker.com/r/linuxserver/calibre-web

<hr>

## Instructions

An example overlay is provided from my environment. Simply create a new overlay using it as an example and deploy it to your environment like so:

   ```bash
    kustomize build Calibre-Web/overlays/example | kubectl apply -f-
   ```

Don't forget to update the kustomizations and password files according to your environment.
