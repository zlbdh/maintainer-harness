# Codex For OSS Current Readiness Snapshot

This snapshot records a recent verified application-readiness state for
Maintainer Harness. It is evidence for the review process, not a submission
approval.

## Snapshot

| Field | Value |
| --- | --- |
| Checked at UTC | `2026-06-03T06:04:04.8439272Z` |
| Repository | `zlbdh/maintainer-harness` |
| Measured commit | `37c5f6e37b8be0e0d181c04e9e8f4e55e1cc6b38` |
| Source command | token-backed `Codex readiness monitor` artifact after the required local command completed and later anonymous GitHub API follow-up checks became rate-limited |
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
| Harness validation | success at snapshot time | https://github.com/zlbdh/maintainer-harness/actions/runs/26866800274 |
| GitHub Pages deployment | success at snapshot time | https://github.com/zlbdh/maintainer-harness/actions/runs/26866799636 |
| Codex readiness monitor | success at snapshot time | https://github.com/zlbdh/maintainer-harness/actions/runs/26866831879 |
| Monitor artifact | success at snapshot time | `codex-readiness-report`, artifact `7376952842`, digest `sha256:b5d62197a1c8e7658ada3f47b829c4954c369f54819e1ee08a951e608d55249e` |
| Public evidence link health | pass | `scripts/checks/check-public-evidence-links.ps1` checked 19 public URLs |
| Public readiness | pass | `scripts/checks/check-public-ready.ps1` includes the default high-confidence secret scan |
| Security posture | pass | `scripts/checks/check-security-posture.ps1` includes the default high-confidence secret scan |
| External feedback registry | pass | `docs/external-feedback-evidence.yaml` is valid and currently empty |

The local `scripts/checks/measure-application-readiness.ps1 -PassThru` command
was run first for this monitoring pass and completed with the same 60/90 gate
state. Later anonymous GitHub API follow-up checks became rate-limited, so this
snapshot uses the token-backed GitHub Actions monitor artifact as the final
source of truth for the measured commit, score, public metrics, and latest
CI/Pages run IDs. This file records the measured commit, not necessarily the
commit that last edited this Markdown file; documentation-only snapshot
refreshes can leave the repository HEAD newer than the measured commit. If a
future local anonymous GitHub API call is rate-limited, do not treat the
repository as ready from local output alone; use the latest token-backed monitor
artifact as the final pre-submit gate.

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
feedback-driven follow-up template, and owner dogfooding follow-ups on main
improve the handoff path, but they are not counted as external feedback.

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
