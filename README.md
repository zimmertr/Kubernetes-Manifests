# Kubernetes Manifests

* [Summary](#summary)
* [Instructions](#instructions)
  * [Core](#core)
  * [Argo CD](#argo-cd)

<hr>

## Summary

A collection of applications meant to be deployed to Kubernetes.

Using Proxmox? Consider using [TKS](https://github.com/zimmertr/TJs-Kubernetes-Service) to deploy your cluster!

<hr>

## Instructions

### Core

Assuming you're using TKS and have disabled Flannel, Core is necessary to install a CNI and enable Metrics Server:

```bash
kubectl kustomize --enable-helm core/cilium | kubectl apply -f-
kubectl kustomize --enable-helm core/kubelet-csr-approver | kubectl apply -f-
kubectl kustomize --enable-helm core/metrics-server | kubectl apply -f-
```

### Argo CD

Argo CD is deployed manually at first using the same Kustomize pattern:

```bash
kubectl kustomize --enable-helm argo/argo-cd | kubectl apply -f-
```

Then you can apply ApplicationSets for a group of applications. For example, Core and Argo:

```bash
kubectl apply -f core/applicationset.yml
kubectl apply -f argo/applicationset.yml
```
