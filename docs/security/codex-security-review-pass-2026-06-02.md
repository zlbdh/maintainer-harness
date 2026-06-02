# Codex Security Review Pass - 2026-06-02

## Executive Summary

Status: pass with one remediation. The first review pass focused on agent write-scope escape risk and MCP read-only guarantees. No critical findings were found. One medium finding in the review wrapper's path-scope matcher was remediated by adding anchored glob matching, traversal rejection, and a security posture self-test.

## Scope Reviewed

| Area | Evidence |
| --- | --- |
| Agent registry | `config/agent-registry.yaml:13`, `config/agent-registry.yaml:50`, `config/agent-registry.yaml:66`, and `config/agent-registry.yaml:99` declare explicit `allowed_paths`; repo executor roles stay within source or manifest paths. |
| Task cards | `examples/sample-change/tasks/harness.md:13`, `examples/issue-to-review/tasks/harness.md:17`, and `examples/release-workflow/tasks/harness.md:14` list allowed paths; `templates/task-card.md:25` keeps future task cards centered on change boundaries. |
| Review wrapper | `scripts/orchestrator/review-worker-output.ps1:19` now loads the shared path scope helper; `scripts/orchestrator/review-worker-output.ps1:241` checks worker changed files before deterministic approval; `scripts/orchestrator/review-worker-output.ps1:497` runs Codex review in read-only mode. |
| Path-scope helper | `scripts/lib/HarnessPathScope.ps1:18` rejects absolute and parent-traversal paths; `scripts/lib/HarnessPathScope.ps1:39` converts glob patterns into anchored regexes; `scripts/lib/HarnessPathScope.ps1:64` is the single helper used by the review wrapper. |
| MCP catalog | `mcp/catalog.yaml:4`, `mcp/catalog.yaml:21`, `mcp/catalog.yaml:39`, and `mcp/catalog.yaml:55` keep entries in `dev-or-test`; `mcp/catalog.yaml:5`, `mcp/catalog.yaml:22`, `mcp/catalog.yaml:40`, and `mcp/catalog.yaml:56` keep access `readonly`. |
| MCP blueprints and policy | `mcp/blueprints/api-contract-readonly.md:12` and `mcp/blueprints/db-schema-readonly.md:14` list disallowed mutations; `standards/global/mcp-safety.md:15` through `standards/global/mcp-safety.md:18` require read-only, non-production MCP at this stage. |

## Findings

### MH-SEC-001 - Medium - Remediated

The review wrapper previously treated allowed paths as simple string suffixes instead of anchored glob patterns. That created two risks: valid scopes like `docs/**` could be misclassified, and exact file scopes like `README.md` could be treated too broadly if a worker reported a nested path ending in that name.

Impact: a future deterministic review could incorrectly block valid scoped work or incorrectly approve a worker-reported path that only matched by suffix.

Remediation:

- Added `scripts/lib/HarnessPathScope.ps1` with normalized repo-relative matching.
- Rejected absolute paths and `..` traversal before matching.
- Converted allowed path globs to anchored regexes.
- Updated `scripts/orchestrator/review-worker-output.ps1` to use the shared helper.
- Added `path-scope-helper` assertions to `scripts/checks/check-security-posture.ps1:150`.

### False Positive Rationale - Agent Write Scopes

The registry does not currently contain repository-wide write grants such as `**`, `.`, or `/`. Governance roles are limited to control-plane evidence and docs paths; repo executor roles are limited to `src/**` plus build or manifest files. Task cards repeat allowed paths and out-of-scope actions, which reduces ambiguity before worker execution.

Residual risk: `reports/**`, `changes/**`, and `release/**` may contain local context if misused. They remain ignored or evidence-oriented and should continue to be redacted before public sharing.

### False Positive Rationale - MCP Read-Only Guarantees

The MCP catalog entries are blueprint-stage, `dev-or-test`, `readonly`, snapshot-required, and source-stamp-required. The blueprints explicitly forbid production access, mutations, secrets, and customer data transfer. MCP output remains context only and cannot directly become a release decision under `standards/global/mcp-safety.md:47`.

Residual risk: any future write-capable or production MCP integration must be treated as a new design with a separate security review before being added to the catalog.

## Verification

```powershell
.\scripts\checks\check-security-posture.ps1 -SensitivePattern '<private-pattern>'
.\scripts\checks\check-public-ready.ps1 -SensitivePattern '<private-pattern>'
.\scripts\bootstrap\verify-workspace.ps1
```

Result: all three checks passed locally after the remediation.
