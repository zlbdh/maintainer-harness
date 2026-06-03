# Maintainer Review Kit

Use this page when asking an outside maintainer or devtools builder for a quick
critique. The goal is real feedback, not artificial engagement.

For a web-first handoff, use:
https://zlbdh.github.io/maintainer-harness/external-review.html

Copy-ready external review templates are here:
https://zlbdh.github.io/maintainer-harness/external-review.html#templates

Current gate status is public here:
https://github.com/zlbdh/maintainer-harness/issues/7#issuecomment-4609294155

Public review request packet:
https://github.com/zlbdh/maintainer-harness/blob/main/docs/review-request.md

That page also includes copy-ready comment templates for issue `#5` and issue
`#6`. Please use them only after inspecting the project or running the demo.

To generate a local copy-paste request packet, run:

```powershell
.\scripts\checks\write-review-request-packet.ps1
```

The generated packet includes the external review templates, issue `#5`,
issue `#6`, issue `#7`, and the current readiness gate status so reviewers can
choose the shortest public feedback path.

## Reviewer Fit

Send the review request to people who can judge at least one part of the
workflow:

- open source maintainers who review pull requests or releases
- devtools builders working on CI, agent workflows, or release evidence
- engineers who have tried coding agents in real repositories
- security-minded reviewers who can evaluate write scopes and evidence trails

Do not send this as a star request to people who cannot inspect the project.
Owner comments, private messages, and uninspected stars do not count toward the
90% gate.
Self-owned alternate accounts do not count as external validation.

## Five-Minute Review Path

Pick one path:

| Path | Time | What to do | Best feedback link |
| --- | ---: | --- | --- |
| Review the workflow shape | 3 min | Read the sample issue-to-review packet and say what evidence is missing. | https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new |
| Compare worker evidence | 3 min | Read the good/bad worker output example and name the missing evidence. | https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new |
| Run the clean demo | 5 min | Clone the repo and run the one-command demo report. | https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new |
| Review the security boundary | 5 min | Read the Codex Security overview and flag unsafe agent or MCP assumptions. | https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new |

Use issue `#7`, a commit, or a release note only after feedback produces a
concrete follow-up artifact.

## Demo Commands

```powershell
git clone https://github.com/zlbdh/maintainer-harness.git
cd maintainer-harness
.\scripts\checks\run-review-demo.ps1
```

On macOS or Linux with PowerShell 7:

```bash
git clone https://github.com/zlbdh/maintainer-harness.git
cd maintainer-harness
pwsh ./scripts/checks/run-review-demo.ps1
```

To run each check manually:

```powershell
.\scripts\checks\validate-repos.ps1
.\scripts\bootstrap\verify-workspace.ps1
.\scripts\checks\validate-change.ps1 -Path examples\sample-change
.\scripts\checks\validate-change.ps1 -Path examples\issue-to-review
.\scripts\checks\validate-change.ps1 -Path examples\release-workflow
.\scripts\checks\check-public-ready.ps1
.\scripts\checks\check-security-posture.ps1
.\scripts\checks\write-first-run-report.ps1
```

The final command writes a local Markdown report and JSON summary under
`reports/first-run/`. Review both before sharing and remove secrets, private
repository names, tokens, customer data, or production logs.
For automatic 90% readiness counting, paste the report as a public comment on
issue `#6`: https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new
The report includes a `Copy This Comment Into Issue #6` block so reviewers do
not need to trim the full local report by hand.

## What Feedback Helps Most

- What evidence would make agent worker output reviewable enough to accept,
  reject, or request changes?
- Is the good/bad example in `docs/worker-output-reviewability.md` strict
  enough for real maintainer review?
- Which file or command made the workflow clear first?
- Which file or command was confusing, slow, or too platform-specific?
- What security boundary should fail before a worker can change files?
- What one change would make this useful enough to try on a real issue?

## What Counts As Public Evidence

For the 90% Codex for OSS readiness score, only public reviewer-visible signals
count:

- a public issue comment from someone outside the author loop
- a public first-run report on issue `#6`
- a public issue, commit, or release created from feedback
- a real star from someone who inspected the workflow

Self-owned alternate accounts do not count. Do not use a second account or a
controlled proxy account to create stars, comments, reports, forks, watchers, or
follow-up artifacts for the readiness gate.

Machine-readable evidence is recorded in `docs/external-feedback-evidence.yaml`
only after the public URL exists. Private messages can inform improvements, but
they do not count as public external evidence.

## Star-Safe Note

If the workflow is useful after inspection, a star helps other maintainers find
it. Feedback is more useful than the star, and star trades, paid stars, bots, or
bulk engagement are not acceptable.
