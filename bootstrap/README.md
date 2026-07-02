# Bootstrap

This directory implements the [app-of-apps](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/) pattern using two root Argo CD `Application` resources. You apply these two by hand once; afterward they recursively discover and manage every `AppProject` and `ApplicationSet` in the repository.

* `appprojects.yml` — recurses the repo root and syncs every `**/appproject.yml` (the per-group `AppProject` resources).
* `applicationsets.yml` — recurses the repo root and syncs every `**/applicationset.yml` (the per-group `ApplicationSet` resources).

Both exclude the `old/**` directory and any `**/*.disabled` files.

## Usage

Once Argo CD itself is running (see the [Argo](../argo/README.md) README), apply the two root apps. Apply the `AppProject`s **first** so the projects exist before the `ApplicationSet`-generated `Application`s reference them:

```bash
kubectl apply -f bootstrap/appprojects.yml
kubectl apply -f bootstrap/applicationsets.yml
```

Both apps use `selfHeal: true`, so ordering is not strictly required — Argo CD will converge either way — but applying projects first avoids transient "project not found" errors.

## Disabling a resource

Both root apps use a directory source with `include`/`exclude` globs, so an individual resource is disabled by renaming its file so it no longer matches the `include` glob:

```bash
# Disable a group's ApplicationSet
mv media/applicationset.yml media/applicationset.yml.disabled

# Disable a group's AppProject
mv media/appproject.yml media/appproject.yml.disabled
```

Because the file no longer matches the `include` glob, the corresponding resource drops out of the root app's manifest set and is pruned. This mirrors the existing `git`-generator convention where `ApplicationSet`s exclude `<group>/*.disable*` subdirectories.
