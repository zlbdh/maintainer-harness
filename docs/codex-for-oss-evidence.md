# Codex for OSS Evidence Matrix

This document maps Maintainer Harness to the public Codex for Open Source program themes.

## Program Fit

Program source: [OpenAI Codex for Open Source](https://developers.openai.com/community/codex-for-oss).

The application is positioned around maintainership value rather than popularity. The repository is early, but it directly supports the program themes of pull request review, maintainer automation, release workflows, API-credit-backed dogfooding, and careful security boundaries.

| Program theme | Maintainer Harness evidence |
| --- | --- |
| Maintainer automation | `scripts/bootstrap/init-change.ps1`, `scripts/orchestrator/dispatch-change.ps1`, and `.agent/skills/` turn maintenance work into repeatable packets. |
| Pull request review workflows | `examples/issue-to-review/`, `templates/worker-result.md`, `schemas/worker-response.schema.json`, `schemas/review-response.schema.json`, and `scripts/orchestrator/review-worker-output.ps1` define reviewable worker output. |
| Worker output reviewability | `docs/worker-output-reviewability.md`, `templates/worker-result.md`, `schemas/worker-response.schema.json`, `schemas/review-response.schema.json`, and `examples/issue-to-review/verification/workers/harness.md` show the difference between vague agent output and evidence a maintainer can accept, reject, or request changes on. |
| Release workflows | `examples/release-workflow/`, `templates/release-note.md`, `release/README.md`, `standards/global/release-gates.md`, and `templates/postmortem.md` preserve release evidence, skipped checks, rollback, and postmortem-ready notes. |
| Day-to-day coding and triage | `docs/workflow.md`, `docs/harness-sop.md`, and `.agent/skills/local-baseline-triage/` define bounded maintainer routines. |
| API credits usage | `docs/codex-for-oss-application.md` explains dogfooding: task generation, review packets, baseline triage, validation summaries, and reusable examples. |
| Security care | `SECURITY.md`, `docs/security/`, `docs/security/redaction-patterns.md`, `standards/global/mcp-safety.md`, `mcp/`, `.gitignore`, `scripts/checks/check-public-ready.ps1`, and `scripts/checks/check-security-posture.ps1` keep write access, secrets, validation evidence redaction, and publication hygiene explicit. |
| Codex Security review | `docs/security/threat-model.md`, `docs/security/codex-security-project-overview.md`, `docs/security/codex-security-scope.md`, `docs/security/codex-security-review-pass-2026-06-02.md`, and `docs/security/security-review-checklist.md` define and exercise the review surface for agent write scopes, MCP read-only guarantees, generated worktrees, validation evidence, and release gates. |
| Reviewer readiness | `docs/codex-for-oss-reviewer-brief.md` gives a short reviewer-facing case for full support, including current metrics, why early-stage support is still useful, and 30/60/90 day public commitments. |
| 90% scorecard | `docs/codex-for-oss-90-scorecard.md`, `scripts/checks/measure-application-readiness.ps1`, and `scripts/checks/assert-form-submission-ready.ps1` define and enforce the hard external-signal gates before asking the maintainer to submit the form. |
| Current readiness snapshot | `docs/codex-for-oss-current-readiness.md` records the latest full API-backed score, public metrics, CI and Pages runs, and missing hard gates without treating owner comments as external feedback. |
| Token-backed readiness artifacts | `.github/workflows/harness-validation.yml` runs the readiness monitor with `GITHUB_TOKEN` on the Windows validation job and uploads `codex-readiness.json` plus `codex-readiness.md` for the commit. The dedicated `Codex readiness monitor` also uploads `external-feedback-candidates.json` and `external-feedback-review-queue.md` beside the readiness JSON so real public comments can be reviewed without relying on local anonymous API calls. |
| First-run and follow-up feedback capture | `scripts/checks/write-first-run-report.ps1`, `scripts/checks/add-external-feedback-evidence.ps1`, `docs/external-feedback-evidence.yaml`, `scripts/checks/validate-external-feedback-evidence.ps1`, `.github/ISSUE_TEMPLATE/first_run_feedback.md`, `.github/ISSUE_TEMPLATE/feedback_follow_up.md`, `.github/ISSUE_TEMPLATE/config.yml`, and issue `#6` make outside demo reports and feedback-driven follow-ups easier to generate, register, and validate without publishing private paths. The generator writes ignored Markdown and JSON summaries so reviewers can audit local results before posting public feedback, and the append helper rejects duplicate or non-public evidence URLs. |
| External feedback candidate review | `scripts/checks/find-external-feedback-candidates.ps1` scans issue `#5`, `#6`, and `#7` for non-owner, non-bot public comments that are not already registered, then prints guarded pending evidence commands for maintainer review. `scripts/checks/write-external-feedback-review-queue.ps1` turns those candidates into JSON and Markdown review queues. The scheduled readiness monitor runs the same queue with `GITHUB_TOKEN` and uploads both artifacts. It does not create comments, stars, or verified evidence by itself. |
| One-command outside review demo | `scripts/checks/run-review-demo.ps1` runs the public demo checks and hands reviewers the generated first-run Markdown report, JSON summary path, issue `#6`, external review templates, review kit, and worker-output example; public handoff pages include Windows and `pwsh` macOS/Linux command paths. |
| Maintainer review handoff | `docs/maintainer-review-kit.md`, `docs/review-request.md`, `scripts/checks/write-review-request-packet.ps1`, and `scripts/checks/check-external-review-handoff.ps1` give outside reviewers a five-minute path to inspect the workflow shape, run the demo, review the security boundary, or use the external review templates while CI prevents the direct issue links and copy-ready template route from drifting. |
| Chinese friend review guide | `docs/friend-review-guide-zh.md` gives the maintainer a copy-paste Chinese tutorial for real friends, maintainers, and developers: inspect the project, optionally run the demo, then decide whether to comment or star. The public-ready gate checks that this route stays linked from README and `docs/share.md`. |
| Evidence integrity | `docs/review-request.md`, `docs/launch-kit.md`, `docs/maintainer-review-kit.md`, `docs/share.md`, `scripts/checks/check-external-review-handoff.ps1`, and `scripts/checks/check-public-ready.ps1` explicitly state and verify that self-owned alternate accounts do not count as external validation. |
| External review path | `docs/external-review.html` maps the hard 90% external-signal gates to public reviewer actions: issue `#5`, issue `#6`, real stars after inspection, and feedback-driven follow-up artifacts. |
| Public dogfooding plan | `docs/dogfooding-plan.md` defines the first 30 days of API-credit-backed public maintainer workflows and avoids unsupported adoption claims. |
| Public dogfooding evidence | `docs/dogfooding-runs/2026-06-02-application-hardening.md` records the first Codex-assisted application hardening run, and `docs/dogfooding-runs/2026-06-03-readiness-transparency.md` records the readiness transparency run, produced artifacts, validation gates, and remaining weak signals. |
| External validation plan | `docs/external-validation-sprint.md` defines the honest path for turning weak external usage into public maintainer feedback, first-run reports, and star-safe discovery signals. |
| Public launch readiness | `docs/index.html`, `docs/external-review.html`, the GitHub Pages project site at `https://zlbdh.github.io/maintainer-harness/`, `docs/demo.md`, `docs/share.md`, `docs/launch-kit.md`, `docs/launch-log.md`, `docs/codex-for-oss-submission-readiness.md`, the `v0.1.20` cross-platform default public secret-scan release, pinned issues `#5`, `#6`, and `#7`, feedback-specific issue templates, labels, and the public profile README at `https://github.com/zlbdh/zlbdh` make the repository easier to try, share, critique, and contribute to without artificial star growth. |
| Public evidence link health | `scripts/checks/check-public-evidence-links.ps1` verifies that the project site, external review page, release, pinned issues, readiness monitor workflow, and key raw evidence files remain reachable before the application evidence is used. |
| Cross-platform validation | `.github/workflows/harness-validation.yml`, `scripts/lib/HarnessRepoTools.ps1`, and `docs/cross-platform-validation.md` keep the public validation gate runnable on Windows, Ubuntu, and macOS while clearly limiting worker orchestration claims until dogfooding feedback arrives. |

## Why This Is Useful Despite Early Adoption

The project is early, so it should not claim broad external adoption. Its application case is that the workflow itself can be reused by maintainers even before the project has popularity metrics. Its value is in making a difficult maintainer workflow concrete:

- every change has a durable `change-id`
- impact analysis is stored in files, not only chat history
- worker write scopes are explicit
- generated worktrees and product checkouts stay out of the public control repository
- local validation output is captured before release decisions
- publication checks can fail loudly before private material is pushed
- security posture checks can fail loudly when MCP access, agent scopes, ignored artifacts, or Codex Security review docs drift
- validation report redaction guidance makes public evidence sharing safer before maintainers copy ignored local reports into tracked summaries

This is a practical fit for open source maintainers who want AI assistance while preserving reviewability and trust.

## Evidence To Mention In The Application

- The repository is a maintainer tool, not a private product.
- Codex would be used to improve and dogfood the harness itself.
- The first target workflows are PR review packets, maintainer triage, validation summaries, and release evidence; `examples/issue-to-review/` shows the PR review packet shape and `examples/release-workflow/` shows the release evidence shape.
- The project is honest about early stage and limited usage metrics.
- The repository includes public hygiene controls before submission.
- Codex Security is useful because the project coordinates agents, MCP context, generated worktrees, validation evidence, and release gates.
- The full-support request is backed by public artifacts: CI, issue templates, a dogfooding plan, a Codex Security project overview, and a security posture gate.
- The submission readiness checklist maps public evidence to form fields while keeping private applicant data in an ignored local draft.
- The first Codex Security review pass is recorded publicly and includes one remediated path-scope finding plus MCP false-positive rationale.
- The repository now includes validation report redaction guidance for local paths, tokens, private endpoints, logs, customer data, and private repository names.
- The repository has a policy-safe launch path: a GitHub Pages project site, a validated demo, a compact share page, a launch-ready release, GitHub topics, labeled issues, a public feedback issue, a good-first-issue path, a launch log, and a GitHub profile README entry.
- The feedback issue and first-run issue are pinned in the repository so visitors can find the real contribution path without artificial star growth.
- The latest public site and launch materials include a star-safe call to action: ask for demo feedback first, and present stars only as an honest discovery signal for maintainers who find the workflow useful.
- The reviewer brief gives the application a short, auditable narrative for why an early project with no adoption metrics can still produce reusable ecosystem value.
- The first public dogfooding run shows that the project is already using Codex-style workflows to improve its own application evidence, while recording weak signals honestly.
- The readiness transparency dogfooding run shows that score checks, CI/Pages timing, public link health, and missing external gates are being recorded publicly instead of hidden in local notes.
- The external validation sprint and 90% scorecard make the readiness threshold explicit: real stars, public maintainer comments, outside first-run feedback, and a feedback-driven follow-up artifact.
- The current readiness snapshot keeps the public application status honest by showing the latest 60/90 score, successful CI and Pages runs, and the missing external hard gates.
- The first-run report generator gives outside reviewers a paste-ready, sanitized issue draft after running the demo commands.
- The one-command review demo reduces outside first-run friction by running the public checks and pointing reviewers to the generated report and issue `#6`.
- The worker-output reviewability example gives reviewers a short good/bad comparison before they critique the harness on issue `#5`.
- The public review request packet gives maintainers a fixed URL for asking real reviewers to inspect, run, or critique the harness without relying on ignored local generated reports.
- The evidence integrity rule makes self-owned alternate accounts, controlled proxy accounts, and author-loop interactions ineligible for stars, comments, reports, forks, watchers, or follow-up artifacts.

## Publication Gate

The final application should only be submitted after:

```powershell
.\scripts\checks\check-public-ready.ps1 -SensitivePattern "<legacy-name>|<private-remote>|<local-path>|<private-role>"
.\scripts\checks\check-public-evidence-links.ps1
.\scripts\checks\check-security-posture.ps1 -SensitivePattern "<legacy-name>|<private-remote>|<local-path>|<private-role>"
.\scripts\checks\assert-form-submission-ready.ps1
```

returns no failures on the public GitHub repository.
