# Harness Engineering

Harness engineering is the practice of building a control plane around repository work so that agent-assisted maintenance is bounded, repeatable, and auditable.

In this project, the harness is responsible for the work around code changes:

- receive and clarify a change
- identify affected repositories and interfaces
- assign one owner per write scope
- prepare worker packets
- run local validation
- record release and postmortem evidence
- feed learnings back into skills and standards

It is not a replacement for product code, CI, or human maintainer judgment.

## Design Principles

- **Files before memory**: durable facts live in repository files, not only in chat.
- **Scope before execution**: no worker starts until write boundaries are explicit.
- **Evidence before claims**: verification output is required before completion.
- **Read-only context by default**: MCP and external context should start read-only.
- **Generic by default**: examples should use sample repositories unless they are clearly marked as case studies.

## Maintenance Loop

1. Intake a change and create a `change-id`.
2. Fill `brief.md`.
3. Fill `impact.yaml`.
4. Fill `execution.yaml`.
5. Generate repo-level task cards.
6. Dispatch worker packets.
7. Run verification.
8. Record release notes and postmortem.
9. Convert useful lessons into skills, standards, or tests.
