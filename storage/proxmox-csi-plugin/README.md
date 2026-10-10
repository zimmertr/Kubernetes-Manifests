# Proxmox CSI Plugin

The [Proxmox CSI Plugin](https://github.com/sergelogvinov/proxmox-csi-plugin) provisions volumes from Proxmox storage and attaches them to the node a pod runs on. It talks to Proxmox with an API token, and places volumes using each node's zone and region labels.

1. Make sure you have a Proxmox cluster. Single-node clusters work. I create mine with my [configure_cluster](https://github.com/zimmertr/Bootstrap-Proxmox/tree/main/roles/configure_cluster) Ansible role.

2. Create the `kubernetes-csi@pve` user and token with the [bootstrap](https://github.com/zimmertr/TJs-Kubernetes-Service/tree/main/bootstrap) Terraform root in TKS. `terraform output -json api_tokens | jq` prints the token as `<token_id>=<token_secret>`.

3. Copy [configs/config.yaml.example](configs/config.yaml.example) to `configs/config.yaml` and set `token_id` and `token_secret` to the two halves of the token. `config.yaml` is gitignored.

4. On every new cluster, create the secret from the root README's [Secrets and Volumes](../../README.md#secrets-and-volumes), then label the nodes. The zone is the Proxmox host and the region is the Proxmox cluster:

   ```bash
   NODES=$(kubectl get nodes --no-headers | awk '{print $1}' | paste -sd, -)
   ./bin/label_nodes "$NODES" earth sol-milkyway
   ```
