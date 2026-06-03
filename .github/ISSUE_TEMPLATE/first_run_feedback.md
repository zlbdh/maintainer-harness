---
name: First-run feedback
about: Report friction from trying the 90-second demo
title: "[First run]: "
labels: "area:demo, area:feedback"
---

## Environment

- OS:
- Shell:
- PowerShell version:
- Git version:

## Commands Tried

Windows PowerShell:

```powershell
.\scripts\checks\run-review-demo.ps1
```

macOS or Linux with PowerShell 7:

```bash
pwsh ./scripts/checks/run-review-demo.ps1
```

Cloud path if local Git or PowerShell setup would slow you down:

```text
https://codespaces.new/zlbdh/maintainer-harness?quickstart=1
```

Codespaces first-run guide:
https://github.com/zlbdh/maintainer-harness/blob/main/docs/codespaces-first-run.md

The demo runner writes a sanitized report under `reports/first-run/`. You can
paste the relevant sections here after reviewing them. It does not post comments automatically, does not create stars, and does not register evidence.

To count toward the public readiness gate, add first-run feedback as a comment
on issue #6 after running the demo:
https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new

External review page with copy-ready issue #5 and issue #6 comment templates:
https://zlbdh.github.io/maintainer-harness/external-review.html#templates

First-run troubleshooting:
https://github.com/zlbdh/maintainer-harness/blob/main/docs/first-run-troubleshooting.md

中文排障:
https://github.com/zlbdh/maintainer-harness/blob/main/docs/first-run-troubleshooting-zh.md

Only paste a report after you actually ran the demo or inspected the project.

## Result

- Passed:
- Failed:
- Slow or confusing:

## If It Failed

- Key error output, 3-10 lines:
- What would have helped:
- Did the troubleshooting page cover this case? yes / no / not checked

## First Useful File

Which file helped the workflow make sense first?

## First Confusing File Or Command

Which file or command should be clearer?

## Smallest Improvement

What one small change would make the demo easier to try?

## Sanitized Output

Do not paste secrets, private repository names, local private paths, tokens, customer data, or production logs.

```text

```
