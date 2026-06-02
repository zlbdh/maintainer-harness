# Contributing

Thank you for considering a contribution to Maintainer Harness.

This project is a control plane for agent-assisted maintenance. Contributions should keep the harness generic, auditable, and safe to run around many different repositories.

## Good First Contributions

- Improve documentation for a maintainer workflow.
- Add a new validation check that works without private infrastructure.
- Improve PowerShell script portability.
- Add an example change packet under `examples/`.
- Tighten schemas or templates without binding them to a specific company or product.

## Local Setup

```powershell
.\scripts\checks\validate-repos.ps1
.\scripts\bootstrap\verify-workspace.ps1
.\scripts\checks\run-local-baseline.ps1 -SkipCommandExecution
```

The sample repositories in `repos/repos.yaml` are placeholders. A clean checkout is expected to warn that those local repositories have not been cloned.

## Pull Request Expectations

Every pull request should include:

- the problem being solved
- the affected commands, templates, or docs
- the validation commands that were run
- any compatibility notes for existing change packets

Do not include product source checkouts, private logs, credentials, customer data, or generated worktrees.

## Design Rules

- Keep the harness repository-agnostic.
- Prefer structured YAML/JSON/Markdown contracts over chat-only instructions.
- Make validation reproducible from the command line.
- Keep worker write scopes explicit.
- Avoid adding dependencies unless they remove meaningful operational risk.

