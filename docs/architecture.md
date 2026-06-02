# Architecture

Maintainer Harness is a control repository. Product repositories remain separate and are referenced through `repos/repos.yaml`.

```text
maintainer-harness
├── repos/repos.yaml              # repository metadata
├── config/agent-registry.yaml    # role and write-scope registry
├── templates/                    # reusable change artifacts
├── changes/<change-id>/          # one auditable maintenance change
├── scripts/                      # local orchestration and checks
├── reports/                      # generated validation summaries
└── .agent/skills/                # local maintainer recipes
```

## Runtime Layers

- **Governance layer**: intake, impact design, release, knowledge feedback.
- **Repository execution layer**: one task card and one worker packet per repo.
- **Verification layer**: local baseline checks, worker result review, acceptance.
- **Knowledge layer**: postmortem output converted into standards, skills, or regression checks.

## Repository Metadata

Each repository entry defines:

- stable `id`
- public or internal `remote`
- local checkout path under `repos/`
- validation profile
- build/test/smoke commands
- current readiness status

The sample `repos.yaml` is intentionally generic. Maintainers should replace it with their own repositories before running real workflows.
