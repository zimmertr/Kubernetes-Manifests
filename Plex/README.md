## Plex Media Server

<p align="center">
  <img src="https://raw.githubusercontent.com/zimmertr/Kubernetes-Manifests/master/Plex/screenshot.png" width="800">
</p>

**Summary:**

These manifests are used to deploy an instance of Plex Media Server. They rely on MetalLB to configure a load balancer as well as an exported NFS mountpoint that Kubernetes can bind to in order to store Persistent Volumes for the configuration as well as the other files that the server will interact with. 

Approximate Deployment Time: 1-5 minutes

* [Project Docker Containers](https://github.com/plexinc/pms-docker)

**Requirements:**  

    1) Exported NFS Server with which Kubernetes can communicate.  
    2) Directory named `/Plex` created on the NFS Endpoint you specify in `vars.yml`.
    2) Working load balancer integrated with Kubernetes Services. (https://metallb.universe.tf/)  
    3) Python modules required to use the k8s Ansible module (https://docs.ansible.com/ansible/latest/modules/k8s_module.html).    
        * pip install openshift kubernetes pyyaml 
        * If you're on MacOS, you might have to do this instead (https://github.com/ansible/ansible/issues/43637#issuecomment-443495763).

**Instructions:**  

    1) Make sure you satisfy the above requirements.   
    2) Fill out the `vars.yml` file with the parameters specific to your environment.  
    3) Execute the playbook: `ansible-playbook provision.yml`.  


**Problems:**

    1) Scaling this up to more than one pod causes issues. 

    
**Deletion:**  

    1) You can roll back this deployment with the `delete.yml` playbook: `ansible-playbook delete.yml`.
        - Please note, this will not remove the deployed namespace because I could not be sure you didn't specify an existing namespace. I would hate to delete your `default` for example. So you must manually clean that up. `kubectl delete ns >namespace name<`
