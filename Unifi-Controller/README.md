## Unifi Controller

<p align="center">
  <img src="https://raw.githubusercontent.com/zimmertr/TKS-Deploy_Kubernetes_Apps/master/Unifi-Controller/screenshot.png" width="800">
</p>

**Summary:**

These manifests are used to deploy an instance of the *Unifi Controller*. 

Approximate Deployment Time: 10-15 minutes

**Requirements:**  

1. Load Balancer integration so that the Service can expose the pods.
2. NFS Server to which Kubernetes can bind Persistent Volumes.
3. Directory structsure created on the NFS Endpoint you specify in `vars.yml`.
4. Python modules required to use the k8s [Ansible module](https://docs.ansible.com/ansible/latest/modules/k8s_module.html).    
    * pip install openshift kubernetes pyyaml 
    * If you're on MacOS, you might have to do [this](https://github.com/ansible/ansible/issues/43637#issuecomment-443495763) instead.

**Instructions:**  

*Optional:*

1. Export a backup of your existing Unifi Controller settings to a .unf file.
2. If you plan on running the controller on a different network than your AP's, you can likely set DHCP options for remote discovery on your router. Instructions can be found [here](https://help.ubnt.com/hc/en-us/articles/204909754-UniFi-Device-Adoption-Methods-for-Remote-UniFi-Controllers).

*Required:*

1. Modify `vars.yml` with parameters according to your environment.
2. Create the necessary directories defined in `vars.yml` on your NFS server.
3. Stop any existing Unifi Controllers on the same network.   
4. Execute the playbook: `ansible-playbook provision.yml`.  
5. Navigate to https://host.name:8443/ to access the software.
6. If you took a backup, feel free to restore it. You will need to delete your devices, however, as the relationship will have been broken.
    * Devices -> Device -> Config -> Manage Device -> Forget
7. Reset your Ubiquiti devices to factory defaults.
8. SSH into your Unifi Devices and manually inform the controller of their existence.
    * `set-inform http://>{IP,HOSTNAME}<:8080/inform`
9. After a few moments, your devices will appear in the Controller. Click Adopt and configure away. 
    * If your devices get stuck in an Adopting -> Disconnected loop make sure that your `Controller Hostname/IP` is configured correctly in the settings. This should automatically be set by the `system.properties` injection, however. You can test this by SSHing into the device and trying to resolve the Unifi Controller LB IP/DNS.

**TODO:**

1. Test to see if password allows for special characters correctly.  
2. Figure out a way to allow this to scale to more than one pod.
    * Load Balancing the controller [does not appear to be supported](https://community.ubnt.com/t5/UniFi-Feature-Requests/Unifi-Controller-Redundancy/idi-p/680341).
3. Create init container to enforce that Unifi Controller does not start up before Mongo is ready.

**Deletion:**  

1. You can roll back this deployment with the `delete.yml` playbook: `ansible-playbook delete.yml`.
    * Please note, this will not remove the deployed namespace because I could not be sure you didn't specify an existing namespace. I would hate to delete your `default` for example. So you must manually clean that up. `kubectl delete ns >namespace name<`
