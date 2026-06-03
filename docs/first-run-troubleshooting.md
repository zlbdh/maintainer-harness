# First-Run Troubleshooting

Use this page when a real reviewer gets stuck while running the public
`run-review-demo.ps1` path. A failed first run is still useful feedback when it
is public, specific, and scrubbed of secrets.

## Check The Basics

- You need network access to GitHub.
- Windows can use PowerShell.
- macOS or Linux needs PowerShell 7 and the `pwsh` command.
- The demo does not need private repositories, production credentials, API
  keys, customer data, or production logs.

## Start From A Clean Checkout

Windows PowerShell:

```powershell
git clone https://github.com/zlbdh/maintainer-harness.git
cd maintainer-harness
.\scripts\checks\run-review-demo.ps1
```

macOS or Linux with PowerShell 7:

```bash
git clone https://github.com/zlbdh/maintainer-harness.git
cd maintainer-harness
pwsh ./scripts/checks/run-review-demo.ps1
```

## Common Issues

### Git Is Not Found

You may see:

```text
git: The term 'git' is not recognized
```

Fix:

- Install Git.
- Open a new terminal.
- Run `git --version` before cloning again.

### pwsh Is Not Found

You may see:

```text
pwsh: command not found
```

Fix:

- Install PowerShell 7.
- Open a new terminal.
- Run `pwsh --version`.
- Re-run `pwsh ./scripts/checks/run-review-demo.ps1`.

### Windows Blocks Script Execution

You may see:

```text
running scripts is disabled on this system
```

Use a one-time bypass for this demo command:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\checks\run-review-demo.ps1
```

Or with PowerShell 7:

```powershell
pwsh -ExecutionPolicy Bypass -File .\scripts\checks\run-review-demo.ps1
```

### The Script Path Is Not Found

You may see:

```text
The term '.\scripts\checks\run-review-demo.ps1' is not recognized
```

Make sure the terminal is in the repository root:

```powershell
cd maintainer-harness
Get-ChildItem .\scripts\checks\run-review-demo.ps1
.\scripts\checks\run-review-demo.ps1
```

macOS or Linux:

```bash
cd maintainer-harness
ls ./scripts/checks/run-review-demo.ps1
pwsh ./scripts/checks/run-review-demo.ps1
```

## Reduce Copy/Paste Friction

Copy the generated issue #6 comment block after the report is written:

```powershell
.\scripts\checks\run-review-demo.ps1 -CopyCommentToClipboard
```

Copy the block and open the issue #6 comment target:

```powershell
.\scripts\checks\run-review-demo.ps1 -CopyCommentToClipboard -OpenCommentTarget
```

macOS or Linux:

```bash
pwsh ./scripts/checks/run-review-demo.ps1 -CopyCommentToClipboard -OpenCommentTarget
```

`-OpenCommentTarget` only opens the browser target. It does not post a comment automatically. Review the generated text before pasting anything publicly.

## Post A Failed First Run

If the command fails, post the failure on issue #6:

```text
https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new
```

Useful failure report:

```text
I tried the Maintainer Harness review demo and got stuck.
OS / shell: [Windows PowerShell / macOS pwsh / Linux pwsh]
Command: [paste the command]
Key error output: [paste the most important 3-10 lines]
What would have helped: [one specific doc or command improvement]
```

Do not paste tokens, private repository URLs, customer data, production logs,
or sensitive local paths. Specific failure reports are more useful than vague
praise.
