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

Commands:
- .\scripts\checks\validate-change.ps1 -Path examples\issue-to-review
  ExitCode: 0
  Summary: packet structure validates

Skipped checks:
- live GitHub issue fetch skipped because this is a synthetic example
- product repository test suite skipped because no product repository is connected

Risks:
- example does not prove behavior in a real downstream repository

Handoff:
- verification-agent should compare this result with acceptance.md and public
  hygiene checks before accepting release evidence
```

## Maintainer Review Questions

Ask these before accepting worker output:

- Can I see what inputs the worker used?
- Can I see the exact files changed?
- Can I rerun the listed commands?
- Are skipped checks named with a reason?
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
