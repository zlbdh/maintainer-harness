# Threat Model

Maintainer Harness is a control plane for agent-assisted open source maintenance. It does not store product code by default, but it coordinates repositories, worker scopes, validation output, release evidence, and optional read-only MCP context. That makes boundary control the main security concern.

## Assets

- Repository metadata in `repos/repos.yaml`
- Agent roles, write scopes, and verification commands in `config/agent-registry.yaml`
- Change packets under `changes/`
- Validation evidence under `reports/`
- Release notes and postmortems under `release/` and `templates/`
- Read-only MCP blueprints under `mcp/`
- Maintainer decisions captured in docs and generated packets

## Trust Boundaries

| Boundary | Expected Control |
| --- | --- |
| Harness repository to product repositories | Product repositories stay under ignored `repos/` checkouts unless intentionally connected by maintainers. |
| Main agent to worker agents | Workers receive explicit task cards, allowed paths, and verification commands. |
| Worker output to release evidence | Reviewer scripts and verification templates require evidence before acceptance. |
| MCP context to maintainer decisions | MCP blueprints are read-only, source-stamped, and not sufficient by themselves for release decisions. |
| Local reports to public repository | Generated reports are ignored and must not contain secrets, customer data, or private paths in commits. |

## Entry Points And Untrusted Inputs

- Maintainer-authored repository metadata in `repos/repos.yaml`
- Role definitions and allowed paths in `config/agent-registry.yaml`
- Change briefs, impact files, execution files, and worker outputs under `changes/`
- Read-only MCP catalog entries and blueprints under `mcp/`
- GitHub issues or pull requests that a maintainer may convert into change packets

These inputs are expected to come from maintainers, contributors, or automation. They should still be treated as untrusted until validation scripts, review gates, and human review confirm them.

## Sensitive Data Paths And Privileged Actions

- Ignored local product checkouts under `repos/**`
- Ignored generated worktrees under `worktrees/**`
- Ignored local reports under `reports/**`
- Runtime packets under `changes/CHG-*/runtime/**`
- Privileged actions such as accepting worker output, publishing release notes, enabling write-capable MCP, or connecting real repositories

## Primary Threats

| Threat | Impact | Current Mitigation |
| --- | --- | --- |
| Over-broad agent write scope | Worker modifies unrelated files or repositories. | `config/agent-registry.yaml`, task cards, review wrapper, and write-scope checks. |
| Sensitive data committed to the public control repo | Secrets, customer data, or private paths become public. | `.gitignore`, `check-public-ready.ps1`, and `check-security-posture.ps1`. |
| Write-capable MCP introduced too early | Agent can mutate external systems or production data. | `standards/global/mcp-safety.md`, `mcp/catalog.yaml`, and security posture checks require read-only blueprints. |
| Validation evidence trusted without execution | Maintainers make release decisions from unsupported claims. | Validation templates, baseline scripts, and audit scripts preserve command output and status. |
| Product repository checkout committed accidentally | Private product source becomes part of the public harness. | `/repos/**` ignore rule with only `repos/repos.yaml` tracked. |
| Generated worktree or runtime packet leakage | Temporary files reveal local paths, logs, or implementation details. | `/worktrees/**`, generated reports, and runtime directories are ignored. |

## Assumptions

- Maintainers run the harness from a trusted local machine or CI runner.
- Product repositories are cloned separately and are not committed to this control repository.
- MCP integrations remain read-only until a separate security design is reviewed.
- Generated local reports can contain sensitive context and therefore remain ignored by default.

## Security Review Priorities

Codex Security review would be most useful for:

- agent write-scope enforcement
- MCP read-only guarantees
- publication hygiene and secret leakage prevention
- review wrapper logic that decides whether worker output can be accepted
- validation evidence handling before release decisions

For a shorter paste-ready Codex Security project overview, see `docs/security/codex-security-project-overview.md`.
