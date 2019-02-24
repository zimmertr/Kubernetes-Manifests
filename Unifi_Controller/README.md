## Unifi Controller

<p align="center">
  <img src="https://raw.githubusercontent.com/zimmertr/Kubernetes-Manifests/master/Unifi_Controller/screenshot.png" width="800">
</p>

**Summary:**

These manifests are used to deploy the Unifi Controller to Kubernetes. They rely on MetalLB to configure a load balancer as well as an exported NFS mountpoint that Kubernetes can bind to with a persistent volume in order to store Unifi's configuration. Furthermore, additional configuration will be necessary at the software level and device discovery may not work. (Or my network might just suck)

Approximate Deployment Time: 10-15 minutes

* [Project Docker Containers](https://github.com/linuxserver/docker-unifi)

**Requirements:**

    1) Exported NFS Server with which Kubernetes can communicate.  
    2) Working load balancer integrated with Kubernetes Services. (https://metallb.universe.tf/)  
    3) Python modules required to use the k8s Ansible module (https://docs.ansible.com/ansible/latest/modules/k8s_module.html).    
        * pip install openshift kubernetes pyyaml 
        * If you're on MacOS, you might have to do this instead (https://github.com/ansible/ansible/issues/43637#issuecomment-443495763).

**Instructions:**

*Optional:*

    1) Export a backup of your existing Unifi Controller settings to a .unf file.
    2) If you plan on running the controller on a different network than your AP's, you can likely set DHCP options for remote discovery on your router. Instructions can be found here: https://help.ubnt.com/hc/en-us/articles/204909754-UniFi-Device-Adoption-Methods-for-Remote-UniFi-Controllers

*Required:*

    1) Stop any existing Unifi Controllers on the same network.
    2) Make sure you satisfy the above requirements.   
    3) Fill out the `vars.yml` file with the parameters specific to your environment.  
    4) Execute the playbook: `ansible-playbook provision.yml`.  
    5) Once it has been deployed, connect to the LB IP/DNS and you will be greeted by the Welcome Wizard.
    6) If you took a backup, feel free to restore it. You will need to delete your devices, however, as the relationship will have been broken.
        - Devices -> Device -> Config -> Manage Device -> Forget
    7) Reset your Ubiquiti devices to factory defaults.
    8) SSH into your Unifi Devices and manually inform the controller of their existence.
        - `set-inform http://>{IP,HOSTNAME}<:8080/inform`
    9) After a few moments, your devices will appear in the Controller. Click Adopt and configure away. 
        - If your devices get stuck in an Adopting -> Disconnected loop make sure that your `Controller Hostname/IP` is configured correctly in the settings. This should automatically be set by the `system.properties` injection, however. You can test this by SSHing into the device and trying to resolve the Unifi Controller LB IP/DNS.

**TODO:**

    1) Set up liveness/readiness probes against status api endpoint.  
    2) Monitor resource utilization and configure limits and requests.   
    3) Test to see if password allows for special characters correctly.  


**Problems:**

    1) Scaling this up to more than one pod causes issues. Load Balancing the controller does not appear to be supported. 
        - https://community.ubnt.com/t5/UniFi-Feature-Requests/Unifi-Controller-Redundancy/idi-p/680341
        - Currently trying to decentralize the MongoDB instance to resolve this.
        - Installing a proper certificate may remediate the issue.

**Deletion:**

    1) You can roll back this deployment with the `delete.yml` playbook: `ansible-playbook delete.yml`.
        - Please note, this will not remove the deployed namespace because I cannot be sure you didn't specify an existing namespace. I would hate to delete your `default` for example. So you must manually clean that up. `kubectl delete ns >namespace name<`
