# Istio

This application is meant to be deployed to Kubernetes using Ansible.

* **Website**: https://istio.io/
* **Container Image:** https://hub.docker.com/u/istio

<hr>

## Instructions

Set the version of Istio you wish to install in `./roles/deploy_istio/vars/main.yml` and execute `ansible-playbook deploy_istio.yml` to deploy Istio using your current Kube context.
