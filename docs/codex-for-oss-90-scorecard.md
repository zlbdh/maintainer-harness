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
or on its six-hour schedule, writes a step summary, and uploads a
`codex-readiness.json` artifact. It uses the GitHub Actions token for
authenticated API checks so monitoring does not depend on local anonymous rate
limits.

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

As of the latest full API-backed local check on 2026-06-03, Maintainer Harness
scores 60/90. The concrete public snapshot is recorded in
`docs/codex-for-oss-current-readiness.md`. Later local anonymous checks may be
temporarily blocked by GitHub API rate limits, so the scheduled workflow is the
preferred ongoing monitor:

- PASS: core public evidence package
- PASS: public dogfooding evidence and external validation sprint
- PASS: latest main CI and Pages deployment
- PASS: worker output reviewability example is now included in the public
  evidence package
- FAIL: 0/5 real stars
- FAIL: 0/2 external issue comments
- FAIL: 0/1 outside first-run report
- FAIL: 0/1 feedback-driven follow-up artifact

The next work should focus on the external validation sprint rather than adding
more internal documentation.
