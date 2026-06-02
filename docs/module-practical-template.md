# Module Practical Template

Use this template when a feature spans more than one repository.

## 1. Goal

Describe the user-visible outcome.

## 2. Affected Repositories

```yaml
affected_repos:
  - id: api
    modules: []
  - id: web
    modules: []
```

## 3. Dependency Order

```yaml
dependency_order:
  - api
  - web
```

## 4. Write Scopes

```yaml
write_scopes:
  business_repos:
    api:
      - src/**
    web:
      - src/**
```

## 5. Verification

```text
api: mvn test
web: npm run build
```

## 6. Acceptance

Record the exact evidence that proves the feature is complete:

- command output
- screenshots if UI is involved
- API contract checks
- release and rollback notes
