# Core

* [Summary](#summary)
* [Instructions](#instructions)
  * [Argo CD](#argo-cd)
  * [Cilium](#cilium)
  * [Kubelet CSR Approver](#kubelet-csr-approver)
  * [Metrics Server](#metrics-server)

<hr>

## Summary

Core is a collection of essential applications required to make TKS functional.

<hr>

## Instructions

### Gateway API

[Gateway API](https://gateway-api.sigs.k8s.io/) is a gateway Ingress solution for Kubernetes. You might need to run apply a second time as `kubectl` will likely fail to create some resources until the CRDs are available.

```bash
kubectl kustomize --enable-helm gateway-api | kubectl apply -f-
```

### Cilium

[Cilium](https://cilium.io/) is the preferred CNI when using TKS; most of the applications in this repository assume it is being used.

```bash
kubectl kustomize --enable-helm cilium | kubectl apply -f-
```

<hr>

### Kubelet CSR Approver

Cilium will not be completely ready until you approve the necessary Certificate Signing Requests. This can be done manually with `kubectl certificate approve`, or you can use [Kubelet CSR Approver](https://github.com/postfinance/kubelet-csr-approver). 

```bash
kubectl kustomize --enable-helm kubelet-csr-approver | kubectl apply -f-
```

<hr>

### Metrics Server

[Metrics Server](https://github.com/kubernetes-sigs/metrics-server) is needed to enable the Metrics API in Kubernetes.

```bash
kubectl kustomize --enable-helm metrics-server | kubectl apply -f-
```
