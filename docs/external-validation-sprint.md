# External Validation Sprint

This sprint is the fastest honest path to stronger Codex for OSS application
signals. It exists because the repository already has public maintenance
evidence, but still lacks external usage signals.

## Goal

Collect real maintainer signals within 24-48 hours:

- 3-5 stars from people who have actually inspected the project
- 2 issue comments from maintainers or devtools builders
- 1 first-run report from someone outside the author loop
- 1 public follow-up issue or roadmap update created from that feedback

Do not buy stars, trade stars, use bots, or ask people to star without looking
at the project. The strongest signal is a maintainer saying what would make the
workflow reviewable enough to try.

## Why This Matters For The Application

The Codex for OSS form asks for evidence such as GitHub stars, monthly
downloads, or why the project matters to the ecosystem. Maintainer Harness has a
strong ecosystem rationale and active maintenance trail, but it is still new.
This sprint is designed to turn the weak "0 external usage" signal into honest
early feedback evidence.

## Target People

Prioritize people who can judge the workflow:

- open source maintainers who review pull requests
- devtools builders working on CI, release, or agent workflows
- engineers who have tried coding agents in real repositories
- security-minded maintainers who care about write scopes and evidence trails

Avoid broad audiences until the demo path has at least one outside report.

Use `docs/maintainer-review-kit.md` as the shortest public reviewer handoff.
It gives maintainers a five-minute path to inspect, run, or security-review the
workflow without needing private repository context.
Use `https://zlbdh.github.io/maintainer-harness/external-review.html` when a
reviewer needs one web page with the four public signal actions and short
copy-ready comment templates for issue `#5` and issue `#6`.
For local copy-paste request drafts, run
`scripts/checks/write-review-request-packet.ps1`.

## Message Template

```text
I am applying Maintainer Harness to OpenAI Codex for OSS and would value a quick maintainer critique.

It is an early open source control plane for agent-assisted maintenance: change briefs, impact maps, scoped task cards, validation evidence, release gates, and security boundaries.

Project site:
https://zlbdh.github.io/maintainer-harness/

Five-minute review kit:
https://github.com/zlbdh/maintainer-harness/blob/main/docs/maintainer-review-kit.md

The most useful feedback is not "looks good" -- it is:
What evidence would make an agent worker output reviewable enough for you to accept, reject, or request changes?

If the workflow is useful after inspecting it, a star helps other maintainers discover it. Feedback is more valuable than the star.
```

## Short Public Post

```text
I am testing Maintainer Harness, an early OSS control plane for agent-assisted maintenance.

It turns agent work into change briefs, impact maps, scoped task cards, validation evidence, release gates, and security boundaries.

I would love maintainer feedback:
What evidence would make worker output reviewable enough to trust?

https://zlbdh.github.io/maintainer-harness/
```

## Feedback Capture

Ask outside reviewers to run:

```powershell
.\scripts\checks\run-review-demo.ps1
```

The script writes an ignored Markdown draft under `reports/first-run/` with
sanitized command output and the first-run issue link. Reviewers still decide
what to share publicly; the project should not create feedback on their behalf.
For automatic readiness counting, the preferred public target is a comment on
issue `#6`: https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new
The generated report includes a shorter `Copy This Comment Into Issue #6`
section for public posting and links the external review page with copy-ready
issue `#5` and issue `#6` templates:
https://zlbdh.github.io/maintainer-harness/external-review.html#templates

Record each useful response in `docs/launch-log.md` or a GitHub issue:

| Field | Example |
| --- | --- |
| Date | 2026-06-02 |
| Channel | GitHub issue, X, LinkedIn, direct maintainer message |
| Signal | star, issue comment, first-run report, roadmap suggestion |
| Feedback theme | validation clarity, scope safety, platform friction, release evidence |
| Follow-up artifact | issue URL, commit URL, release URL |

Private names are not required. Public URLs are stronger when available.
For machine-readable scorekeeping, add public verified signals to
`docs/external-feedback-evidence.yaml` and run:

```powershell
.\scripts\checks\validate-external-feedback-evidence.ps1
```

The Harness validation workflow also publishes a non-blocking Codex for OSS
readiness summary on the Windows job, so public reviewers can see whether the
external-signal gate is still open without treating missing stars as a CI
failure.
The dedicated `Codex readiness monitor` workflow can also be run manually after
new stars, issue comments, first-run reports, or feedback follow-up artifacts
arrive.

## 90% Readiness Threshold

The application should be re-estimated near 90% only after these public signals
exist:

| Signal | Target |
| --- | ---: |
| Stars from real readers | 5+ |
| Public issue comments or first-run reports | 2+ |
| Outside first-run report | 1+ |
| Feedback converted into issue or commit | 1+ |
| Latest CI and Pages after feedback update | success |

Until then, the honest full-support probability should remain below 90% because
external usage is still unproven.

## What To Do After Feedback Arrives

1. Add a launch-log row for each public signal.
2. Convert concrete feedback into an issue or small documentation fix.
3. Run public readiness and security posture checks.
4. Publish a small release or commit anchor if feedback changes the project.
5. Update `docs/codex-for-oss-reviewer-brief.md` with the new signal count.
6. Run `scripts/checks/measure-application-readiness.ps1` with `GITHUB_TOKEN`
   or `GH_TOKEN` set so the 90% monitor does not depend on anonymous API
   limits.
