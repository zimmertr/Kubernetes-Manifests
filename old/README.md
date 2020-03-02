# Kubernetes Manifests

## Summary

A collection of Kustomize projects used to deploy various software applications to Kubernetes. Personally used and tested with my home [Kubernetes Cluster](https://github.com/zimmertr/Bootstrap-Kubernetes-with-QEMU).

## How to Use

Each application has its own `base` and `overlays` directory. The `base` directory contains a collection of manifests that are used to deploy the application within my environment. The `overlays` directory contains an `example` overlay which demonstrates how you may develop patches to configure this application for your environment. The premise behind Kustomize is that you develop a General collection of manifests that can be kustomized using Overlays for different envrionments like `Dev` and `Prod`. Kustomize has [Very Good Documentation](https://github.com/kubernetes-sigs/kustomize/tree/master/docs) if you would like to learn more.

My environment obtains Persistent Volumes using the [NFS Client Provisioner](https://github.com/kubernetes-incubator/external-storage/tree/master/nfs-client) and obtains Load Balancers using [MetalLB](https://metallb.universe.tf/). In the event that your environment is differnet, you will need to at the very least modify this configuration with an overlay for each application.

Many of the underlying Docker images I use are configurable using different Environment Variables. For each of these I have included a base configuration in my `kustomization.yml` according to my spec. It is likely you will need to override these parameters using a `configMapGenerator` set to `replace` in your overlay's `kustomization.yml` file.

Once you have developed your `Overlay`, you can deploy the application to your cluster with `kubectl apply -k overlays/example`. In the even that you are succesful, please consider submitting it as a Pull Request to this repository so that I may add it as an additional example.

## Projects

*Click on a link for additional project information.*

| Project | Notes |
| ------- | ------------ |
| [Atlassian Confluence](Confluence/) | * Requires at least a [trial license](https://www.atlassian.com/software/confluence/pricing?tab=self-managed)<br> * Application is particularly resource intensive. |
| [Atlassian Jira Software](Jira_Software/) | * Requires at least a [trial license](https://www.atlassian.com/software/jira/pricing?tab=self-managed)<br> * Application is particularly resource intensive. |
| [Deluge](Deluge/) | |
| [Grafana](Grafana/) | * Postgres starts up slower than Grafana, `crashloopbackoff` will occur.<br> * Will resolve itself after Postgres accepts connections and Grafana retries. |
| [Grocy](Grocy/) | |
| [Nextcloud](Nextcloud/) | * Has a very long start up time. |
| [OpenVPN Access Server](OpenVPN-as/) | * Has a very long start up time.<br> * Has NET_ADMIN capabilities over the worker node. |
| [Personal Website](Personal_Website/) | |
| [Piwigo](Piwigo/) | |
| [Plex Media Server](Plex/) | * Application is particularly resource intensive. |
| [Radarr](Radarr/) | |
| [Sonarr](Sonarr/) | |
| [Tautulli](Tautulli/) | * Requires a Plex Media Server deployment to use. |
| [Unifi Controller](Unifi_Controller/) | |





