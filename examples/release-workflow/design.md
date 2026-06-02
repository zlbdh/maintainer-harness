# Design

## Approach

Use a release-focused change packet to show the last mile of maintainer work:

1. Validate the change packet and related sample packets.
2. Record passed, skipped, and environment-limited checks separately.
3. Draft a release note from evidence rather than chat summary.
4. Preserve rollback and observation points.
5. Keep postmortem-ready notes available even when no incident occurred.

## Template Links

- `templates/release-note.md` defines the release note shape.
- `templates/verification-result.md` defines command and acceptance evidence.
- `templates/postmortem.md` defines the follow-up structure.
- `standards/global/release-gates.md` defines minimum release gates.

## Boundary

The packet does not create a tag, publish a GitHub release, run product repository tests, or claim external adoption. It demonstrates the release evidence shape with synthetic commands and explicit skipped checks.
