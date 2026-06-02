# Worker Result: Harness

## Summary

Prepared a synthetic issue-to-review packet that shows issue intake, impact mapping, worker scope, validation evidence, and reviewer acceptance criteria.

## Files In Packet

- `brief.md`
- `issue-intake.md`
- `impact.yaml`
- `execution.yaml`
- `design.md`
- `acceptance.md`
- `tasks/harness.md`
- `verification/result.md`

## Validation Evidence

```powershell
.\scripts\checks\validate-change.ps1 -Path examples\issue-to-review
```

Expected outcome: PASS.

## Skipped Checks

- Live GitHub issue fetch: skipped because this is a synthetic example.
- Pull request creation: skipped because the packet demonstrates pre-PR review readiness only.
- Product repository test suite: skipped because no product repository is connected.
