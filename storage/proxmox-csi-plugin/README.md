# Proxmox CSI Plugin

Needs a Proxmox cluster. I create mine with [configure_cluster](https://github.com/zimmertr/Bootstrap-Proxmox/tree/main/roles/configure_cluster).

1. Create the `kubernetes-csi@pve` token with TKS's [bootstrap](https://github.com/zimmertr/TJs-Kubernetes-Service/tree/main/bootstrap) root. `terraform output -json api_tokens | jq` prints it as `<token_id>=<token_secret>`.
2. Copy `configs/config.yaml.example` to `configs/config.yaml` and fill in `token_id` and `token_secret`.
3. Label the nodes on every new cluster:

   ```bash
   ./bin/label_nodes "$(kubectl get nodes --no-headers | awk '{print $1}' | paste -sd, -)" earth sol-milkyway
   ```
