# GitHub Publication Guide

Use this guide when publishing Maintainer Harness as a public GitHub repository.

## 1. Inspect The Current Remote

```powershell
git remote -v
```

If `origin` points at a private, legacy, or incorrectly named remote, replace it before pushing.

```powershell
git remote remove origin
git remote add origin https://github.com/<owner>/<repo>.git
```

Recommended public repository name:

```text
maintainer-harness
```

## 2. Stage Only Public Candidate Files

```powershell
git status --short --ignored
git ls-files --others --exclude-standard
```

Review ignored entries carefully. Legacy local assets, generated reports, worktrees, and product checkouts should stay ignored.

Run the readiness gate before committing:

```powershell
.\scripts\checks\check-public-ready.ps1 -SensitivePattern "<legacy-name>|<private-remote>|<local-path>|<private-role>"
```

It should fail before the first commit because public files are still untracked. The sensitive path and content checks should pass.

You can dry-run the publication sequence without changing Git state:

```powershell
.\scripts\bootstrap\prepare-publication.ps1 -GitHubRemote "https://github.com/<owner>/<repo>.git" -SensitivePattern "<legacy-name>|<private-remote>|<local-path>|<private-role>"
```

When the dry-run output looks right and you are ready to change Git state:

```powershell
.\scripts\bootstrap\prepare-publication.ps1 -Apply -GitHubRemote "https://github.com/<owner>/<repo>.git" -SensitivePattern "<legacy-name>|<private-remote>|<local-path>|<private-role>"
```

## 3. Commit

Prefer the scripted flow above. If staging manually, use:

```powershell
git add .agent .github .gitignore AGENTS.md CHANGELOG.md CODE_OF_CONDUCT.md CONTRIBUTING.md LICENSE MAINTAINERS.md README.md ROADMAP.md SECURITY.md SUPPORT.md changes config docs evals examples mcp release reports repos schemas scripts standards templates
git commit -m "初始化通用开源维护控制平面"
```

## 4. Push

```powershell
git push -u origin main
```

After pushing:

- confirm the repository is public
- confirm GitHub Actions runs `Harness validation`
- confirm the repository page does not show private legacy assets
- copy the public GitHub URL into the application form

## 5. Form Fields

Use `docs/codex-for-oss-application.md` for paste-ready application text.
