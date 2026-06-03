# Codex For OSS Current Readiness Snapshot

This snapshot records the latest tracked readiness state for Maintainer
Harness. It is evidence for the review process, not a submission approval.
The current public package is healthy, but real external usage signals are
still missing.

## Snapshot

| Field | Value |
| --- | --- |
| Checked at UTC | `2026-06-03T23:30:27.5872793Z` |
| Repository | `zlbdh/maintainer-harness` |
| observed main commit | `4b30a585e75da4535d5b4413128eaced2a5790ba` |
| Source command | local `scripts/checks/measure-application-readiness.ps1 -PassThru` |
| Readiness score | API-backed `60/90` hard-gate state |
| Target score | `90` |
| Ready for form submission | no |
| Tag anchor at snapshot time | https://github.com/zlbdh/maintainer-harness/releases/tag/v0.1.20 |

## Latest API-Backed Measurement And Current Observation

The latest local monitoring pass completed
`scripts/checks/measure-application-readiness.ps1 -PassThru`, as required by
the submission gate. It returned an API-backed `60/90`, with
`ready_for_form_submission=false`, because the external-signal hard gates are
missing. A follow-up anonymous API scan for additional feedback candidates then
hit the local rate limit (`remaining=0`,
`reset_utc=2026-06-03T23:39:27Z`), so the later public fallback observation is
not form-submission evidence. The token-backed Codex readiness monitor
completed successfully for observed main commit
`4b30a585e75da4535d5b4413128eaced2a5790ba`.

Use the token-backed artifact or a fresh authenticated/API-backed
`measure-application-readiness.ps1` run immediately before any form submission
decision.

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

The supporting public fallback observation at `2026-06-03T23:33:47Z` found 0
stars, 0 forks, 0 watchers, 3 open issues, and 0 external feedback candidates.
Public fallback observations are discovery and transparency hints only; they
are not authoritative for form submission.

## Workflow Status

The latest public workflow pages for observed main commit
`4b30a585e75da4535d5b4413128eaced2a5790ba` show successful main validation,
Pages deployment, and post-workflow Codex readiness monitoring. The readiness
monitor artifact is produced on the run page, but it was not anonymously
downloadable during this pass.

| Check | Status | Evidence |
| --- | --- | --- |
| Harness validation | success | https://github.com/zlbdh/maintainer-harness/actions/runs/26919452473 |
| GitHub Pages deployment | success | https://github.com/zlbdh/maintainer-harness/actions/runs/26919451701 |
| Codex readiness monitor | success | https://github.com/zlbdh/maintainer-harness/actions/runs/26919508359 |
| Monitor artifact | produced on the run page, but not anonymously downloadable during this pass | `codex-readiness-report` |

## Local Verification

These checks passed in the same monitoring pass:

| Check | Evidence |
| --- | --- |
| Reviewer comment draft preflight | `scripts/checks/test-reviewer-comment-draft-preflight.ps1 -PassThru` checked safe drafts, local paths, private endpoints, raw stack traces, and no-post/no-engagement flags |
| Reviewer invite draft preflight | `scripts/checks/test-reviewer-invite-draft-preflight.ps1 -PassThru` checks star-safe one-to-one invitation drafts without contacting reviewers or creating engagement |
| Public evidence link health | `scripts/checks/check-public-evidence-links.ps1 -PassThru` checked 42 public URLs |
| Public readiness | `scripts/checks/check-public-ready.ps1 -PassThru` |
| Security posture | `scripts/checks/check-security-posture.ps1 -PassThru` |
| External review handoff | `scripts/checks/check-external-review-handoff.ps1 -PassThru` |
| External feedback registry | `scripts/checks/validate-external-feedback-evidence.ps1 -PassThru` found 0 signals and passed the empty registry check |
| External feedback queue | a follow-up anonymous API candidate scan hit GitHub rate limits after the API-backed readiness measurement; the public fallback observation still found 0 candidates and remained non-authoritative |
| Public fallback observation | `scripts/checks/write-public-readiness-observation.ps1 -PassThru` recorded latest public run IDs including `26919508359`, `26919452473`, and `26919451701`, and 0 public external candidates, but remained `authoritative_for_submission=false` |
| Chinese issue chooser route | `.github/ISSUE_TEMPLATE/config.yml` now routes Chinese 3-minute feedback and 10-minute first-run reports to pinned public comment targets |
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
reviewer invite and comment draft preflights, Pages handoff links, live
Codespaces CTA checks, issue historical-anchor guidance, Chinese issue chooser
contact links, and owner dogfooding follow-ups on main improve the handoff
path, but they are not counted as external feedback.

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
