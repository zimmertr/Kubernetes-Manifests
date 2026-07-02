# OpenEBS

This application is meant to be deployed to Kubernetes using Kustomize. 

* **Website**: https://openebs.io/
* **Container Images:** https://quay.io/organization/openebs

<hr>

## Instructions

OpenEBS requires that you install dependencies on the operating systems of the worker nodes prior to installation. Run the following Ansible playbook to install & configure these dependencies and then deploy OpenEBS to your cluster. If you wish to provide a specific OpenEBS Manifest or configure a specific Storage Driver, be sure to modify the variables  in `./OpenEBS/roles/deploy_openebs/vars/main.yml` before running the playbook.

```bash
ansible-playbook -i ansible/inventory.ini ansible/deploy_openebs.yml
```
