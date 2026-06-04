# Codex For OSS Current Readiness Snapshot

This snapshot records the latest tracked readiness state for Maintainer
Harness. It is evidence for the review process, not a submission approval.
The current public package is healthy, but the external-signal hard gate is
still incomplete.

## Snapshot

| Field | Value |
| --- | --- |
| Checked at UTC | `2026-06-04T10:21:49.2915330Z` |
| Repository | `zlbdh/maintainer-harness` |
| observed main commit | `18391931963dcc4e5e3926ed80dc7ad3d8e0908b` |
| Source command | local `scripts/checks/measure-application-readiness.ps1 -PassThru` completed with GitHub API access |
| Readiness score | API-backed `85/90` hard-gate state; still not submission-ready |
| Target score | `90` |
| Ready for form submission | no |
| Tag anchor at snapshot time | https://github.com/zlbdh/maintainer-harness/releases/tag/v0.1.20 |

## Latest API-Limited Observation

After later documentation-only commits, the observed public `main` commit is
`e8a9c9022657679542adebaedc33700b824c2511`. A fresh local retry at
`2026-06-04T11:01Z` still hit the anonymous GitHub API rate limit, with reset
reported as `2026-06-04T11:14:48Z`, so this later observation is not an API-backed submission gate.

Public fallback checks still show the hard star gate missing: the repository
page shows `Star 0`, `Fork 0`, and `Issues 3`, while the workflow badges show
Harness validation, Pages deployment, and Codex readiness monitor as passing.
Issue `#6` has two non-owner first-run comments, and issue `#5` / issue `#7`
have no non-owner comments. The public issue `#7` current gate status comment
was refreshed to point reviewers at the current `85/90` state, the local API
rate-limit caveat, and the remaining `external-stars` 0/5 blocker.

## Latest API-Backed Measurement

The latest local monitoring pass completed
`scripts/checks/measure-application-readiness.ps1 -PassThru`, as required by
the submission gate, with GitHub API access. The result is `85/90`, with
`ready_for_form_submission=false`, for observed main commit
`18391931963dcc4e5e3926ed80dc7ad3d8e0908b`.

Two manually verified public issue `#6` first-run reports are registered in
`docs/external-feedback-evidence.yaml`, and one feedback-driven public commit
follow-up is registered. The API-backed issue comment scan counted the two
public non-owner issue `#6` comments directly. The current public repository
view and API metrics show `Star 0`, `Fork 0`, `Watchers 0`, `Subscribers 0`,
and `Issues 3`, so the external-stars hard gate remains red.

The latest Harness validation, Pages deployment, and Codex readiness monitor
completed successfully for observed main commit
`18391931963dcc4e5e3926ed80dc7ad3d8e0908b`.

Use the token-backed artifact or a fresh authenticated/API-backed
`measure-application-readiness.ps1` run immediately before any form submission
decision.

| Metric | Latest API-backed value / current public observation |
| --- | ---: |
| Stars | 0 |
| Forks | 0 |
| Watchers | 0 |
| Subscribers | 0 |
| Open issues | 3 |
| External feedback comments counted | 2 |
| External first-run reports counted | 2 |
| Feedback-driven follow-up artifacts counted | 1 |
| Verified evidence signals | 3 |

The API-backed issue comment breakdown was:

| Issue | External comments counted |
| --- | ---: |
| `#5` | 0 |
| `#6` | 2 |
| `#7` | 0 |

The direct GitHub comments API did not add extra unregistered comments beyond
the two already reviewed public issue `#6` first-run reports in the evidence
registry.

The registered evidence registry breakdown was:

| Signal type | Verified count |
| --- | ---: |
| Issue comment signals | 0 |
| First-run report signals | 2 |
| Feedback follow-up signals | 1 |

## Workflow Status

The latest public workflow pages for observed main commit
`18391931963dcc4e5e3926ed80dc7ad3d8e0908b` show successful main validation,
Pages deployment, and post-workflow Codex readiness monitoring. The readiness
monitor artifact is produced on the run page, but it was not anonymously
downloadable during this pass.

