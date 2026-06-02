# Roadmap

Maintainer Harness is early-stage and public-ready, but it should grow through maintainer use rather than speculative complexity.

## Near Term

- Publish the cleaned repository and enable the validation workflow.
- Replace sample repository entries with real open source dogfooding repositories when available.
- Add more synthetic examples for bugfix, release, and security-review workflows.
- Add cross-platform validation notes for Linux and macOS contributors.
- Improve JSON output contracts for automation consumers.
- Expand the Codex Security review package with concrete findings from external review.

## Maintainer Automation

- Generate change packets from GitHub issues.
- Produce pull request review packets from `impact.yaml` and `execution.yaml`.
- Summarize validation evidence into release notes.
- Add optional GitHub Actions examples for pull request triage.

## Safety

- Keep write scopes explicit for every worker packet.
- Keep MCP examples read-only by default.
- Add regression checks for public hygiene patterns.
- Document private-data redaction practices for validation reports.
- Keep the security posture gate required in CI before adding write-capable integrations.

## Not Planned

- Storing product source repositories inside the harness.
- Replacing project-specific CI systems.
- Requiring production credentials or write-capable external integrations by default.
