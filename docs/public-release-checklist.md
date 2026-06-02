# Public Release Checklist

Use this checklist before publishing Maintainer Harness or submitting it to an open source support program.

## Repository Visibility

- GitHub profile is public.
- Repository is public.
- Repository description explains the maintainer workflow in one sentence.
- Repository topics include relevant terms such as `codex`, `maintainer-tools`, `agent-workflows`, `open-source`, and `automation`.
- `.github/repository-settings.yml` has been used as the publication reference.

## Public Hygiene

Run:

```powershell
.\scripts\checks\check-public-ready.ps1 -SensitivePattern "<legacy-name>|<private-remote>|<local-path>|<private-role>"
git status --short --ignored
git ls-files --others --exclude-standard
```

Expected result:

- no sensitive path or content matches from public candidate files
- public files appear as tracked or staged
- legacy local assets appear only under ignored entries
- validation evidence copied from ignored reports has been redacted with `docs/security/redaction-patterns.md`

## Validation

Run:

```powershell
.\scripts\checks\validate-repos.ps1
.\scripts\bootstrap\verify-workspace.ps1
.\scripts\checks\discover-contracts.ps1 -NoReport -Quiet -PassThru | ConvertTo-Json -Depth 5
.\scripts\checks\run-local-baseline.ps1 -SkipCommandExecution -Quiet -PassThru | ConvertTo-Json -Depth 5
.\scripts\checks\check-public-ready.ps1
.\scripts\checks\check-security-posture.ps1
```

Expected result:

- repository metadata validates
- harness structure validates
- sample repositories report warning-level `missing-local-env` until replaced or cloned
- baseline output is machine-readable JSON when `-Quiet -PassThru` is used
- public readiness only passes after the repository has a GitHub origin, at least one commit, and no untracked public candidate files
- security posture passes for required security docs, read-only MCP blueprints, explicit agent scopes, and ignored generated artifacts

## Application Readiness

- `README.md` explains what the project is and why it exists.
- `CONTRIBUTING.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`, `SUPPORT.md`, and `MAINTAINERS.md` are present.
- `.github/` contains issue, pull request, and validation workflow templates.
- `docs/codex-for-oss-application.md` contains paste-ready form responses.
- `docs/codex-for-oss-evidence.md` maps repository files to the application claims.
- `docs/security/` explains the threat model and Codex Security review scope.
- `docs/security/redaction-patterns.md` explains how to share validation evidence without raw private report data.
- `examples/sample-change/` demonstrates a safe synthetic workflow.

## Before Submit

- Commit only the public candidate files.
- Replace any private or legacy `origin` remote before pushing.
- Push to a public GitHub repository.
- Confirm GitHub Actions passes on the public repository.
- Use the public repository URL in the application form.
