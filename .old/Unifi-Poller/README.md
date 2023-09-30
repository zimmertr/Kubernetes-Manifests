# Unifi Poller

This application is meant to be deployed to Kubernetes using Kustomize.

* **Website**: https://github.com/unifi-poller/unifi-poller
* **Container Image:** https://hub.docker.com/r/golift/unifi-poller

<hr>

## Notes

* You will need an InfluxDB or Prometheus database to use Unifi-Poller. [Here](https://github.com/zimmertr/TKS-Deploy_Grafana) is how I deploy those.

<hr>

## Instructions

An example overlay is provided from my environment. Simply create a new overlay using it as an example and deploy it to your environment like so:

   ```bash
    kustomize build Unifi-Poller/overlays/example | kubectl apply -f-
   ```

Don't forget to update the environment variables present in `kustomization.yml` and `unifi_poller_secret_refs` according to your environment. More options are documented [here](https://github.com/unifi-poller/unifi-poller/wiki/Configuration).
