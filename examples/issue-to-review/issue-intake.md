# Issue Intake

## Synthetic Issue

```text
Title: Document the validation evidence required before PR review

Maintainers can run agents on documentation tasks, but reviewers need a predictable evidence packet before accepting a pull request. Please add a short review checklist and show which validation commands were run.
```

## Triage

- Category: pull request review workflow
- Risk: low
- Affected surface: maintainer documentation and example packets
- Required reviewer evidence: scope, changed files, validation commands, skipped checks, and final acceptance decision

## Routing Decision

Route the work to `knowledge-agent` because the change is documentation-only and the allowed write paths are `docs/**` and `examples/**`.
