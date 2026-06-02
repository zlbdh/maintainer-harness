# Command Contract

Each configured repository should define the smallest commands that prove local health.

The harness stores these commands in `repos/repos.yaml`:

- `bootstrap_command`
- `build_command`
- `test_command`
- `smoke_command`
- `safe_check_commands`

## Recommended Profiles

### Backend

```yaml
validation_profile: backend-maven
bootstrap_command: "mvn -version"
build_command: "mvn package -DskipTests"
test_command: "mvn test"
safe_check_commands:
  - "mvn -q test"
```

### Web

```yaml
validation_profile: web-vite
bootstrap_command: "npm ci --ignore-scripts"
build_command: "npm run build"
test_command: "npm run test"
safe_check_commands:
  - "npm run build"
  - "npm run test"
```

### Mobile

```yaml
validation_profile: mobile-rn
bootstrap_command: "npm ci --ignore-scripts"
build_command: "npm run start"
test_command: "npm run test -- --watch=false"
safe_check_commands:
  - "npm run lint"
  - "npm run test -- --watch=false"
```

Commands should be local, deterministic, and safe to run repeatedly.
