# Codespaces First-Run Path

Use this path when a real outside reviewer wants to run the demo without first
installing Git or PowerShell locally.

Open the repository in GitHub Codespaces:

https://codespaces.new/zlbdh/maintainer-harness?quickstart=1

The repository includes `.devcontainer/devcontainer.json`, which installs the
official Dev Containers PowerShell feature for the cloud workspace. After the
codespace opens, use the terminal from the repository root.

English first-run:

```bash
pwsh ./scripts/checks/run-review-demo.ps1
```

Chinese first-run with clipboard and issue target handoff:

```bash
pwsh ./scripts/checks/run-review-demo.ps1 -CommentLanguage zh -CopyCommentToClipboard -OpenCommentTarget
```

The script writes ignored local files under `reports/first-run/` and prints a
copy-ready issue `#6` block. It does not post comments automatically, does not create stars, and does not register evidence.
The reviewer still decides what to publish.

Preferred public target:

https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new

Self-owned alternate accounts do not count as external validation. Private
feedback can improve the project, but it does not count toward the 90% gate
unless a reviewer-visible public URL exists and passes validation.

After a real public URL exists, register it through
`docs/external-feedback-evidence.yaml` and run:

```powershell
.\scripts\checks\validate-external-feedback-evidence.ps1
```
