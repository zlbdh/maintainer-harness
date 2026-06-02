# Changes

Each directory under `changes/` represents one auditable maintainer change.

Recommended name format:

```text
CHG-YYYY-NNNN-short-slug
```

A complete change should contain:

```text
brief.md
impact.yaml
execution.yaml
design.md
acceptance.md
tasks/
verification/
postmortem.md
```

Use the bootstrap script to create a new change:

```powershell
.\scripts\bootstrap\init-change.ps1 -ChangeId CHG-2026-0001-sample-change -Title "Sample change"
```

The task cards are generated from the repositories listed in `repos/repos.yaml`.
