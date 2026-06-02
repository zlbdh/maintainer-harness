# Agent, Workflow, Skill, MCP

This document describes the generic roles used by the harness.

## Agents

Agents are role definitions in `config/agent-registry.yaml`.

Default governance roles:

- `change-intake-agent`
- `impact-design-agent`
- `verification-agent`
- `release-agent`
- `knowledge-agent`

Default sample repository roles:

- `api-exec-agent`
- `web-exec-agent`
- `mobile-exec-agent`

Replace or extend these roles to match your repositories.

## Workflows

Workflows define order:

1. intake
2. impact design
3. task generation
4. worker dispatch
5. local verification
6. release packaging
7. knowledge feedback

## Skills

Skills are reusable local recipes under `.agent/skills/`.

Current skills cover:

- change intake
- cross-repo impact
- task card generation
- local baseline triage
- cross-repo acceptance recording
- release package generation
- postmortem to regression
- memory routing
- rule resolution

## MCP

MCP blueprints live under `mcp/`.

The default posture is read-only:

- read API contracts
- read config
- read database schema
- read observability output

Write-capable or production MCP access should require explicit maintainer approval.
