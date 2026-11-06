# Security Policy

## Supported Versions

There are no versions. `main` is what the cluster runs, and a fix ships as the next merge.

## Reporting a Vulnerability

Please report vulnerabilities privately through GitHub:
[Report a vulnerability](https://github.com/zimmertr/Kubernetes-Manifests/security/advisories/new).
Do not open a public issue for security problems.

Include what you found, where it lives (file, workflow, or deployed app), and how to reproduce it.

What to expect:

- **Acknowledgement** within a few days. This is a one-person project, so response times are best effort.
- **Fix**: a confirmed vulnerability is fixed in the next merge, which Argo CD deploys.
- **Credit** in the advisory, unless you'd rather not.

## Scope

In scope: the manifests, the Terraform in `terraform/cloudflare`, and the CI workflows.

Out of scope: the upstream charts and images these manifests deploy. Report issues in those to their maintainers.

There is no bounty program. Reports are still appreciated.
