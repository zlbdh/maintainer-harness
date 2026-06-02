# Dogfooding Plan

Maintainer Harness is early, so the strongest support request is not popularity. It is a concrete plan to use Codex on public maintainer workflows and publish the resulting evidence without exposing private project data.

Public tracking issue: https://github.com/zlbdh/maintainer-harness/issues/7

## First 30 Days

| Window | Goal | Public Artifact |
| --- | --- | --- |
| Days 1-7 | Run the harness on synthetic docs-validation and issue-to-review examples. | Updated `examples/sample-change/` and `examples/issue-to-review/`, validation reports summarized in docs, and roadmap issues. |
| Days 8-14 | Expand pull-request review packet examples with explicit worker scope and reviewer acceptance evidence. | Additional example change packets and schema coverage notes. |
| Days 15-21 | Exercise Codex Security style review on agent scopes, MCP blueprints, ignored artifacts, and release gates. | Updated `docs/security/` notes, checklist outcomes, and tracked fixes. |
| Days 22-30 | Prepare the next public release from verified changes only. | `examples/release-workflow/`, changelog entry, release note draft, passing GitHub Actions run, and tagged release. |

## API Credit Usage

API credits should be spent on maintainer workflows that are public and reusable:

- generating issue-to-change packets from GitHub issues
- drafting scoped worker task cards
- reviewing worker outputs against schemas and allowed paths
- summarizing validation evidence for pull requests and releases
- improving synthetic examples and maintainer skills
- stress-testing security boundaries with Codex Security style prompts

Credits should not be used for private product development, unpublished customer work, or hidden proprietary repositories.

## Adoption Signals To Build Honestly

- Keep the repository public and CI-gated.
- Publish small tagged releases with clear changelog entries.
- Use GitHub issues for the roadmap instead of private notes, starting with the pinned 30-day evidence loop issue.
- Record skipped validation as skipped, not passed.
- Redact validation evidence before copying summaries out of ignored reports.
- Add examples before claiming workflow maturity.
- Avoid claiming broad external adoption until there are real users or contributors.

## Support Requested

The full support request is API credits, six months of ChatGPT Pro with Codex, and Codex Security access. API credits and ChatGPT Pro support the day-to-day dogfooding loop. Codex Security is requested because the project's main risk surface is exactly the boundary between agents, write scopes, MCP context, generated worktrees, validation evidence, and release decisions.
