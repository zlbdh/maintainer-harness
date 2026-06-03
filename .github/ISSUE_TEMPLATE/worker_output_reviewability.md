---
name: Worker output reviewability
about: Describe what evidence would make agent worker output reviewable
title: "[Reviewability]: "
labels: "area:feedback, question"
---

## Maintainer Context

- Project shape: single-repo / multi-repo / release-heavy / security-heavy
- Agent use case: PR review / triage / release notes / cross-repo change / other

To count toward the public readiness gate, add reviewability feedback as a
comment on issue #5 after inspecting the project:
https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new

External review page with copy-ready comment templates:
https://zlbdh.github.io/maintainer-harness/external-review.html#templates

Only use the template after inspecting the project, sample packets, or worker
output example.

## Worker Output You Would Need

What should a worker report before you would accept, reject, or request changes?

## Missing Evidence

Which artifact needs more detail?

- `brief.md`
- `impact.yaml`
- `execution.yaml`
- task card
- `verification/result.md`
- release note
- security posture evidence

## Review Decision

What would make the final decision clear?

- accept
- reject
- request changes
- defer because validation is missing

## Safety Concerns

What checks should run before dispatch, review, or release?

## Smallest Improvement

What one change would make Maintainer Harness easier to trust?
