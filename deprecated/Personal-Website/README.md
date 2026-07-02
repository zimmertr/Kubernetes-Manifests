# My Personal Website

This application is meant to be deployed to Kubernetes using Kustomize. 

* **Website**: https://tjzimmerman.com
* **Container Images:** https://hub.docker.com/u/zimmertr

<hr>


## Instructions

An example overlay is provided from my environment. Simply create a new overlay using it as an example and deploy it to your environment like so:

   ```bash
    kustomize build Personal-Website/overlays/example | kubectl apply -f-
   ```
