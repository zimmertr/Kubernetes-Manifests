# Observability

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

[Kube Prometheus Stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) is a pre-configured monitoring stack built on Prometheus, Grafana, and AlertManager. Each UI is served on its own MetalLB address: Grafana on `192.168.40.110`, Prometheus on `192.168.40.111`, AlertManager on `192.168.40.112`.

Storage is three statically provisioned [Proxmox CSI](../storage/README.md#proxmox-csi-plugin) volumes. The matching ZFS volumes must exist on the Proxmox host before the pods can attach:

```bash
zfs create -V 100G FlashPool/vm-9999-Prometheus-Data
zfs create -V 10G FlashPool/vm-9999-AlertManager-Data
zfs create -V 1G FlashPool/vm-9999-Grafana-Data
```

The Grafana admin credential is a secret created by hand, the same split the [Cloudflare Tunnel](../public/README.md#cloudflared) uses. Grafana stays unhealthy until it exists:

```bash
kubectl create secret generic grafana-admin \
  --from-literal=admin-user=admin \
  --from-literal=admin-password='CHANGEME' \
  -n prometheus-system
```

1. Modify the Kustomize project as per your needs.

2. Deploy (or let Argo CD sync it):
   ```bash
   kustomize build --enable-helm kube-prometheus-stack | kubectl apply --server-side -f-
   ```

<hr>

### Metrics Server

[Metrics Server](https://github.com/kubernetes-sigs/metrics-server) is needed to enable the Metrics API in Kubernetes.

```bash
kustomize build --enable-helm metrics-server | kubectl apply -f-
```

<hr>

### NGINX Prometheus Exporter

[NGINX Prometheus Exporter](https://github.com/nginxinc/nginx-prometheus-exporter) is a Prometheus exporter used to collect metrics from a NGINX webserver. It is currently disabled, and nothing scrapes it: the NGINX edge it measured was replaced by the [Cloudflare Tunnel](../public/README.md#cloudflared).

1. Configure NGINX to enable the `stub_status` endpoint.

2. Modify the Kustomize project as per your needs, and add a scrape job for it to the Kube Prometheus Stack values.

3. Deploy to Kubernetes:
   ```bash
   kustomize build --enable-helm nginx-prometheus-exporter | kubectl apply -f-
   ```
