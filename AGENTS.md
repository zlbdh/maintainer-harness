# Maintainer Harness Agent Guide

This repository is a generic control plane for open source maintenance. Agents working here should improve the harness, templates, validation scripts, and documentation without binding the project to a private product or organization.

## Default Context Order

Read these files before making non-trivial changes:

1. `README.md`
2. `repos/repos.yaml`
3. `config/agent-registry.yaml`
4. `docs/workflow.md`
5. `docs/architecture.md`
6. `docs/agent-workflow-skill-mcp.md`
7. `docs/memory-governance.md`
8. `docs/rule-precedence.md`
9. Relevant files under `changes/<change-id>/`
10. Relevant rules under `standards/`

## Working Rules

- Match the maintainer's language when communicating.
- Keep the harness repository-agnostic.
- Do not commit product source checkouts, generated worktrees, private logs, credentials, customer data, or production endpoints.
- Do not start external repository implementation work without a `change-id`.
- Do not claim impact analysis is complete without `impact.yaml`.
- Do not dispatch parallel workers without `execution.yaml`.
- Do not claim a change is complete without validation evidence.
- Keep worker write scopes explicit and bounded.
- Prefer structured Markdown, YAML, and JSON contracts over chat-only instructions.

## Minimum Change Packet

Each real change packet should include:

- `brief.md`
- `impact.yaml`
- `execution.yaml`
- `design.md`
- `acceptance.md`
- at least one `tasks/<repo>.md`
- `verification/result.md`
- `postmortem.md`

## Validation

Before handing work back, run the narrowest relevant checks. For public-harness changes, prefer:

```powershell
.\scripts\checks\validate-repos.ps1
.\scripts\bootstrap\verify-workspace.ps1
.\scripts\checks\discover-contracts.ps1 -NoReport -Quiet -PassThru | ConvertTo-Json -Depth 5
.\scripts\checks\run-local-baseline.ps1 -SkipCommandExecution -Quiet -PassThru | ConvertTo-Json -Depth 5
```

Fresh public checkouts are expected to warn that sample repositories have not been cloned. That warning is acceptable until maintainers replace the sample repository entries.
