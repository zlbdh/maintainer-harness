# Codex For OSS Current Readiness Snapshot

This snapshot records a recent verified application-readiness state for
Maintainer Harness. It is evidence for the review process, not a submission
approval.

## Snapshot

| Field | Value |
| --- | --- |
| Checked at UTC | `2026-06-03T04:31:06.5136652Z` |
| Repository | `zlbdh/maintainer-harness` |
| Measured commit | `36b932a17c519093a5a31ac5be2ec4ae257c2df1` |
| Source command | local `scripts/checks/measure-application-readiness.ps1 -PassThru`, cross-checked with token-backed `Codex readiness monitor` artifact |
| Readiness score | `60/90` |
| Target score | `90` |
| Ready for form submission | no |
| Release anchor at snapshot time | https://github.com/zlbdh/maintainer-harness/releases/tag/v0.1.18 |

## Current Public Metrics

| Metric | Value |
| --- | ---: |
| Stars | 0 |
| Forks | 0 |
| Watchers | 0 |
| Subscribers | 0 |
| Open issues | 3 |
| External feedback comments counted | 0 |
| External first-run reports counted | 0 |
| Feedback-driven follow-up artifacts counted | 0 |

## Latest Main Validation

| Check | Status | Evidence |
| --- | --- | --- |
| Harness validation | success at snapshot time | https://github.com/zlbdh/maintainer-harness/actions/runs/26863671307 |
| GitHub Pages deployment | success at snapshot time | https://github.com/zlbdh/maintainer-harness/actions/runs/26863670744 |
| Codex readiness monitor | success at snapshot time | https://github.com/zlbdh/maintainer-harness/actions/runs/26863692203 |
| Monitor artifact | success at snapshot time | `codex-readiness-report`, artifact `7375818131`, digest `sha256:06e38c620ac603d3026d52509779bd0170ad95057d722a1254b72b18e3d15a4e` |
| Public evidence link health | pass | `scripts/checks/check-public-evidence-links.ps1` checked 17 public URLs |
| Public readiness | warn, no failures | `scripts/checks/check-public-ready.ps1` reported only the project-specific sensitive-pattern reminder |
| Security posture | warn, no failures | `scripts/checks/check-security-posture.ps1` reported only the project-specific sensitive-pattern reminder |
| External feedback registry | pass | `docs/external-feedback-evidence.yaml` is valid and currently empty |

The local `scripts/checks/measure-application-readiness.ps1 -PassThru` run
succeeded for this snapshot and matched the token-backed GitHub Actions monitor
score. This file records the measured commit, not necessarily the commit that
last edited this Markdown file; documentation-only snapshot refreshes can leave
the repository HEAD newer than the measured commit. If a future local anonymous
GitHub API call is rate-limited, do not treat the repository as ready from local
output alone; use the latest token-backed monitor artifact as the final
pre-submit gate.

## Hard Gates Still Missing

| Gate | Current | Required |
| --- | ---: | ---: |
| Real stars from people who inspected the project | 0 | 5 |
| External issue comments or first-run reports | 0 | 2 |
| External first-run report on issue `#6` | 0 | 1 |
| Feedback converted into a public issue or commit | 0 | 1 |

Issue `#5` and issue `#6` each include a maintainer update that routes real
reviewers to the shortest public review path. Those owner comments are useful
handoff notes, but they are intentionally not counted as external feedback.
Issue `#7` has no comments in this snapshot. The release anchor and owner
dogfooding follow-ups on main improve the handoff path, but they are not
counted as external feedback.

## Next Honest Work

Do not ask the maintainer to submit the OpenAI form yet. The next work should
focus on the external validation sprint:

- invite real maintainers to inspect the project or run the demo
- route first-run reports to issue `#6`
- route worker-output reviewability comments to issue `#5`
- record only verified public evidence in
  `docs/external-feedback-evidence.yaml`
- convert real feedback into a public issue or commit when a follow-up is
  warranted

Stars, comments, and reports must come from real inspection. Do not buy,
exchange, script, or otherwise manufacture engagement.
