# Media

* [Summary](#summary)
* [Instructions](#instructions)
  * [Kube Prometheus Stack](#kube-prometheus-stack)
  * [Metrics Server](#metrics-server)
  * [NGINX Prometheus Exporter](#nginx-prometheus-exporter)

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
<hr>

### Metrics Server

[Metrics Server](https://github.com/kubernetes-sigs/metrics-server) is needed to enable the Metrics API in Kubernetes.

```bash
kubectl kustomize --enable-helm metrics-server | kubectl apply -f-
```

<hr>

### NGINX Prometheus Exporter

[NGINX Prometheus Exporter](https://github.com/nginxinc/nginx-prometheus-exporter) is a Prometheus exporter used to collect metrics from a NGINX webserver.

1. Configure NGINX to enable the `stub_status` endpoint.

2. Modify the Kustomize project as per your needs.

3. Deploy to Kubernetes:
   ```bash
   kubectl kustomize --enable-helm kube-prometheus-stack | kubectl apply -f-
   ```
