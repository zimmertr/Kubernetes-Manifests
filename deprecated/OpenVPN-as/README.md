# OpenVPN Access Server

This application is meant to be deployed to Kubernetes using Kustomize. 

* **Website**: https://openvpn.net/vpn-server/
* **Container Image:** https://hub.docker.com/r/linuxserver/openvpn-as

<hr>

## Instructions

1. An example overlay is provided from my environment. Simply create a new overlay using it as an example and deploy it to your environment like so:

   ```bash
    kustomize build OpenVPN-as/overlays/example | kubectl apply -f-
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
