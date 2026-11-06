# Architectural decision records

One file for each decision: what was decided, when, who decided, and the evidence that settled it. A record sits beside the `CLAUDE.md` rule that states the decision today and does not replace it.

This folder started on 2026-11-06 (zimmertr/yggdrasil#7). Decisions made before then live in the commit history and in the reasons written beside the settings, such as each rule's `description` in `.github/renovate.json`.

## Write a record

- Copy [`0000-template.md`](0000-template.md) to `NNNN-slug.md` with the next free number. Numbers have four digits and are never reused.
- The title is the decision, as one sentence.
- Take the date and the decider from the conversation or issue that settled it, quoting the decider where the words exist.
- Give every observation the date it was made.
- Link the record from its `CLAUDE.md` rule as ` Record: [NNNN](docs/architectural-decision-records/NNNN-slug.md)`.
- A decision ships in the same PR as its record.

## Supersede a record

A new record that reverses an old one says `Supersedes NNNN` in its status line. The old record changes its status line to `Superseded by NNNN` and nothing else.

## Index

| Record | Decision | Date | Status |
|---|---|---|---|
| [0001](0001-argo-cd-renders-every-pr.md) | Argo CD renders a PR's apps before it merges, through argocd-diff-preview | 2026-11-06 | Accepted |
