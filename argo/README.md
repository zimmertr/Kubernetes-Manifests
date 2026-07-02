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
kustomize build --enable-helm argo-cd | kubectl apply -f- --server-side --force-conflicts
```

Once Argo CD is running, bootstrap the rest of the cluster with the [app-of-apps](../bootstrap/README.md) pattern. These two root Applications recursively discover and manage every `AppProject` and `ApplicationSet` in the repository — including this group's, which manage Argo CD, Argo Rollouts, and Argo Workflows. Apply the projects first:

```bash
kubectl apply -f ../bootstrap/appprojects.yml
kubectl apply -f ../bootstrap/applicationsets.yml
```
