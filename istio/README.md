# Istio

* [Summary](#summary)
* [Instructions](#instructions)
  * [Istio](#istio)
  * [Istio Gateway](#istio-gateway)
  * [MetalLB](#metallb)

<hr>

## Summary

Istio is a collection of networking applications needed to stand up the Istio Service Mesh. This is unmaintained as I now use Cilium and Gateway API.

<hr>

## Instructions

### Istio

[Istio](https://istio.io/) is a Service Mesh.

1. Modify the Kustomize project as per your needs.

3. Deploy to Kubernetes:
   ```bash
   kubectl kustomize --enable-helm istio | kubectl apply -f-
   ```

<hr>

### Istio Gateway

[Istio Gateway](https://istio.io/latest/docs/reference/config/networking/gateway/) is an ingress Gateway for Istio.

1. Modify the Kustomize project as per your needs.

3. Deploy to Kubernetes:
   ```bash
   kubectl kustomize --enable-helm istio-gateway | kubectl apply -f-
   ```

<hr>

### MetalLB

[MetalLB](https://metallb.universe.tf/) is a bare metal load balancer implementation.

1. Modify the Kustomize project as per your needs.

3. Deploy to Kubernetes:
   ```bash
   kubectl kustomize --enable-helm metallb | kubectl apply -f-
   ```
