# Worker Harness V1

Worker Harness V1 prepares bounded packets for repository workers.

## Packet Inputs

- `brief.md`
- `impact.yaml`
- `execution.yaml`
- `tasks/<repo>.md`
- repository rule files
- latest local baseline summary
- latest review result, when available

## Packet Guarantees

Each packet states:

- repo id
- role id
- worktree
- branch
- snapshot policy
- allowed write scope
- required result path
- suggested verification commands

## Execution Rules

- Workers operate only in the configured worktree.
- Workers may edit only allowed paths.
- Workers must run verification commands when possible.
- Workers must return structured output.
- Review workers remain read-only.

## V1 Limitations

- No automatic remote push.
- No automatic PR creation.
- No production MCP access.
- No guarantee that sample repositories exist until `repos.yaml` is replaced.
