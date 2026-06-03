# Codex For OSS Current Readiness Snapshot

This snapshot records a recent verified application-readiness state for
Maintainer Harness. It is evidence for the review process, not a submission
approval.

## Snapshot

| Field | Value |
| --- | --- |
| Checked at UTC | `2026-06-03T08:22:05.4765017Z` |
| Repository | `zlbdh/maintainer-harness` |
| Measured commit | `dc8faa5eecb669fdbe5d622f2a4bc89141d6984c` |
| Source command | local `scripts/checks/measure-application-readiness.ps1 -PassThru` run, cross-checked against the token-backed `Codex readiness monitor` artifact |
| Readiness score | `60/90` |
| Target score | `90` |
| Ready for form submission | no |
| Release anchor at snapshot time | https://github.com/zlbdh/maintainer-harness/releases/tag/v0.1.20 |

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
| Harness validation | success at snapshot time | https://github.com/zlbdh/maintainer-harness/actions/runs/26872447631 |
| GitHub Pages deployment | success at snapshot time | https://github.com/zlbdh/maintainer-harness/actions/runs/26872446462 |
| Codex readiness monitor | success at snapshot time | https://github.com/zlbdh/maintainer-harness/actions/runs/26872496675 |
| Monitor artifact | success at snapshot time | `codex-readiness-report`, artifact `7379236543`, digest `sha256:ec1779ef6c561b7a6cf739f59c8c74f98e47660b9b86f6cf2283ad4f5787ee16` |
| Public evidence link health | pass | `scripts/checks/check-public-evidence-links.ps1` checked 25 public URLs, including `docs/friend-review-guide-zh.md` |
| Public readiness | pass | `scripts/checks/check-public-ready.ps1` includes the default high-confidence secret scan |
| Security posture | pass | `scripts/checks/check-security-posture.ps1` includes the default high-confidence secret scan |
| External feedback registry | pass | `docs/external-feedback-evidence.yaml` is valid and currently empty |

The local `scripts/checks/measure-application-readiness.ps1 -PassThru` command
was run first for this monitoring pass and returned a full API-backed result.
The token-backed GitHub Actions monitor artifact for the same commit was also
inspected after the previous push. This file records the measured commit, not
necessarily the commit that last edited this Markdown file; documentation-only
snapshot refreshes can leave the repository HEAD newer than the measured
commit. If a future local anonymous GitHub API call is rate-limited, do not
treat the repository as ready from local output alone; use the latest
token-backed monitor artifact as the final pre-submit gate.

## Hard Gates Still Missing

| Gate | Current | Required |
| --- | ---: | ---: |
| Real stars from people who inspected the project | 0 | 5 |
| External issue comments or first-run reports | 0 | 2 |
| External first-run report on issue `#6` | 0 | 1 |
| Feedback converted into a public issue or commit | 0 | 1 |

Issue `#5` and issue `#6` each include a maintainer update that routes real
reviewers to the shortest public review path. Issue `#7` includes the current
owner dogfooding status comment:
https://github.com/zlbdh/maintainer-harness/issues/7#issuecomment-4609294155

Those owner comments are useful handoff notes, but they are intentionally not
counted as external feedback. The release anchor, CI runtime hygiene,
feedback-driven follow-up template, external feedback candidate finder, Chinese
friend review guide, and owner dogfooding follow-ups on main improve the
handoff path, but they are not counted as external feedback.

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
exchange, script, or otherwise manufacture engagement. Self-owned alternate accounts do not count as external validation.
