| Jira        | Hardcoded to run as `2001:2001`. `chown` your mounted data accordingly. |
| Plex        | `chown` your mounted data to a single UID/GID and set the variables in `kustomization.yml`. |
| Radarr      | `chown` your mounted data to a single UID/GID and set the variables in `kustomization.yml`. |
| Sonarr      | `chown` your mounted data to a single UID/GID and set the variables in `kustomization.yml`. |
| Tautulli    | `chown` your mounted data to a single UID/GID and set the variables in `kustomization.yml`. |
<hr>
### Jira

Modify both of the variables within `postgres_password` to have a unique password. The password should be **the same** for both variables as they represent the Postgres password created for the application's database. They are both simply the unique environment variable that their respective container is hardcoded to receive.



### Sonarr

You will need to provide an overlay to configure your environment variables, persistent storage, and networking.

### MetalLB

Be sure to modify the ConfigMap according to your environment. MetalLB operates in both Layer2 and BGP and your configuration may differ drastically. See here for more information and examples:

https://metallb.universe.tf/configuration/

### OpenEBS

OpenEBS requires that you install dependencies on the operating systems of the worker nodes prior to installation. Run the following Ansible playbook to install & configure these dependencies and then deploy OpenEBS to your cluster. If you wish to provide a specific OpenEBS Manifest or configure a specific Storage Driver, be sure to modify the variables  in `./OpenEBS/roles/deploy_openebs/vars/main.yml` before running the playbook.

```bash
ansible-playbook -i ansible/inventory.ini ansible/deploy_openebs.yml
```

### OpenVPN Access Server

OpenVPN is a complicated application to configure when using virtualized networking. The basic gist of it is:

1. Configure your overlay as usual and deploy the application.

   ```bash
   kubectl apply -k OpenVPN-as/overlays/example
   ```

2. Log in with the default credentials: `admin` : `password`.
3. Read the License Agreement and click `Agree` to continue.
4. Click `User Management` -> `User Permissions` and create a new user.
   * Click the `Admin` checkbox for this user.
   * Click the `More Settings` button and enter a `Local Password` for the user.
   * Click `Save Settings` to submit the new user configuration.
5. Log out of the Access Server and log in with your new user account. Return to the `User Permissions` page and check the `Delete` checkbox for the Admin user. Click `Save Settings` to finish removing this user account.
6. Click `Configuration` -> `Network Settings` and update the `Hostname or IP Address` field to the hostname that clients will use to connect to the VPN. Click `Save Settings`.
7. Click `VPN Settings` and update the configuration areas according to your environment. Click `Save Settings`.

   * At the bare minimum you will likely update the Routing section to include your specific subnets.
8. Click `Web Server` and upload your certificate information. Click `Save` and then click `Update Running Server` to apply the changes to the server.

   * You may lose access for several seconds and you will need to log in again after the server restarts.

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

### Radarr

You will need to provide an overlay to configure your environment variables, persistent storage, and networking.

### Sonarr

You will need to provide an overlay to configure your environment variables, persistent storage, and networking.

### Tautulli

My deployment of Tatulli assumes I want to monitor a Plex log directory. I assume yours does to. So you will need to modify the `pv.yml` to point to your specific storage location. Furthermore, you will need to modify the `svc.yml` according to your network configuration.

### Toodo

You will need to provide an overlay to configure your environment variables, persistent storage, and networking.

