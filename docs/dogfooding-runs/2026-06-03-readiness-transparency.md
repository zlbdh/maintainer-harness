# Dogfooding Run: Readiness Transparency

Date: 2026-06-03

## Purpose

Use Codex-assisted maintenance work to make the Codex for OSS readiness state
more transparent without inflating external adoption signals. The run focused
on publishing the current readiness score, keeping the public gates verifiable,
and avoiding stale CI or Pages run IDs in static evidence.

## Inputs

- Public repository state at commit
  `46e50001dcfaa299bbd33a28c89965f10cbb9aee`.
- `scripts/checks/measure-application-readiness.ps1 -PassThru`.
- GitHub repository metrics from the public API.
- Issue comments on `#5`, `#6`, and `#7`.
- Latest main Harness validation and Pages deployment status.
- Public evidence link health from
  `scripts/checks/check-public-evidence-links.ps1`.

## Public Changes Produced

| Area | Public artifact |
| --- | --- |
| Current readiness state | `docs/codex-for-oss-current-readiness.md` records the latest verified score and missing hard gates. |
| Evidence matrix | `docs/codex-for-oss-evidence.md` links the current readiness snapshot as public evidence. |
| Submission checklist | `docs/codex-for-oss-submission-readiness.md` points form preparation back to the current readiness snapshot. |
| Public gates | `scripts/checks/check-public-ready.ps1` and `scripts/checks/write-application-audit.ps1` require the readiness snapshot. |
| Link health | `scripts/checks/check-public-evidence-links.ps1` now checks the public raw readiness snapshot URL. |
| Token-backed monitor | `.github/workflows/codex-readiness-monitor.yml` now runs after Harness validation or Pages deployment completes so local API rate limits have a better fallback. |

## Evidence Links

- Current readiness snapshot commit:
  https://github.com/zlbdh/maintainer-harness/commit/3edc6d52477c3f79cc80e2034c257741db64471c
- Stable snapshot reference commit:
  https://github.com/zlbdh/maintainer-harness/commit/46e50001dcfaa299bbd33a28c89965f10cbb9aee
- Latest full readiness check at the end of the run:
  `60/90` on commit `46e50001dcfaa299bbd33a28c89965f10cbb9aee`
  at `2026-06-03T01:37:42.7199963Z`.
- Harness validation:
  https://github.com/zlbdh/maintainer-harness/actions/runs/26858325546
- Pages deployment:
  https://github.com/zlbdh/maintainer-harness/actions/runs/26858324953

### Continuation: first-run template friction

- Follow-up commit:
  https://github.com/zlbdh/maintainer-harness/commit/99765a1cb51d781cad937a78c0828dd278e1bdf3
- Latest readiness check after the follow-up:
  `60/90` on commit `99765a1cb51d781cad937a78c0828dd278e1bdf3`
  at `2026-06-03T03:17:52.1609537Z`.
- Harness validation:
  https://github.com/zlbdh/maintainer-harness/actions/runs/26861393546
- Pages deployment:
  https://github.com/zlbdh/maintainer-harness/actions/runs/26861392820
- Codex readiness monitor:
  https://github.com/zlbdh/maintainer-harness/actions/runs/26861423687

The continuation found a maintainer-owned first-run friction point: the
`.github/ISSUE_TEMPLATE/first_run_feedback.md` template did not include the
macOS/Linux `pwsh ./scripts/checks/run-review-demo.ps1` path or the direct issue
`#6` comment target. Commit `99765a1cb51d781cad937a78c0828dd278e1bdf3` fixed
that handoff and updated the public readiness gate to keep the template from
regressing.

This is owner dogfooding evidence only. It does not count as an external
comment, outside first-run report, real star, or feedback-driven follow-up for
the 90% submission gate.

### Continuation: feedback evidence helper and monitor refresh

- Feedback evidence helper commit:
  https://github.com/zlbdh/maintainer-harness/commit/6aed2e2196e7ee1404fec1a1e1336426afa62563
