# Verification Result

## Status

Review-ready synthetic example.

## Reviewer Evidence

- Source issue is sanitized in `issue-intake.md`.
- Impact is mapped in `impact.yaml`.
- Worker ownership, allowed paths, branch, lock state, and evidence paths are recorded in `execution.yaml`.
- Worker task card is bounded to `docs/**` and `examples/**`.
- Skipped live integrations are listed in `verification/workers/harness.md`.

## Expected Commands

```powershell
.\scripts\checks\validate-change.ps1 -Path examples\issue-to-review
.\scripts\checks\validate-repos.ps1
.\scripts\bootstrap\verify-workspace.ps1
.\scripts\checks\check-public-ready.ps1 -SkipSensitivePattern
.\scripts\checks\check-security-posture.ps1 -SkipSensitivePattern
```

## Acceptance Decision

Accept the packet as a public example if the commands pass and no private project identifiers, local paths, credentials, customer data, product screenshots, or production logs are introduced.
