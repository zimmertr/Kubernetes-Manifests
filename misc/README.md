# Misc

* [Summary](#summary)
* [Instructions](#instructions)
  * [Kubelet CSR Approver](#kubelet-csr-approver)

<hr>

## Summary

Misc is a miscellaneous applications.

<hr>

## Instructions

### Kubelet CSR Approver

Cilium and Metrics Server will not be completely ready until you approve the necessary Certificate Signing Requests. This can be done manually with `kubectl certificate approve`, or you can use [Kubelet CSR Approver](https://github.com/postfinance/kubelet-csr-approver).

```bash
kubectl kustomize --enable-helm kubelet-csr-approver | kubectl apply -f-
```
