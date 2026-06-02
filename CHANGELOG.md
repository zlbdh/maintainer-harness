# Changelog

All notable changes to Maintainer Harness will be documented in this file.

This project follows a simple date-based changelog until formal versioned releases begin.

## 2026-06-01

### Added

- Public-ready repository identity as Maintainer Harness.
- Generic sample repository metadata in `repos/repos.yaml`.
- Maintainer role registry in `config/agent-registry.yaml`.
- Change packet templates, worker result schemas, and validation scripts.
- Read-only MCP blueprints for safe context retrieval.
- GitHub issue templates, pull request template, and validation workflow.
- Contribution, security, support, and code of conduct documents.
- Synthetic sample change packet under `examples/sample-change/`.
- Codex for OSS application notes under `docs/codex-for-oss-application.md`.

### Changed

- Reworked local scripts to resolve repository paths relative to the harness root.
- Replaced project-specific repository roles with generic backend, web, and mobile examples.
- Added quiet/pass-through modes for scripts that should support machine-readable output.

### Security

- Generated reports, worktrees, local product checkouts, and private legacy artifacts are ignored by default.
- Public hygiene checks should be run before every publication or release.

