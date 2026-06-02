# Branching And PR

Use branch names that include the change id and repository id.

```text
codex/CHG-2026-0001-api-contract-cleanup
codex/CHG-2026-0001-web-contract-cleanup
```

Recommended commit format:

```text
feat(api): align contract validation [CHG-2026-0001]
fix(web): handle empty approval state [CHG-2026-0002]
docs(harness): update release checklist [CHG-2026-0003]
```

PR descriptions should include:

- change id
- affected repository
- summary
- verification commands and output
- risk and rollback notes
- linked `verification/result.md`

Do not create PRs from this control repository unless the target repository and maintainer approval are explicit.
