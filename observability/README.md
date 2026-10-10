# Observability

* [Summary](#summary)

<hr>

## Summary

Observability is a collection of monitoring applications, deployed by Argo CD:

| Application                                                  | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| [Kube Prometheus Stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) | Prometheus, Grafana, and AlertManager. Each UI has its own MetalLB address: Grafana on `192.168.40.110`, Prometheus on `192.168.40.111`, AlertManager on `192.168.40.112` |
| [Metrics Server](https://github.com/kubernetes-sigs/metrics-server) | Enables the Metrics API in Kubernetes                       |

The stack's storage is three statically provisioned Proxmox CSI volumes, and the Grafana admin credential is a secret. Both are in [Secrets and Volumes](../README.md#secrets-and-volumes) in the main README.

The [NGINX Prometheus Exporter](https://github.com/nginxinc/nginx-prometheus-exporter) is disabled, and nothing scrapes it: the NGINX edge it measured was replaced by the [Cloudflare Tunnel](../public/README.md#cloudflared).
