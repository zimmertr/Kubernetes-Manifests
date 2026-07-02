# Kubernetes Manifests

* [Summary](#summary)
* [Instructions](#instructions)
  * [Networking](#networking)
    * [Istio](#istio)
    * [Cilium](#cilium)
  * [Argo CD](#argo-cd)
  

<hr>

## Summary

This repository contains a collection of Kustomize projects and Argo CD resources used to deploy applications to Kubernetes. 

Using Proxmox? Consider using [TKS](https://github.com/zimmertr/TJs-Kubernetes-Service) to deploy your cluster!

<hr>

## Instructions

### Networking

#### Istio

Assuming you're using TKS with Flannel, [Istio](istio/README.md) can be used to set up Metal LB & Istio:

```bash
# You may have to run this multiple times
kustomize build istio/metallb | kubectl apply -f-
kustomize build --enable-helm istio/istio | kubectl apply -f-
kustomize build --enable-helm istio/istio-gateway | kubectl apply -f-
```

#### Cilium

Assuming you're using TKS and have disabled Flannel, [Cilium](cilium/README.md)) Can be used to install Cilium and Gateway API:

```bash
kustomize build --enable-helm cilium/gateway-api | kubectl apply -f-
kustomize build --enable-helm cilium/cilium | kubectl apply -f-
kustomize build --enable-helm misc/kubelet-csr-approver | kubectl apply -f-
```

<hr>

### Argo CD

[Argo CD](argo/README.md) is deployed manually at first using the same Kustomize pattern:

```bash
kustomize build --enable-helm argo/argo-cd | kubectl apply -f- --server-side --force-conflicts
```

Then bootstrap the rest of the cluster with the [app-of-apps](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/) pattern. The two root Applications at the repo root recursively discover and manage every `AppProject` and `ApplicationSet` in the repository (excluding `deprecated/` and any `*.disabled` files). Apply the projects first so they exist before the generated Applications reference them:

```bash
kubectl apply -f appprojects.yml
kubectl apply -f applicationsets.yml
```

To disable an individual resource, rename its file so it no longer matches the include glob, e.g. `mv media/applicationset.yml media/applicationset.yml.disabled`. It drops out of the root app's manifest set and is pruned.

![Alt text](https://raw.githubusercontent.com/zimmertr/Kubernetes-Manifests/main/screenshot.png "Website Screenshot")
