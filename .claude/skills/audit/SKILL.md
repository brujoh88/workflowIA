---
name: audit
description: System-wide code audit with 8 modules
argument-hint: [module-letter|all]
allowed-tools: Bash(tsc:*), Bash(*test*), Bash(*lint*), Read, Write, Edit, Glob, Grep
---

# System Audit: $ARGUMENTS

Run a comprehensive system audit. Can run all modules or a specific one.

**Usage**:
- `/audit` or `/audit all` — Run all modules
- `/audit A` — Run only Types module
- `/audit B C` — Run specific modules

## Step 0: Load Configuration

Read `.claude/project.config.json`:
- `{maxFileLines}` = `config.workflow.maxFileLines` (default: 400)
- `{maxFunctionLines}` = `config.workflow.maxFunctionLines` (default: 50)
- `{testCmd}` = `config.commands.test`
- `{stack}` = `config.project.stack`
- `{coverageThreshold}` = `config.workflow.coverageThreshold` (default: 80)

Detect project characteristics:
- TypeScript? → check for `tsconfig.json`
- ORM? → check for Prisma, TypeORM, Sequelize, etc.
- Frontend framework? → check `package.json` dependencies
- Test framework? → check for jest/vitest/pytest config
- API docs? → check for Swagger/OpenAPI files

## Modules

### Module A: Types (Conditional: TypeScript projects)

**Goal**: Zero type errors.

```bash
npx tsc --noEmit 2>&1 | head -50
```

- Count errors by category
- Report top 5 most problematic files
- If clean: report "No type errors found"

### Module B: Authorization & Security

**Goal**: No unprotected endpoints or queries.

1. Find all API route/endpoint files:
   ```
   Glob: src/api/**/*.ts, src/routes/**/*.ts, src/**/controller*.ts
   ```

2. For each endpoint, verify:
   - [ ] Has authentication middleware/guard/decorator
   - [ ] Has authorization check (role/permission-based)
   - [ ] Query parameters are validated/sanitized

3. Find raw SQL or ORM queries without filters:
   ```
   Grep: "\.query\(|\.raw\(|\.execute\(" in src/
   Grep: "findMany|findAll" without "where" clause
   ```

4. Report unprotected endpoints and unfiltered queries.

### Module C: Input Validation

**Goal**: All inputs validated at system boundaries.

1. Find controller/route handler functions:
   ```
   Grep: "@Body|@Query|@Param|req\.body|req\.query|req\.params" in src/
   ```

2. For each input point, verify:
   - [ ] Has validation decorator/middleware (class-validator, Zod, Joi, etc.)
   - [ ] Error messages are user-friendly (not stack traces)

3. Report unvalidated inputs with file:line references.

### Module D: File Size Limits

**Goal**: Enforce `maxFileLines` and `maxFunctionLines`.

1. Scan all source files:
   ```
   Glob: src/**/*.{ts,tsx,js,jsx,py,go,rs}
   ```

2. For each file:
   - Count total lines → flag if > `{maxFileLines}`
   - Count function/method lines → flag if > `{maxFunctionLines}`

3. Report oversized files and functions with line counts and suggested split points.

### Module E: Test Coverage

**Goal**: Business logic files have corresponding test files.

1. Find business logic files:
   ```
   Glob: src/services/**/*.*, src/domain/**/*.*, src/use-cases/**/*.*
   ```

2. For each business file, check for corresponding test:
   ```
   Glob: tests/**/*{filename}*, src/**/*{filename}.test.*, src/**/*{filename}.spec.*
   ```

3. Report:
   - Files WITH tests (count)
   - Files WITHOUT tests (list with file paths)
   - Coverage ratio: `{with tests}/{total}` = `{%}`
   - Flag if below `{coverageThreshold}`%

### Module F: API Documentation

**Goal**: All endpoints are documented.

1. Find all endpoint definitions:
   ```
   Grep: "@Get|@Post|@Put|@Delete|@Patch|router\.(get|post|put|delete|patch)" in src/
   ```

2. For each endpoint, check for documentation:
   - Swagger/OpenAPI decorators (`@ApiOperation`, `@ApiResponse`)
   - JSDoc comments above the handler
   - Entry in docs/ files

3. Report undocumented endpoints.

### Module G: Architecture

**Goal**: Files follow the established project structure.

1. Detect the architecture pattern:
   - Layered: controllers → services → repositories
   - Feature-based: features/{name}/ grouping
   - DDD: domain/application/infrastructure separation

2. Find files that don't fit the pattern:
   - Business logic in controllers/routes
   - Database access outside repositories/services
   - Utility files in wrong locations

3. Report architectural violations with suggested correct locations.

### Module H: Quality Patterns

**Goal**: No anti-patterns in production code.

Search for common anti-patterns:
```
Grep: "any" (as type annotation, not in strings/comments)
Grep: "@ts-ignore|@ts-nocheck" in src/ (not in tests)
Grep: "console\.log|console\.debug|console\.info" in src/ (not in logger files)
Grep: "TODO|FIXME|HACK|XXX" in src/
Grep: "eslint-disable" in src/
```

Report each finding with file:line and context.

## Output

### Report Format

Generate report in `context/auditorias/YYYY-MM-DD-{module|full}.md`:

```markdown
# Audit Report: {date}

**Scope**: {modules run}
**Project**: {project name}
**Stack**: {stack}

## Summary

| Module | Issues | Status |
|--------|--------|--------|
| A. Types | {N} errors | PASS / FAIL / SKIP |
| B. Security | {N} issues | PASS / FAIL / SKIP |
| C. Validation | {N} missing | PASS / FAIL / SKIP |
| D. File Size | {N} oversized | PASS / FAIL / SKIP |
| E. Coverage | {N}% coverage | PASS / FAIL / SKIP |
| F. API Docs | {N} undocumented | PASS / FAIL / SKIP |
| G. Architecture | {N} violations | PASS / FAIL / SKIP |
| H. Quality | {N} anti-patterns | PASS / FAIL / SKIP |

## Details

### Module X: {Name}
{Detailed findings per module}

## Recommended Actions

Priority actions to address findings:
1. **[CRITICAL]** {action}
2. **[IMPORTANT]** {action}
3. **[SUGGESTION]** {action}
```

### BACKLOG Integration

After generating the report, ask user:
> "Found {N} issues. Want to add any as BACKLOG items?"

If yes:
- Add selected issues to BACKLOG "Next (Prioritized)" section
- Format as standard BACKLOG items with audit reference

## Rules

- **Read-only analysis** — Never modify source code during audit
- **Concrete evidence** — Every finding must include file:line reference
- **Skip gracefully** — If a module doesn't apply (e.g., no TypeScript), mark as SKIP
- **Configurable thresholds** — Use values from project.config.json
- **No false positives** — Verify each finding is genuine before reporting
