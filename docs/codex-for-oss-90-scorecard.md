# Codex For OSS 90% Readiness Scorecard

This scorecard defines when Maintainer Harness is ready to ask the maintainer to
submit the Codex for OSS form. It is intentionally stricter than ordinary
project readiness because the goal is a high-confidence full-support request:
API credits, ChatGPT Pro with Codex, and Codex Security.

## Current Rule

Do not ask the maintainer to submit the form until the readiness score reaches
90 and all hard external-signal gates pass.

Run:

```powershell
.\scripts\checks\measure-application-readiness.ps1
```

For continuous monitoring, set `GITHUB_TOKEN` or `GH_TOKEN` before running the
script. Anonymous GitHub API calls can be rate-limited, which makes the score
temporarily unverifiable even when the repository itself is public.

The script checks the GitHub repository, latest main CI, latest Pages
deployment, stars, public feedback comments, first-run reports, and manually
recorded follow-up artifacts.

External first-run reports are counted automatically when an outside reviewer
comments on issue `#6`. Public reports elsewhere can still count after their
URL is added as a verified `first-run-report` signal in
`docs/external-feedback-evidence.yaml`.

GitHub Actions also runs the readiness monitor on the Windows validation job
with `GITHUB_TOKEN`, writes a non-blocking step summary, and uploads
`codex-readiness.json` plus `codex-readiness.md` as a
`codex-readiness-${commit}` artifact. A score below 90 stays visible but does
not fail CI; CI failures are reserved for broken repository structure, public
hygiene, evidence registry format, or security posture drift.

The repository also includes a dedicated `Codex readiness monitor` workflow
under `.github/workflows/codex-readiness-monitor.yml`. It can be run manually
or on its six-hour schedule, and it also runs after the main Harness validation
or Pages deployment workflows complete. It writes a step summary and uploads a
`codex-readiness.json`, `external-feedback-candidates.json`, and
`external-feedback-review-queue.md` artifacts. It uses the GitHub Actions token
for authenticated API checks so monitoring does not depend on local anonymous
rate limits. The candidate report and review queue are review aids only: they
exclude owner, bot, duplicate, and already-registered comments, but nothing
counts until a maintainer reviews the public URL and registers verified
evidence. The post-workflow trigger is preferred when local checks are
rate-limited because it runs after the CI/Pages state has settled instead of
inside the still-running validation job.

Public follow-up evidence is recorded in
`docs/external-feedback-evidence.yaml` and validated by
`scripts/checks/validate-external-feedback-evidence.ps1`. Only `verified`
entries with public `https://` URLs count toward the score.

## Hard Gates

| Gate | Required |
| --- | ---: |
| Real stars from people who inspected the project | 5+ |
| External issue comments or first-run reports | 2+ |
| External first-run report on the demo path | 1+ |
| Feedback converted into a public issue or commit | 1+ |
| Latest Harness validation on main | success |
| Latest Pages deployment on main | success |

## Score Model

| Area | Points |
| --- | ---: |
| Core public evidence package | 35 |
| Dogfooding evidence and external validation sprint | 15 |
| External stars | 10 |
| External feedback comments | 10 |
| External first-run report | 10 |
| Feedback-driven follow-up artifact | 5 |
| Latest CI success | 5 |
| Latest Pages success | 5 |

The external gates are hard requirements. A high score without real external
feedback is not enough.

## Current Expected State

As of the verified 2026-06-03 readiness-monitor artifact recorded in
`docs/codex-for-oss-current-readiness.md`, Maintainer Harness scores 60/90 on
commit `dd051ea05c0eb16071342c39f354b0cb4615c4f7`. The required local
readiness command hit the anonymous GitHub API rate limit for the same
monitoring pass, so the token-backed post-workflow GitHub Actions monitor
artifact is the final source of truth:

- PASS: core public evidence package
- PASS: public dogfooding evidence and external validation sprint
- PASS: latest main CI and Pages deployment
- PASS: latest post-workflow Codex readiness monitor
- PASS: GitHub Actions workflows now target Node 24-compatible action versions
  for checkout and artifact upload
- PASS: public readiness and security posture, including the default
  high-confidence secret scan
- PASS: worker output reviewability example is now included in the public
  evidence package
- PASS: feedback-driven follow-up template is available for converting real
  public feedback into an auditable follow-up artifact
- PASS: external feedback candidate finder is available and avoids counting
  owner, bot, duplicate, or already-registered comments
- FAIL: 0/5 real stars
- FAIL: 0/2 external issue comments
- FAIL: 0/1 outside first-run report
- FAIL: 0/1 feedback-driven follow-up artifact

The next work should focus on the external validation sprint rather than adding
more internal documentation.
