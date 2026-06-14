# Share Maintainer Harness

This is the compact sharing page for Maintainer Harness. Use it when posting, replying to feedback, or sending the project to maintainers.

The goal is discovery through real inspection. Do not use this page to ask for
bulk engagement, star trades, paid recommendations, controlled accounts, or
copy-pasted praise.

## Primary Link

https://zlbdh.github.io/maintainer-harness/

## Reviewer Link

https://zlbdh.github.io/maintainer-harness/external-review.html#templates

## Public Review Request

https://github.com/zlbdh/maintainer-harness/blob/main/docs/review-request.md

## First-run troubleshooting

https://github.com/zlbdh/maintainer-harness/blob/main/docs/first-run-troubleshooting.md

## Codespaces first-run

https://github.com/zlbdh/maintainer-harness/blob/main/docs/codespaces-first-run.md

## 中文朋友实测教程

https://github.com/zlbdh/maintainer-harness/blob/main/docs/friend-review-guide-zh.md

## 中文发送前检查清单

https://github.com/zlbdh/maintainer-harness/blob/main/docs/friend-review-send-checklist-zh.md

## 中文反馈回收说明

https://github.com/zlbdh/maintainer-harness/blob/main/docs/friend-feedback-recovery-zh.md

## One-Liner

Maintainer Harness turns agent work into scoped change packets, validation evidence, and release-ready review trails.

## Who To Send It To

Prioritize people who can judge the workflow quickly:

- open source maintainers who review agent-assisted changes
- developers already using Codex, Claude Code, Cursor, or similar coding agents
- reviewers responsible for CI, release notes, security checks, or multi-repo changes
- DevTools, platform, or engineering productivity engineers
- friends with GitHub accounts who are willing to actually read the review page or run the demo

Avoid sending it to people who have no context and would only click a button to
help you. That does not create useful validation.

## 30-Second Value Check

Send reviewers to the project only if this sounds relevant to them:

```text
Maintainer Harness is a small OSS workflow for making AI-agent changes easier to review.
It asks agents to work from scoped change packets and leaves maintainer-readable evidence:
allowed paths, impact notes, validation output, skipped-check reasons, and follow-up links.
```

The fastest useful action is not praise. It is one of these:

- inspect the external review page and say what evidence is missing
- run the Codespaces demo and report the first-run result
- star or share only after inspection, if the workflow is useful enough to recommend

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

Cloud path without local Git or PowerShell setup:
https://codespaces.new/zlbdh/maintainer-harness?quickstart=1

Then paste the generated `Copy This Comment Into Issue #6` block into:
https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new

Optional clipboard helper after the report is written:
`.\scripts\checks\run-review-demo.ps1 -CopyCommentToClipboard`
or `pwsh ./scripts/checks/run-review-demo.ps1 -CopyCommentToClipboard`

Optional issue #6 browser handoff without posting automatically:
`.\scripts\checks\run-review-demo.ps1 -OpenCommentTarget`
or `pwsh ./scripts/checks/run-review-demo.ps1 -OpenCommentTarget`

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
.\scripts\checks\find-external-feedback-candidates.ps1
```

## Useful Links

- Project site: https://zlbdh.github.io/maintainer-harness/
- External review path: https://zlbdh.github.io/maintainer-harness/external-review.html
- Source repo: https://github.com/zlbdh/maintainer-harness
- Demo: https://github.com/zlbdh/maintainer-harness/blob/main/docs/demo.md
- Maintainer review kit: https://github.com/zlbdh/maintainer-harness/blob/main/docs/maintainer-review-kit.md
- Public review request packet: https://github.com/zlbdh/maintainer-harness/blob/main/docs/review-request.md
- Recommendation check: https://github.com/zlbdh/maintainer-harness/blob/main/docs/recommendation-check.md
- First-run troubleshooting: https://github.com/zlbdh/maintainer-harness/blob/main/docs/first-run-troubleshooting.md
- Codespaces first-run: https://github.com/zlbdh/maintainer-harness/blob/main/docs/codespaces-first-run.md
- Chinese friend send checklist: https://github.com/zlbdh/maintainer-harness/blob/main/docs/friend-review-send-checklist-zh.md
- Chinese friend feedback recovery: https://github.com/zlbdh/maintainer-harness/blob/main/docs/friend-feedback-recovery-zh.md
- Copy-ready review comments: https://zlbdh.github.io/maintainer-harness/external-review.html#templates
- Worker output reviewability: https://github.com/zlbdh/maintainer-harness/blob/main/docs/worker-output-reviewability.md
- Issue-to-review example: https://github.com/zlbdh/maintainer-harness/tree/main/examples/issue-to-review
- Release workflow example: https://github.com/zlbdh/maintainer-harness/tree/main/examples/release-workflow
- Latest tag anchor: https://github.com/zlbdh/maintainer-harness/releases/tag/v0.1.21
- 30-day dogfooding tracker: https://github.com/zlbdh/maintainer-harness/issues/7
- Current gate status: https://github.com/zlbdh/maintainer-harness/issues/7#issuecomment-4609294155
- Feedback follow-up template: https://github.com/zlbdh/maintainer-harness/issues/new?template=feedback_follow_up.md
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
- External feedback candidate finder: https://github.com/zlbdh/maintainer-harness/blob/main/scripts/checks/find-external-feedback-candidates.ps1
- Worker output reviewability template: https://github.com/zlbdh/maintainer-harness/issues/new?template=worker_output_reviewability.md
- Feedback follow-up template: https://github.com/zlbdh/maintainer-harness/issues/new?template=feedback_follow_up.md
- Social preview: https://github.com/zlbdh/maintainer-harness/blob/main/docs/assets/social-preview.svg

## Short Post

```text
I published Maintainer Harness, an open source control plane for agent-assisted maintenance.

