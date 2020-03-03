# Kubernetes Manifests

## Summary

A collection of Kustomize projects to deploy complex enterprise software to Kubernetes. 

<hr>



## Instructions

To deploy an application, create a Kustomize overlay and populate it with your patches. Then run:

```bash
kubectl apply -k >Application</Overlay
```

<hr>



## Storage Notes

It is bad practice to run processes within containers as root. When people develop container images they often avoid this by running the proccess as a specific user. Sometimes this value is configurable via an enviroment variable and some time it is not. Be sure to consult this table to determine the user account you should be using. In these situations, you will have to `chown` the files on your backing storage before exposing them to Kubernetes via Persistent Volumes. Otherwise your pod will have permissions issues. In most situations you will also need to modify the environment variables set in the `kustomization.yml` file before deploying. 

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

Be sure to modify the environment varibles present within `kustomization.yml`. You will need to replace the contents of `PLEX_CLAIM` immediatly before deploying as the token that is generated at https://www.plex.tv/claim/ expires after 4 minutes. Depending on your network connection and computing resources you may cut it close. 