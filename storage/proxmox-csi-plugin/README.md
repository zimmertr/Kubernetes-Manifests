# Proxmox CSI Plugin

The [Proxmox CSI Plugin](https://github.com/sergelogvinov/proxmox-csi-plugin/tree/main) provisions volumes from a Proxmox Storage ID and attaches them to the worker node a pod runs on.

1. Ensure that you have created a Proxmox cluster. Single-node clusters can be used. I use my [configure_cluster](https://github.com/zimmertr/Bootstrap-Proxmox/tree/main/roles/configure_cluster) Ansible role to create mine.

2. Ensure that you have created an API token according to the plugin's [requirements](https://github.com/sergelogvinov/proxmox-csi-plugin/tree/main#install-csi-plugin). I use the [bootstrap](https://github.com/zimmertr/TJs-Kubernetes-Service/tree/main/bootstrap) Terraform root in TKS to create mine. It creates the `kubernetes-csi@pve` user listed in its [`vars/bootstrap.tfvars`](https://github.com/zimmertr/TJs-Kubernetes-Service/blob/main/vars/bootstrap.tfvars), and `terraform output -json api_tokens | jq` prints its token as `<token_id>=<token_secret>`.

3. Copy [configs/config.yaml.example](configs/config.yaml.example) to `configs/config.yaml` and set `token_id` and `token_secret` to the two halves of that token. `config.yaml` is gitignored.

4. Label all of your nodes with their zone and region. The plugin places volumes by these labels, so do this on every new cluster:

   ```bash
   NODES=$(kubectl get nodes --no-headers=true | awk '{print $1}' | tr '\n' ',')
   ZONE="earth"
   REGION="sol-milkyway"

   ./bin/label_nodes $NODES $ZONE $REGION
   ```
