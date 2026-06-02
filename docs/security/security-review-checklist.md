# Security Review Checklist

Use this checklist before requesting Codex Security review, adding new agent roles, or enabling new MCP integrations.

## Publication Hygiene

- Run `scripts/checks/check-public-ready.ps1` with project-specific sensitive terms.
- Run `scripts/checks/check-security-posture.ps1`.
- Confirm product checkouts under `repos/` are ignored.
- Confirm generated reports and worktrees are ignored.
- Confirm shared validation evidence follows `docs/security/redaction-patterns.md`.
- Confirm no credentials, tokens, cookies, private endpoints, or customer data appear in tracked files.
- Confirm `docs/security/codex-security-project-overview.md` still reflects current entry points, trust boundaries, sensitive paths, and review priorities.

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
- Redacted summaries keep command names, status, skipped checks, and maintainer-relevant findings without raw private transcripts.

## Codex Security Request

When requesting Codex Security support, point reviewers to:

- `docs/security/threat-model.md`
- `docs/security/codex-security-project-overview.md`
- `docs/security/codex-security-scope.md`
- `docs/security/redaction-patterns.md`
- `standards/global/mcp-safety.md`
- `config/agent-registry.yaml`
- `.github/workflows/harness-validation.yml`
- `scripts/checks/check-security-posture.ps1`
