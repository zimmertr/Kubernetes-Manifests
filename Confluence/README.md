## Confluence

<p align="center">
  <img src="https://raw.githubusercontent.com/zimmertr/Kubernetes-Manifests/master/Confluence/screenshot.png" width="800">
</p>

**Summary:**

These manifests are used to deploy an instance of Confluence. They rely on MetalLB to configure a load balancer as well as an exported NFS mountpoint that Kubernetes can bind to in order to store Persistent Volumes for the configuration as well as the other files that the server will interact with. Please be aware, Jira Software requires at minimum a trial [license](https://www.atlassian.com/software/confluence/pricing?tab=self-managed) to operate. 

Approximate Deployment Time: 1-5 minutes

**Requirements:**  

    1) Exported NFS Server with which Kubernetes can communicate.  
    2) Directory structsure created on the NFS Endpoint you specify in `vars.yml`.
    3) Working load balancer integrated with Kubernetes Services. (https://metallb.universe.tf/)  
    4) Python modules required to use the k8s Ansible module (https://docs.ansible.com/ansible/latest/modules/k8s_module.html).    
        * pip install openshift kubernetes pyyaml 
        * If you're on MacOS, you might have to do this instead (https://github.com/ansible/ansible/issues/43637#issuecomment-443495763).

**Instructions:**  

    1) Make sure you satisfy the above requirements.   
    2) Fill out the `vars.yml` file with the parameters specific to your environment.  
    3) Execute the playbook: `ansible-playbook provision.yml`.  
    4) Navigate to `hostname`:8080/ and click `Production Installation`.
    5) If you have a license for an additional App, feel free to select it now. Otherwise, click `Next`.
    6) Insert your Confluence License and click `Next`.
    5) Select `My Own Database` and configure the database like so:
        - Database Type: PostgreSQL
        - Setup Type: Simple
        - Hostname: postgres
        - Port: 5432
        - Database name: confluence
        - Username: confluence
        - Password: >Password set in vars.yml<
    6) Click 'Next' and wait for the Postgres database to be configured by Confluence.
        - You tail `tail` the logs for the Confluence pod on Kubernetes to watch the progress.
    7) From there, you can click `Next` and finish configuring the software as normal.

**Deletion:**  

    1) You can roll back this deployment with the `delete.yml` playbook: `ansible-playbook delete.yml`.
        - Please note, this will not remove the deployed namespace because I could not be sure you didn't specify an existing namespace. I would hate to delete your `default` for example. So you must manually clean that up. `kubectl delete ns >namespace name<`
