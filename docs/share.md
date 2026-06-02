# Share Maintainer Harness

This is the compact sharing page for Maintainer Harness. Use it when posting, replying to feedback, or sending the project to maintainers.

## Primary Link

https://zlbdh.github.io/maintainer-harness/

## One-Liner

Maintainer Harness turns agent work into scoped change packets, validation evidence, and release-ready review trails.

## What To Try

```powershell
git clone https://github.com/zlbdh/maintainer-harness.git
cd maintainer-harness
.\scripts\checks\validate-repos.ps1
.\scripts\bootstrap\verify-workspace.ps1
.\scripts\checks\validate-change.ps1 -Path examples\sample-change
.\scripts\checks\validate-change.ps1 -Path examples\issue-to-review
.\scripts\checks\validate-change.ps1 -Path examples\release-workflow
.\scripts\checks\check-security-posture.ps1 -SkipSensitivePattern
```

## Useful Links

- Project site: https://zlbdh.github.io/maintainer-harness/
- Source repo: https://github.com/zlbdh/maintainer-harness
- Demo: https://github.com/zlbdh/maintainer-harness/blob/main/docs/demo.md
- Issue-to-review example: https://github.com/zlbdh/maintainer-harness/tree/main/examples/issue-to-review
- Release workflow example: https://github.com/zlbdh/maintainer-harness/tree/main/examples/release-workflow
- Latest release: https://github.com/zlbdh/maintainer-harness/releases/tag/v0.1.8
- Feedback issue: https://github.com/zlbdh/maintainer-harness/issues/5
- Good first issue: https://github.com/zlbdh/maintainer-harness/issues/6
- Pinned feedback issue: https://github.com/zlbdh/maintainer-harness/issues/5
- Pinned first-run issue: https://github.com/zlbdh/maintainer-harness/issues/6
- First-run feedback template: https://github.com/zlbdh/maintainer-harness/issues/new?template=first_run_feedback.md
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
