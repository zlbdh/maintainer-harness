# Validation Report Redaction Patterns

Maintainer Harness treats generated validation reports as local evidence first and public evidence only after review. The default stance is conservative: keep complete reports ignored, then copy only the smallest safe summary into tracked files such as `verification/result.md`, release notes, or issue comments.

This guidance follows two public security principles: logs and reports should exclude or mask secrets and sensitive personal data, and repository secret scanning is a backstop rather than a replacement for local review.

## Private Data Classes

Remove, mask, hash, or replace these classes before sharing validation evidence:

| Class | Examples | Safe Placeholder |
| --- | --- | --- |
| Local paths | drive roots, home directories, workspace folders, temp directories | `<local-path>` |
| Tokens and credentials | API keys, access tokens, cookies, passwords, private certificates | `<secret-redacted>` |
| Private endpoints | internal hosts, VPN addresses, staging URLs, database hosts | `<private-endpoint>` |
| Logs and stack traces | production logs, customer request payloads, full exception dumps | `<log-redacted>` |
| Customer or personal data | names, emails, phone numbers, account IDs, order data | `<customer-data-redacted>` |
| Repository names | private repo names, branch names, remotes, organization slugs | `<private-repo>` |
| Environment values | `.env` keys, connection strings, machine names, CI secrets | `<env-redacted>` |

If the value is not needed for a maintainer decision, delete it instead of masking it.

## Ignored Artifact Boundaries

These paths are intentionally local-only and must stay ignored:

- `reports/**`: generated validation reports and application audits
- `worktrees/**`: generated or temporary worker checkouts
- `changes/CHG-*/runtime/**`: runtime packets and transient worker context
- `repos/**`: local product checkouts, except the tracked `repos/repos.yaml`

Do not move full generated reports into `docs/`, `examples/`, `release/`, or issue comments. Instead, copy a short redacted summary into the change packet's `verification/result.md`.

## Pre-Share Checklist

Run this before sharing validation evidence in a pull request, issue, release note, support application, or external post:

1. Confirm the complete report remains under an ignored path such as `reports/local-validation/`.
2. Copy only the command, status, and maintainer-relevant finding into a tracked file.
3. Replace private values with stable placeholders such as `<local-path>` or `<secret-redacted>`.
4. Run the default high-confidence secret scan:

```powershell
.\scripts\checks\check-public-ready.ps1
.\scripts\checks\check-security-posture.ps1
```

5. Add a project-specific scan for local names, endpoints, or roles that the
   default high-confidence pattern cannot know:

```powershell
$pattern = "<legacy-name>|<private-remote>|<local-path>|<private-role>"
.\scripts\checks\check-public-ready.ps1 -SensitivePattern $pattern
.\scripts\checks\check-security-posture.ps1 -SensitivePattern $pattern
```

6. Inspect ignored files before publishing:

```powershell
git status --short --ignored
git ls-files --others --exclude-standard
```

6. Record skipped checks as skipped. Do not rewrite an environment-limited check as passed.
7. If a secret was exposed, rotate it before publishing a redacted summary.

## Synthetic Redaction Examples

Path redaction:

```text
Before: D:\private-work\sample-api\src\Service.cs failed lint
After:  <local-path>\sample-api\src\Service.cs failed lint
```

Token redaction:

```text
Before: Authorization: Bearer ghp_exampletoken
After:  Authorization: Bearer <secret-redacted>
```

Endpoint redaction:

```text
Before: https://staging.internal.example.local/api/health returned 502
After:  <private-endpoint>/api/health returned 502
```

Repository redaction:

```text
Before: private-org/customer-portal branch hotfix/customer-42
After:  <private-repo> branch <private-branch>
```

Review summary:

```text
Safe: validate-change examples/issue-to-review passed; product repository tests were skipped because no product checkout is connected.
Unsafe: full local test transcript with machine paths, private remotes, request payloads, and stack traces.
```

## Reviewer Notes

- Prefer structured summaries over raw terminal transcripts.
- Keep evidence reproducible by naming commands, statuses, and skipped checks.
- Keep sensitive scan terms out of tracked files; pass them through `-SensitivePattern`.
- Treat GitHub secret scanning and push protection as backup controls. Local redaction still happens before commit.

## References

- OWASP Logging Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html
- GitHub secret scanning documentation: https://docs.github.com/en/code-security/concepts/secret-security/about-secret-scanning
