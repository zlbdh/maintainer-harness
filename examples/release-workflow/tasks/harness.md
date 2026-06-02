# Task: Prepare Synthetic Release Evidence

## Owner

`release-agent`

## Scope

- Prepare a release note from verification evidence.
- Preserve skipped and environment-limited checks without overstating them.
- Record rollback steps and post-release observation points.
- Prepare postmortem-ready notes for future learning capture.

## Allowed Paths

- `examples/release-workflow/**`
- `docs/**`
- `release/**`

## Required Output

- `verification/result.md`
- `verification/workers/harness.md`
- `release/release-note.md`
- `release/postmortem-ready.md`

## Validation

```powershell
.\scripts\checks\validate-change.ps1 -Path examples\release-workflow
.\scripts\checks\check-public-ready.ps1 -SkipSensitivePattern
.\scripts\checks\check-security-posture.ps1 -SkipSensitivePattern
```

## Out Of Scope

- Publishing a real release.
- Creating a real tag.
- Running downstream product tests without connected product repositories.
