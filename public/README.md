# Public

* [Summary](#summary)
* [Instructions](#instructions)
  * [Kube Prometheus Stack](#kube-prometheus-stack)

<hr>

## Summary

Public is a collection of my public-facing applications.

<hr>

## Instructions

### CertManager

[Cert Manager](https://cert-manager.io/) is a tool used to request and manage X509 certificates.

1. Modify the Kustomize project as per your needs.

3. Deploy to Kubernetes:
   ```bash
   kubectl kustomize --enable-helm certificate-manager | kubectl apply -f-
   ```

### Personal Website

[Personal Website](https://tjzimmerman.com) is my personal website.

1. Modify the Kustomize project as per your needs.

3. Deploy to Kubernetes:
   ```bash
   kubectl kustomize --enable-helm personal-website | kubectl apply -f-
   ```

