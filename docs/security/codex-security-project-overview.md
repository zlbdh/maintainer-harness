# Codex Security Project Overview

This file is a paste-ready project overview for Codex Security threat-model context. It is intentionally short and repository-specific so security findings can be ranked against the actual control-plane risks in Maintainer Harness.

## Project Overview

Maintainer Harness is an open source control plane for agent-assisted maintenance. It generates change packets, impact maps, scoped worker task cards, validation summaries, release evidence, and reusable maintainer skills. It does not store product repositories by default; local product checkouts, generated worktrees, and validation reports are ignored.

## Entry Points And Untrusted Inputs

- `repos/repos.yaml`: maintainer-provided repository metadata and validation commands.
- `config/agent-registry.yaml`: maintainer-provided role names, write scopes, and verification expectations.
- `changes/*`: change briefs, impact files, execution plans, worker outputs, and verification evidence.
- `mcp/catalog.yaml` and `mcp/blueprints/*`: optional read-only external context definitions.
- GitHub pull requests and issues that may be converted into change packets.

Treat those inputs as maintainer-controlled but still untrusted until schema checks, review gates, and command evidence pass.

## Trust Boundaries And Auth Assumptions

- Product repositories stay outside the public harness and are not committed into `repos/`.
- Worker agents receive explicit task cards and allowed paths instead of broad repository write access.
- MCP context is read-only, dev-or-test scoped, source-stamped, and not sufficient by itself for release decisions.
- Generated reports and worktrees may contain local paths or private context, so they remain ignored by default.
- GitHub Actions validates the public harness, but project-specific product CI remains owned by downstream maintainers.

## Sensitive Data Paths Or Privileged Actions

- Sensitive paths: ignored `repos/**`, `worktrees/**`, `reports/**`, and `changes/CHG-*/runtime/**`.
- Privileged decisions: accepting worker output, opening pull requests, publishing release notes, enabling write-capable MCP, or connecting real repositories.
- Expected secret classes: API keys, tokens, cookies, private endpoints, customer data, production logs, and local filesystem paths.

## Areas To Review First

1. Agent write-scope enforcement in `config/agent-registry.yaml`, task cards, and `scripts/orchestrator/review-worker-output.ps1`.
2. Publication hygiene in `.gitignore`, `scripts/checks/check-public-ready.ps1`, and `scripts/checks/check-security-posture.ps1`.
3. MCP read-only guarantees in `standards/global/mcp-safety.md`, `mcp/catalog.yaml`, and `mcp/blueprints/*`.
4. Validation evidence handling in `scripts/checks/*`, `templates/verification-result.md`, and release templates.
5. GitHub workflow coverage in `.github/workflows/harness-validation.yml`.

## Expected Review Output

Useful Codex Security findings should include ranked vulnerability hypotheses, reproduction or validation commands when possible, affected files, root cause, and minimal remediation patches. False positives should still record why a path is safe so the threat model can be improved.
