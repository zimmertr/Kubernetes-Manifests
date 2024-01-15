# Cilium

* [Summary](#summary)
* [Instructions](#instructions)
  * [Argo CD](#argo-cd)
  * [Cilium](#cilium)
  * [Kubelet CSR Approver](#kubelet-csr-approver)
  * [Metrics Server](#metrics-server)

<hr>

## Summary

Cilium is a collection of essential applications required to make TKS functional when using Cilium and Gateway API.

:warning: **Warning** :warning: I no longer use Cilium due to [L2 Announcement issues](https://github.com/cilium/cilium/issues/26586#issuecomment-1891021144) so this is unmaintained.

<hr>

## Instructions

### Gateway API

[Gateway API](https://gateway-api.sigs.k8s.io/) is a gateway Ingress solution for Kubernetes. You might need to run apply a second time as `kubectl` will likely fail to create some resources until the CRDs are available.

```bash
kubectl kustomize --enable-helm gateway-api | kubectl apply -f-
```

<hr>

### Cilium

[Cilium](https://cilium.io/) is the preferred CNI when using TKS; most of the applications in this repository assume it is being used.

```bash
kubectl kustomize --enable-helm cilium | kubectl apply -f-
```

<hr>

### Kubelet CSR Approver

Cilium will not be completely ready until you approve the necessary Certificate Signing Requests. This can be done manually with `kubectl certificate approve`, or you can use [Kubelet CSR Approver](https://github.com/postfinance/kubelet-csr-approver). 

```bash
kubectl kustomize --enable-helm ../misc/kubelet-csr-approver | kubectl apply -f-
```
