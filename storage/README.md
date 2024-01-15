# Storage

* [NFS Subdir Provisioner](#nfs-subdir-provisioner)
* [Proxmox CSI Driver](#proxmox-csi-driver)

<hr>

## NFS Subdir Provisioner

### Summary

NFS Subdir Provisioner is an in-tree storage provisioner that can be used to dynamically provision volumes on an NFS server.

Website: https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner

### Instructions

1. Configure `values.yml`

2. Deploy the application:
   ```bash
   kubectl kustomize --enable-helm nfs-subdir-provisioner | kubectl apply -f-
   ```

<hr>

## Proxmox CSI Driver

### Summary

Proxmox CSI Driver is a CSI plugin that can be used to dynamically provision volumes from a Proxmox Storage ID and attach them to the worker node on which a pod is running.

Website: https://github.com/sergelogvinov/proxmox-csi-plugin/tree/main

### Instructions

1. Ensure that you have created a Proxmox cluster. Single-node clusters can be used. I use my [configure_cluster](https://github.com/zimmertr/Bootstrap-Proxmox/tree/main/roles/configure_cluster) Ansible role to create mine.

2. Ensure that you have created an API token according to the driver's [requirements](https://github.com/sergelogvinov/proxmox-csi-plugin/tree/main#install-csi-driver). I use my [create_user](https://github.com/zimmertr/Bootstrap-Proxmox/tree/main/roles/create_user) Ansible role to create mine.

3. Create a Kubernetes secret that contains your cluster & API token information using [config.yaml.example](proxmox-csi-driver/configs/config.yaml.example) as an example.
   ```bash
   kubectl create ns csi-proxmox
   
   kubectl create secret generic -n csi-proxmox proxmox-csi-plugin --from-file=proxmox-csi-driver/configs/config.yaml
   ```

4. Label all of your nodes according to your configuration.
   ```bash
   NODES=$(kubectl get nodes --no-headers=true | awk '{print $1}' | tr '\n' ',')
   ZONE="earth"
   REGION="sol-milkyway"
   
   ./proxmox-csi-driver/bin/label_nodes $NODES $ZONE $REGION
   ```

5. Modify [storageclass.yml](https://github.com/zimmertr/Kubernetes-Manifests/blob/main/storage/proxmox-csi-driver/resources/storageclass.yml) according to your Proxmox Storage IDs and the documentation [here](https://github.com/sergelogvinov/proxmox-csi-plugin/blob/main/docs/options.md). 

6. Deploy the CSI driver

   ```bash
   kubectl kustomize --enable-helm proxmox-csi-driver | kubectl apply -f-
   ```
