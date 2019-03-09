# Kubernetes Manifests 

## Summary

A collection of Kubernetes Manifests separated by project for use with deploying to my [personal Kubernetes Cluster](https://github.com/zimmertr/Bootstrap-Kubernetes-with-QEMU).

## Projects

**Deluge**

[These manifests](Deluge/) are used to deploy Deluge to Kubernetes. They relies on MetalLB to configure a load balancer as well as an exported NFS mountpoint that Kubernetes can bind to with three persistent volumes in order to store the Deluge configuration as well as interact with your Downloaded files and other subdirectories on your fileserver involved in running a Bittorrent server.


**Personal Website**

[These manifests](Personal_Website/) are used to deploy my personal website to Kubernetes. They rely on MetalLB to configure a load balancer as well as an exported NFS mountpoint that Kubernetes can bind to with a persistent volume in order to serve up public files. 


**Sonarr**

[These manifests](Sonarr/) are used to deploy Sonarr to Kubernetes. They rely on MetalLB to configure a load balancer as well as an exported NFS mountpoint that Kubernetes can bind to with a persistent volume in order to interact with downloaded TV Shows and other subdirectories on your fileserver involved in running a Bittorrent server that is integrated with RSS feeds. 


**Radarr**

[These manifests](Radarr/) are used to deploy Radarr to Kubernetes. They rely on MetalLB to configure a load balancer as well as an exported NFS mountpoint that Kubernetes can bind to with a persistent volume in order to interact with downloaded Movies and other subdirectories on your fileserver involved in running a Bittorrent server that is integrated with RSS feeds. 


**Unifi Controller**

[These Manifests](Unifi_Controller/) are used to deploy the Unifi Controller to Kubernetes. They rely on MetalLB to configure a load balancer as well as an exported NFS mountpoint that Kubernetes can bind to with a persistent volume in order to store Unifi's configuration. Furthermore, additional configuration will be necessary at the software level and device discovery may not work. 
