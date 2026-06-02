# Maintainer Harness

[![Harness validation](https://github.com/zlbdh/maintainer-harness/actions/workflows/harness-validation.yml/badge.svg)](https://github.com/zlbdh/maintainer-harness/actions/workflows/harness-validation.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Security posture](https://img.shields.io/badge/security%20posture-CI%20gated-green)](docs/security/security-review-checklist.md)

Maintainer Harness is a lightweight control plane for open source maintainers who want Codex and other agents to work from scoped packets instead of vague chat.

**Status:** early public-ready project. The current repository uses synthetic sample repositories so maintainers can inspect the workflow before connecting real projects.

**Project site:** https://zlbdh.github.io/maintainer-harness/

**Reviewer kit:** if you have five minutes, use
`docs/maintainer-review-kit.md` to inspect the workflow shape, run the clean
demo, or leave public feedback.

**Reviewability example:** `docs/worker-output-reviewability.md` compares vague
worker output with evidence a maintainer can actually review.

**Share or star:** if the demo is useful, share the project site or star the
repository so other maintainers can find it. Feedback is more valuable than a
vanity metric; the best starting points are issue
[#5](https://github.com/zlbdh/maintainer-harness/issues/5) for reviewability
feedback and issue [#6](https://github.com/zlbdh/maintainer-harness/issues/6)
for first-run friction.

It does not replace your product repositories. It keeps the operational layer around them auditable:

- change intake
- cross-repository impact analysis
- task cards and write scopes
- worker dispatch packets
- local validation reports
- release notes and postmortems
- reusable maintainer skills

The project is intentionally repository-agnostic. The default configuration uses sample repositories under `repos/repos.yaml`; replace those entries with your own repositories before running real maintenance workflows.

![Maintainer Harness social preview](docs/assets/social-preview.svg)

## Try It In 90 Seconds

The default sample change is synthetic and safe to run in a clean checkout:

```powershell
.\scripts\checks\run-review-demo.ps1
```

That one command runs the public demo checks and writes a paste-ready first-run
feedback draft under `reports/first-run/`. To run the same checks manually:

```powershell
.\scripts\checks\validate-repos.ps1
.\scripts\bootstrap\verify-workspace.ps1
.\scripts\checks\validate-change.ps1 -Path examples\sample-change
.\scripts\checks\validate-change.ps1 -Path examples\issue-to-review
.\scripts\checks\validate-change.ps1 -Path examples\release-workflow
.\scripts\checks\check-security-posture.ps1 -SkipSensitivePattern
```

That flow checks the harness, validates a complete sample change packet, and confirms the public security posture. See `docs/demo.md` for a short transcript and the project site for a shareable overview.

If you want to report first-run friction, generate a paste-ready issue draft:

```powershell
.\scripts\checks\write-first-run-report.ps1
```

If you want a local packet for asking maintainers to review the project:

```powershell
.\scripts\checks\write-review-request-packet.ps1
```

## Why This Exists

Agent-assisted maintenance often fails for ordinary reasons:

- the task starts before scope is clear
- multiple workers touch the same files
- validation is described but not actually run
- release notes lose the evidence trail
- project knowledge stays trapped in chat history

This harness turns those risks into files, checks, and repeatable commands.

## Who This Is For

- maintainers coordinating fixes across multiple repositories
- open source projects trying agent-assisted PR review without losing auditability
- teams that want workers to receive explicit write scopes and validation commands
- contributors who need clear evidence before a release decision

It is not a hosted product, a replacement for project-specific CI, or a way to bypass human review.

## Core Concepts

- `change-id`: one durable identifier for each maintenance change
- `brief.md`: what changed and why
- `impact.yaml`: affected repositories, interfaces, configs, and dependency order
- `execution.yaml`: owners, branches, worktrees, lock state, and result locations
- `tasks/<repo>.md`: one bounded task card per repository
- `verification/result.md`: final evidence and acceptance result
- `.agent/skills/`: local recipes for common maintainer workflows

## Directory Layout

```text
.
├── AGENTS.md
├── .agent/
│   └── skills/
├── repos/
│   └── repos.yaml
├── config/
│   └── agent-registry.yaml
├── docs/
├── standards/
├── templates/
├── changes/
├── evals/
├── reports/
├── release/
├── mcp/
└── scripts/
```

## Quick Start

1. Edit `repos/repos.yaml` and replace the sample repositories with your project repositories.

2. Check the harness structure and repository metadata:

```powershell
.\scripts\checks\validate-repos.ps1
.\scripts\bootstrap\verify-workspace.ps1
```

3. Dry-run repository clone or sync:

```powershell
.\scripts\bootstrap\clone-repos.ps1 -DryRun
.\scripts\bootstrap\sync-repos.ps1 -DryRun
```

4. Discover local contracts and run baseline checks:

```powershell
.\scripts\checks\discover-contracts.ps1
.\scripts\checks\run-local-baseline.ps1 -SkipCommandExecution
```

5. Create a change packet:

```powershell
.\scripts\bootstrap\init-change.ps1 -ChangeId CHG-2026-0001-sample-change -Title "Sample maintainer workflow"
.\scripts\checks\validate-change.ps1 -ChangeId CHG-2026-0001-sample-change
```

6. Prepare worker packets:

```powershell
.\scripts\orchestrator\dispatch-change.ps1 -ChangeId CHG-2026-0001-sample-change -DryRun
```

See `examples/sample-change/` for a synthetic docs-validation packet, `examples/issue-to-review/` for an issue-to-change packet shaped for pull request review, and `examples/release-workflow/` for release evidence and skipped-check handling.

## Validation

The default validation workflow runs on Windows PowerShell and is also wired into GitHub Actions:

```powershell
.\scripts\checks\validate-repos.ps1
.\scripts\bootstrap\verify-workspace.ps1
.\scripts\checks\discover-contracts.ps1 -NoReport -Quiet -PassThru | ConvertTo-Json -Depth 5
.\scripts\checks\run-local-baseline.ps1 -SkipCommandExecution -Quiet -PassThru | ConvertTo-Json -Depth 5
.\scripts\checks\check-public-ready.ps1
.\scripts\checks\check-security-posture.ps1
```

GitHub Actions runs the public validation gate on Windows, Ubuntu, and macOS. In a fresh checkout, sample repositories are expected to report warning-level `missing-local-env` until you replace or clone them. See `docs/validation.md` and `docs/cross-platform-validation.md`.

## Configuration Files

- `repos/repos.yaml`: repository metadata and validation commands
- `config/agent-registry.yaml`: maintainer roles and allowed write scopes
- `templates/`: change, task, verification, release, and postmortem templates
- `standards/`: global and repository-specific guardrails
- `mcp/`: read-only MCP blueprints for safe external context

## Open Source Project Files

- `CONTRIBUTING.md`: contribution workflow and local validation
- `SECURITY.md`: vulnerability reporting and security boundaries
- `CODE_OF_CONDUCT.md`: community behavior expectations
- `SUPPORT.md`: support channels and issue guidance
- `MAINTAINERS.md` and `.github/CODEOWNERS`: ownership and review routing
- `.github/repository-settings.yml`: suggested public GitHub description, topics, and branch protection
- `.github/`: issue and pull request templates
- `docs/codex-for-oss-application.md`: application summary for OpenAI Codex for OSS
- `docs/codex-for-oss-evidence.md`: evidence matrix for Codex for OSS program fit
- `docs/codex-for-oss-submission-readiness.md`: public submission readiness checklist for the application evidence package
- `docs/codex-for-oss-reviewer-brief.md`: one-page reviewer brief for the full-support request
- `docs/codex-for-oss-90-scorecard.md`: hard gates and script-backed scorecard for the 90% readiness target
- `docs/dogfooding-plan.md`: 30-day public dogfooding plan for API-credit-backed maintainer workflows
- `docs/dogfooding-runs/`: public dogfooding run notes and validation evidence
- `docs/external-validation-sprint.md`: 24-48 hour plan for collecting honest maintainer feedback signals
- `docs/maintainer-review-kit.md`: five-minute outside maintainer feedback path
- `docs/worker-output-reviewability.md`: good/bad worker output evidence example for maintainer review
- `docs/index.html`, `docs/site.css`, and `docs/.nojekyll`: GitHub Pages project site
- `docs/demo.md`: short demo transcript for the synthetic maintainer workflow
- `docs/cross-platform-validation.md`: Windows, Ubuntu, and macOS validation coverage and current boundaries
- `docs/launch-kit.md`: policy-safe launch copy and outreach plan for real open source discovery
- `docs/share.md`: compact share page with demo commands and canonical links
- `docs/launch-log.md`: public launch action and metrics tracking
- `docs/assets/social-preview.svg`: social preview card for launch posts
- `docs/security/`: threat model, Codex Security project overview, review scope, first review pass, redaction guidance, and security review checklist
- `docs/github-publication.md`: safe publication steps for GitHub
- `examples/issue-to-review/`: synthetic GitHub issue intake through pull request review evidence
- `examples/release-workflow/`: synthetic release note, rollback, skipped-check, and postmortem-ready evidence
- `CHANGELOG.md` and `ROADMAP.md`: project status and planned maintainer workflows
- `.github/workflows/harness-validation.yml`: public CI entry point
- `scripts/bootstrap/prepare-publication.ps1`: dry-run/apply helper for the final public commit
- `scripts/checks/write-application-audit.ps1`: ignored pre-application audit report generator
- `scripts/checks/run-review-demo.ps1`: one-command external review demo and first-run report handoff
- `scripts/checks/write-first-run-report.ps1`: ignored first-run report generator for outside demo feedback
- `scripts/checks/write-review-request-packet.ps1`: ignored outreach packet generator for honest maintainer review requests
- `scripts/checks/check-security-posture.ps1`: CI-friendly security posture gate for agent scopes, MCP safety, and ignored artifacts
- `.github/workflows/codex-readiness-monitor.yml`: scheduled and manual Codex for OSS readiness monitor

## Public Hygiene

This repository is meant to be public. Do not commit:

- product source checkouts under `repos/`
- generated worktrees under `worktrees/`
- local validation reports with sensitive paths
- credentials, tokens, private endpoints, customer data, or production logs
- unredacted validation evidence copied from ignored report paths

The included `.gitignore` keeps the default repository safe for public use, but maintainers should still review `git status --ignored` before publishing.

## License

MIT License. See `LICENSE`.
