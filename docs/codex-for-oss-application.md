# Codex for OSS Application Notes

This file provides a paste-ready project summary for the OpenAI Codex for OSS application form.

## Project Name

Maintainer Harness

## Repository

https://github.com/zlbdh/maintainer-harness

## Short Description

Maintainer Harness is a lightweight open source control plane for agent-assisted software maintenance. It turns cross-repository work into auditable change packets, scoped worker tasks, validation commands, release evidence, and reusable maintainer skills.

## Why Codex Helps

Maintainers often need to coordinate fixes across several repositories while keeping scope, evidence, and release notes consistent. Codex is useful here because it can read the harness files, generate bounded task cards, run validation scripts, and summarize evidence without turning the process into unstructured chat history.

## OSS Relevance

The project is designed for maintainers of multi-repository open source systems, especially projects that want to use AI agents without losing auditability. It focuses on safe defaults:

- repository metadata lives in `repos/repos.yaml`
- agent roles and write scopes live in `config/agent-registry.yaml`
- every change gets a durable `change-id`
- worker packets are generated from explicit impact and execution files
- validation output is recorded before release decisions
- MCP examples are read-only by default

See `docs/codex-for-oss-evidence.md` for a file-by-file evidence matrix that maps the repository to maintainer automation, pull request review workflows, release workflows, API credits usage, and security care.

See `docs/dogfooding-plan.md` for the first 30 days of public API-credit-backed dogfooding and `docs/security/codex-security-project-overview.md` for a paste-ready Codex Security threat-model overview.

## Current Stage

Early public-ready project. The repository has been generalized from local maintainer experiments into a reusable harness. It does not yet have broad external adoption, stars, or contributors, so the application should be honest about its stage and emphasize maintainership value rather than popularity.

## Form Checklist

- GitHub username: make the profile public before submitting.
- GitHub repository URL: publish this cleaned repository and make it public before submitting.
- Role: choose `Primary maintainer` if you own and maintain the repository.
- Organization ID: use the `org-...` value from the OpenAI API Platform organization settings.
- Interest: select API credits, ChatGPT Pro with Codex, and Codex Security.

## Why Does This Repository Qualify? 500 Characters Max

Maintainer Harness is an early OSS control plane for safer AI-assisted maintenance. It targets PR review, maintainer automation, release evidence, and agent security boundaries across multi-repo projects. It has public CI, security posture gates, Codex Security context, and feedback-first discovery materials while staying honest about early adoption.

## Why Does This Project Need Codex Security? 500 Characters Max

Maintainer Harness models agent-assisted OSS maintenance where Codex may read MCP context, propose PR changes, and produce worker output. Codex Security would help stress-test write scopes, path traversal, prompt-injection risks in issue/PR text, secret redaction, dependency evidence, and release gates. The repo already includes a threat model, redaction guide, CI security posture checks, and a remediated path-scope finding.

## How Will You Use API Credits? 500 Characters Max

I will use API credits and ChatGPT Pro with Codex to dogfood public maintainer workflows: generate issue-to-task packets, review worker outputs, stress-test scope boundaries, summarize validation for PRs/releases, and build synthetic examples. Credits support open maintainer automation and security review, not private product development.

## Anything Else? 500 Characters Max

Please also consider Codex Security. This repo coordinates agent write scopes, MCP context, generated worktrees, validation evidence, and release gates. It includes a threat model, paste-ready overview, review scope, first review pass with one remediated path-scope finding, redaction guide, and CI security posture checks.

## Longer Project Narrative

Maintainer Harness is an early open source project that helps maintainers use Codex safely on multi-repository maintenance work. Instead of asking an agent to make broad changes directly, the harness creates auditable change packets: intake, impact analysis, task cards, write scopes, worker dispatch packets, local validation reports, release notes, and postmortems.

The goal is to make agent-assisted OSS maintenance more reproducible and reviewable. Codex can help maintainers read project context, draft bounded implementation tasks, run local validation commands, and summarize evidence for pull requests and releases. The repository is intentionally generic and includes sample repository metadata, schemas, templates, PowerShell scripts, read-only MCP blueprints, and reusable maintainer skills.

This is a new public project, so it does not yet have large adoption metrics. The reason I am applying is to use Codex to improve the harness itself and demonstrate a practical workflow for other open source maintainers who want AI assistance without losing control of scope, security, or release evidence.

## Current Public Evidence

- Project site: https://zlbdh.github.io/maintainer-harness/
- Latest release: https://github.com/zlbdh/maintainer-harness/releases/tag/v0.1.10
- Latest main commit: https://github.com/zlbdh/maintainer-harness/commit/5f1c357636ce58bf354a0e39f0474644c2747cfe
- Latest successful CI: https://github.com/zlbdh/maintainer-harness/actions/runs/26821647602
- Latest successful Pages deployment: https://github.com/zlbdh/maintainer-harness/actions/runs/26821645827
- Current metrics: 0 stars, 0 forks, 0 watchers, and 3 open issues as of 2026-06-02.
- Public growth posture: feedback-first discovery materials are published; the project does not ask for artificial stars.
