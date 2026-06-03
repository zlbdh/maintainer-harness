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

## Validation

- Public readiness check: PASS.
- Security posture check: PASS.
- Public evidence link checker: PASS, 16 public URLs.
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
- Issue `#7` has no comments.

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
