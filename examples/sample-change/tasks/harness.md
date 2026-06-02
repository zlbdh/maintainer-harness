# Task: Harness Documentation Validation

## Owner

`knowledge-agent`

## Scope

- Explain the sample maintainer workflow.
- Keep examples generic and synthetic.
- Avoid product-specific names, local paths, screenshots, credentials, private endpoints, and production logs.

## Allowed Paths

- `README.md`
- `docs/**`
- `examples/**`

## Validation

```powershell
.\scripts\checks\validate-repos.ps1
.\scripts\bootstrap\verify-workspace.ps1
.\scripts\checks\validate-change.ps1 -Path examples\sample-change
.\scripts\checks\check-security-posture.ps1 -SkipSensitivePattern
```
