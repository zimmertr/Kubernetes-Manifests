# Application Manifests

## Summary

A collection of applications meant to be deployed to Kubernetes.

## Instructions

To apply an individual application:

```bash
kubectl kustomize --enable-helm $APP | kubectl apply -f-
```

To apply everything:

```bash
kubectl kustomize --enable-helm argo-cd | kubectl apply -f-
kubectl apply -f applicationset.yml
```

