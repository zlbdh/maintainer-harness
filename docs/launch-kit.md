# Launch Kit

This kit is for growing real open source discovery without buying stars, asking for fake upvotes, or creating inauthentic engagement. The goal is simple: make the project easy to understand, easy to try, and easy to give feedback on.

## Ground Rules

- Do not buy stars, use bots, trade stars, or ask friends to upvote.
- Ask for feedback, not vanity metrics.
- Share the repository only where maintainer tooling, agent workflows, CI, or open source release process are on topic.
- Make it easy to try the project before asking anyone to care about it.
- Be clear that the project is early and uses synthetic examples.

Useful public rules:

- GitHub topics help people discover repositories by purpose and subject: https://docs.github.com/en/github/administering-a-repository/classifying-your-repository-with-topics
- GitHub allows project-related README and description text, but inauthentic activity is risky: https://docs.github.com/en/site-policy/acceptable-use-policies/github-acceptable-use-policies
- Show HN is for things people can try, and the rules say not to ask friends to upvote or comment: https://news.ycombinator.com/showhn.html

## Repository Pitch

Short description:

```text
Scoped change packets for agent-assisted open source maintenance.
```

One-liner:

```text
Maintainer Harness turns agent work into scoped change packets, validation evidence, and release-ready review trails.
```

Longer version:

```text
Maintainer Harness is an open source control plane for maintainers using Codex or other agents. Instead of starting from vague chat, each change gets a brief, impact map, execution plan, bounded worker task cards, validation evidence, and release gates. The sample workflow is synthetic, so maintainers can inspect the pattern before connecting real repositories.
```

## Launch Targets

| Channel | Best Use | Draft |
| --- | --- | --- |
| GitHub Pages project site | Give external visitors one clean project entry point before they inspect repository files. | Publish from `main` / `docs` at https://zlbdh.github.io/maintainer-harness/. |
| GitHub profile README | Make the project visible from the maintainer profile even before manual pinning. | Published at https://github.com/zlbdh/zlbdh. |
| GitHub profile pinned repo | Add another fixed profile entry. | Pin `maintainer-harness` manually from the GitHub profile UI; the public API does not expose profile pinning. |
| Hacker News Show HN | Ask technical maintainers for feedback after the demo path is clear. | Use the Show HN draft below. |
| X / Twitter | Short technical hook and repository link. | Use the short post or thread below. |
| LinkedIn | Maintainer story and open source process angle. | Use the LinkedIn draft below. |
| Reddit or forum posts | Ask for workflow critique in relevant maintainer/devtools communities. | Use the feedback request below. |
| GitHub issues | Show an active public roadmap. | Keep issues `#5`, `#6`, and `#7` pinned so outside maintainers can find feedback, first-run paths, and the 30-day evidence loop quickly. |

Current public launch anchors:

- Project site: https://zlbdh.github.io/maintainer-harness/
- Source repo: https://github.com/zlbdh/maintainer-harness
- Latest release: https://github.com/zlbdh/maintainer-harness/releases/tag/v0.1.15
- CI workflow: https://github.com/zlbdh/maintainer-harness/actions/workflows/harness-validation.yml
- Feedback issue: https://github.com/zlbdh/maintainer-harness/issues/5
- Good first issue: https://github.com/zlbdh/maintainer-harness/issues/6
- 30-day dogfooding tracker: https://github.com/zlbdh/maintainer-harness/issues/7
- Pinned feedback issue: https://github.com/zlbdh/maintainer-harness/issues/5
- Pinned first-run issue: https://github.com/zlbdh/maintainer-harness/issues/6
- Pinned dogfooding tracker: https://github.com/zlbdh/maintainer-harness/issues/7
- Demo path: https://github.com/zlbdh/maintainer-harness/blob/main/docs/demo.md
- Maintainer review kit: https://github.com/zlbdh/maintainer-harness/blob/main/docs/maintainer-review-kit.md
- Worker output reviewability: https://github.com/zlbdh/maintainer-harness/blob/main/docs/worker-output-reviewability.md
- Issue-to-review example: https://github.com/zlbdh/maintainer-harness/tree/main/examples/issue-to-review
- Release workflow example: https://github.com/zlbdh/maintainer-harness/tree/main/examples/release-workflow
- Share page: https://github.com/zlbdh/maintainer-harness/blob/main/docs/share.md
- Social preview: https://github.com/zlbdh/maintainer-harness/blob/main/docs/assets/social-preview.svg
- Launch log: https://github.com/zlbdh/maintainer-harness/blob/main/docs/launch-log.md
- GitHub profile README: https://github.com/zlbdh/zlbdh
- First-run feedback target: https://github.com/zlbdh/maintainer-harness/issues/6
- First-run feedback template fallback: https://github.com/zlbdh/maintainer-harness/issues/new?template=first_run_feedback.md
- Review demo runner: https://github.com/zlbdh/maintainer-harness/blob/main/scripts/checks/run-review-demo.ps1
- First-run report generator: https://github.com/zlbdh/maintainer-harness/blob/main/scripts/checks/write-first-run-report.ps1
- Review request packet generator: https://github.com/zlbdh/maintainer-harness/blob/main/scripts/checks/write-review-request-packet.ps1
- Worker output reviewability template: https://github.com/zlbdh/maintainer-harness/issues/new?template=worker_output_reviewability.md

