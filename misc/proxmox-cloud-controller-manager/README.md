# Proxmox Cloud Controller Manager

The [Proxmox CCM](https://github.com/sergelogvinov/proxmox-cloud-controller-manager) gives each node its `providerID` and its zone and region labels, and deletes a node from Kubernetes once its VM is gone. It needs TKS's `cluster.external_cloud_provider` turned on.

1. Create a `kubernetes-ccm@pve` user and token. I use the [bootstrap](https://github.com/zimmertr/TJs-Kubernetes-Service/tree/main/bootstrap) Terraform root in TKS.

2. Copy [configs/config.yaml.example](configs/config.yaml.example) to `configs/config.yaml` and set `token_id` and `token_secret` to the two halves of the token. `config.yaml` is gitignored.

3. Install it before anything else, see [Cloud Controller Manager](../../README.md#cloud-controller-manager) in the root README.
