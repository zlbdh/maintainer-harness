# Security Policy

Maintainer Harness is designed to sit beside product repositories, so security boundaries matter.

## Supported Versions

The default branch is the only supported line until the project publishes tagged releases.

## Reporting a Vulnerability

Please report vulnerabilities privately through GitHub Security Advisories when available. If advisories are not enabled, contact the maintainers using the repository owner's preferred private channel.

Please include:

- affected file or command
- reproduction steps
- expected and observed behavior
- possible impact
- any logs with secrets removed

## Security Boundaries

The harness should not commit or require:

- API keys, access tokens, passwords, cookies, or private certificates
- customer data, production logs, or private endpoints
- product source checkouts under `repos/`
- generated worktrees under `worktrees/`
- validation reports containing sensitive local paths

MCP blueprints in this repository are intentionally read-only. Any write-capable integration should be reviewed as a separate design change.

