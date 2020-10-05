# Tautulli

This application is meant to be deployed to Kubernetes using Kustomize. 

* **Website**: https://tautulli.com/
* **Container Image:** https://hub.docker.com/r/linuxserver/tautulli

<hr>

## Notes

* The container image requires the volume mounted files to be owned by a single `UID` and `GID` which is set in the Kustomization.yml file.
* My deployment of Tatulli assumes I want to monitor a Plex log directory. I assume yours does to. So you will need to modify the `pv.yml` to point to your specific storage location. Furthermore, you will need to modify the `svc.yml` according to your network configuration.


<hr>

## Instructions

An example overlay is provided from my environment. Simply create a new overlay using it as an example and deploy it to your environment like so:

   ```bash
    kustomize build Tautulli/overlays/example | kubectl apply -f-
   ```
