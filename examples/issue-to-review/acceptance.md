# Acceptance

This issue-to-review packet is accepted when:

- The source issue is captured in sanitized form.
- `impact.yaml` maps the issue to at least one affected repository and review surface.
- `execution.yaml` assigns owners, write scopes, branches, lock state, worker result path, and review result path.
- `tasks/harness.md` gives the worker clear allowed paths and validation commands.
- `verification/result.md` records reviewer evidence and expected command output.
- The packet passes `scripts/checks/validate-change.ps1 -Path examples/issue-to-review`.
- The example remains synthetic and free of private repository names, credentials, customer data, local paths, production logs, and product-specific screenshots.
