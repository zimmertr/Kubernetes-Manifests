# Media

* [Summary](#summary)
* [Instructions](#instructions)
  * [Plex Media Server](#plex-media-server)
  * [Radarr](#radarr)
  * [ruTorrent](#rutorrent)
  * [Sonarr](#sonarr)

<hr>

## Summary

Media is a collection of entertainment applications.

<hr>

## Instructions

### Plex Media Server

[Plex Media Server](https://www.plex.tv/) is a media streaming application.

1. Modify the Kustomize project as per your needs.

2. Update the Claim token using https://plex.tv/claim. 

3. Deploy to Kubernetes:
   ```bash
   kubectl kustomize --enable-helm plex-media-server | kubectl apply -f-
   ```

<hr>

### Radarr

[Radarr](https://radarr.video/) is a movie collection manager.

1. Modify the Kustomize project as per your needs.

2. Deploy to Kubernetes:
   ```bash
   kubectl kustomize --enable-helm radarr | kubectl apply -f-
   ```

<hr>

### ruTorrent

[ruTorrent](https://github.com/Novik/ruTorrent) is a bittorrent client.

1. Modify the Kustomize project as per your needs.

2. Deploy to Kubernetes:
    ```bash
    kubectl kustomize --enable-helm rutorrent | kubectl apply -f-
    ```

<hr>

### Sonarr

[Sonarr](https://sonarr.tv/) is a television collection manager.

1. Modify the Kustomize project as per your needs.

2. Deploy to Kubernetes:
    ```bash
    kubectl kustomize --enable-helm sonarr | kubectl apply -f-
    ```
