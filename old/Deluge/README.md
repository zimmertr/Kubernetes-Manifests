# Deluge

This application is meant to be deployed to Kubernetes using Kustomize. 

* **Website**: https://deluge-torrent.org/
* **Container Image:** https://hub.docker.com/r/linuxserver/deluge

<hr>

## Notes

* The container image requires the volume mounted files to be owned by a single `UID` and `GID` which is set in the Kustomization.yml file.

<hr>

## Instructions

An example overlay is provided from my environment. Simply create a new overlay using it as an example and deploy it to your environment like so:

   ```bash
    kustomize build Deluge/overlays/example | kubectl apply -f-
   ```
