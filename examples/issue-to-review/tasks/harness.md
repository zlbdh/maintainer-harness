# Task: Prepare PR Review Evidence Packet

## Owner

`knowledge-agent`

## Source Issue

Synthetic GitHub issue `example/maintainer-tool#42`.

## Scope

- Convert the issue into maintainer-facing review evidence.
- Keep all repository names, branches, and validation output synthetic.
- Make the result easy for a pull request reviewer to accept, reject, or request changes.

## Allowed Paths

- `docs/**`
- `examples/**`

## Required Output

- Summarize what changed.
- List files that would be included in a pull request.
- Record validation commands and expected outcomes.
- Call out skipped checks explicitly.

## Validation

```powershell
.\scripts\checks\validate-change.ps1 -Path examples\issue-to-review
.\scripts\checks\check-security-posture.ps1 -SkipSensitivePattern
```

## Out Of Scope

- Opening a real pull request.
- Fetching live GitHub comments.
- Running product repository tests.
