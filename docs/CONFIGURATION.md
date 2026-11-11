# Configuration

The settings that shape how this repo is checked and kept current. Each app's own settings live in its folder's `values.yml` and kustomization.

## Renovate

`.github/renovate.json` extends `config:recommended`, so Renovate finds image tags and chart versions in the manifests, and actions in the workflows. Each rule carries its reason in its `description`:

- Minor and patch updates merge themselves once they are seven days old.
- zimmertr/yggdrasil's module pin merges itself after three days, the wait every repo that calls the modules uses.
- `ghcr.io/zimmertr/bluebird`, `ghcr.io/zimmertr/bluebird-helm`, `ghcr.io/zimmertr/hevy-garmin-sync-helm`, `ghcr.io/zimmertr/personal-website` and `ghcr.io/zimmertr/mountaineers-activity-scraper` are off: those repos' releases write their tags here ([CICD.md](CICD.md#bump-prs-from-other-repos)).
- `ghcr.io/ggml-org/llama.cpp` follows only its `light-b<build>` tags.
- A regex manager reads `# renovate:` comments on workflow `env:` lines, such as `DIFF_PREVIEW_IMAGE`. A value may carry `@sha256:` and a digest, and Renovate moves both.
- Folders matching `*/*.disabled/*` are ignored.

## Watch patterns

`Validate manifests` renders only the apps a PR touches ([CICD.md](CICD.md#what-validate-manifests-renders)). It reads the `argocd-diff-preview/watch-pattern` annotation, a regex matched against the PR's changed files:

| Where | Pattern | Renders when |
|---|---|---|
| Each folder's ApplicationSet | `<folder>/.*` | Anything in the folder changes |
| Each ApplicationSet's template, so each generated app | `{{ path }}/.*` | Anything in that app's folder changes |
| `public/bluebird-pr/applicationset.yml` | `public/bluebird-pr/.*` | The preview set or its project changes |
| `root-applicationset.yml` | `(.*/)?applicationset\.yml` | Any ApplicationSet changes |
| `root-appproject.yml` | `(.*/)?appproject\.yml` | Any AppProject changes |

Argo CD itself ignores these annotations. A new folder of apps copies its ApplicationSet from a sibling, annotations included.

## The throwaway Argo CD

`pr.yml` gives argocd-diff-preview a `values.yaml` with `configs.cm."kustomize.buildOptions": "--enable-helm"`, the one setting from `argo/argo-cd/values.yml` the apps need to render, and the chart version from `argo/argo-cd/kustomization.yml`. The image is pinned by tag and digest in `DIFF_PREVIEW_IMAGE`.

## Secrets and volumes

Not in the repo. The README lists every Secret and ZFS volume to create by hand, and the outputs of zimmertr/yggdrasil's `terraform/cloudflare` some of them read.