## Show HN Draft

Title:

```text
Show HN: Maintainer Harness - scoped change packets for agent-assisted OSS work
```

Text:

```text
I built Maintainer Harness because agent-assisted maintenance often loses the boring but important parts: scope, evidence, review boundaries, and release notes.

The repo is a file-based control plane. A change becomes a brief, impact map, execution plan, worker task cards, validation evidence, and release gates. It is intentionally early and uses synthetic sample repositories so people can try the pattern without connecting private code.

The security surface is also part of the project: explicit worker write scopes, read-only MCP blueprints, ignored generated worktrees/reports, and CI checks for public readiness and security posture.

Demo path:

git clone https://github.com/zlbdh/maintainer-harness.git
cd maintainer-harness
.\scripts\checks\validate-repos.ps1
.\scripts\checks\validate-change.ps1 -Path examples\sample-change
.\scripts\checks\validate-change.ps1 -Path examples\issue-to-review
.\scripts\checks\validate-change.ps1 -Path examples\release-workflow
.\scripts\checks\check-security-posture.ps1 -SkipSensitivePattern
.\scripts\checks\write-first-run-report.ps1

I would like feedback from maintainers who have tried using agents for PR review, release work, or cross-repo changes. What evidence would you need before trusting a worker output?
```

## X / Twitter Short Post

```text
I published Maintainer Harness: a small open source control plane for agent-assisted maintenance.

It turns Codex/agent work into:
- change briefs
- impact maps
- scoped worker tasks
- validation evidence
- release gates

Early, synthetic, and CI-gated:
https://zlbdh.github.io/maintainer-harness/
```

## X / Twitter Thread

```text
1/ I published Maintainer Harness, an open source control plane for maintainers using Codex or other coding agents.

The problem it targets is not "can an agent write code?"
It is: where did the scope, evidence, and release decision go?

2/ Each change becomes files:
- brief.md
- impact.yaml
- execution.yaml
- task cards
- validation evidence
- release notes

That makes worker output easier to review and reject.

3/ The first security boundary is intentionally boring:
- explicit allowed paths
- read-only MCP blueprints
- ignored product checkouts
- ignored generated reports/worktrees
- public readiness and security posture checks in CI

4/ The repo is early and uses synthetic examples. That is deliberate. Maintainers can inspect the workflow before connecting real repositories.

Demo:
https://zlbdh.github.io/maintainer-harness/

5/ I would love feedback from OSS maintainers who have tried agent-assisted PR review or release work:

What evidence would make a worker output reviewable enough for you?
```

## LinkedIn Draft

```text
I published Maintainer Harness, an open source control plane for agent-assisted maintenance.

The project came from a simple problem: coding agents can produce work quickly, but maintainers still need scope, evidence, review boundaries, and release notes.

Maintainer Harness keeps those pieces in files:

- change brief
- cross-repo impact map
- execution plan
- bounded worker task cards
- validation evidence
- release gates
- security posture checks

The first release is intentionally early and uses synthetic repositories. That lets maintainers inspect the pattern before connecting private code.

I am especially interested in feedback from people who maintain multi-repo projects or have tried using agents for PR review and release work.

What would you need to see before trusting an agent's worker output?

https://zlbdh.github.io/maintainer-harness/

#opensource #maintainers #codex #developerexperience
```

