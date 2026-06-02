# Harness Mapping

This file maps general harness engineering ideas to this repository.

## Idea To Artifact

| Idea | Artifact |
| --- | --- |
| Change intake | `brief.md` |
| Cross-repo impact | `impact.yaml` |
| Execution ownership | `execution.yaml` |
| Repo task scope | `tasks/<repo>.md` |
| Worker context | `runtime/packets/<repo>-worker.md` |
| Verification evidence | `verification/result.md` |
| Release evidence | `release-note.md` |
| Learning feedback | `postmortem.md`, `standards/`, `.agent/skills/` |

## Current Scope

This repository focuses on local, auditable maintainer workflows:

- no default production access
- no default write-capable MCP access
- no automatic push or PR creation
- no customer-specific examples in the public baseline

## Next Improvements

- Add sample fixtures for tests.
- Add schema checks for `repos.yaml`.
- Add deterministic tests for generated change directories.
- Add a public example change that uses only synthetic repositories.
