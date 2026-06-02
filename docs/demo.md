# Demo

This demo is designed for maintainers who want to understand the harness before connecting a real repository. It uses only the synthetic sample change under `examples/sample-change/`.

## 30-Second Story

Maintainer Harness turns agent work into reviewable files:

1. Describe a change.
2. Map which repositories and interfaces are affected.
3. Generate scoped worker tasks.
4. Record validation evidence.
5. Review worker output before a release decision.

The point is not to make agents more autonomous. The point is to make their work easier to audit.

## Try It From A Clean Checkout

```powershell
git clone https://github.com/zlbdh/maintainer-harness.git
cd maintainer-harness

.\scripts\checks\validate-repos.ps1
.\scripts\bootstrap\verify-workspace.ps1
.\scripts\checks\validate-change.ps1 -Path examples\sample-change
.\scripts\checks\check-security-posture.ps1 -SkipSensitivePattern
```

## What To Look For

- `examples/sample-change/brief.md` explains the maintainer request.
- `examples/sample-change/impact.yaml` records affected surfaces.
- `examples/sample-change/execution.yaml` records owners, branches, and worker tasks.
- `examples/sample-change/tasks/harness.md` gives one worker a bounded task.
- `examples/sample-change/verification/result.md` records acceptance evidence.
- `config/agent-registry.yaml` keeps role write scopes explicit.
- `docs/security/codex-security-project-overview.md` explains the highest-risk security boundaries.

## Expected Result

In a clean checkout, the harness should validate. The default sample repositories under `repos/repos.yaml` are intentionally marked `missing-local-env`, so baseline commands can warn or skip until a maintainer replaces those entries with real repositories.

That is a feature, not a hidden failure: the public repository can be tried without private product code.

## Demo Script For A Maintainer Audience

```text
I built Maintainer Harness because agent-assisted maintenance gets messy fast.

The common failure is not that an agent cannot write code. It is that scope, evidence, and release decisions disappear into chat.

This repo keeps those decisions in files: a change brief, impact map, execution plan, worker task card, validation evidence, and release gates.

The sample flow is synthetic, so you can clone it and inspect the pattern without giving it a private repository.

The first security target is boring on purpose: keep write scopes explicit, keep MCP read-only by default, and fail before private reports or product checkouts become public.
```
