# Streetmerchant

This application is meant to be deployed to Kubernetes using Kustomize.

* **Website**: https://github.com/jef/streetmerchant
* **Container Image:** ghcr.io/jef/streetmerchant:nightly

<hr>

## Notes

* Be sure to modify the environment variables in the deployment manifest. I tried to put them in the kustomization yaml and pass them in via `envFrom` and a `SecretGenerator` but it didn't work. :shrug:

<hr>

## Instructions

An example overlay is provided from my environment. Simply create a new overlay using it as an example and deploy it to your environment like so:

   ```bash
    kustomize apply -k StreetMerchant
   ```