- Public readiness gate follow-up:
  https://github.com/zlbdh/maintainer-harness/commit/36b932a17c519093a5a31ac5be2ec4ae257c2df1
- Latest release anchor:
  https://github.com/zlbdh/maintainer-harness/releases/tag/v0.1.18
- Latest readiness check after the follow-up:
  `60/90` on commit `36b932a17c519093a5a31ac5be2ec4ae257c2df1`
  at `2026-06-03T04:31:06.5136652Z`.
- Harness validation:
  https://github.com/zlbdh/maintainer-harness/actions/runs/26863671307
- Pages deployment:
  https://github.com/zlbdh/maintainer-harness/actions/runs/26863670744
- Codex readiness monitor:
  https://github.com/zlbdh/maintainer-harness/actions/runs/26863692203
- Codex readiness monitor artifact:
  `codex-readiness-report`, artifact `7375818131`, digest
  `sha256:06e38c620ac603d3026d52509779bd0170ad95057d722a1254b72b18e3d15a4e`.

The continuation added
`scripts/checks/add-external-feedback-evidence.ps1`, a guarded append helper
for `docs/external-feedback-evidence.yaml`. It rejects non-public URLs,
duplicate IDs, duplicate evidence URLs, and malformed one-line metadata before
running the external feedback evidence validator. The public readiness gate now
checks that duplicate evidence URLs remain rejected.

This helper reduces maintainer friction after real public feedback appears. It
does not count as an external comment, outside first-run report, real star, or
feedback-driven follow-up for the 90% submission gate.

### Continuation: default public secret scan

- Latest release anchor:
  https://github.com/zlbdh/maintainer-harness/releases/tag/v0.1.20
- Latest readiness check after the cross-platform fallback:
  `60/90` on commit `7604643f4cd97df97355a5046326790875bc2879`
  at `2026-06-03T04:58:17.5335964Z`.
- Harness validation:
  https://github.com/zlbdh/maintainer-harness/actions/runs/26864633867
- Pages deployment:
  https://github.com/zlbdh/maintainer-harness/actions/runs/26864633435
- Codex readiness monitor:
  https://github.com/zlbdh/maintainer-harness/actions/runs/26864653122
- Codex readiness monitor artifact:
  `codex-readiness-report`, artifact `7376155107`, digest
  `sha256:4461f169bff85f82acd0d5c92f3a4e5cd4aeab2b956a703582b071687927e2d1`.

The continuation replaced the previous `-SkipSensitivePattern` CI posture with
a default high-confidence secret-value scan in
`scripts/checks/check-public-ready.ps1` and
`scripts/checks/check-security-posture.ps1`. Reviewers still can pass a
project-specific `-SensitivePattern` for local names, endpoints, or private
roles that a generic scanner cannot know. The first CI attempt exposed an
`rg` availability difference on macOS and Ubuntu, so the scanner now uses a
PowerShell file scan over `git ls-files` instead of requiring `rg`.

This makes the public/security posture gates stricter and more reproducible. It
does not count as an external comment, outside first-run report, real star, or
feedback-driven follow-up for the 90% submission gate.

### Continuation: Node 24 CI hygiene and current monitor refresh

- CI runtime compatibility commit:
  https://github.com/zlbdh/maintainer-harness/commit/655877c77770cb0393007a0ad7e9868e908b35ea
- Current readiness check:
  `60/90` on commit `655877c77770cb0393007a0ad7e9868e908b35ea`
  at `2026-06-03T05:33:04.0750159Z`.
- Harness validation:
  https://github.com/zlbdh/maintainer-harness/actions/runs/26865666866
- Pages deployment:
  https://github.com/zlbdh/maintainer-harness/actions/runs/26865666279
- Codex readiness monitor:
  https://github.com/zlbdh/maintainer-harness/actions/runs/26865695846
- Codex readiness monitor artifact:
  `codex-readiness-report`, artifact `7376520337`, digest
  `sha256:c91501dbb9b6c208ee7c4fc4ebacc78bb1a3f572cc0b2e1ba1ee31808f73d9cd`.

