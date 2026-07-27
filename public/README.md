# Public

* [Summary](#summary)
* [Instructions](#instructions)
  * [Bluebird](#bluebird)
  * [Bluebird PR](#bluebird-pr)
  * [CertManager](#certmanager)
  * [Personal Website](#personal-website)

<hr>

## Summary

Public is a collection of my public-facing applications.

<hr>

## Instructions

### Bluebird

[Bluebird](https://bluebirdforecast.com) is a map-based weather window finder for hikers and mountaineers. The Kustomize project inflates the [bluebird-helm](https://artifacthub.io/packages/helm/bluebird-helm/bluebird-helm) OCI chart and deploys behind Argo Rollouts (canary) and an Istio VirtualService.

The image tag in [bluebird/kustomization.yml](bluebird/kustomization.yml) is bumped automatically by the release workflow in [zimmertr/bluebird](https://github.com/zimmertr/bluebird) on every merge to `main`. Edit it by hand only to pin or roll back.

1. Modify the Kustomize project as per your needs.

2. Deploy to Kubernetes:
   ```bash
   kustomize build --enable-helm bluebird | kubectl apply -f-
   ```

### Bluebird PR

Bluebird PR provides ephemeral preview environments, one per pull request in [zimmertr/bluebird](https://github.com/zimmertr/bluebird). An Argo CD `pullRequest` generator watches for PRs labeled `create pr container` and deploys the `zimmertr/bluebird-pr:pr-<number>-<sha>` image at `pr-<number>.ganymede.sol.milkyway`. Applications are pruned automatically once the PR is closed or the label is removed.

Unlike the rest of `public/`, this directory has no Kustomize project. It owns its own `ApplicationSet` and `AppProject`, and is excluded from the `public/*` generator in [applicationset.yml](applicationset.yml) so the [root generators](../README.md#argo-cd) manage it directly. Nothing needs to be applied by hand once the cluster is bootstrapped.

1. To apply the resources ahead of a bootstrap, or after editing them:
   ```bash
   kubectl apply -f bluebird-pr/appproject.yml
   kubectl apply -f bluebird-pr/applicationset.yml
   ```

### CertManager

[Cert Manager](https://cert-manager.io/) is a tool used to request and manage X509 certificates.

1. Modify the Kustomize project as per your needs.

2. Deploy to Kubernetes:
   ```bash
   kustomize build --enable-helm cert-manager | kubectl apply -f-
   ```

### Personal Website

[Personal Website](https://tjzimmerman.com) is my personal website.

1. Modify the Kustomize project as per your needs.

2. Deploy to Kubernetes:
   ```bash
   kustomize build --enable-helm personal-website | kubectl apply -f-
   ```
