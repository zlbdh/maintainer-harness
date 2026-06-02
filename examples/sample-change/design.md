# Design

## Approach

Use a documentation-only sample change packet to show the maintainer workflow without requiring private repositories or generated worktrees.

## Files

- `brief.md` captures the request.
- `impact.yaml` records the affected harness surface.
- `execution.yaml` records ownership, write scope, validation evidence paths, and lock state.
- `tasks/harness.md` gives the worker a bounded task.
- `acceptance.md` defines the review criteria.
- `verification/result.md` records expected validation evidence.

## Boundary

The sample does not clone repositories, open worktrees, or call production integrations. It exists to make the packet structure easy to inspect and validate from a clean checkout.
