# Kubernetes Manifests 

## Summary

A collection of Kubernetes Manifests separated by project for use with deploying to my [personal Kubernetes Cluster](https://github.com/zimmertr/Bootstrap-Kubernetes-with-QEMU).

## Personal Website With JS Terminal Emulator

**Summary:**

These manifests are used to build my personal website. They rely on MetalLB to configure a load balancer as well as an exported NFS mountpoint that Kubernetes can bind to with a persistent volume in order to serve up public files. 

[Project Source](https://github.com/zimmertr/Personal-Website-With-JS-Terminal-Emulator)

[Project Docker Containers](https://github.com/zimmertr/Personal-Website-With-JS-Terminal-Emulator/tree/master/Docker)

**Requirements:**

    1) Exported NFS Server with which Kubernetes can communicate.
    2) Working [load balancer](https://metallb.universe.tf/) integrated with Kubernetes Services.
    3) Wunderground [API key](https://www.wunderground.com/weather/api/)
    4) Google Analytics [Tracking ID](https://developers.google.com/analytics/devguides/collection/analyticsjs/)
    5) Python modules required to use the [k8s Ansible module](https://docs.ansible.com/ansible/latest/modules/k8s_module.html).
        a) 

**Instructions:**
    1) Make sure you satisfy the above requirements. 
    2) Fill out the `vars.yml` file with the parameters specific to your environment.
    3) Create a python virtual environment: `python3 -m venv .env`
    4) Connect to the virtual environment: `source .env/bin/activate`
    5) Install the required modules: `pip install openshift kubernetes pyyaml`
        * tl;dr: `pip install openshift kubernetes pyyaml`
        * If you're on MacOS, you might have to [do this instead](https://github.com/ansible/ansible/issues/43637#issuecomment-443495763).
    6) Execute the playbook: `ansible-playbook provision.yml`
