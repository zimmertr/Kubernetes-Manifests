# Argo

* [Summary](#summary)
* [Instructions](#instructions)
  * [Argo CD](#argo-cd)

<hr>

## Summary

Argo is a collection of Argo Applications.

<hr>

## Instructions

To get started, deploy Argo CD

```bash
kubectl kustomize --enable-helm argo-cd | kubectl apply -f-
```

Once Argo CD is running, you can use ApplicationSets to manage Argo CD, Argo Rollouts, and Argo Workflows.

```bash
kubectl apply -f applicationset.yml
```
