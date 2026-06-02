# Memory Governance

The harness does not create a universal memory database.

Durable knowledge should live where it can be reviewed:

- requirements and decisions in `changes/<change-id>/`
- reusable rules in `standards/`
- repeatable procedures in `.agent/skills/`
- validation evidence in `reports/` and `verification/`
- release evidence in `release/`

## Layers

- Repository files: long-term memory.
- Current thread: short-term working context.
- MCP: external read-only context unless explicitly approved.
- Skills: reusable execution recipes.
- Workflows: ordered procedures.
- Rules: boundaries and conflict resolution.

## Write-Back Rule

If the same lesson appears twice, convert it into one of:

- a rule
- a template update
- a skill update
- a regression test
- a checklist item
