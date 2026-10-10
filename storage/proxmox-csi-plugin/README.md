# Proxmox CSI Plugin

1. Create a `kubernetes-csi@pve` user and token. I use the [bootstrap](https://github.com/zimmertr/TJs-Kubernetes-Service/tree/main/bootstrap) Terraform root in TKS.

3. Copy [configs/config.yaml.example](configs/config.yaml.example) to `configs/config.yaml` and set `token_id` and `token_secret` to the two halves of the token. `config.yaml` is gitignored.

4. On every new cluster, create the secret from the root README's [Secrets and Volumes](../../README.md#secrets-and-volumes), then label the nodes. The zone is the Proxmox host and the region is the Proxmox cluster:

   ```bash
   NODES=$(kubectl get nodes --no-headers | awk '{print $1}' | paste -sd, -)
   ./bin/label_nodes "$NODES" earth sol-milkyway
   ```
