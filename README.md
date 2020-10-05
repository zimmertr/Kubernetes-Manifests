# TKS - Deploy Kubernetes Apps

This repository can be used on its own but it is intended to be used as a submodule of [TKS](https://github.com/zimmertr/TKS). TKS enables enthusiasts and administrators alike to easily provision highly available and production-ready Kubernetes clusters and other modern infrastructure on Proxmox VE.

* [Summary](Summary/README.md)
* [Requirements](Requirements/README.md)
* [Instructions](Instructions/README.md)

<hr>

## Summary

`Deploy Kubernetes Apps` is a collection of Kubernetes manifests, Kustomizations, and Ansible roles used to deploy applications to Kubernetes.

<hr>

## Requirements

This project assumes you have a working [Kubernetes cluster](https://github.com/zimmertr/TKS-Bootstrap_Kubernetes).
<hr>

## Instructions

When possible, an application is expressed with Kustomize and contains an example overlay from my environment. Simply create a new overlay from this example and deploy it.

```bash
kubectl apply -k APP/overlays/example
```

Sometimes it is necessary to use the Kustomize binary instead of `kubectl -k` to build manifests. In a situation where `kubectl -k` throws an error, try instead:

```bash
kustomize build APP/overlays/example | kubectl apply -f-
```

In some cases, an application requires more than just Kustomize to be deployed. For example, OpenEBS requires that you install an iSCSI driver on your worker nodes. In these cases, an Ansible role and additional instructions are provided.

In all cases, a supplemental README is provided with further details about configuring & deploying the application. Consult the table below for links and more information.


| Application | Deployment Method | Details |
| ----------- | ----------------- | ------- |
| [Confluence](Confluence/README.md) | Kustomize ||
| [Dashboard](Dashboard/README.md) | Ansible / Kustomize |Ansible is used to generate certificates. Kustomize is used to deploy the application.|
| [Deluge](Deluge/README.md) | Kustomize ||
| [Federated Monitoring (Grafana)](Federated-Monitoring/README.md) | Kustomize ||
| [Grafana](Grafana/README.md) | Grafana | This project has been retired in favor of [Federated Monitoring (Grafana)](Federated-Monitoring/README.md). |
| [Grocy](Grocy/README.md) | Kustomize ||
| [Istio](Istio/README.md) | Ansible |Ansible is used to download and deploy the requested version of Istio using `istioctl`.|
| [Jira](Jira/README.md) | Kustomize ||
| [MetalLB](MetalLB/README.md) | Kustomize ||
| [Nextcloud](Nextcloud/README.md) | Ansible |Out of Date -- Needs to be ported to Kustomize.|
| [NFS Provisioner](NFS-Provisioner/README.md) | Ansible / Kustomize |Ansible is used to install `nfs-common` on the worker nodes. Kustomize is used to deploy the application.|
| [OpenEBS](OpenEBS/README.md) | Ansible / Kustomize |Ansible is used to install `iscsid` and configure the worker nodes. Kustomize is used to deploy the application.|
| [OpenVPN-as](OpenVPN-as/README.md) | Ansible |Out of Date -- Needs to be ported to Kustomize.|
| [Personal Website](Personal-Website/README.md) | Kustomize ||
| [Piwigo](Piwigo/README.md) | Ansible |Out of Date -- Needs to be ported to Kustomize.|
| [Plex Media Server](Plex-Media-Server/README.md) | Kustomize ||
| [Radarr](Radarr/README.md) | Kustomize ||
| [ruTorrent](ruTorrent/README.md) | Kustomize ||
| [Sonarr](Sonarr/README.md) | Kustomize ||
| [Tautulli](Tautulli/README.md) | Kustomize ||
| [Toodo](Toodo/README.md) | Kustomize ||
| [Unifi-Controller](Unifi-Controller/README.md) | Ansible |Out of Date -- Needs to be ported to Kustomize.|
