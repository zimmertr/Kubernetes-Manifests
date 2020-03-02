# Kubernetes Manifests

## Summary

A collection of Kustomize projects for deploying applications to Kubernetes.

### Pre-Instructions

# SSH

### OpenEBS

1. OpenEBS requires that you install dependencies on the operating systems of the worker nodes prior to installation.
```
ansible-playbook -i ansible/inventory.ini ansible/deploy_openebs.yml
```
