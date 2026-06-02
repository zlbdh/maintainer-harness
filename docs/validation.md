# Validation

Maintainer Harness separates three validation levels.

The public GitHub Actions gate runs the core validation path on Windows, Ubuntu, and macOS. See `docs/cross-platform-validation.md` for the exact scope and current boundary.

## 1. Harness Metadata

```powershell
.\scripts\checks\validate-repos.ps1
```

This checks `repos/repos.yaml` for required fields, allowed statuses, supported validation profiles, unique repository ids, and local paths under `repos/`.

For automation:

```powershell
.\scripts\checks\validate-repos.ps1 -Quiet -PassThru | ConvertTo-Json -Depth 5
```

## 2. Harness Structure

```powershell
.\scripts\bootstrap\verify-workspace.ps1
```

This checks that the control repository contains required docs, schemas, templates, scripts, skill folders, examples, and open source governance files.

The default sample repositories are not cloned in a clean checkout, so warnings about `sample-api-service`, `sample-web-app`, and `sample-mobile-app` are expected.

## 3. Repository Contracts And Baseline

```powershell
.\scripts\checks\discover-contracts.ps1
.\scripts\checks\run-local-baseline.ps1 -SkipCommandExecution
```

Contract discovery inspects local repositories when present. Baseline validation checks whether the repository exists, whether it is a Git checkout, whether the expected branch and manifest files are present, and whether validation commands can be run.

For automation:

```powershell
.\scripts\checks\discover-contracts.ps1 -NoReport -Quiet -PassThru | ConvertTo-Json -Depth 5
.\scripts\checks\run-local-baseline.ps1 -SkipCommandExecution -Quiet -PassThru | ConvertTo-Json -Depth 5
```

## Expected Fresh Checkout Result

In a fresh public checkout, the harness itself should validate, while sample product repositories should report `missing-local-env` with warning-level baseline status until the maintainer replaces or clones them.

## Sample Change Packet

The synthetic sample packet is part of the public demo path:

```powershell
.\scripts\checks\validate-change.ps1 -Path examples\sample-change
.\scripts\checks\validate-change.ps1 -Path examples\issue-to-review
.\scripts\checks\validate-change.ps1 -Path examples\release-workflow
```

GitHub Actions also runs these checks so the demo packets cannot drift silently.

## Validation Evidence Redaction

Generated reports under `reports/` are ignored because they can include local paths, private repository names, stack traces, endpoints, or environment details. Before copying validation evidence into tracked files, use `docs/security/redaction-patterns.md`.

The tracked summary should keep the command, status, skipped checks, and maintainer-relevant findings. It should not include raw terminal transcripts, secrets, customer data, private endpoints, or full local paths.

## Public Readiness

Before applying to an open source support program, run:

```powershell
.\scripts\checks\check-public-ready.ps1
.\scripts\checks\check-security-posture.ps1
```

This check verifies required public files, harness structure, Git commit state, origin host, whether public candidate files are tracked, and whether public candidate paths or contents match project-specific sensitive terms. It intentionally reports failure before the repository has a public GitHub remote and an initial commit.

For project-specific private names or local paths, pass a one-time pattern from the shell instead of storing those terms in the public repository:

```powershell
.\scripts\checks\check-public-ready.ps1 -SensitivePattern "<legacy-name>|<private-remote>|<local-path>|<private-role>"
```

CI may use `-SkipSensitivePattern` after the one-time local publication scan has passed.

## Security Posture

Before requesting full open source support or enabling new automation surfaces, run:

```powershell
.\scripts\checks\check-security-posture.ps1 -SensitivePattern "<legacy-name>|<private-remote>|<local-path>|<private-role>"
```

This check verifies Codex Security review docs, MCP read-only guarantees, agent write-scope declarations, ignored generated artifacts, private vulnerability reporting, and project-specific sensitive path/content scans.

Use `scripts/bootstrap/prepare-publication.ps1` for a dry-run of staging, remote replacement, and commit creation before changing Git state.

## Application Audit

Generate a pre-application report:

```powershell
.\scripts\checks\write-application-audit.ps1 -SensitivePattern "<legacy-name>|<private-remote>|<local-path>|<private-role>"
```

The report is written under `reports/application-audit/`, which is ignored by Git. It checks form-section length, evidence files, workspace structure, redaction guidance, sensitive terms, security posture, and publication blockers.
