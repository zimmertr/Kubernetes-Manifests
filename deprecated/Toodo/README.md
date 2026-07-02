# Toodo

This application is meant to be deployed to Kubernetes using Kustomize. 

* **Website**: https://github.com/gobuffalo/toodo
* **Container Image:** https://harbor.tjzimmerman.dev/tks/toodo:demo

<hr>

## Instructions

An example overlay is provided from my environment. Simply create a new overlay using it as an example and deploy it to your environment like so:

   ```bash
    kustomize build Toodo/overlays/example | kubectl apply -f-
   ```
