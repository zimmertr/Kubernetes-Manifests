# Contributing

This repo is what TJ's cluster runs, so changes come through PRs that TJ reviews.

1. Branch from the latest `main`.
2. Make one change per PR, and title it `type(scope): summary`, such as `feat(ai): add open-webui`.
3. Open the PR. `Validate manifests` renders the apps you touched with Argo CD and posts the diff; read it before asking for review ([docs/CICD.md](docs/CICD.md)).
4. Update the `docs/` page that owns the topic in the same PR, and add a decision record when the PR makes a decision ([docs/architectural-decision-records](docs/architectural-decision-records/README.md)).

A new app goes in its own subfolder of the folder that fits it, as a kustomization; its folder's ApplicationSet picks it up. A new top-level folder needs its own `applicationset.yml`, with the watch patterns ([docs/CONFIGURATION.md](docs/CONFIGURATION.md#watch-patterns)), and its own `appproject.yml`.

Never commit a Secret. List any Secret or volume an app needs in the README instead.
