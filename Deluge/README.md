## Deluge

<p align="center">
  <img src="https://raw.githubusercontent.com/zimmertr/Kubernetes-Manifests/master/Deluge/screenshot.png" width="800">
</p>

# Summary:

These manifests are used to deploy an instance of *Deluge* using [Kustomize](https://kustomize.io/).

# How To Use:

See the [Parent README](../README.md) for more information on how I use Kustomize to configure my applications.

# Common Kustomizations:

**dep.yml:**
1. Exposing custom ports.
2. Specifying different volume paths.
3. Allocating custom resources.

**pv_config**, **pv_downloads**, **pv_fileserver:**
1. Using a different Storage Class.
2. Using a different NFS Server & Mount Path.

**svc.yml:**
1. Using a different Load Balance Controller.
2. Using Custom Ports.
3. Using a different Address Pool or IP Address in MetalLB.
