# Storage

* [Summary](#summary)
* [Instructions](#instructions)
   * [NFS Subdir Provisioner](#nfs-subdir-provisioner)
   * [Proxmox CSI Plugin](#proxmox-csi-plugin)

## Summary

Storage is a collection of plugins that provide persistent storage capabilities to TKS.

<hr>

## Instructions

### NFS Subdir Provisioner

The [NFS Subdir Provisioner](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner) is an in-tree storage provisioner that can be used to dynamically provision volumes on an NFS server.


1. Configure `values.yml`

2. Deploy the application:

   ```bash
   kubectl kustomize --enable-helm nfs-subdir-provisioner | kubectl apply -f-
   ```

<hr>

### Proxmox CSI Plugin

The [Proxmox CSI Plugin](https://github.com/sergelogvinov/proxmox-csi-plugin/tree/main) is a CSI plugin that can be used to dynamically provision volumes from a Proxmox Storage ID and attach them to the worker node on which a pod is running.

1. Ensure that you have created a Proxmox cluster. Single-node clusters can be used. I use my [configure_cluster](https://github.com/zimmertr/Bootstrap-Proxmox/tree/main/roles/configure_cluster) Ansible role to create mine.

2. Ensure that you have created an API token according to the plugin's [requirements](https://github.com/sergelogvinov/proxmox-csi-plugin/tree/main#install-csi-plugin). I use my [create_user](https://github.com/zimmertr/Bootstrap-Proxmox/tree/main/roles/create_user) Ansible role to create mine.

3. Create a Kubernetes secret that contains your cluster & API token information using [config.yaml.example](proxmox-csi-plugin/configs/config.yaml.example) as an example.

   ```bash
   kubectl create ns csi-proxmox
   
   kubectl create secret generic -n csi-proxmox proxmox-csi-plugin --from-file=proxmox-csi-plugin/configs/config.yaml
   ```

4. Label all of your nodes according to your configuration.

   ```bash
   NODES=$(kubectl get nodes --no-headers=true | awk '{print $1}' | tr '\n' ',')
   ZONE="earth"
   REGION="sol-milkyway"
   
   ./proxmox-csi-plugin/bin/label_nodes $NODES $ZONE $REGION
   ```

5. Deploy the CSI plugin

   ```bash
   kustomize build --enable-helm proxmox-csi-plugin | kubectl apply -f-
   ```