The continuation moved the public validation workflows to Node 24-compatible
GitHub Actions versions (`actions/checkout@v6` and
`actions/upload-artifact@v7`) and kept the explicit Node 24 runtime opt-in in
place. The required local readiness command completed without anonymous API
rate limiting, and the token-backed post-workflow monitor reported the same
score and missing gates.

This improves CI maintainability and keeps the public readiness snapshot
current. It does not count as an external comment, outside first-run report,
real star, or feedback-driven follow-up for the 90% submission gate.

### Continuation: GitHub issue chooser direct feedback links

The continuation found one remaining handoff friction point: the GitHub issue
chooser had feedback-specific templates, but its contact links did not directly
route outside reviewers to the public issue `#5`, issue `#6`, or current issue
`#7` gate status. The issue chooser now exposes direct links for reviewability
feedback, first-run reports, and the current readiness gate before the generic
external review page. The worker-output reviewability template also points to
the issue `#5` comment box directly.

`scripts/checks/check-public-ready.ps1` now checks those direct links so the
external feedback handoff cannot silently drift back to a less useful route.
This reduces reviewer friction, but it does not count as an external comment,
outside first-run report, real star, or feedback-driven follow-up for the 90%
submission gate.

### Continuation: feedback-driven follow-up template

The continuation added `.github/ISSUE_TEMPLATE/feedback_follow_up.md` so real
external feedback can be converted into a public follow-up issue with the
source URL, concrete concern, planned change, and verification checklist in one
place. The template is linked from the issue chooser, external review page,
launch kit, share page, external validation sprint, and generated review request
packet.

`scripts/checks/check-public-ready.ps1`,
`scripts/bootstrap/verify-workspace.ps1`, and
`scripts/checks/check-public-evidence-links.ps1` now check for the follow-up
template. This prepares the project to count a real `feedback-follow-up` signal
when it exists, but the template itself does not count as external feedback,
outside first-run evidence, a real star, or a feedback-driven follow-up.

### Continuation: external feedback candidate finder

The continuation added
`scripts/checks/find-external-feedback-candidates.ps1`, a read-only helper that
scans issue `#5`, issue `#6`, and issue `#7` for new non-owner, non-bot public
comments that are not already present in
`docs/external-feedback-evidence.yaml`. The script prints guarded
`add-external-feedback-evidence.ps1` commands with `-Status pending`, so a
maintainer still has to review the public comment before changing the signal to
`verified`.

This reduces bookkeeping friction after real public feedback arrives. It does
not create external comments, outside first-run reports, real stars, or
feedback-driven follow-ups for the 90% submission gate.

## Validation

- Public readiness check: PASS, including the default high-confidence secret
  scan.
- Security posture check: PASS, including the default high-confidence secret
  scan.
- Public evidence link checker: PASS, 20 public URLs.
- Latest main Harness validation: success.
- Latest main Pages deployment: success.
- Latest Codex readiness monitor: success.
- External feedback evidence registry: valid and empty.

## What Remains Weak

- 0/5 real stars.
- 0/2 external issue comments or first-run reports.
- 0/1 external first-run report on issue `#6`.
- 0/1 feedback-driven public issue or commit.
- Issue `#5` and issue `#6` only contain owner routing comments.
- Issue `#7` only contains the owner dogfooding status comment.

## Follow-Up

- Do not ask the maintainer to submit the OpenAI form from this run alone.
- Route real first-run reports to issue `#6`.
- Route worker-output reviewability comments to issue `#5`.
- Record only verified public evidence in
  `docs/external-feedback-evidence.yaml`.
- Convert real feedback into a public issue or commit when it warrants a
  follow-up.
- Keep static readiness documents as snapshots; use the readiness script or the
  token-backed GitHub Actions artifact for final pre-submit checks.
- Prefer the dedicated post-workflow readiness monitor artifact over the
  validation-job artifact when local API checks are rate-limited, because the
  validation-job artifact can see its own CI run before it has completed.
