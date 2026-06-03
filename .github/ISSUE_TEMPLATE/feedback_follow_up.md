---
name: Feedback-driven follow-up
about: Track a public issue created from real external feedback
title: "[Follow-up]: "
labels: "area:feedback"
---

Use this only after real public feedback exists. Owner-only ideas, private
messages without a public summary, uninspected stars, or speculative roadmap
items do not count toward the 90% readiness gate.

## Public Feedback Source

Link the public comment, first-run report, discussion, or review that created
this follow-up:

-

## Feedback Summary

What concrete concern, friction, or missing evidence did the outside reviewer
raise?

## Planned Follow-Up

What public issue, commit, release note, or documentation change will close the
loop?

## Readiness Evidence Type

Choose the closest type:

- feedback-follow-up issue
- feedback-follow-up commit
- feedback-follow-up release note
- feedback-follow-up documentation update

## Verification

- [ ] Public feedback source is linked above.
- [ ] The source came from someone outside the author loop.
- [ ] The follow-up is specific enough to verify.
- [ ] Any local/private details have been removed.
- [ ] After the public follow-up exists, register it with:

```powershell
.\scripts\checks\add-external-feedback-evidence.ps1 -Id YYYY-MM-DD-feedback-follow-up -Type feedback-follow-up -Status verified -Url https://example.com/public-follow-up -Summary 'Concrete feedback was converted into a public follow-up.'
```
