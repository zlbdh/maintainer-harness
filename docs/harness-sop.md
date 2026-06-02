# Harness SOP

## Goal

Move maintainer work from ad hoc chat into structured, reviewable files.

## Standard Flow

1. Create a change id.
2. Fill `brief.md`.
3. Fill `impact.yaml`.
4. Fill `execution.yaml`.
5. Generate task cards.
6. Prepare worker packets.
7. Run local validation.
8. Record acceptance.
9. Prepare release notes.
10. Write the postmortem.

## Minimal Commands

```powershell
.\scripts\checks\validate-repos.ps1
.\scripts\bootstrap\verify-workspace.ps1
.\scripts\checks\validate-change.ps1 -ChangeId CHG-2026-0001-sample-change
.\scripts\checks\run-local-baseline.ps1 -SkipCommandExecution
```

## Human Approval Gates

Human approval is required before:

- pushing to a remote repository
- creating a pull request
- running write-capable production tools
- transmitting sensitive data
- changing repository ownership or release policy
