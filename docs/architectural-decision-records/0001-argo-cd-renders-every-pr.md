# 0001. Argo CD renders a PR's apps before it merges, through argocd-diff-preview

- Status: Accepted
- Date: 2026-11-06
- Decider: TJ, 2026-11-06, in zimmertr/yggdrasil#7, choosing to trial argocd-diff-preview over keeping the shell steps
- Issues and PRs: zimmertr/yggdrasil#7, #1915
- Cited in code as: none
- Guide: [`CLAUDE.md`](../../CLAUDE.md), Rules, "A PR's apps are rendered by Argo CD before it merges"

## Context

`Validate manifests` was inline shell: PyYAML parsed each changed YAML file, kustomize was downloaded by hand with a checksum Renovate couldn't move, and a loop walked each changed file up to its kustomization and built it. zimmertr/yggdrasil#7 asks every repo to replace its own scripts with a maintained tool where one exists.

## Decision

- `Validate manifests` runs argocd-diff-preview in Docker. It creates a kind cluster on the runner, installs Argo CD, renders the PR's apps on `main` and on the PR, and posts the diff as a sticky comment. A manifest Argo CD can't render fails the job.
- The ApplicationSets and the two root Applications carry `argocd-diff-preview/watch-pattern` annotations, so only the apps whose folder the PR touches are rendered.
- The throwaway Argo CD is the chart version `argo/argo-cd` pins, with `--enable-helm`, as the cluster runs it.
- The image is pinned by tag and digest, and Renovate moves both.

## Evidence

- 2026-11-06, #1915: with every app selected (the annotations weren't on `main` yet), the job rendered 28 apps on each branch in 29 seconds, and took 1 minute 37 seconds in all.
- 2026-11-06, #1915: a kustomization listing a missing file failed the job with `Failed to extract application` for that app, after the 300-second timeout.
- 2026-11-06: without `--enable-helm`, every app with `helmCharts` failed with kustomize's "must specify --enable-helm", which is why the setting is passed.

## Alternatives rejected

- Keeping the shell and swapping yamllint in for PyYAML: no maintained tool renders only the kustomizations a PR touches, so the loop would stay.
- Rendering with kustomize alone: it misses what Argo CD adds, such as the ApplicationSets' generators.

## Consequences

- A broken app fails the job only after the 300-second timeout, instead of at once.
- The job needs `pull-requests: write` for its comment.
- A new top-level folder's ApplicationSet needs the watch patterns, or every PR renders its apps. A new app inside an existing folder is covered by the template's pattern.
