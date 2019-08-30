# Kubernetes Manifests 

## Summary

A collection of Kubernetes Manifests used to deploy common enterprise and homelab-related software. Fully automated and declarative via Ansible. Personally used in conjunction with my home [Kubernetes Cluster](https://github.com/zimmertr/Bootstrap-Kubernetes-with-QEMU).

All projects require that your Kubernetes cluster has a Load Balancer integration and the ability to bind with an NFS server. I use [MetalLB](https://metallb.universe.tf) and [NFS-Provisioner](https://github.com/kubernetes-incubator/external-storage/tree/master/nfs-client), both of which can be deployed to your cluster automatically using these Ansible projects:

* [MetalLB](https://github.com/zimmertr/Bootstrap-Kubernetes-with-QEMU/blob/master/playbooks/optional/deploy_metallb.yml)
* [NFS-Provisioner](https://github.com/zimmertr/Bootstrap-Kubernetes-with-QEMU/blob/master/playbooks/optional/deploy_nfs_provisioner.yml)

It is necessary to create the directories used for your Persistent Volumes on your NFS server before deploying a project. If you do not do this, then the PVCs will never be able to bind to your server. For example, before deploying Jira Software, I would run the following command against my NFS Server: 

`$> mkdir -p /SaturnPool/Kubernetes/Jira/{postgres,data}`

## Projects

*Click on a link for additional project information.*

| Project | Notes |
| ------- | ------------ |
| [Atlassian Confluence](Confluence/) | * Requires at least a [trial license](https://www.atlassian.com/software/confluence/pricing?tab=self-managed)<br> * Application is particularly resource intensive. |
| [Atlassian Jira Software](Jira_Software/) | * Requires at least a [trial license](https://www.atlassian.com/software/jira/pricing?tab=self-managed)<br> * Application is particularly resource intensive. |
| [Deluge](Deluge/) | |
| [Nextcloud](Nextcloud/) | * Has a very long start up time. |
| [OpenVPN Access Server](OpenVPN-as/) | * Has a very long start up time.<br> * Has NET_ADMIN capabilities over the worker node. |
| [Personal Website](Personal_Website/) | |
| [Piwigo](Piwigo/) | |
| [Plex Media Server](Plex/) | * Application is particularly resource intensive. |
| [Radarr](Radarr/) | |
| [Sonarr](Sonarr/) | |
| [Tautulli](Tautulli/) | * Requires a Plex Media Server deployment to use. |
| [Unifi Controller](Unifi_Controller/) | |
