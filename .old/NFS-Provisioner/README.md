# NFS Provisioner

This application is meant to be deployed to Kubernetes using Ansible.

* **Website**: https://github.com/kubernetes-retired/external-storage/tree/master/nfs-client
* **Container Image:** https://quay.io/repository/external_storage/nfs-client-provisioner?tag=latest&tab=tags

<hr>

## Instructions

Create an Overlay for your NFS mountpoint and update `deploy_nfs_provisioner.yml` to reference it. Ensure your `./TKS/inventory.yml` is accurage and execute `ansible-playbook -i inventory.yml TKS-Deploy_Kubernetes_Apps/NFS_Provisioner/deploy_nfs_provisioner.yml` to deploy the NFS Provisioner to Kubernetes.
