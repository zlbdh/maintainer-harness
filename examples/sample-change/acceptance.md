# Acceptance

This sample change is accepted when:

- The change packet passes `scripts/checks/validate-change.ps1 -Path examples/sample-change`.
- Harness metadata passes `scripts/checks/validate-repos.ps1`.
- Harness structure passes `scripts/bootstrap/verify-workspace.ps1`.
- Security posture passes `scripts/checks/check-security-posture.ps1 -SkipSensitivePattern`.
- The example remains synthetic and free of private repository names, credentials, customer data, local paths, or product-specific screenshots.
