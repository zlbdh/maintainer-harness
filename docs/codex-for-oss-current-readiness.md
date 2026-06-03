# Codex For OSS Current Readiness Snapshot

This snapshot records a recent verified application-readiness state for
Maintainer Harness. It is evidence for the review process, not a submission
approval.

## Snapshot

| Field | Value |
| --- | --- |
| Checked at UTC | `2026-06-03T14:10:33.8984648Z` |
| Repository | `zlbdh/maintainer-harness` |
| Measured commit | `bde584c42282f635af030b8bc2952a3cd90ff93c` |
| Source command | local `scripts/checks/measure-application-readiness.ps1 -PassThru` was attempted first and hit the anonymous GitHub API rate limit; public GitHub HTML, `scripts/checks/write-public-readiness-observation.ps1 -PassThru`, and the token-backed `Codex readiness monitor` run were used for this transparency snapshot |
| Readiness score | `60/90` estimated from the unchanged hard-gate counts below |
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
| Harness validation | success at snapshot time | https://github.com/zlbdh/maintainer-harness/actions/runs/26890144926 |
| GitHub Pages deployment | success at snapshot time | https://github.com/zlbdh/maintainer-harness/actions/runs/26890143076 |
| Codex readiness monitor | success at snapshot time | https://github.com/zlbdh/maintainer-harness/actions/runs/26890197631 |
| Monitor artifact | present on the run page, but not anonymously downloadable during this pass | `codex-readiness-report` |
| Public evidence link health | pass | `scripts/checks/check-public-evidence-links.ps1` checked 26 public URLs, including `docs/friend-review-guide-zh.md` and the public readiness observation script |
| Public readiness | pass | `scripts/checks/check-public-ready.ps1` includes the default high-confidence secret scan and guards that public HTML fallback output is not a form-submission gate |
| Security posture | pass | `scripts/checks/check-security-posture.ps1` includes the default high-confidence secret scan |
| External feedback registry | pass | `docs/external-feedback-evidence.yaml` is valid and currently empty |

The local `scripts/checks/measure-application-readiness.ps1 -PassThru` command
was run first for this monitoring pass and stopped at the anonymous GitHub API
rate limit. Because that failure prevents local API-backed verification, this
snapshot is not a submission approval. It records the public state that was
still visible without authentication: 0 stars, 0 forks, 0 watchers, open issues
`#5`, `#6`, and `#7`, successful current-main validation, successful Pages
deployment, and a successful token-backed readiness monitor run. Use the latest
token-backed monitor artifact as the final pre-submit gate once it can be
inspected by an authenticated actor. The public readiness observation fallback
recorded 0 external feedback candidates and hard-coded
`ready_for_form_submission=false`, so it is a status aid rather than an approval
signal. Documentation-only snapshot refreshes can
leave the repository HEAD newer than the measured commit listed above; that is
expected and does not change the external-signal counts.

## Hard Gates Still Missing

| Gate | Current | Required |
| --- | ---: | ---: |
| Real stars from people who inspected the project | 0 | 5 |
| External issue comments or first-run reports | 0 | 2 |
| External first-run report on issue `#6` | 0 | 1 |
| Feedback converted into a public issue or commit | 0 | 1 |

Issue `#5` and issue `#6` each include a maintainer update that routes real
reviewers to the shortest public review path. Issue `#5`, the GitHub Pages
home page, the external review page, and the share page now link directly to
the Chinese friend review guide and first-run troubleshooting paths. Issue
`#7` includes the owner dogfooding status comment:
https://github.com/zlbdh/maintainer-harness/issues/7#issuecomment-4609294155

Those owner comments are useful handoff notes, but they are intentionally not
counted as external feedback. The release anchor, CI runtime hygiene,
feedback-driven follow-up template, external feedback candidate finder, Chinese
friend review guide, public readiness observation fallback, Pages handoff links,
and owner dogfooding follow-ups on main improve the handoff path, but they are
not counted as external feedback.

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
