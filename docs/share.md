# Share Maintainer Harness

This is the compact sharing page for Maintainer Harness. Use it when posting, replying to feedback, or sending the project to maintainers.

## Primary Link

https://zlbdh.github.io/maintainer-harness/

## Reviewer Link

https://zlbdh.github.io/maintainer-harness/external-review.html#templates

## One-Liner

Maintainer Harness turns agent work into scoped change packets, validation evidence, and release-ready review trails.

## What To Try

Fastest first-run route:

```powershell
git clone https://github.com/zlbdh/maintainer-harness.git
cd maintainer-harness
.\scripts\checks\run-review-demo.ps1
```

macOS/Linux with PowerShell 7:

```bash
git clone https://github.com/zlbdh/maintainer-harness.git
cd maintainer-harness
pwsh ./scripts/checks/run-review-demo.ps1
```

Then paste the generated `Copy This Comment Into Issue #6` block into:
https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new

If you only inspected the docs or worker-output example, leave one concrete
reviewability note here:
https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new

Full local check path:

```powershell
git clone https://github.com/zlbdh/maintainer-harness.git
cd maintainer-harness
.\scripts\checks\validate-repos.ps1
.\scripts\bootstrap\verify-workspace.ps1
.\scripts\checks\validate-change.ps1 -Path examples\sample-change
.\scripts\checks\validate-change.ps1 -Path examples\issue-to-review
.\scripts\checks\validate-change.ps1 -Path examples\release-workflow
.\scripts\checks\check-public-ready.ps1
.\scripts\checks\check-security-posture.ps1
.\scripts\checks\run-review-demo.ps1
.\scripts\checks\write-first-run-report.ps1
.\scripts\checks\write-review-request-packet.ps1
```

## Useful Links

- Project site: https://zlbdh.github.io/maintainer-harness/
- External review path: https://zlbdh.github.io/maintainer-harness/external-review.html
- Source repo: https://github.com/zlbdh/maintainer-harness
- Demo: https://github.com/zlbdh/maintainer-harness/blob/main/docs/demo.md
- Maintainer review kit: https://github.com/zlbdh/maintainer-harness/blob/main/docs/maintainer-review-kit.md
- Copy-ready review comments: https://zlbdh.github.io/maintainer-harness/external-review.html#templates
- Worker output reviewability: https://github.com/zlbdh/maintainer-harness/blob/main/docs/worker-output-reviewability.md
- Issue-to-review example: https://github.com/zlbdh/maintainer-harness/tree/main/examples/issue-to-review
- Release workflow example: https://github.com/zlbdh/maintainer-harness/tree/main/examples/release-workflow
- Latest release: https://github.com/zlbdh/maintainer-harness/releases/tag/v0.1.20
- 30-day dogfooding tracker: https://github.com/zlbdh/maintainer-harness/issues/7
- Current gate status: https://github.com/zlbdh/maintainer-harness/issues/7#issuecomment-4609294155
- Feedback comment target: https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new
- First-run feedback comment target: https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new
- Reviewability comment target: https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new
- First-run comment target: https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new
- Pinned feedback issue: https://github.com/zlbdh/maintainer-harness/issues/5
- Pinned first-run issue: https://github.com/zlbdh/maintainer-harness/issues/6
- First-run feedback target: https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new
- First-run feedback template fallback: https://github.com/zlbdh/maintainer-harness/issues/new?template=first_run_feedback.md
- Review demo runner: https://github.com/zlbdh/maintainer-harness/blob/main/scripts/checks/run-review-demo.ps1
- First-run report generator: https://github.com/zlbdh/maintainer-harness/blob/main/scripts/checks/write-first-run-report.ps1
- Review request packet generator: https://github.com/zlbdh/maintainer-harness/blob/main/scripts/checks/write-review-request-packet.ps1
- Worker output reviewability template: https://github.com/zlbdh/maintainer-harness/issues/new?template=worker_output_reviewability.md
- Social preview: https://github.com/zlbdh/maintainer-harness/blob/main/docs/assets/social-preview.svg

## Short Post

```text
I published Maintainer Harness, an open source control plane for agent-assisted maintenance.

It turns vague agent work into scoped change packets, validation evidence, and release-ready review trails.

The demo is synthetic and safe to try from a clean checkout:
https://zlbdh.github.io/maintainer-harness/
```

## Feedback Prompt

```text
For maintainers using Codex or other coding agents: what evidence would make a worker output reviewable enough for you to accept, reject, or request changes?
```

## Star-Safe CTA

Use this only after giving people the demo link or asking for feedback:

```text
If this workflow is useful, a star helps other maintainers discover it. The most helpful response is still feedback on what evidence would make agent output reviewable.
```

Avoid asking for star trades, bulk upvotes, automated engagement, or support
from people who have not seen the project. The project is stronger when stars
come from people who understand what the harness is trying to make safer.
