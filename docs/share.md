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
.\scripts\checks\check-security-posture.ps1 -SkipSensitivePattern
```

## Useful Links

- Project site: https://zlbdh.github.io/maintainer-harness/
- Source repo: https://github.com/zlbdh/maintainer-harness
- Demo: https://github.com/zlbdh/maintainer-harness/blob/main/docs/demo.md
- Latest release: https://github.com/zlbdh/maintainer-harness/releases/tag/v0.1.3
- Feedback issue: https://github.com/zlbdh/maintainer-harness/issues/5
- Good first issue: https://github.com/zlbdh/maintainer-harness/issues/6
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
