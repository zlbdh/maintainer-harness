# Cross-Platform Validation

Maintainer Harness started as a Windows PowerShell workflow, but the public validation gates should be inspectable by maintainers on common open source development platforms.

## CI Coverage

The `harness-validation.yml` workflow runs the core validation gate on:

- `windows-latest`
- `ubuntu-latest`
- `macos-latest`

The cross-platform gate covers:

- repository metadata validation
- harness structure validation
- synthetic sample change validation
- issue-to-review packet validation
- release workflow packet validation
- machine-readable discovery and baseline dry-run output
- public readiness checks
- security posture checks

## Local Commands

Use PowerShell 7 or newer where possible. The same command shape works on Windows, Linux, and macOS:

```powershell
./scripts/checks/validate-repos.ps1
./scripts/bootstrap/verify-workspace.ps1
./scripts/checks/validate-change.ps1 -Path examples/sample-change
./scripts/checks/validate-change.ps1 -Path examples/issue-to-review
./scripts/checks/validate-change.ps1 -Path examples/release-workflow
./scripts/checks/check-public-ready.ps1 -SkipSensitivePattern
./scripts/checks/check-security-posture.ps1 -SkipSensitivePattern
```

## Current Boundary

The cross-platform promise is intentionally limited to public validation gates. Worker orchestration scripts still prioritize the Windows maintainer workflow until real Linux or macOS dogfooding feedback arrives.

When expanding the harness, prefer repository-relative paths with `/` and resolve them through `Join-HarnessPath` before calling `Test-Path`, `Get-Content`, or another file API.
