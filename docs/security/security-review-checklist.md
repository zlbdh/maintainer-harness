# Security Review Checklist

Use this checklist before requesting Codex Security review, adding new agent roles, or enabling new MCP integrations.

## Publication Hygiene

- Run `scripts/checks/check-public-ready.ps1` with project-specific sensitive terms.
- Run `scripts/checks/check-security-posture.ps1`.
- Confirm product checkouts under `repos/` are ignored.
- Confirm generated reports and worktrees are ignored.
- Confirm no credentials, tokens, cookies, private endpoints, or customer data appear in tracked files.

## Agent Scope

- Every worker role has explicit `allowed_paths`.
- Worker roles do not default to repository-wide write access.
- Release and verification roles write only evidence, not product source.
- Review output distinguishes verified work from environment-limited or externally blocked work.

## MCP Safety

- MCP entries are read-only.
- MCP entries are limited to development or test environments.
- MCP entries require source stamps or snapshots.
- MCP outputs do not become release decisions without repository evidence.
- Write-capable MCP requires a separate design and security review before use.

## Validation Evidence

- Validation commands are declared in repository metadata or task packets.
- Skipped validation is recorded as skipped or warning-level evidence.
- Release notes cite validation artifacts, not only chat summaries.
- Application audit and public readiness checks pass before submitting support requests.

## Codex Security Request

When requesting Codex Security support, point reviewers to:

- `docs/security/threat-model.md`
- `docs/security/codex-security-scope.md`
- `standards/global/mcp-safety.md`
- `config/agent-registry.yaml`
- `.github/workflows/harness-validation.yml`
- `scripts/checks/check-security-posture.ps1`

