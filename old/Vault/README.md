# Vault

This application is meant to be deployed to Kubernetes using Kustomize.

<hr>

## Instructions

An example overlay is provided from my environment. Simply create a new overlay using it as an example and deploy it to your environment like so:

   ```bash
    kustomize build Vault/overlays/example | kubectl apply -f-
   ```

Start the pod and let Vault intialize the configuration directory. Shut it down and move `vaualt.hcl` into place at `vault/config/`. Restart the pod to apply your configuration file. 
