# Istio

* [Summary](#summary)

<hr>

## Summary

Istio is a collection of networking applications needed to stand up the Istio Service Mesh:

| Application                                                  | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| [Istio](https://istio.io/)                                   | The Service Mesh                                             |
| [Istio Gateway](https://istio.io/latest/docs/reference/config/networking/gateway/) | The shared ingress gateway every public and internal hostname goes through |
| [MetalLB](https://metallb.universe.tf/)                      | A bare metal load balancer that gives the gateway its IP     |

They're installed by hand before Argo CD, see [Istio](../README.md#istio) in the main README for the order. Argo CD manages them after that.
