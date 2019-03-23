# Kubernetes Manifests 

## Summary

A collection of Kubernetes Manifests separated by project for use with deploying to my [personal Kubernetes Cluster](https://github.com/zimmertr/Bootstrap-Kubernetes-with-QEMU).

## Projects

**Deluge**

[These manifests](Deluge/) are used to deploy Deluge to Kubernetes. It leverages MetalLB to configure a bare metal load balancer as well as an exported NFS mountpoint that Kubernetes can bind persistent volumes to in order to store the configuration and interact with other files related to the server. 


**Jira Software**

[These manifests](Jira_Software) are used to deploy an instance of Jira Software. They rely on MetalLB to configure a load balancer as well as an exported NFS mountpoint that Kubernetes can bind to in order to store Persistent Volumes for the configuration as well as the other files that the server will interact with. Please be aware, Jira Software requires at minimum a trial [license](https://www.atlassian.com/software/jira/pricing?tab=self-managed) to operate. 

**Personal Website**

[These manifests](Personal_Website/) are used to deploy my personal website to Kubernetes. They rely on MetalLB to configure a load balancer as well as an exported NFS mountpoint that Kubernetes can bind to with a persistent volume in order to serve up public files. The variables file used for the deployment allows the user to provide a Google Analytics tracking ID as well as a Weather Underground API key for use with the terminal emulator. 


**Plex Media Server**

[These manifests](Plex/) are used to deploy Plex Media Server to Kubernetes. They rely on MetalLB to configure a load balancer as well as an exported NFS mountpoint that Kubernetes can bind to to store configuration files as well as interact with your media library. The variables file used for the deployment allows the user to configure Plex in a multitude of ways.


**Radarr**

[These manifests](Radarr/) are used to deploy Radarr to Kubernetes. They rely on MetalLB to configure a load balancer as well as an exported NFS mountpoint that Kubernetes can bind to with a persistent volume in order to interact with downloaded Movies and other subdirectories on your fileserver involved in running a Bittorrent server that is integrated with RSS feeds. 


**Sonarr**

[These manifests](Sonarr/) are used to deploy Sonarr to Kubernetes. They rely on MetalLB to configure a load balancer as well as an exported NFS mountpoint that Kubernetes can bind to with a persistent volume in order to interact with downloaded TV Shows and other subdirectories on your fileserver involved in running a Bittorrent server that is integrated with RSS feeds. 


**Unifi Controller**

[These Manifests](Unifi_Controller/) are used to deploy the Unifi Controller to Kubernetes. They rely on MetalLB to configure a load balancer as well as an exported NFS mountpoint that Kubernetes can bind to with a persistent volume in order to store Unifi's configuration. Furthermore, additional configuration will be necessary at the software level and device discovery may not work. The backing MongoDB database that Unifi uses is not bundled with the controller pod in this release, but rather is deployed alongside the controller as an external database.