It turns vague agent work into scoped change packets, validation evidence, and release-ready review trails.

The demo is synthetic and safe to try from a clean checkout:
https://zlbdh.github.io/maintainer-harness/
```

## Maintainer-Focused Post

```text
For open source maintainers experimenting with coding agents:

I built Maintainer Harness to make agent output easier to accept, reject, or request changes on. It turns vague agent work into scoped change packets, impact notes, validation evidence, skipped-check reasons, and release-ready review trails.

The demo uses synthetic sample repos, so you can inspect it without connecting private projects:
https://zlbdh.github.io/maintainer-harness/external-review.html

If you maintain a repo, I am most interested in this question: what evidence would make an agent-generated change reviewable enough for you?
```

## One-To-One Reviewer Invite

Run this through `scripts/checks/check-reviewer-invite-draft.ps1` before using
it if you edit the wording:

```text
I am testing a small open source workflow for reviewing AI-agent-generated changes.

It is not a direct star request. Please only star after you inspect it and would honestly recommend it to another maintainer.

If you have 5-10 minutes, can you first open the external review page or run the Codespaces demo, then tell me what evidence is missing or confusing?

External review path:
https://zlbdh.github.io/maintainer-harness/external-review.html

Codespaces first-run:
https://codespaces.new/zlbdh/maintainer-harness?quickstart=1
```

## 中文一对一邀请

```text
我在测试一个开源小工具，用来让 AI agent 生成的改动更容易被维护者审查。

这不是让你直接 star，也不需要 star；只有你先看过或跑过，觉得确实值得推荐给别的维护者时，再自己决定。

如果你有 5-10 分钟，可以先打开外部评审页，或者用 Codespaces 跑一次 demo，然后告诉我哪里看不懂、哪个证据不够、哪里会影响你接受 agent 输出吗？

外部评审页：
https://zlbdh.github.io/maintainer-harness/external-review.html

Codespaces 云端 demo：
https://codespaces.new/zlbdh/maintainer-harness?quickstart=1
```

## Channel Notes

Use the same feedback-first framing everywhere:

- X / LinkedIn: lead with the maintainer pain, then link the external review page.
- V2EX / 掘金 / 开源中国: use the Chinese invite and ask for first-run friction.
- Hacker News / Reddit: use the maintainer-focused post and ask for evidence gaps.
- GitHub discussions or maintainer groups: ask whether the scoped packet format would fit their review workflow.
- Private friends: send the one-to-one invite only to people willing to actually inspect or run it.

Do not post the same message repeatedly. A small number of targeted posts is
better than broad low-context promotion.

## Feedback Prompt

```text
For maintainers using Codex or other coding agents: what evidence would make a worker output reviewable enough for you to accept, reject, or request changes?
```

## Star-Safe CTA

Use this only after giving people the demo link or asking for feedback:

```text
If this workflow is useful enough that you would recommend it to another maintainer after inspecting it, a star helps discovery. If the value is unclear, the most helpful response is concrete feedback on what evidence would make agent output reviewable.
```

Avoid asking for star trades, bulk upvotes, automated engagement, or support
from people who have not seen the project. The project is stronger when stars
come from people who understand what the harness is trying to make safer.
Do not star only to help the author, satisfy a request, or support a project
you did not inspect.
Self-owned alternate accounts do not count as external validation.
