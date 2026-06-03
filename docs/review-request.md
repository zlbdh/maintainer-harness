# Maintainer Harness Review Request

Use this public packet when asking a real maintainer, devtools builder, or
security-minded reviewer for a short critique. The goal is concrete feedback,
not artificial engagement.

Do not ask for star trades, paid stars, bots, bulk upvotes, or support from
people who have not inspected the project. A star is useful only after someone
has looked at the workflow and finds it worth recommending.

Self-owned alternate accounts do not count as external validation. Do not use a
second account, a controlled organization account, or a close proxy to create
stars, comments, forks, watchers, first-run reports, or feedback follow-ups for
the 90% gate.

## Fast Links

- Project site: https://zlbdh.github.io/maintainer-harness/
- External review path: https://zlbdh.github.io/maintainer-harness/external-review.html
- Copy-ready comment templates: https://zlbdh.github.io/maintainer-harness/external-review.html#templates
- Maintainer review kit: https://github.com/zlbdh/maintainer-harness/blob/main/docs/maintainer-review-kit.md
- Codespaces first-run guide: https://github.com/zlbdh/maintainer-harness/blob/main/docs/codespaces-first-run.md
- Codespaces quickstart: https://codespaces.new/zlbdh/maintainer-harness?quickstart=1
- Worker output reviewability example: https://github.com/zlbdh/maintainer-harness/blob/main/docs/worker-output-reviewability.md
- Source repository: https://github.com/zlbdh/maintainer-harness
- Current readiness snapshot: https://github.com/zlbdh/maintainer-harness/blob/main/docs/codex-for-oss-current-readiness.md
- Current gate status: https://github.com/zlbdh/maintainer-harness/issues/7#issuecomment-4609294155
- Reviewability feedback target: https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new
- First-run report target: https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new
- Feedback follow-up template: https://github.com/zlbdh/maintainer-harness/issues/new?template=feedback_follow_up.md

Use the external review page and current readiness snapshot for the latest
review anchors. The original issue `#5` and issue `#6` bodies are historical context and can mention older release anchors, but those issues remain the
right public comment targets.

## Who To Ask

Ask people who can judge at least one part of the workflow:

- open source maintainers who review pull requests or releases
- devtools builders working on CI, agent workflows, or release evidence
- engineers who have tried coding agents in real repositories
- security-minded reviewers who can evaluate write scopes and evidence trails

Private replies can help improve the project, but they do not count toward the
90% application gate unless the reviewer also leaves a public comment, report,
issue, commit, or release link.

## Five-Minute Paths

Pick one path. A short concrete note is better than broad praise.

| Time | Best action | Public target |
| --- | --- | --- |
| 3 min | Inspect the worker-output example and name one evidence gap before accepting agent output. | https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new |
| 5 min | Clone the repo, run the clean demo, and paste the generated first-run block. | https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new |
| 5 min | Use Codespaces if local Git or PowerShell setup would block a first-run report. | https://codespaces.new/zlbdh/maintainer-harness?quickstart=1 |
| 5 min | Review the security boundary around scoped writes, read-only MCP context, generated reports, and release evidence. | https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new |
| After feedback | Turn a concrete feedback item into a visible follow-up issue, commit, or release note. | https://github.com/zlbdh/maintainer-harness/issues/new?template=feedback_follow_up.md |

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

Cloud path if local Git or PowerShell setup would slow you down:

```text
https://codespaces.new/zlbdh/maintainer-harness?quickstart=1
```

The demo uses synthetic sample packets. It does not require private
repositories, production credentials, generated worktrees, or customer data.

## Short Maintainer Request

```text
Could I ask for a five-minute maintainer critique?

Maintainer Harness is an early OSS control plane for agent-assisted
maintenance: change briefs, impact maps, scoped task cards, validation
evidence, release gates, and security boundaries.

The fastest path is here:
https://zlbdh.github.io/maintainer-harness/external-review.html#templates

The worker-output example is here:
https://github.com/zlbdh/maintainer-harness/blob/main/docs/worker-output-reviewability.md

The most useful feedback is one concrete answer:
What evidence would make an agent worker output reviewable enough for you to
accept, reject, or request changes?
```

## First-Run Request

```text
Could you try a clean first run and report any friction?

Maintainer Harness uses synthetic sample packets, so it can be tested without
private repositories or production credentials.

Windows:
.\scripts\checks\run-review-demo.ps1

macOS/Linux with PowerShell 7:
pwsh ./scripts/checks/run-review-demo.ps1

Cloud path if local Git or PowerShell setup would slow you down:
https://codespaces.new/zlbdh/maintainer-harness?quickstart=1

Codespaces first-run guide:
https://github.com/zlbdh/maintainer-harness/blob/main/docs/codespaces-first-run.md

If you run it, please paste the generated public comment block into issue #6:
https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new

Short friction reports are more useful than praise.
```

## Security Boundary Request

```text
Could you review the safety boundary for this agent-maintenance workflow?

I am especially looking for weak assumptions around scoped write paths,
read-only MCP context, ignored local reports, generated worktrees, validation
evidence, and release decisions.

Review path:
https://zlbdh.github.io/maintainer-harness/external-review.html

Feedback target:
https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new
```

## What Counts Toward The 90% Gate

Only public, reviewer-visible signals count:

- a public issue comment from someone outside the author loop
- a public first-run report on issue `#6`
- a public feedback-driven issue, commit, or release
- a real star from someone who inspected the workflow

Self-owned alternate accounts do not count, even if they are public. Evidence
must come from a real outside reviewer who can inspect or run the workflow.

If feedback arrives somewhere else publicly, verify it before recording it in
`docs/external-feedback-evidence.yaml`. If feedback is private, use it to
improve the project, but do not count it as external evidence.
