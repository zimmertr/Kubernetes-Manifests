# Varken

This application is meant to be deployed to Kubernetes using Kustomize.

* **Website**: https://github.com/Boerderij/Varken
* **Container Image:** https://hub.docker.com/r/boerderij/varken

<hr>

## Notes

* You will need an InfluxDB to use Varken. [Here](https://github.com/zimmertr/TKS-Deploy_Grafana) is how I deploy one.
* You will need a MaxMind License Key if you want to monitor Tautulli. They are free to generate. [Here](https://www.maxmind.com/en/geolite2/signup) is where you make one.

<hr>

## Instructions

An example overlay is provided from my environment. Simply create a new overlay using it as an example and deploy it to your environment like so:

   ```bash
    kustomize build Varken/overlays/example | kubectl apply -f-
   ```

Don't forget to update the environment variables present in `kustomization.yml` and `varken_secret_refs` according to your environment. More options are documented [here](https://wiki.cajun.pro/books/varken/page/breakdown).