| Check | Status | Evidence |
| --- | --- | --- |
| Harness validation | success | https://github.com/zlbdh/maintainer-harness/actions/runs/26945730251 |
| GitHub Pages deployment | success | https://github.com/zlbdh/maintainer-harness/actions/runs/26945729499 |
| Codex readiness monitor | success | https://github.com/zlbdh/maintainer-harness/actions/runs/26945767968 |
| Monitor artifact | produced on the run page, but not anonymously downloadable during this pass | `codex-readiness-report` |

## Local Verification

These checks are the current tracked verification set. In this pass, link
health, public readiness, security posture, and external feedback registry were
rerun; rows for targeted demo and form-gate coverage are retained from the
latest successful targeted validations unless their files change.

| Check | Evidence |
| --- | --- |
| Reviewer comment draft preflight | `scripts/checks/test-reviewer-comment-draft-preflight.ps1 -PassThru` checked safe drafts, local paths, private endpoints, raw stack traces, and no-post/no-engagement flags |
| Reviewer invite draft preflight | `scripts/checks/test-reviewer-invite-draft-preflight.ps1 -PassThru` checks star-safe one-to-one invitation drafts without contacting reviewers or creating engagement |
| PowerShell source encoding | `scripts/checks/test-powershell-source-encoding.ps1 -PassThru` confirmed 48 tracked PowerShell source files and 0 UTF-8 BOM violations |
| Public evidence link health | `scripts/checks/check-public-evidence-links.ps1 -PassThru` checked 45 public URLs |
| Public readiness | `scripts/checks/check-public-ready.ps1 -PassThru` |
| Security posture | `scripts/checks/check-security-posture.ps1 -PassThru` |
| External review handoff | `scripts/checks/check-external-review-handoff.ps1 -PassThru` |
| External feedback registry | `scripts/checks/validate-external-feedback-evidence.ps1 -PassThru` found 3 verified signals: 2 first-run reports and 1 feedback follow-up |
| Inspection-first star language | `scripts/checks/check-public-ready.ps1 -PassThru` confirms README and Pages copy ask readers to star/share only after inspection and only if useful enough to recommend |
| Windows PowerShell 5.1 / CP936 demo | `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\checks\run-review-demo.ps1 -CommentLanguage zh` under code page 936 completed with `Passed: 6; Failed: 0; Skipped: 0` |
| Chinese issue chooser route | `.github/ISSUE_TEMPLATE/config.yml` now routes Chinese 3-minute feedback and 10-minute first-run reports to pinned public comment targets |
| Form submission gate tests | `scripts/checks/test-form-submission-ready.ps1 -PassThru` confirmed the not-ready and score-mismatch fixtures block submission |

## Hard Gates Still Missing

| Gate | Current | Required |
| --- | ---: | ---: |
| Real stars from people who inspected the project | 0 | 5 |
| External issue comments or first-run reports | 2 | 2 |
| External first-run report on issue `#6` | 2 | 1 |
| Feedback converted into a public issue or commit | 1 | 1 |

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
contact links, Windows PowerShell 5.1 encoding hardening, first-run newcomer
next-step guidance, and owner dogfooding follow-ups on main improve the handoff
path, but they are not counted as external feedback.

This snapshot records the observed main commit for this monitoring pass; later documentation-only commits can make repository HEAD newer without changing the
external-signal counts. It still does not replace the required API-backed pre-submit readiness measurement immediately before form submission.

## Next Honest Work

Do not ask the maintainer to submit the OpenAI form yet. The next work should
focus on the external validation sprint:

- invite real maintainers to inspect the project or run the demo
- route any additional first-run reports to issue `#6`
- route worker-output reviewability comments to issue `#5`
- record only verified public evidence in
  `docs/external-feedback-evidence.yaml`
- convert real feedback into a public issue or commit when a follow-up is
  warranted

Stars, comments, and reports must come from real inspection. Do not buy,
exchange, script, or otherwise manufacture engagement. Self-owned alternate accounts do not count as external validation.
