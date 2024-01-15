# Kubernetes Manifests

* [Summary](#summary)
* [Instructions](#instructions)
  * [Istio](#istio)
  * [Cilium](#cilium)
  * [Argo CD](#argo-cd)

<hr>

## Summary

This repository contains a collection of Kustomize projects and Argo CD resources used to deploy applications to Kubernetes. 

Using Proxmox? Consider using [TKS](https://github.com/zimmertr/TJs-Kubernetes-Service) to deploy your cluster!

<hr>

## Instructions

### Istio

Assuming you're using TKS with Flannel, `Istio` can be used to set up Metal LB & Istio:

```bash
# You may have to run this multiple times
kubectl kustomize istio/metallb | kubectl apply -f-
kubectl kustomize --enable-helm istio | kubectl apply -f-
kubectl kustomize --enable-helm istio-gateway | kubectl apply -f-
```

### Cilium

Assuming you're using TKS and have disabled Flannel, `Cilium` Can be used to install Cilium and Gateway API:

```bash
kubectl kustomize --enable-helm cilium/gateway-api | kubectl apply -f-
kubectl kustomize --enable-helm cilium/cilium | kubectl apply -f-
kubectl kustomize --enable-helm cilium/kubelet-csr-approver | kubectl apply -f-
kubectl kustomize --enable-helm cilium/metrics-server | kubectl apply -f-
```

### Argo CD

Argo CD is deployed manually at first using the same Kustomize pattern:

```bash
kubectl kustomize --enable-helm argo/argo-cd | kubectl apply -f-
```

Then you can apply ApplicationSets for a group of applications. For example:

```bash
kubectl apply -f argo/applicationset.yml
```
