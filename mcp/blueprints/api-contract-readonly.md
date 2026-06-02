# API Contract Read-Only MCP Blueprint

Purpose: expose API contracts as read-only context for maintainers and worker agents.

Allowed:

- list API schemas
- read endpoint metadata
- read sample requests and responses
- compare generated clients with source contracts

Not allowed by default:

- call production endpoints
- mutate schemas
- read secrets
- transmit customer data

Typical use:

- identify affected repositories
- prepare `impact.yaml`
- generate repo-level task cards
- verify that implementation and documentation stayed aligned
