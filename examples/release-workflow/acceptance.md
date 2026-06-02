# Acceptance

This release workflow packet is accepted when:

- `verification/result.md` cites validation commands and classifies each as PASS, WARN, or SKIP.
- `release/release-note.md` links the release decision to evidence, rollback steps, and observation points.
- `release/postmortem-ready.md` shows what would be captured if the release later produced a learning item.
- Skipped or environment-limited checks are not represented as passed.
- The packet references `templates/release-note.md`, `templates/verification-result.md`, and `standards/global/release-gates.md`.
- The packet passes `scripts/checks/validate-change.ps1 -Path examples/release-workflow`.
- Public readiness and security posture checks still pass.
