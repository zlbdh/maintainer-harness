# Naming

## Change IDs

```text
CHG-YYYY-NNNN-short-slug
```

Example:

```text
CHG-2026-0001-api-contract-cleanup
```

## Task Cards

Task cards should use repository ids from `repos/repos.yaml`:

```text
tasks/api.md
tasks/web.md
tasks/mobile.md
```

## Branches

```text
codex/<change-id>-<repo-id>
```

## Worker Results

```text
verification/workers/<repo-id>.md
runtime/reviews/<repo-id>-review.md
```

Prefer short, stable repository ids. Avoid customer names, private project names, and environment-specific path fragments.
