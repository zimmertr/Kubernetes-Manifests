## Unifi Controller

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

*Required:*
    1) Stop your existing Unifi Controller service.
    2) Make sure you satisfy the above requirements.   
    3) Fill out the `vars.yml` file with the parameters specific to your environment.  
    4) Execute the playbook: `ansible-playbook provision.yml`.  
    5) Once it has been deployed, connect to the LB IP/DNS and you will be greeted by the Welcome Wizard.
    6) If you took a backup, feel free to restore it. You will need to delete your devices, however, as the relationship will have been broken.
    7) Configure your Unifi Controller to be informed over a different identity. 
        - Enable `Override inform host with controller hostname/IP`
        - Set Controller Hostname/IP to the IP associated with your load balancer service.
            - Hostname if your DHCP server pushes out your DNS server to all clients.
            - IP Address otherwise, since your Unifi devices won't be able to resolve DNS by default. 
    8) Hardware reset your Unifi devices.
    9) SSH into your Unifi Devices and manually inform the controller of their existence.
        - `set-inform http://>{IP,HOSTNAME}<:8080/inform`
    10) After a few moments, your devices will appear in the Controller. Click Adopt and configure away. 


**Problems:**
    1) Unfortunately I have not gotten Device Discovery to work yet. It could be my network. 
    2) Controller may eventually report that APs are no longer working. But they will be?

**Deletion:**  

    1) You can roll back this deployment with the `delete.yml` playbook: `ansible-playbook delete.yml`.
        - Please note, this will not remove the deployed namespace because I could not be sure you didn't specify an existing namespace. I would hate to delete your `default` for example. So you must manually clean that up. `kubectl delete ns >namespace name<`
