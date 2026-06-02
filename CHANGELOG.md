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
- Validation report redaction guide under `docs/security/redaction-patterns.md`.
- Security posture, workspace verification, public readiness, and application audit now require the redaction guide.
- `v0.1.6` release anchor for the synthetic release workflow example.
- `v0.1.5` release anchor for validation report redaction guidance.
- Synthetic release workflow packet under `examples/release-workflow/` covering release notes, skipped checks, rollback, and postmortem-ready evidence.
- GitHub Actions, workspace verification, public readiness, and application audit now include the release workflow example.
- First Codex Security review pass under `docs/security/codex-security-review-pass-2026-06-02.md`.
- Shared path-scope helper for review-worker output checks.
- `v0.1.7` release anchor for the first Codex Security review pass.
- First-run feedback and worker-output reviewability issue templates.
- `v0.1.8` release anchor for feedback conversion templates.
- Launch materials now record pinned feedback issues `#5` and `#6`.
- Public Codex for OSS submission readiness checklist.
- Public 30-day Codex dogfooding tracker issue and milestone.
- `v0.1.9` release anchor for submission readiness and public dogfooding tracking.
- Cross-platform validation gate for Windows, Ubuntu, and macOS.
- `v0.1.10` release anchor for the cross-platform validation gate.
- Reviewer brief for Codex for OSS full-support evaluation, including current metrics, early-stage rationale, and 30/60/90 day public commitments.
- `v0.1.11` release anchor for the Codex for OSS reviewer brief.
- Public dogfooding run notes under `docs/dogfooding-runs/`, starting with the Codex application hardening run.
- External validation sprint plan for collecting honest maintainer feedback, first-run reports, and star-safe discovery signals.
- Script-backed 90% readiness scorecard for the Codex for OSS full-support target.
- First-run report generator for outside demo feedback.
- `v0.1.12` release anchor for the first-run report generator.
- Authenticated GitHub API support for the 90% readiness monitor.
- External feedback evidence registry and validator for machine-readable 90% scorekeeping.
- Maintainer review kit for five-minute outside feedback handoff.
- Review request packet generator for honest maintainer outreach.
- Worker output reviewability example for outside maintainers to compare vague
  agent replies with reviewable evidence.
- Non-blocking Codex for OSS readiness summary in the Harness validation
  workflow.
- `v0.1.13` release anchor for the worker-output reviewability and readiness
  monitor package.
- One-command review demo runner for outside first-run feedback.
- `v0.1.14` release anchor for the one-command external review demo.
- First-run feedback handoff now points reviewers to issue `#6` first so the
  readiness monitor can count outside reports automatically.

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
- Security posture checks now assert anchored allowed-path glob matching and traversal rejection.
- Public readiness checks now require the feedback-specific issue templates.
- Codex for OSS application evidence now links the reviewer brief and latest support request rationale.
- Launch and share materials now point to the v0.1.14 one-command review demo
  release.
- Worker and review response schema titles now use generic Maintainer Harness names.

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
