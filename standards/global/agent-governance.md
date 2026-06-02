# Agent Governance

## Core Rules

- One worker owns one write scope at a time.
- A worker must not edit files outside its allowed paths.
- A worker must not share a writable worktree with another worker.
- A worker must record verification commands and outcomes.
- Review workers are read-only unless explicitly promoted by a maintainer.

## Role Types

- governance agent: writes control-repo artifacts
- repo executor: writes one configured product repository
- verification agent: reads worker output and records evidence
- release agent: prepares release notes and rollback notes
- knowledge agent: turns postmortems into rules, skills, or evals

## Escalation

Escalate to a human maintainer when:

- write scope is unclear
- a task requires production access
- secrets or customer data are involved
- validation cannot run locally
- two workers need the same file
