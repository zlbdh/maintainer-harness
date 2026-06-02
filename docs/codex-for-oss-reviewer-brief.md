# Codex For OSS Reviewer Brief

This is the short review packet for the Maintainer Harness application. It is
designed for a reviewer who needs to understand the support request quickly
without trusting private context or inflated adoption claims.

## One-Sentence Case

Maintainer Harness is an early open source control plane that makes
agent-assisted maintenance reviewable: every Codex or worker action is tied to a
change brief, impact map, scoped task card, validation evidence, release gate,
and security boundary.

## Why This Matters Without Popularity Metrics Yet

The repository is new and currently has no broad adoption. Its value is that it
targets a fast-growing maintainer problem before it becomes invisible:
maintainers are experimenting with coding agents, but agent work often loses the
boring evidence needed to accept, reject, or release changes safely.

Maintainer Harness turns that evidence into public, reusable files and checks.
That makes it useful to the open source ecosystem even before the repository has
large star counts.

## Why Full Support Helps

| Requested support | How it will be used publicly |
| --- | --- |
| API credits | Generate issue-to-change packets, scoped worker tasks, validation summaries, and release evidence examples. |
| ChatGPT Pro with Codex | Dogfood daily maintainer workflows and turn findings into public docs, templates, examples, and issues. |
| Codex Security | Review the risk surface where agents read MCP context, handle issue/PR text, propose patches, obey write scopes, redact evidence, and influence release decisions. |

## Current Public Evidence

- Public repository: https://github.com/zlbdh/maintainer-harness
- Project site: https://zlbdh.github.io/maintainer-harness/
- Latest release: https://github.com/zlbdh/maintainer-harness/releases/tag/v0.1.13
- Main branch CI history: https://github.com/zlbdh/maintainer-harness/actions/workflows/harness-validation.yml?query=branch%3Amain
- Main branch Pages history: https://github.com/zlbdh/maintainer-harness/actions?query=workflow%3A%22pages+build+and+deployment%22+branch%3Amain
- Cross-platform validation: `docs/cross-platform-validation.md`
- Pull request review packet example: `examples/issue-to-review/`
- Release evidence packet example: `examples/release-workflow/`
- Codex Security overview: `docs/security/codex-security-project-overview.md`
- First Codex Security review pass: `docs/security/codex-security-review-pass-2026-06-02.md`
- Public dogfooding tracker: https://github.com/zlbdh/maintainer-harness/issues/7
- Feedback route: https://github.com/zlbdh/maintainer-harness/issues/5

## Current Metrics

As of 2026-06-02, the repository has 0 stars, 0 forks, 0 watchers, and 3 open
issues. The application should not claim adoption it does not have. The
stronger current signal is the public evidence package, passing validation
gates, pinned feedback issues, and a concrete 30-day dogfooding plan.

## External Validation Plan

The remaining weak signal is outside usage. The project now tracks a
feedback-first validation sprint in `docs/external-validation-sprint.md`. The
target is 5+ real stars from people who inspected the project, 2+ public issue
comments or first-run reports, 1 outside first-run report, and 1 feedback-driven
follow-up issue or commit. Until those signals exist, the application should
stay honest that external adoption is not proven yet.

The hard 90% readiness gate is tracked in
`docs/codex-for-oss-90-scorecard.md` and measured by
`scripts/checks/measure-application-readiness.ps1`. The current script-backed
score is below 90 until real external feedback appears.

## 30 / 60 / 90 Day Commitments

| Window | Public commitment |
| --- | --- |
| 30 days | Publish at least three Codex-backed maintainer workflow runs: issue-to-review, security-scope review, and release evidence summary. |
| 60 days | Convert first-run feedback into templates, validation checks, or example packets, and publish the resulting release notes. |
| 90 days | Decide whether the harness is useful enough for real downstream maintainers; if not, publish the lessons and narrow the scope honestly. |

## Why Codex Security Is A Fit

Codex Security is relevant because the project is not merely asking Codex to
write code. It is trying to define safe boundaries for agent work itself:

- untrusted issue and PR text may become task packets
- worker output must stay inside allowed paths
- MCP context is read-only and source-stamped
- generated worktrees and validation reports may contain private context
- release decisions require evidence, not chat-only claims

That risk surface is exactly where early security review can produce reusable
open source maintainer patterns.

## Honest Acceptance Criteria

If support is granted, success should be measured by public maintainer evidence,
not private claims:

- new examples that external maintainers can run
- issue comments or feedback converted into tracked improvements
- validation checks that fail when safety boundaries drift
- release notes that record what Codex helped produce
- security findings, false positives, and remediations recorded in public docs
