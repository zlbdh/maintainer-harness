# Codex for OSS Evidence Matrix

This document maps Maintainer Harness to the public Codex for Open Source program themes.

## Program Fit

Program source: [OpenAI Codex for Open Source](https://developers.openai.com/community/codex-for-oss).

The application is positioned around maintainership value rather than popularity. The repository is early, but it directly supports the program themes of pull request review, maintainer automation, release workflows, API-credit-backed dogfooding, and careful security boundaries.

| Program theme | Maintainer Harness evidence |
| --- | --- |
| Maintainer automation | `scripts/bootstrap/init-change.ps1`, `scripts/orchestrator/dispatch-change.ps1`, and `.agent/skills/` turn maintenance work into repeatable packets. |
| Pull request review workflows | `examples/issue-to-review/`, `templates/worker-result.md`, `schemas/worker-response.schema.json`, `schemas/review-response.schema.json`, and `scripts/orchestrator/review-worker-output.ps1` define reviewable worker output. |
| Release workflows | `templates/release-note.md`, `release/README.md`, `standards/global/release-gates.md`, and `templates/postmortem.md` preserve release evidence. |
| Day-to-day coding and triage | `docs/workflow.md`, `docs/harness-sop.md`, and `.agent/skills/local-baseline-triage/` define bounded maintainer routines. |
| API credits usage | `docs/codex-for-oss-application.md` explains dogfooding: task generation, review packets, baseline triage, validation summaries, and reusable examples. |
| Security care | `SECURITY.md`, `docs/security/`, `standards/global/mcp-safety.md`, `mcp/`, `.gitignore`, `scripts/checks/check-public-ready.ps1`, and `scripts/checks/check-security-posture.ps1` keep write access, secrets, and publication hygiene explicit. |
| Codex Security review | `docs/security/threat-model.md`, `docs/security/codex-security-project-overview.md`, `docs/security/codex-security-scope.md`, and `docs/security/security-review-checklist.md` define the review surface for agent write scopes, MCP read-only guarantees, generated worktrees, validation evidence, and release gates. |
| Public dogfooding plan | `docs/dogfooding-plan.md` defines the first 30 days of API-credit-backed public maintainer workflows and avoids unsupported adoption claims. |
| Public launch readiness | `docs/index.html`, the GitHub Pages project site at `https://zlbdh.github.io/maintainer-harness/`, `docs/demo.md`, `docs/share.md`, `docs/launch-kit.md`, `docs/launch-log.md`, the `v0.1.3` release, issues `#5` and `#6`, labels, and the public profile README at `https://github.com/zlbdh/zlbdh` make the repository easier to try, share, critique, and contribute to without artificial star growth. |

## Why This Is Useful Despite Early Adoption

The project is early, so it should not claim broad external adoption. Its application case is that the workflow itself can be reused by maintainers even before the project has popularity metrics. Its value is in making a difficult maintainer workflow concrete:

- every change has a durable `change-id`
- impact analysis is stored in files, not only chat history
- worker write scopes are explicit
- generated worktrees and product checkouts stay out of the public control repository
- local validation output is captured before release decisions
- publication checks can fail loudly before private material is pushed
- security posture checks can fail loudly when MCP access, agent scopes, ignored artifacts, or Codex Security review docs drift

This is a practical fit for open source maintainers who want AI assistance while preserving reviewability and trust.

## Evidence To Mention In The Application

- The repository is a maintainer tool, not a private product.
- Codex would be used to improve and dogfood the harness itself.
- The first target workflows are PR review packets, maintainer triage, validation summaries, and release evidence; `examples/issue-to-review/` now shows the PR review packet shape.
- The project is honest about early stage and limited usage metrics.
- The repository includes public hygiene controls before submission.
- Codex Security is useful because the project coordinates agents, MCP context, generated worktrees, validation evidence, and release gates.
- The full-support request is backed by public artifacts: CI, issue templates, a dogfooding plan, a Codex Security project overview, and a security posture gate.
- The repository has a policy-safe launch path: a GitHub Pages project site, a validated demo, a compact share page, a launch-ready release, GitHub topics, labeled issues, a public feedback issue, a good-first-issue path, a launch log, and a GitHub profile README entry.

## Publication Gate

The final application should only be submitted after:

```powershell
.\scripts\checks\check-public-ready.ps1 -SensitivePattern "<legacy-name>|<private-remote>|<local-path>|<private-role>"
.\scripts\checks\check-security-posture.ps1 -SensitivePattern "<legacy-name>|<private-remote>|<local-path>|<private-role>"
```

returns no failures on the public GitHub repository.
