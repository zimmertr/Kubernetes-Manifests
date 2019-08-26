## OpenVPN-as

<p align="center">
  <img src="https://raw.githubusercontent.com/zimmertr/Kubernetes-Manifests/master/OpenVPN-as/screenshot.png" width="800">
</p>

**Summary:**

These manifests are used to deploy an instance of *OpenVPN Access Server*. 

Approximate Deployment Time: 10-20 minutes

**Requirements:**  

1. Load Balancer integration so that the Service can expose the pods.
2. NFS Server to which Kubernetes can bind Persistent Volumes.
3. Directory structsure created on the NFS Endpoint you specify in `vars.yml`.
4. Python modules required to use the k8s [Ansible module](https://docs.ansible.com/ansible/latest/modules/k8s_module.html).    
    * pip install openshift kubernetes pyyaml 
    * If you're on MacOS, you might have to do [this](https://github.com/ansible/ansible/issues/43637#issuecomment-443495763) instead.
5. Requires `NET_ADMIN` privileges in order to perform various network-related tasks.

**Instructions:**  

1. Modify `vars.yml` with parameters according to your environment.
2. Create the necessary directories defined in `vars.yml` on your NFS server.
3. Execute the playbook: `ansible-playbook provision.yml`.  
4. Navigate to https://host.name:943/admin to access the software.
5. Log in with the default credentials: `admin` : `password`.
6. Read the License Agreement and click `Agree` to continue.
7. Click `User Management` -> `User Permissions` and create a new user.
    * Click the `Admin` checkbox for this user.
    * Click the `More Settings` button and enter a `Local Password` for the user.
    * Click `Save Settings` to submit the new user configuration.
8. Log out of the Access Server and log in with your new user account. Return to the `User Permissions` page and check the `Delete` checkbox for the Admin user. Click `Save Settings` to finish removing this user account.
9. Click `Configuration` -> `Network Settings` and update the `Hostname or IP Address` field to the hostname that clients will use to connect to the VPN. Click `Save Settings`.
10. Click `VPN Settings` and update the configuration areas according to your environment. Click `Save Settings`. 
    * At the bare minimum you will likely update the Routing section to include your specific subnets.
11. Click `Web Server` and upload your certificate information. Click `Save` and then click `Update Running Server` to apply the changes to the server.
    * You may lose access for several seconds and you will need to log in again after the server restarts. 

**Tips:**

1. If you wish to change any of the ports that OpenVPN-as uses, for example moving the web interface from 943 to 443, you will need to also update the corresponding ports in the Service and Deployment files as well. 

```
kubectl edit -n openvpn-as svc openvpn-tcp
kubectl edit -n openvpn-as deploy openvpn
```

**TODO:**

1. Figure out a way to allow this to scale to more than one pod.

**Deletion:**  

1. You can roll back this deployment with the `delete.yml` playbook: `ansible-playbook delete.yml`.
    * Please note, this will not remove the deployed namespace because I could not be sure you didn't specify an existing namespace. I would hate to delete your `default` for example. So you must manually clean that up. `kubectl delete ns >namespace name<`
