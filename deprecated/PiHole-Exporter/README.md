# Pi-Hole Exporter

This application is meant to be deployed to Kubernetes using Kustomize.

* **Website**: https://github.com/eko/pihole-exporter
* **Container Image:** https://hub.docker.com/r/ekofr/pihole-exporter

<hr>

## Notes

* You will need a Prometheus database to use Unifi-Poller. [Here](https://github.com/zimmertr/TKS-Deploy_Grafana) is how I deploy one.

<hr>

## Instructions

An example overlay is provided from my environment. Simply create a new overlay using it as an example and deploy it to your environment like so:

   ```bash
    kustomize build PiHole-Exporter/overlays/example | kubectl apply -f-
   ```

Don't forget to update the environment variables present in `kustomization.yml` and `pihole_exporter_secret_refs` according to your environment. Options are documented [here](https://hub.docker.com/r/ekofr/pihole-exporter).
