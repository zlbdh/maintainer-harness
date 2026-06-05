# Worker Output Reviewability

Use this page to review whether an agent worker result is ready for maintainer
review. It is intentionally short so outside maintainers can critique the
workflow without reading every harness file first.

## Not Reviewable

This kind of worker output is too vague:

```text
Done. I updated the docs and everything looks good.
```

Why a maintainer should reject it:

- no input snapshot
- no changed file list
- no exact commands
- no exit codes
- no skipped checks
- no risk statement
- no handoff to final verification

The problem is not tone. The problem is that the maintainer cannot reproduce,
review, or safely reject the work.

## Reviewable

A reviewable worker output should look more like this:

```text
Status: completed

Input snapshot:
- brief.md
- impact.yaml
- execution.yaml
- tasks/harness.md

Changed files:
- docs/demo.md
- examples/issue-to-review/verification/result.md

Scope / diff comparison:
| File | Declared scope? | Diff reviewed? | Maintainer decision |
| --- | --- | --- | --- |
| docs/demo.md | yes: docs example | yes | accept |
| examples/issue-to-review/verification/result.md | yes: verification example | yes | accept |

Commands:
- .\scripts\checks\validate-change.ps1 -Path examples\issue-to-review
  ExitCode: 0
  Summary: packet structure validates

Skipped checks:
- live GitHub issue fetch skipped because this is a synthetic example
  Decision level: acceptable explanation
- product repository test suite skipped because no product repository is connected
  Decision level: conditional acceptance; not release evidence for a real repo

Risks:
- example does not prove behavior in a real downstream repository

Handoff:
- verification-agent should compare this result with acceptance.md and public
  hygiene checks before accepting release evidence
```

## Scope / Diff Comparison

A maintainer should be able to compare every changed file with the declared
write scope before accepting worker output.

| Question | Accept | Request changes | Reject |
| --- | --- | --- | --- |
| Is the file inside the declared write scope? | Yes, and the scope is specific. | The scope is vague but can be narrowed. | The file is outside scope or touches another repo without approval. |
| Was the diff reviewed, not just the filename? | Yes, the actual diff supports the task. | The diff is too large or mixes unrelated cleanup. | The diff contradicts the task or hides unrelated behavior. |
| Does the file connect to the acceptance criteria? | Yes, the output names the criterion. | The link is plausible but not explicit. | No acceptance criterion explains the change. |

If a worker output lists changed files without this comparison, the maintainer
can ask for rework even when commands pass.

## Skipped Check Decision Levels

Skipped checks are not all equal. Name the reason and decision level so the
maintainer can decide whether to accept, request changes, or block the result.

| Decision level | Use when | Maintainer action |
| --- | --- | --- |
| Acceptable explanation | The check is irrelevant to the synthetic example, unavailable by design, or covered by a narrower check. | Accept the skip, but do not cite it as passing evidence. |
| Conditional acceptance | The check matters for a real repository, but the current packet is only a scoped example or dry run. | Accept the example only; require the check before release or real-repo rollout. |
| Blocking skip | The skipped check covers touched behavior, security, data handling, release gates, or an explicit acceptance criterion. | Reject or request changes until the check runs or the scope is changed. |

## Maintainer Review Questions

Ask these before accepting worker output:

- Can I see what inputs the worker used?
- Can I see the exact files changed?
- Can I compare changed files against declared write scope and acceptance criteria?
- Can I rerun the listed commands?
- Are skipped checks named with a reason and decision level?
- Are risks specific enough to act on?
- Is there a clear handoff to final verification?
- Is private context excluded from public evidence?

## Harness Artifacts To Inspect

- `templates/worker-result.md`
- `schemas/worker-response.schema.json`
- `schemas/review-response.schema.json`
- `examples/issue-to-review/verification/workers/harness.md`
- `examples/issue-to-review/verification/result.md`

## Feedback Prompt

If this is still not enough evidence, please leave a public comment:

https://github.com/zlbdh/maintainer-harness/issues/5

The most useful feedback is specific: name the missing evidence that would make
you accept, reject, or request changes on an agent worker result.
