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

Once Argo CD is running, bootstrap the rest of the cluster with the [app-of-apps](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/) pattern. The two root Applications at the repo root recursively discover and manage every `AppProject` and `ApplicationSet` in the repository — including this group's, which manage Argo CD, Argo Rollouts, and Argo Workflows. Apply the projects first:

```bash
kubectl apply -f ../root-appproject.yml
kubectl apply -f ../root-applicationset.yml
```
