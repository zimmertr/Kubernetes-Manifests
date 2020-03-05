# Kubernetes Manifests

## Summary

A collection of Kustomize projects to deploy complex enterprise software to Kubernetes.

<hr>



## Instructions

Create a copy of the example overlay for each application and modify it according to your environment. When necessary, take further actions according to the notes below. Deploy the application using Kustomize. For example:
```
kubectl apply -k Confluence/overlays/example
```

<hr>



## Storage Notes

It is bad practice to run a process within a container as root. Some container image providers run their process as a specific unprivileged users. In some situations, the user and group ID for this user are configurable with Environment Variables. Other times, the developer will require you to conform the file ownership of your volumes to their schema. In either case, the applications that are affected by this are documented in the table below.

| Application | Description                                                  |
| ----------- | ------------------------------------------------------------ |
| Confluence  | Hardcoded to run as `2002:2002`. `chown` your mounted data accordingly. |
| Deluge      | `chown` your mounted data to a single UID/GID and set the variables in `kustomization.yml`. |
| Jira        | Hardcoded to run as `2002:2002`. `chown` your mounted data accordingly. |
| Plex        | `chown` your mounted data to a single UID/GID and set the variables in `kustomization.yml`. |
| Radarr      | `chown` your mounted data to a single UID/GID and set the variables in `kustomization.yml`. |
| Sonarr      | `chown` your mounted data to a single UID/GID and set the variables in `kustomization.yml`. |
| Tautulli    | `chown` your mounted data to a single UID/GID and set the variables in `kustomization.yml`. |

<hr>



## Special Notes

### Confluence & Jira

Modify both of the variables within `postgres_password` to have a unique password. The password should be **the same** for both variables as they represent the Postgres password created for the application's database. They are both simply the unique environment variable that their respective container is hardcoded to receive.

## Dashboard

There are a few ways to deploy the Kubernetes Dashboard using this project.

1. Deploy the Dashboard the default way:

   ```bash
   kubectl apply -k Dashboard/base
   ```

2. Deploy the Dashboard and add a new Service Account and ClusterRoleBinding in an overlay to allow you to log into the Dashboard as an administrative user.

   1. Copy `Dashboard/overlays/example` to `Dashboard/overlays/myoverlay` and delete `svc.yml` from the directory. Modify the `kustomization.yml` file in your overlay to not include this file in the `resources` section.
   2. Optionally remove `dep.yml` as well. This is included to provide a single argument to the Dashboard container that prevents it from timing out.
   3. Modify the value for `name` in `crb.yml` and `sa.yml` to refer to your personal username.
   4. Deploy the Dashboard using your custom overlay, retrieve the authentication token, and proxy the Dashboard to your workstation. Be sure to replace `REPLACEME` with your chosen username:

   ```bash
   kubectl apply -k Dashboard/overlays/myoverlay
   kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep REPLACEME | awk '{print $1}')
   kubectl proxy
   ```

3. Deploy the Dashboard and allow external access through a Load Balancer.

   1. Copy `Dashboard/overlays/example` to `Dashboard/overlays/myoverlay` and modify the value for `loadBalancerIp` in `svc.yml` to the IP Address to which you wish to bind the service.
   2. Modify the value for `name` in `crb.yml` and `sa.yml` to refer to your personal username.
   4. Uncomment and update the `subject_alt_name`  variable in `Dashboard/roles/generate_certificates/vars/main.yml`  to be the hostname or IP Address of your load balancer.
   5. Deploy the Dashboard using Ansible , expose it with a Load Balancer, and retrieve the authentication token:

```bash
   ansible-playbook deploy_dashboard.yml
   kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep REPLACEME | awk '{print $1}')
```

### MetalLB

Be sure to modify the ConfigMap according to your environment. MetalLB operates in both Layer2 and BGP and your configuration may differ drastically.

### OpenEBS

OpenEBS requires that you install dependencies on the operating systems of the worker nodes prior to installation. Run the following Ansible playbook to install & configure these dependencies and then deploy OpenEBS to your cluster. If you wish to provide a specific OpenEBS Manifest or configure a specific Storage Driver, be sure to modify the variables  in `./OpenEBS/roles/deploy_openebs/vars/main.yml` before running the playbook.

```bash
ansible-playbook -i ansible/inventory.ini ansible/deploy_openebs.yml
```

### Personal Website

Honestly this container is in rough shape and you're better off not messing with it until I fix it.

### Plex

Plex is a highly personalized application to deploy. Therefore, the `base` will not function in your environment as is. At the very least you will need to provide it several `PersistentVolume` resources to point to your media. This can be done by creating an overlay.

1. Copy `Plex/overlays/example` to `Plex/overlays/myoverlay`.

2. Update the Environmnet Variables present in `kustomization.yml` to reflect your environment. Be sure to obtain a Plex Claim token within 4 minutes of deploying the application or it will expire.

3. Update `svc_tcp.yml` and `svc_udp.yml` according to your environment. My environment exposes each app with a virtual load balancer.

4. Update `pv.yml` and `pvc.yml` to point to all of your personal media. You may add or remove as many volumes as you wish.

5. Update `dep.yml` to point to all of your new Persistent Volumes.

6. Deploy Plex using your custom overlay:

   ```bash
   kubectl apply -k Plex/overlays/myoverlay
   ```

### Tautulli

My deployment of Tatulli assumes I want to monitor a Plex log directory. I assume yours does to. So you will need to modify the `pv.yml` to point to your specific storage location. Furthermore, you will need to modify the `svc.yml` according to your network configuration.
