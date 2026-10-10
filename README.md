# Kubernetes Manifests

* [Summary](#summary)
* [Instructions](#instructions)
  * [Networking](#networking)
    * [Istio](#istio)
    * [Cilium](#cilium)
  * [Argo CD](#argo-cd)
  * [Secrets and Volumes](#secrets-and-volumes)
  

<hr>

## Summary

This repository contains a collection of Kustomize projects and Argo CD resources used to deploy applications to Kubernetes. 

Using Proxmox? Consider using [TKS](https://github.com/zimmertr/TJs-Kubernetes-Service) to deploy your cluster!

<hr>

## Instructions

### Networking

#### Istio

Assuming you're using TKS with Flannel, [Istio](istio/README.md) can be used to set up Metal LB & Istio:

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

Assuming you're using TKS and have disabled Flannel, [Cilium](cilium/README.md)) Can be used to install Cilium and Gateway API:

```bash
kustomize build --enable-helm cilium/gateway-api | kubectl apply -f-
kustomize build --enable-helm cilium/cilium | kubectl apply -f-
kustomize build --enable-helm misc/kubelet-csr-approver | kubectl apply -f-
```

<hr>

### Argo CD

[Argo CD](argo/README.md) is deployed manually at first using the same Kustomize pattern:

```bash
kustomize build --enable-helm argo/argo-cd | kubectl apply -f- --server-side --force-conflicts
```

Then bootstrap the rest of the cluster with the [app-of-apps](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/) pattern. The two root Applications at the repo root recursively discover and manage every `AppProject` and `ApplicationSet` in the repository (excluding any `*.disable*` files). Apply the projects first so they exist before the generated Applications reference them:

```bash
kubectl apply -f root-appproject.yml
# The projects are created by Argo in the background. ApplicationSets that
# start before theirs exists fail until their next refresh minutes later.
kubectl -n argo-system wait application/root-appprojects --for=jsonpath='{.status.sync.status}'=Synced --timeout=5m
kubectl apply -f root-applicationset.yml
```

To disable an individual resource, rename its file to match `*.disable*`, e.g. `mv media/applicationset.yml media/applicationset.disable`. It drops out of the root app's manifest set and is pruned.

<hr>

### Secrets and Volumes

Argo CD deploys everything else, but it can't create secrets or anything on the Proxmox host. These are the only things I do by hand.

Once per Proxmox host, create the ZFS volumes the statically provisioned [Proxmox CSI](storage/README.md#proxmox-csi-plugin) volumes point at. They outlive the cluster, so a rebuild picks the data back up:

```bash
zfs create -V 100G FlashPool/vm-9999-Prometheus-Data
zfs create -V 10G FlashPool/vm-9999-AlertManager-Data
zfs create -V 1G FlashPool/vm-9999-Grafana-Data
zfs create -V 50G FlashPool/vm-9999-Jellyfin-Cache
zfs create -V 50G FlashPool/vm-9999-Jellyfin-Config
zfs create -V 10G FlashPool/vm-9999-ruTorrent-Data
zfs create -V 10G FlashPool/vm-9999-Sonarr-Data
```

Also once, apply [terraform/cloudflare](public/README.md#cloudflared) for the tunnel, DNS records and cert-manager's token, and create the Proxmox users with TKS's [bootstrap](https://github.com/zimmertr/TJs-Kubernetes-Service/tree/main/bootstrap) root.

On every new cluster, run these from the root of this repo once Argo CD has synced, since it creates the namespaces. Each app stays unhealthy until its secret exists:

```bash
# Cloudflared and cert-manager: tokens from terraform/cloudflare
kubectl create secret generic cloudflared-token -n cloudflared-system \
  --from-literal=token="$(terraform -chdir=terraform/cloudflare output -raw tunnel_token)"
kubectl create secret generic cloudflare-api-token -n cert-manager \
  --from-literal=api-token="$(terraform -chdir=terraform/cloudflare output -raw cert_manager_token)"

# Proxmox CSI Plugin: copy config.yaml.example to config.yaml and add the token
# from TKS's bootstrap, then label the nodes with their zone and region
kubectl create secret generic proxmox-csi-plugin -n csi-proxmox \
  --from-file=storage/proxmox-csi-plugin/configs/config.yaml
./storage/proxmox-csi-plugin/bin/label_nodes \
  "$(kubectl get nodes --no-headers | awk '{print $1}' | paste -sd, -)" earth sol-milkyway

# Grafana
kubectl create secret generic grafana-admin -n prometheus-system \
  --from-literal=admin-user=admin --from-literal=admin-password='CHANGEME'

# Mountaineers Activity Scraper
kubectl create secret generic mountaineers-activity-scraper-creds -n mountaineers-activity-scraper-system \
  --from-file=misc/mountaineers-activity-scraper/files/google_cloud_credentials.json

# Strava Heatmap Proxy: export the cookie first, see public/README.md
# Run it again with a fresh cookie whenever the pod crash loops
kubectl create secret generic strava-heatmap-proxy-cookies -n strava-heatmap-proxy-system \
  --from-file=strava-cookies.json=public/strava-heatmap-proxy/files/strava-cookies.json \
  --dry-run=client -o yaml | kubectl apply -f-
```

![Alt text](https://raw.githubusercontent.com/zimmertr/Kubernetes-Manifests/main/screenshot.png "Website Screenshot")
