# Misc

* [Summary](#summary)
* [Instructions](#instructions)
  * [Kubelet CSR Approver](#kubelet-csr-approver)

<hr>

## Summary

Misc is a miscellaneous applications.

<hr>

## Instructions

### Heimdall

```bash
kubectl kustomize --enable-helm heimdall | kubectl apply -f-
```

### Homepage

Update `homepage/files/{configs,icons,images}` according to your needs then install with `kubectl` or Argo CD. `seed-volumes.sh` will automatically seed volumes with your configuration files, images, and icons on init.

```bash
kubectl kustomize --enable-helm homepage | kubectl apply -f-
```

### Kubelet CSR Approver

Cilium and Metrics Server will not be completely ready until you approve the necessary Certificate Signing Requests. This can be done manually with `kubectl certificate approve`, or you can use [Kubelet CSR Approver](https://github.com/postfinance/kubelet-csr-approver).

```bash
kubectl kustomize --enable-helm kubelet-csr-approver | kubectl apply -f-
```
