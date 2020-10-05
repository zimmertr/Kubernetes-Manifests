# Plex Media Server

This application is meant to be deployed to Kubernetes using Kustomize. 

* **Website**: https://www.plex.tv/
* **Container Image:** https://hub.docker.com/r/plexinc/pms-docker

<hr>

## Notes

* The container image requires the volume mounted files to be owned by a single `UID` and `GID` which is set in the Kustomization.yml file.

## Instructions

Plex is a highly personalized application to deploy. Therefore, the `base` will not function in your environment as is. At the very least you will need to provide it several `PersistentVolume` resources to point to your media. This can be done by creating an overlay.

1. Copy `Plex/overlays/example` to `Plex/overlays/myoverlay`.

2. Update the Environmnet Variables present in `kustomization.yml` to reflect your environment. Be sure to obtain a Plex Claim token within 4 minutes of deploying the application or it will expire.

3. Update `svc_tcp.yml` and `svc_udp.yml` according to your environment. My environment exposes each app with a virtual load balancer.

4. Update `pv.yml` and `pvc.yml` to point to all of your personal media. You may add or remove as many volumes as you wish.

5. Update `dep.yml` to point to all of your new Persistent Volumes.

6. Deploy Plex using your custom overlay:

   ```bash
   kubectl apply -k Plex/overlays/myoverlay
   ```
