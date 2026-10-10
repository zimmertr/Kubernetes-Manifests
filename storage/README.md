# Storage

* [Summary](#summary)
* [Instructions](#instructions)
   * [Proxmox CSI Plugin](#proxmox-csi-plugin)

## Summary

Storage is a collection of plugins that provide persistent storage capabilities to TKS, deployed by Argo CD. The [NFS Subdir Provisioner](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner) is disabled. Configure its `values.yml` before turning it back on.

<hr>

## Instructions

### Proxmox CSI Plugin

The [Proxmox CSI Plugin](https://github.com/sergelogvinov/proxmox-csi-plugin/tree/main) is a CSI plugin that can be used to dynamically provision volumes from a Proxmox Storage ID and attach them to the worker node on which a pod is running.

1. Ensure that you have created a Proxmox cluster. Single-node clusters can be used. I use my [configure_cluster](https://github.com/zimmertr/Bootstrap-Proxmox/tree/main/roles/configure_cluster) Ansible role to create mine.

2. Ensure that you have created an API token according to the plugin's [requirements](https://github.com/sergelogvinov/proxmox-csi-plugin/tree/main#install-csi-plugin). I use the [bootstrap](https://github.com/zimmertr/TJs-Kubernetes-Service/tree/main/bootstrap) Terraform root in TKS to create mine. It creates the `kubernetes-csi@pve` user listed in its [`vars/bootstrap.tfvars`](https://github.com/zimmertr/TJs-Kubernetes-Service/blob/main/vars/bootstrap.tfvars). `terraform output -json api_tokens | jq` prints each token as `<token_id>=<token_secret>`.

3. Copy [config.yaml.example](proxmox-csi-plugin/configs/config.yaml.example) to `config.yaml` and add your cluster and token. It's gitignored.

4. On every new cluster, create the secret and label the nodes with their zone and region. The commands are in [Secrets and Volumes](../README.md#secrets-and-volumes) in the main README. If you aren't using TKS, label your nodes the same way, since the plugin places volumes by those labels.
