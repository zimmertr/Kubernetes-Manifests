# Media

* [Summary](#summary)
* [Instructions](#instructions)
  * [Kube Prometheus Stack](#kube-prometheus-stack)

<hr>

## Summary

Observability is a collection of monitoring applications.

<hr>

## Instructions

### Kube Prometheus Stack

[Kube Prometheus Stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) is a pre-configured monitoring stack built on Prometheus, Grafana, and AlertManager

1. Modify the Kustomize project as per your needs.

2. Update `Values.grafana.adminPassword`

3. Deploy to Kubernetes:
   ```bash
   kubectl kustomize --enable-helm kube-prometheus-stack | kubectl apply -f-
   ```

