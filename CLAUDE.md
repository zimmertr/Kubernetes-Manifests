# Kubernetes-Manifests

Everything TJ runs on the TKS cluster, as kustomizations that Argo CD syncs from `main`. Start with [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

This repo took a trimmed set of the files a new project starts with (zimmertr/yggdrasil record 0038). When a change here makes a decision, write its record; when it needs a page `docs/` doesn't have yet, add it in the same PR.

## Documentation

A change that makes any page untrue updates it in the same PR. The README is TJ's: keep it accurate and in his voice, and never restructure it.

| Doc | Holds |
|---|---|
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | The folders, the root Applications, the ApplicationSets and projects, what is disabled |
| [`docs/CICD.md`](docs/CICD.md) | The PR checks, the bump PRs other repos open, Renovate, and Argo CD's sync after a merge |
| [`docs/CONFIGURATION.md`](docs/CONFIGURATION.md) | `renovate.json`'s rules, the watch-pattern annotations, and where Secrets and volumes come from |
| [`docs/USAGE.md`](docs/USAGE.md) | What TJ sees on a PR and in Argo CD, and what to do when it breaks |
| [`docs/architectural-decision-records/`](docs/architectural-decision-records/README.md) | One record per decision. The README is the index and says how to write one |

## Rules

- **`main` is what runs.** Argo CD syncs every app from `main` with prune and self-heal, so a merge is a deploy.
- **A PR's apps are rendered by Argo CD before it merges.** `Validate manifests` runs argocd-diff-preview, which renders the apps the PR touches in a throwaway cluster and posts the diff. A new app folder's ApplicationSet already carries the watch pattern. Record: [0001](docs/architectural-decision-records/0001-argo-cd-renders-every-pr.md)
- **Other repos' releases write their own tags.** bluebird, bluebird-helm, hevy-garmin-sync, Personal-Website and Mountaineers-Activity-Scraper open the bump PRs for their image tag and chart version, and Renovate is told to leave those packages alone. Don't edit those lines by hand.
- **No Secrets in the repo.** Secrets and statically provisioned volumes are created by hand, as the README lists.
- **Renovate's shared rules live in zimmertr/yggdrasil.** `.github/renovate.json` extends its preset and adds only this repo's own rules ([CONFIGURATION.md](docs/CONFIGURATION.md#renovate)). A rule every repo wants goes in the preset, not here.

## Issues

File issues with the `create-issue` skill from zimmertr/ai-config: the two-sentence summary, the six sections, the hemingway and humanizer passes, one priority, one type, the area labels and the session label. The skill reads the four things below from this section.

- **The reader**: TJ, who runs the cluster and knows Kubernetes and Argo CD.
- **The gates**: `Validate manifests`, `PR Title / PR Title` and the three `Lint /` checks pass; the `docs/` page that owns the topic changes in the same PR; the README changes only to stay accurate.
- **The constraints**: never change the cluster with `kubectl` without TJ's okay (reads are fine); no Secret values in the repo or in logs; the release-owned tags stay out of Renovate.
- **The areas**: `kubernetes` (an app's manifests, Argo CD, the ApplicationSets), `ci` (the workflows and Renovate), `security`.

## Working in this repo

- Work in a fresh clone in the session's scratchpad, never in TJ's checkout. Branch from the latest `origin/main`.
- Everything reaches main through a squash-merged PR. Never push to main.
- The PR title is `type(scope): summary`; the `PR Title` check refuses anything else.
- CI runs on zimmertr/yggdrasil's `pr-title` and `lint` modules, pinned by commit SHA with the version beside it. Renovate bumps the pin, and a patch or minor merges itself with no wait.
- Actions are pinned to commit SHAs with the version in a comment, and so is the argocd-diff-preview image (tag and digest).
