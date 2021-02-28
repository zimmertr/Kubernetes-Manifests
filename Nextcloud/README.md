# NextCloud

This application is meant to be deployed to Kubernetes using Kustomize.

<hr>

## Instructions

An example overlay is provided from my environment. Simply create a new overlay using it as an example and deploy it to your environment like so:

   ```bash
    kustomize build NextCloud/overlays/example | kubectl apply -f-
   ```

Don't forget to update the kustomizations and password files according to your environment.
