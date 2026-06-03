# Codex For OSS Current Readiness Snapshot

This snapshot records a recent verified application-readiness state for
Maintainer Harness. It is evidence for the review process, not a submission
approval.

## Snapshot

| Field | Value |
| --- | --- |
| Checked at UTC | `2026-06-03T03:47:22.2964583Z` |
| Repository | `zlbdh/maintainer-harness` |
| Measured main commit | `f35d41571611503406a4e77692851ef31a636053` |
| Source command | `scripts/checks/measure-application-readiness.ps1 -PassThru` |
| Readiness score | `60/90` |
| Target score | `90` |
| Ready for form submission | no |
| Release anchor at snapshot time | https://github.com/zlbdh/maintainer-harness/releases/tag/v0.1.16 |

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
| Harness validation | success at snapshot time | https://github.com/zlbdh/maintainer-harness/actions/runs/26862341961 |
| GitHub Pages deployment | success at snapshot time | https://github.com/zlbdh/maintainer-harness/actions/runs/26862341574 |
| Codex readiness monitor | success at snapshot time | https://github.com/zlbdh/maintainer-harness/actions/runs/26862366542 |
| Monitor artifact | success at snapshot time | `codex-readiness-report`, artifact `7375365536`, digest `sha256:8f12909f7195f5b6c47d7acbe01818bd0b5f042c910beeff978c107ee816db4f` |
| Public evidence link health | pass | `scripts/checks/check-public-evidence-links.ps1` checked 16 public URLs |
| Public readiness | pass | `scripts/checks/check-public-ready.ps1` |
| Security posture | pass | `scripts/checks/check-security-posture.ps1` |
| External feedback registry | pass | `docs/external-feedback-evidence.yaml` is valid and currently empty |

For the live main commit, exact CI run IDs, and exact Pages run ID, rerun the
source command or inspect the latest `codex-readiness-report` artifact from the
Codex readiness monitor workflow. The static snapshot should not be used as a
substitute for the final pre-submit gate.

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
