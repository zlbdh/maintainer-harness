# Rule Precedence

When instructions conflict, use this order:

1. User request in the current thread.
2. Repository `AGENTS.md`.
3. Change-specific files under `changes/<change-id>/`.
4. Repository-specific standards under `standards/`.
5. Skill instructions under `.agent/skills/`.
6. General documentation under `docs/`.

## Conflict Handling

If a lower-priority rule conflicts with a higher-priority rule:

- follow the higher-priority rule
- record the conflict in the result or postmortem
- update the lower-priority rule if the conflict is recurring

## Safety Defaults

- No production access without explicit approval.
- No sensitive-data transmission without explicit approval.
- No completion claim without fresh verification evidence.
