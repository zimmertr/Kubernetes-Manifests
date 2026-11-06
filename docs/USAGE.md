# Usage

What TJ sees from this repo, and what to do when it breaks.

## On a PR

- **An "Argo CD Diff Preview" comment** with the rendered diff of every app the PR touches, updated on each push.
- **Bump PRs from other repos' releases** (`chore: bump ...`). They merge themselves once the checks pass.
- **Renovate PRs** (`chore(deps): update ...`). Minor and patch merge themselves after seven days, yggdrasil's pin after three. Majors wait for TJ.

## In Argo CD

Every app syncs from `main` within Argo CD's poll after a merge. Refresh one app to skip the wait:

```bash
kubectl -n argo-system annotate application <app> argocd.argoproj.io/refresh=normal --overwrite
```

## When it breaks

- **`Validate manifests` fails with "Failed to extract application".** Argo CD couldn't render that app. The error in the job's log is the same one Argo CD would show after a merge, such as a missing file or a chart that won't template. Fix the manifest in the PR.
- **`Validate manifests` times out.** A PR that touches many apps can need more than the job's `TIMEOUT` (300 seconds). Raise it in `pr.yml`, or split the PR.
- **A bump PR doesn't merge itself.** One of the checks failed on it; the job's log says which app. Fix forward in the releasing repo, or fix the manifest here in its own PR.
- **An app is OutOfSync or Degraded after a merge.** The render passed but the cluster refused it, often a missing Secret or volume. Check the README's list, and the app's events with `kubectl`.
