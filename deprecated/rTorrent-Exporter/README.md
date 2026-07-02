# rTorrent Exporter

This application is meant to be deployed to Kubernetes using Kustomize.

* **Website**: https://github.com/mdlayher/rtorrent_exporter
* **Container Image:** https://hub.docker.com/repository/docker/zimmertr/rtorrent-exporter

<hr>

## Notes

* You will need a Prometheus database to use the rTorrent Exporter.
* You will need an instance of rTorrent to use the rTorrent Exporter.

<hr>

## Instructions

An example overlay is provided from my environment. Simply create a new overlay using it as an example and deploy it to your environment like so:

   ```bash
    kustomize build rTorrent-Exporter/overlays/example | kubectl apply -f-
   ```

Don't forget to update the deployment arguments according to your environment. Options are documented [here](https://github.com/mdlayher/rtorrent_exporter/blob/6da5c490c27c2832bf4412510bd66edc14f9171b/cmd/rtorrent_exporter/main.go#L15).
