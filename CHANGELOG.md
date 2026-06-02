# Changelog

All notable changes to Maintainer Harness will be documented in this file.

This project follows a simple date-based changelog until formal versioned releases begin.

## 2026-06-02

### Added

- Codex Security review package under `docs/security/`.
- Security posture gate in `scripts/checks/check-security-posture.ps1`.
- GitHub Actions step for CI security posture validation.
- Full-support Codex for OSS application wording covering API credits, ChatGPT Pro with Codex, and Codex Security.
- Paste-ready Codex Security project overview aligned to entry points, trust boundaries, sensitive data paths, privileged actions, and review priorities.
- Public 30-day dogfooding plan for API-credit-backed maintainer workflows.
- Demo transcript and launch kit for policy-safe open source discovery.
- Complete synthetic sample change packet that validates from a clean checkout.
- Public feedback issue and `v0.1.1` launch-ready release anchors in launch materials.
- GitHub profile README anchor for Maintainer Harness visibility.
- Project-specific GitHub labels and a good-first-issue demo feedback path.
- Share page, launch log, and social preview asset for public launch posts.
- `v0.1.2` release anchor for the share asset package.
- GitHub Pages project site under `docs/index.html` with demo commands, evidence links, and feedback routes.
- Public readiness and workspace checks now require the project site files.
- `v0.1.3` release anchor for the project site package.
- Synthetic issue-to-review packet under `examples/issue-to-review/` covering issue intake, impact mapping, worker scope, and reviewer acceptance evidence.
- GitHub Actions, workspace verification, public readiness, and application audit now include the issue-to-review example.
- `v0.1.4` release anchor for the issue-to-review packet example.

### Changed

- Application audit now includes security posture status.
- Application audit now checks the dogfooding plan and Codex Security project overview.
- MCP catalog owner scope is generic for open source maintainers.
- Public release docs now include security posture checks.
- README now surfaces CI, license, and security posture badges.
- README now includes a 90-second try path and clearer maintainer audience positioning.
- Suggested GitHub topics now include developer-tools, GitHub Actions, security tooling, and CLI tooling discovery terms.
- GitHub Actions now validates the synthetic sample change packet.
- Suggested repository metadata now points visitors to the demo path.
- Suggested repository metadata now points visitors to the GitHub Pages project site.

## 2026-06-01

### Added

- Public-ready repository identity as Maintainer Harness.
- Generic sample repository metadata in `repos/repos.yaml`.
- Maintainer role registry in `config/agent-registry.yaml`.
- Change packet templates, worker result schemas, and validation scripts.
- Read-only MCP blueprints for safe context retrieval.
- GitHub issue templates, pull request template, and validation workflow.
- Contribution, security, support, and code of conduct documents.
- Synthetic sample change packet under `examples/sample-change/`.
- Codex for OSS application notes under `docs/codex-for-oss-application.md`.

### Changed

- Reworked local scripts to resolve repository paths relative to the harness root.
- Replaced project-specific repository roles with generic backend, web, and mobile examples.
- Added quiet/pass-through modes for scripts that should support machine-readable output.

### Security

- Generated reports, worktrees, local product checkouts, and private legacy artifacts are ignored by default.
- Public hygiene checks should be run before every publication or release.
