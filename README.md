# Kubernetes Manifests

## Summary

A collection of applications meant to be deployed to Kubernetes.

Using Proxmox? Consider using [TKS](https://github.com/zimmertr/TJs-Kubernetes-Service) to deploy your cluster!

## Instructions

To apply an individual application:

```bash
kubectl kustomize --enable-helm $APP | kubectl apply -f-
```

To apply everything:

```bash
kubectl kustomize --enable-helm argo-cd | kubectl apply -f-
watch kubectl get all -n argo-system # Wait for Argo to be finished deploying
kubectl apply -f applicationset.yml
```

