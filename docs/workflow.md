# Workflow

This workflow keeps maintainer work reproducible from request to release.

## 1. Intake

Create a change directory:

```powershell
.\scripts\bootstrap\init-change.ps1 -ChangeId CHG-2026-0001-sample-change -Title "Sample change"
```

Fill `brief.md` with:

- user-visible goal
- non-goals
- acceptance criteria
- known risks

## 2. Impact Design

Fill `impact.yaml` with:

- affected repositories
- affected modules, interfaces, tables, configs, or docs
- dependency order
- notes and constraints

Do not start repository work until this file is clear enough for task cards.

## 3. Execution Planning

Fill or review `execution.yaml`:

- repo owners
- write scopes
- branch names
- worktree paths
- lock state
- worker result paths

One worker should own one write scope at a time.

## 4. Dispatch

Generate worker packets:

```powershell
.\scripts\orchestrator\dispatch-change.ps1 -ChangeId CHG-2026-0001-sample-change -DryRun
```

Packets combine the brief, impact, execution plan, task card, local baseline summary, and repo rules.

## 5. Verification

Run the smallest command that proves the claim:

```powershell
.\scripts\checks\validate-change.ps1 -ChangeId CHG-2026-0001-sample-change
.\scripts\checks\run-local-baseline.ps1 -SkipCommandExecution
```

For real repository work, remove `-SkipCommandExecution` when local dependencies are available.

## 6. Release And Learning

Record:

- `verification/result.md`
- `release-note.md`
- `postmortem.md`

Turn repeated lessons into:

- a new skill under `.agent/skills/`
- a new rule under `standards/`
- a regression check under `evals/`
