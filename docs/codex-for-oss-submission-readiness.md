# Codex For OSS Submission Readiness

This checklist records the public evidence that supports the Maintainer Harness application. It intentionally excludes private applicant data such as email address and OpenAI organization ID; those stay in the ignored local form draft under `reports/application-audit/`.

## Public Project Evidence

| Item | Evidence |
| --- | --- |
| Project site | https://zlbdh.github.io/maintainer-harness/ |
| External review path | https://zlbdh.github.io/maintainer-harness/external-review.html |
| Source repository | https://github.com/zlbdh/maintainer-harness |
| Latest release | https://github.com/zlbdh/maintainer-harness/releases/tag/v0.1.17 |
| Reviewer brief commit | https://github.com/zlbdh/maintainer-harness/commit/32e6a0ad378a4e52478d067c8d78d30522b1e0cb |
| Reviewer brief CI | https://github.com/zlbdh/maintainer-harness/actions/runs/26829792583 |
| Reviewer brief Pages deployment | https://github.com/zlbdh/maintainer-harness/actions/runs/26829787083 |
| Main branch CI history | https://github.com/zlbdh/maintainer-harness/actions/workflows/harness-validation.yml?query=branch%3Amain |
| Non-blocking readiness monitor | `Report Codex for OSS readiness` step in the Harness validation workflow, plus the `codex-readiness-${commit}` artifact from the Windows validation job |
| Post-workflow readiness monitor | https://github.com/zlbdh/maintainer-harness/actions/workflows/codex-readiness-monitor.yml |
| Main branch Pages history | https://github.com/zlbdh/maintainer-harness/actions?query=workflow%3A%22pages+build+and+deployment%22+branch%3Amain |
| Evidence matrix | `docs/codex-for-oss-evidence.md` |
| Reviewer brief | `docs/codex-for-oss-reviewer-brief.md` |
| 90% readiness scorecard | `docs/codex-for-oss-90-scorecard.md` |
| Current readiness snapshot | `docs/codex-for-oss-current-readiness.md` |
| Worker output reviewability example | `docs/worker-output-reviewability.md` |
| First public dogfooding run | `docs/dogfooding-runs/2026-06-02-application-hardening.md` |
| Readiness transparency dogfooding run | `docs/dogfooding-runs/2026-06-03-readiness-transparency.md` |
| External validation sprint | `docs/external-validation-sprint.md` |
| Demo path | `docs/demo.md` |
| Cross-platform validation | `docs/cross-platform-validation.md` |
| Launch kit | `docs/launch-kit.md` |
| Dogfooding plan | `docs/dogfooding-plan.md` |
| Public 30-day dogfooding tracker | https://github.com/zlbdh/maintainer-harness/issues/7 |
| Issue-to-review example | `examples/issue-to-review/` |
| Release workflow example | `examples/release-workflow/` |
| Codex Security overview | `docs/security/codex-security-project-overview.md` |
| Codex Security review pass | `docs/security/codex-security-review-pass-2026-06-02.md` |
| Redaction guide | `docs/security/redaction-patterns.md` |
| Pinned feedback issue | https://github.com/zlbdh/maintainer-harness/issues/5 |
| Pinned first-run issue | https://github.com/zlbdh/maintainer-harness/issues/6 |
| Star-safe discovery update | https://github.com/zlbdh/maintainer-harness/commit/08163a46095ed2bf930dcb785101a10042de5af6 |
| Current public metrics | Counted by `scripts/checks/measure-application-readiness.ps1`, recorded in `docs/codex-for-oss-current-readiness.md`, and monitored by the post-workflow readiness workflow; do not submit until the hard external-signal gates pass. |

## Form Answers

Use the ignored local draft `reports/application-audit/form-fill-draft.md` for private fields and paste-ready 500-character answers.

Public answer mapping:

- GitHub username: `zlbdh`
- Repository URL: `https://github.com/zlbdh/maintainer-harness`
- Role: primary maintainer
- Interests: Codex Security and project API credits
- Qualification answer: use the draft section `Why Does This Repository Qualify? 500 Characters Max`
- Codex Security justification: use the draft section `Why Does This Project Need Codex Security?`
- API credits answer: use the draft section `How Will You Use API Credits? 500 Characters Max`
- Additional notes: use the draft section `Anything Else? 500 Characters Max` and reference `docs/codex-for-oss-reviewer-brief.md` if space allows.

## Pre-Submit Gate

Run these from the repository root before submitting:

```powershell
$pattern = '<private-name>|<private-remote>|<local-path>|<private-role>'
.\scripts\checks\check-public-ready.ps1 -SensitivePattern $pattern
.\scripts\checks\check-public-evidence-links.ps1
.\scripts\checks\check-security-posture.ps1 -SensitivePattern $pattern
.\scripts\checks\write-application-audit.ps1 -SensitivePattern $pattern
.\scripts\checks\measure-application-readiness.ps1
```

The current application audit is passing in the ignored report directory.
The readiness score intentionally exits non-zero until the 90% external-signal
gate is reached.

## Manual Web Form Step

- Use the ignored local draft for private applicant data and final form values.
- Submit the web form manually if browser verification requires an interactive Turnstile check.
- Optionally pin the repository on the GitHub profile UI. The repository README and profile README already link the project, and issues `#5`, `#6`, and `#7` are pinned inside the repository.
