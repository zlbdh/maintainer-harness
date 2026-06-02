# Design

## Approach

Represent the maintainer workflow as a file-based packet:

1. `issue-intake.md` captures the incoming GitHub issue in sanitized form.
2. `impact.yaml` maps the issue to affected surfaces.
3. `execution.yaml` assigns ownership, write scope, branch, lock state, and evidence paths.
4. `tasks/harness.md` gives the worker a bounded documentation task.
5. `verification/workers/harness.md` records worker output.
6. `verification/result.md` records reviewer acceptance evidence.

## Reviewer Packet Shape

The reviewer should be able to answer four questions without reading chat history:

- What issue started this work?
- Which files may the worker touch?
- Which validation commands were run or intentionally skipped?
- What evidence supports accepting, rejecting, or requesting changes?

## Boundary

This example does not call GitHub, clone repositories, create branches, or open pull requests. It demonstrates the review packet shape that a maintainer can adapt to a real issue later.
