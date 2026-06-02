# Maintainer Review Kit

Use this page when asking an outside maintainer or devtools builder for a quick
critique. The goal is real feedback, not artificial engagement.

To generate a local copy-paste request packet, run:

```powershell
.\scripts\checks\write-review-request-packet.ps1
```

## Five-Minute Review Path

Pick one path:

| Path | Time | What to do | Best feedback link |
| --- | ---: | --- | --- |
| Review the workflow shape | 3 min | Read the sample issue-to-review packet and say what evidence is missing. | https://github.com/zlbdh/maintainer-harness/issues/5 |
| Compare worker evidence | 3 min | Read the good/bad worker output example and name the missing evidence. | https://github.com/zlbdh/maintainer-harness/issues/5 |
| Run the clean demo | 5 min | Clone the repo and run the one-command demo report. | https://github.com/zlbdh/maintainer-harness/issues/6 |
| Review the security boundary | 5 min | Read the Codex Security overview and flag unsafe agent or MCP assumptions. | https://github.com/zlbdh/maintainer-harness/issues/5 |

## Demo Commands

```powershell
git clone https://github.com/zlbdh/maintainer-harness.git
cd maintainer-harness
.\scripts\checks\run-review-demo.ps1
```

To run each check manually:

```powershell
.\scripts\checks\validate-repos.ps1
.\scripts\bootstrap\verify-workspace.ps1
.\scripts\checks\validate-change.ps1 -Path examples\sample-change
.\scripts\checks\validate-change.ps1 -Path examples\issue-to-review
.\scripts\checks\validate-change.ps1 -Path examples\release-workflow
.\scripts\checks\check-security-posture.ps1 -SkipSensitivePattern
.\scripts\checks\write-first-run-report.ps1
```

The final command writes a local Markdown report under `reports/first-run/`.
Review it before sharing and remove secrets, private repository names, tokens,
customer data, or production logs.
For automatic 90% readiness counting, paste the report as a public comment on
issue `#6`: https://github.com/zlbdh/maintainer-harness/issues/6
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

Machine-readable evidence is recorded in `docs/external-feedback-evidence.yaml`
only after the public URL exists. Private messages can inform improvements, but
they do not count as public external evidence.

## Star-Safe Note

If the workflow is useful after inspection, a star helps other maintainers find
it. Feedback is more useful than the star, and star trades, paid stars, bots, or
bulk engagement are not acceptable.
