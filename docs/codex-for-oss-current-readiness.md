# Codex For OSS Current Readiness Snapshot

This snapshot records a recent monitored application-readiness state for
Maintainer Harness. It is evidence for the review process, not a submission
approval. When the local anonymous GitHub API is rate-limited, this document
records only the public state and token-backed workflow status that were
visible during the pass.

## Snapshot

| Field | Value |
| --- | --- |
| Checked at UTC | `2026-06-03T16:09:25.6619940Z` |
| Repository | `zlbdh/maintainer-harness` |
| Observed commit | `5e808853ffd0c74d248ce44a7fc0191dc9deb2d1` |
| Source command | local `scripts/checks/measure-application-readiness.ps1 -PassThru` was attempted first and hit the anonymous GitHub API rate limit; public GitHub HTML, `scripts/checks/write-public-readiness-observation.ps1 -PassThru`, and the token-backed `Codex readiness monitor` run were used for this transparency snapshot |
| Readiness score | `60/90` from the latest API-backed hard-gate state and unchanged public external-signal counts; not a local API-backed approval in this pass |
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
| Harness validation | success at snapshot time | https://github.com/zlbdh/maintainer-harness/actions/runs/26897102232 |
| GitHub Pages deployment | success at snapshot time | https://github.com/zlbdh/maintainer-harness/actions/runs/26897098381 |
| Codex readiness monitor | success at snapshot time | https://github.com/zlbdh/maintainer-harness/actions/runs/26897194452 |
| Monitor artifact | present on the run page, but not anonymously downloadable during this pass | `codex-readiness-report` |
| Public evidence link health | pass | `scripts/checks/check-public-evidence-links.ps1` checked 34 public URLs, including the live external review Codespaces CTAs, `docs/friend-review-guide-zh.md`, and the public readiness observation script |
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
signal. This snapshot records the observed main commit for this monitoring
pass; later documentation-only commits can make repository HEAD newer without
changing the external-signal counts. It still does not replace the required API-backed pre-submit readiness measurement.

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
live Codespaces CTA checks, and owner dogfooding follow-ups on main improve the
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