## Forum Feedback Request

```text
I am looking for feedback on an early open source maintainer tool:
https://zlbdh.github.io/maintainer-harness/

It is a file-based control plane for agent-assisted maintenance. Instead of letting an agent work from chat alone, it creates a change brief, impact map, execution plan, bounded task cards, validation evidence, and release gates.

The repo is intentionally synthetic for now, so it can be tried without private code. The highest-risk areas are agent write scopes, read-only MCP context, ignored generated artifacts, and evidence handling before releases.

For people who maintain OSS projects: what would make this workflow useful enough to try on a real issue?
```

## Seven-Day Launch Checklist

| Day | Action | Success Signal |
| --- | --- | --- |
| 1 | Publish the GitHub Pages project site and set it as the repository homepage. | Visitors get one clean overview, demo path, and feedback route. |
| 1 | Publish the GitHub profile README and verify topics. | Profile visitors can find the project. |
| 1 | Pin the repo on the GitHub profile through the GitHub UI. | Profile visitors get a second fixed entry point. |
| 1 | Post the X short post. | At least one maintainer comment or repost. |
| 2 | Share the LinkedIn post. | Feedback from devtools/open source contacts. |
| 3 | Submit Show HN if the maintainer can stay online to answer questions. | Technical feedback, not just stars. |
| 4 | Turn feedback into GitHub issues. | Public roadmap becomes more specific. |
| 5 | Invite one contributor to try issue #6 and report first-run friction. | The first contribution path is tested by someone outside the maintainer loop. |
| 6 | Post a short update with what changed. | Shows the project is maintained. |
| 7 | Review stars, forks, issues, traffic, and comments. | Decide next launch topic. |

Record links, comments, and follow-up items in `docs/launch-log.md`.

## 48-Hour Star And Feedback Sprint

Use this when the project needs a quick credibility lift before an application
review. It is intentionally feedback-first: stars are a discovery signal, not
the ask that opens the conversation.

For the concrete 90% readiness threshold and message templates, see
`docs/external-validation-sprint.md`.

| Window | Action | Copy Anchor | Evidence To Record |
| --- | --- | --- | --- |
| Hour 0 | Pin the repository on the GitHub profile UI. | "Open source control plane for agent-assisted maintenance." | Screenshot or profile URL in the launch log. |
| Hour 1 | Send the share page to 3-5 maintainers or devtools builders who can critique the workflow. | "Could you tell me what evidence would make this worker output reviewable?" | Names omitted if private; record channel and feedback theme. |
| Hour 2 | Generate the review request packet and send the maintainer review kit, worker-output example, and one-command review demo to reviewers who prefer a structured 5-minute path. | "Pick one path: inspect, run, or review security boundaries." | Public issue comment or first-run report URL. |
| Hour 4 | Post the short X / Twitter copy with the project site. | Use the short post above. | Post URL and first replies. |
| Hour 12 | Share the LinkedIn draft with a feedback question. | "What would you need before trusting an agent's worker output?" | Post URL and comments. |
| Hour 24 | Convert useful replies into GitHub issues or roadmap notes. | Link issue #5, #6, or #7. | Issue URLs and follow-up owner. |
| Hour 36 | Publish a small update if feedback produced a concrete change. | "Here is what changed after first-run feedback." | Commit, release, or issue link. |
| Hour 48 | Review stars, forks, comments, and traffic. | No vanity claims; report the numbers as-is. | Update `docs/launch-log.md`. |

Good star wording:

```text
If this workflow is useful, a star helps other maintainers find it. Feedback on the demo is even more useful right now.
```

Do not use:

```text
Star-for-star, paid stars, bot engagement, private group upvote requests, or "please star even if you have not tried it."
```

## Metrics To Track

- stars and forks
- issue comments from real maintainers
- clone count and referral traffic from GitHub Insights
- release downloads if assets are added later
- number of feedback items converted into roadmap issues
- validation failures found by outside users

Stars are a signal, not the goal. The stronger signal is whether maintainers can try the workflow and tell you what would make it trustworthy.
