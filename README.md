# Kubernetes Manifests

* [Summary](#summary)
* [Instructions](#instructions)
  * [Cloud Controller Manager](#cloud-controller-manager)
  * [Networking](#networking)
    * [Istio](#istio)
    * [Cilium](#cilium)
  * [Argo CD](#argo-cd)
  * [Secrets and Volumes](#secrets-and-volumes)
  

<hr>

## Summary

A collection of services I deploy to Kubernetes with Argo CD using [TKS](https://github.com/zimmertr/TJs-Kubernetes-Service).

<hr>

## Instructions

### Cloud Controller Manager

If TKS's `cluster.external_cloud_provider` is on, nodes stay tainted until the [Proxmox CCM](misc/proxmox-cloud-controller-manager) runs, so install it first. See its README for populating `config.yaml`.

```bash
kubectl create secret generic proxmox-cloud-controller-manager -n kube-system \
  --from-file=config.yaml=misc/proxmox-cloud-controller-manager/configs/config.yaml
kustomize build --enable-helm misc/proxmox-cloud-controller-manager | kubectl apply -f-
```

<hr>

### Networking

#### Istio

Assuming you're using TKS with Flannel, [Istio](istio) can be used to set up Metal LB & Istio:

```bash
# The first apply creates MetalLB's CRDs and controller, but its pools can't be
# created until the controller's webhook is up. Wait for it and apply again.
kustomize build istio/metallb | kubectl apply -f-
kubectl -n metallb-system rollout status deploy/controller
kustomize build istio/metallb | kubectl apply -f-

kustomize build --enable-helm istio/istio | kubectl apply -f-
kustomize build --enable-helm istio/istio-gateway | kubectl apply -f-
```

#### Cilium

Assuming you're using TKS and have disabled Flannel, [Cilium](cilium) Can be used to install Cilium and Gateway API:

```bash
kustomize build --enable-helm cilium/gateway-api | kubectl apply -f-
kustomize build --enable-helm cilium/cilium | kubectl apply -f-
kustomize build --enable-helm misc/kubelet-csr-approver | kubectl apply -f-
```

<hr>

### Argo CD

[Argo CD](argo/argo-cd) is deployed manually at first using the same Kustomize pattern:

```bash
kustomize build --enable-helm argo/argo-cd | kubectl apply -f- --server-side --force-conflicts
```

Then bootstrap the rest of the cluster with the [app-of-apps](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/) pattern, recursively discovering AppProjects and ApplicationSets:

```bash
kubectl apply -f root-appproject.yml
# The projects are created by Argo in the background. ApplicationSets that
# start before theirs exists fail until their next refresh minutes later.
kubectl -n argo-system wait application/root-appprojects --for=jsonpath='{.status.sync.status}'=Synced --timeout=5m
kubectl apply -f root-applicationset.yml
```

<hr>

### Secrets and Volumes

Argo CD cannot create Secret resources since they're not tracked in this repo. And cannot create any statically referenced persistent volumes. So they must be created by hand.

Create any ZFS volumes the statically provisioned [Proxmox CSI](storage/proxmox-csi-plugin/README.md) PersistentVolume resources point at:

```bash
zfs create -V 100G FlashPool/vm-9999-Prometheus-Data
zfs create -V 10G FlashPool/vm-9999-AlertManager-Data
zfs create -V 1G FlashPool/vm-9999-Grafana-Data
zfs create -V 50G FlashPool/vm-9999-Jellyfin-Cache
zfs create -V 50G FlashPool/vm-9999-Jellyfin-Config
zfs create -V 10G FlashPool/vm-9999-ruTorrent-Data
zfs create -V 10G FlashPool/vm-9999-Sonarr-Data
```

Apply [terraform/cloudflare](terraform/cloudflare/README.md) for the Cloudflare tunnel, DNS records and cert-manager API token:

```bash
terraform -chdir=terraform/cloudflare init
terraform -chdir=terraform/cloudflare apply -var-file=cloudflare.tfvars
```

Create any Secret resources using the Terraform outputs:

```bash
# Cloudflared and Cert-Manager
kubectl create secret generic cloudflared-token -n cloudflared-system \
  --from-literal=token="$(terraform -chdir=terraform/cloudflare output -raw tunnel_token)"
kubectl create secret generic cloudflare-api-token -n cert-manager \
  --from-literal=api-token="$(terraform -chdir=terraform/cloudflare output -raw cert_manager_token)"

# Proxmox CSI Plugin
# See storage/proxmox-csi-plugin/README.md
kubectl create secret generic proxmox-csi-plugin -n csi-proxmox \
  --from-file=storage/proxmox-csi-plugin/configs/config.yaml

# Grafana
kubectl create secret generic grafana-admin -n prometheus-system \
  --from-literal=admin-user=admin --from-literal=admin-password='CHANGEME'

# Mountaineers Activity Scraper
# See misc/mountaineers-activity-scraper/README.md
kubectl create secret generic mountaineers-activity-scraper-creds -n mountaineers-activity-scraper-system \
  --from-file=misc/mountaineers-activity-scraper/files/google_cloud_credentials.json

# Strava Heatmap Proxy
# See public/strava-heatmap-proxy/README.md
kubectl create secret generic strava-heatmap-proxy-cookies -n strava-heatmap-proxy-system \
  --from-file=strava-cookies.json=public/strava-heatmap-proxy/files/strava-cookies.json \
  --dry-run=client -o yaml | kubectl apply -f-
```
