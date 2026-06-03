# Codex For OSS Current Readiness Snapshot

This snapshot records the latest tracked readiness state for Maintainer
Harness. It is evidence for the review process, not a submission approval.
The current public package is healthy, but real external usage signals are
still missing.

## Snapshot

| Field | Value |
| --- | --- |
| Checked at UTC | `2026-06-03T22:12:42.8869524Z` |
| Repository | `zlbdh/maintainer-harness` |
| observed main commit | `0f903e676ba987ed22f09800b9d2ce108fc25ce0` |
| Source command | local `scripts/checks/write-public-readiness-observation.ps1 -PassThru` after the local anonymous GitHub API readiness check hit rate limits |
| Readiness score | last API-backed `60/90` hard-gate state; current public fallback is non-authoritative |
| Target score | `90` |
| Ready for form submission | no |
| Tag anchor at snapshot time | https://github.com/zlbdh/maintainer-harness/releases/tag/v0.1.20 |

## Latest API-Backed Measurement And Current Observation

The latest local monitoring pass still started with
`scripts/checks/measure-application-readiness.ps1 -PassThru`, as required by
the submission gate, but the anonymous GitHub API limit was exhausted during
the post-commit recheck. The failing request reported
`remaining=0` and `reset_utc=2026-06-03T22:36:54.0000000Z`, so the local
post-commit fallback observation must not be treated as form-submission
evidence.

The last completed API-backed local measurement before that limit window was
still `60/90`, with `ready_for_form_submission=false`. The token-backed
Codex readiness monitor also completed successfully for current main commit
`0f903e676ba987ed22f09800b9d2ce108fc25ce0`, but its artifact was not
anonymously downloadable during this pass. Use the token-backed artifact or a
fresh authenticated `measure-application-readiness.ps1` run before any form
submission decision.

| Metric | API-backed value |
| --- | ---: |
| Stars | 0 |
| Forks | 0 |
| Watchers | 0 |
| Subscribers | 0 |
| Open issues | 3 |
| External feedback comments counted | 0 |
| External first-run reports counted | 0 |
| Feedback-driven follow-up artifacts counted | 0 |
| Verified evidence signals | 0 |

The API-backed issue comment breakdown was:

| Issue | External comments counted |
| --- | ---: |
| `#5` | 0 |
| `#6` | 0 |
| `#7` | 0 |

The supporting public fallback observation at `2026-06-03T22:12:42Z` found 0
stars, 0 forks, 0 watchers, 3 open issues, and 0 external feedback
candidates. Public HTML fallback observations are discovery and transparency
hints only; they are not authoritative for form submission.

## Workflow Status

The latest public workflow pages for observed main commit
`0f903e676ba987ed22f09800b9d2ce108fc25ce0` show successful main validation,
Pages deployment, and post-workflow Codex readiness monitoring. The readiness
monitor artifact is produced on the run page, but it was not anonymously
downloadable during this pass.

| Check | Status | Evidence |
| --- | --- | --- |
| Harness validation | success | https://github.com/zlbdh/maintainer-harness/actions/runs/26916132172 |
| GitHub Pages deployment | success | https://github.com/zlbdh/maintainer-harness/actions/runs/26916130385 |
| Codex readiness monitor | success | https://github.com/zlbdh/maintainer-harness/actions/runs/26916170901 |
| Monitor artifact | produced on the run page, but not anonymously downloadable during this pass | `codex-readiness-report` |

## Local Verification

These checks passed in the same monitoring pass:

| Check | Evidence |
| --- | --- |
| Reviewer comment draft preflight | `scripts/checks/test-reviewer-comment-draft-preflight.ps1 -PassThru` checked safe drafts, local paths, private endpoints, raw stack traces, and no-post/no-engagement flags |
| Public evidence link health | `scripts/checks/check-public-evidence-links.ps1 -PassThru` checked 38 public URLs |
| Public readiness | `scripts/checks/check-public-ready.ps1 -PassThru` |
| Security posture | `scripts/checks/check-security-posture.ps1 -PassThru` |
| External review handoff | `scripts/checks/check-external-review-handoff.ps1 -PassThru` |
| External feedback registry | `scripts/checks/validate-external-feedback-evidence.ps1 -PassThru` found 0 signals and passed the empty registry check |
| External feedback queue | `scripts/checks/write-external-feedback-review-queue.ps1 -AllowHtmlFallback -PassThru` found 0 candidates |
| Public fallback observation | `scripts/checks/write-public-readiness-observation.ps1 -PassThru` recorded the current main run IDs and 0 public external candidates, but remained `authoritative_for_submission=false` |
| Form submission gate tests | `scripts/checks/test-form-submission-ready.ps1 -PassThru` confirmed the not-ready and score-mismatch fixtures block submission |

## Hard Gates Still Missing

| Gate | Current | Required |
| --- | ---: | ---: |
| Real stars from people who inspected the project | 0 | 5 |
| External issue comments or first-run reports | 0 | 2 |
| External first-run report on issue `#6` | 0 | 1 |
| Feedback converted into a public issue or commit | 0 | 1 |

Issue `#5` and issue `#6` remain the shortest public feedback routes, and
issue `#7` includes the owner dogfooding status comment:
https://github.com/zlbdh/maintainer-harness/issues/7#issuecomment-4609294155

Owner comments, local reports, copied review packets, generated outreach plans,
and public fallback observations are useful handoff or transparency evidence,
but they are intentionally not counted as external feedback. The tag anchor,
CI runtime hygiene, feedback-driven follow-up template, external feedback
candidate finder, Chinese friend review guide, one-page Chinese review guide,
copy-ready reviewer outreach drafts, public readiness observation fallback,
reviewer comment draft preflight, Pages handoff links, live Codespaces CTA
checks, issue historical-anchor guidance, and owner dogfooding follow-ups on
main improve the handoff path, but they are not counted as external feedback.

This snapshot records the observed main commit for this monitoring pass; later documentation-only commits can make repository HEAD newer without changing the
external-signal counts. It still does not replace the required API-backed pre-submit readiness measurement immediately before form submission.

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
