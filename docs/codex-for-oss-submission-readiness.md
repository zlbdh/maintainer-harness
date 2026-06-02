# Codex For OSS Submission Readiness

This checklist records the public evidence that supports the Maintainer Harness application. It intentionally excludes private applicant data such as email address and OpenAI organization ID; those stay in the ignored local form draft under `reports/application-audit/`.

## Public Project Evidence

| Item | Evidence |
| --- | --- |
| Project site | https://zlbdh.github.io/maintainer-harness/ |
| Source repository | https://github.com/zlbdh/maintainer-harness |
| Latest release | https://github.com/zlbdh/maintainer-harness/releases/tag/v0.1.9 |
| Main branch CI history | https://github.com/zlbdh/maintainer-harness/actions/workflows/harness-validation.yml?query=branch%3Amain |
| Main branch Pages history | https://github.com/zlbdh/maintainer-harness/actions?query=workflow%3A%22pages+build+and+deployment%22+branch%3Amain |
| Evidence matrix | `docs/codex-for-oss-evidence.md` |
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

## Form Answers

Use the ignored local draft `reports/application-audit/form-fill-draft.md` for private fields and paste-ready 500-character answers.

Public answer mapping:

- GitHub username: `zlbdh`
- Repository URL: `https://github.com/zlbdh/maintainer-harness`
- Role: primary maintainer
- Interests: Codex Security and project API credits
- Qualification answer: use the draft section `Why Does This Repository Qualify? 500 Characters Max`
- API credits answer: use the draft section `How Will You Use API Credits? 500 Characters Max`
- Additional notes: use the draft section `Anything Else? 500 Characters Max`

## Pre-Submit Gate

Run these from the repository root before submitting:

```powershell
$pattern = '<private-name>|<private-remote>|<local-path>|<private-role>'
.\scripts\checks\check-public-ready.ps1 -SensitivePattern $pattern
.\scripts\checks\check-security-posture.ps1 -SensitivePattern $pattern
.\scripts\checks\write-application-audit.ps1 -SensitivePattern $pattern
```

The current application audit is passing in the ignored report directory.

## Manual Confirmation Needed

- Confirm how to split applicant name across the form's required last-name and first-name fields.
- Confirm whether to only fill the form or fill and submit it.
- Optionally pin the repository on the GitHub profile UI. The repository README and profile README already link the project, and issues `#5`, `#6`, and `#7` are pinned inside the repository.
