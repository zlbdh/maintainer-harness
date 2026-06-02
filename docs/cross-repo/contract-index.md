# Contract Index

Use this file to index cross-repository contracts.

Recommended fields:

- contract name
- owner repository
- consumer repositories
- source file or schema
- validation command
- last verified date

Example:

```text
Contract: public REST API
Owner: api
Consumers: web, mobile
Validation: npm run test && mvn test
```

Do not include private endpoint URLs, credentials, or customer-specific payloads.
