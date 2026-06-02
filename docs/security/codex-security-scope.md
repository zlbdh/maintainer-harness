# Codex Security Review Scope

Maintainer Harness requests Codex Security support because the project is specifically about safe agent-assisted maintenance. The security questions are about control-plane boundaries, not only application vulnerabilities.

## In Scope

- Paste-ready security project overview in `docs/security/codex-security-project-overview.md`
- Agent role definitions in `config/agent-registry.yaml`
- Worker packet generation in `scripts/orchestrator/dispatch-change.ps1`
- Worker review and acceptance logic in `scripts/orchestrator/review-worker-output.ps1`
- Local baseline and validation scripts in `scripts/checks/`
- Public hygiene checks in `scripts/checks/check-public-ready.ps1`
- Security posture checks in `scripts/checks/check-security-posture.ps1`
- MCP safety rules in `standards/global/mcp-safety.md`
- MCP blueprints and catalog entries under `mcp/`
- GitHub workflow gates in `.github/workflows/harness-validation.yml`

## Out Of Scope

- Private product repositories that a maintainer may connect later
- Production credentials, production databases, customer data, and private logs
- Write-capable MCP integrations that have not gone through a separate design review
- Generated local reports under ignored `reports/` paths

## Review Questions

1. Can a worker agent escape its intended write scope?
2. Can generated packets cause a maintainer to trust unverified work?
3. Can private repository checkouts, generated worktrees, or validation reports be committed by mistake?
4. Are MCP blueprints safely constrained to read-only, dev-or-test context?
5. Do scripts make publication hygiene and security posture failures visible enough before release?
6. Are there missing checks that would improve confidence for open source maintainers using Codex?

## Why This Matters For OSS

Open source maintainers often need help with triage, review, and release work, but they also need reproducible evidence and clear authority boundaries. A security review of this harness can improve not only one repository, but a reusable pattern for maintainers adopting agent-assisted workflows.
