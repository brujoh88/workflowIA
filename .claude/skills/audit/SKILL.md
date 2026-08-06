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
- `{maxFunctionLines}` = `config.workflow.maxFunctionLines` (default: 50)
- `{testCmd}` = `config.commands.test`
- `{coverageCmd}` = `config.commands.coverage` (empty if not configured)
- `{stack}` = `config.project.stack`
- `{coverageThreshold}` = `config.workflow.coverageThreshold` (default: 80)
- `{testMaxWorkers}` = `config.workflow.testMaxWorkers` (default: 2)
- `{dockerEnabled}` = `config.docker.enabled` · `{dbContainer}` = `config.docker.dbContainer`

**File size limits** — `config.workflow.maxFileLines` is an **object keyed by file type**, not a
number: `default` (400), `services` (500), `components` (300), `hooks` (150). Read each key and
apply the one matching the file. If it is a plain number (older config), use it for every type.

## Step 0.5: Read the Previous Audit

Find the most recent report in `context/auditorias/`:
```
Glob: context/auditorias/*.md
```

If one exists for the same scope, read it and keep its findings in hand. **Every finding in this
run gets classified against it** — otherwise the fifth audit repeats the first one's forty
findings and nobody can tell what moved:

| Class | Meaning |
|-------|---------|
| **NEW** | Not in the previous report |
| **PERSISTS** | Also in the previous report — carry the date it was **first** seen |
| **RESOLVED** | In the previous report, gone now |

Match findings by `file:line` plus the nature of the issue, not by exact text — a line number
shifts when code above it changes. When unsure, classify as PERSISTS and say the match was fuzzy.

If there is no previous report, say so: everything is NEW by definition, and that is the baseline.

Detect project characteristics:
- TypeScript? → check for `tsconfig.json`
- ORM? → check for Prisma, TypeORM, Sequelize, etc.
- Frontend framework? → check `package.json` dependencies
- Test framework? → check for jest/vitest/pytest config
- API docs? → check for Swagger/OpenAPI files

## Modules

### Module A: Types (Conditional: TypeScript projects)

**Goal**: Zero type errors.

Count over the **full** output, then show a sample. Truncating first and counting after reports
a fraction of the real number:

```bash
npx tsc --noEmit 2>&1 > /tmp/audit-tsc.txt
wc -l < /tmp/audit-tsc.txt                                    # total lines
grep -cE "error TS[0-9]+" /tmp/audit-tsc.txt                  # real error count
grep -oE "error TS[0-9]+" /tmp/audit-tsc.txt | sort | uniq -c | sort -rn | head -10
grep -oE "^[^(]+" /tmp/audit-tsc.txt | sort | uniq -c | sort -rn | head -5   # worst files
```

- Report the **total** error count, the top error codes, and the 5 worst files — all derived from
  the complete output
- Show the first 15 errors verbatim as a sample, labelled as a sample
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
   - Pick its limit by type: `*.service.*` → services · `*.tsx` / `*.component.*` → components ·
     `hooks/` or `use[A-Z]*` → hooks · everything else → default
   - Count total lines → flag if over **that** limit (say which limit applied)
   - Count function/method lines → flag if > `{maxFunctionLines}`

3. Report oversized files and functions with line counts and suggested split points.

### Module E: Test Coverage

**Goal**: Know how much of the business logic is actually exercised.

Two different measurements. **Never call the second one "coverage"** — a test file that exists
and asserts nothing counts as present but covers zero, and reporting that as a percentage against
`{coverageThreshold}` is a number that lies (R5 requires real coverage).

**E.1 — Real coverage (when `{coverageCmd}` is configured)**

```bash
{coverageCmd}    # add --maxWorkers={testMaxWorkers} per R19 if the runner supports it
```

Report the tool's own numbers: statements / branches / functions / lines. Compare against
`{coverageThreshold}`. List the least-covered business files with their real percentages.

If the command fails, say why (missing dependency, needs Docker per `{dockerEnabled}`, tests
failing) and fall through to E.2 — clearly labelled as a fallback, not as coverage.

**E.2 — Test file presence (always, and it is NOT coverage)**

1. Find business logic files:
   ```
   Glob: src/services/**/*.*, src/domain/**/*.*, src/use-cases/**/*.*
   ```

2. For each, look for a matching test file:
   ```
   Glob: tests/**/*{filename}*, src/**/*{filename}.test.*, src/**/*{filename}.spec.*
   ```

3. Report as **"business files with a test file: {N}/{M}"** — never as a coverage percentage.
   List the files with none. Flag any matched test file under 10 lines: it exists but almost
   certainly asserts nothing.

**If `{coverageCmd}` is not configured**, report E.2 only and state plainly: *"Real coverage was
not measured — no coverage command configured. Set `commands.coverage` to measure it."*
Status is **SKIP**, not PASS. An unmeasured threshold is not a met threshold.

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

4. **Duplicated business rules (R25)** — the same question answered in two places:
   - Build a list of the domain's decision points: state enums, boolean flags exposed by the API
     (`canX`, `isBlocked`, `isComplete`), and threshold comparisons.
   - For each, grep for every site that evaluates it. A rule duplicated by copy-paste rarely
     shares a function name — search for the **condition**, not the identifier:
     ```
     Grep: the state constant(s) involved (e.g. "PENDING|APPROVED")
     Grep: the field comparison (e.g. "\.status\s*===|\.status\s*!==")
     Grep: the threshold or numeric literal
     ```
   - Flag as a violation when the same condition is evaluated in 2+ files and at least one of
     them is not importing from the other.
   - Report as: `{condition} answered in {file:line} and {file:line} — extract to a pure function`.
   - Also flag: frontend files that reconstruct a backend fact (a copied list of states used to
     decide whether something is finished or blocked).

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
**Compared against**: `context/auditorias/{previous file}.md` ({date}) — or "first audit, baseline"

## Movement since the last audit

| | Count |
|---|---|
| **Resolved** since {previous date} | {N} |
| **New** | {N} |
| **Still open** | {N} — oldest first seen {date} |

{One line naming what got fixed. If nothing moved, say that plainly — it is the finding.}

## Summary

| Module | Result | New | Persists | Status |
|--------|--------|-----|----------|--------|
| A. Types | {N} type errors (full count) | {N} | {N} | PASS / FAIL / SKIP |
| B. Security | {N} issues | {N} | {N} | PASS / FAIL / SKIP |
| C. Validation | {N} missing | {N} | {N} | PASS / FAIL / SKIP |
| D. File Size | {N} over their type limit | {N} | {N} | PASS / FAIL / SKIP |
| E. Coverage | {real %} — or "not measured" | {N} | {N} | PASS / FAIL / SKIP |
| E. Test presence | {N}/{M} business files have a test file | {N} | {N} | — |
| F. API Docs | {N} undocumented | {N} | {N} | PASS / FAIL / SKIP |
| G. Architecture | {N} violations | {N} | {N} | PASS / FAIL / SKIP |
| H. Quality | {N} anti-patterns | {N} | {N} | PASS / FAIL / SKIP |

## Details

### Module X: {Name}
{Findings, each tagged NEW / PERSISTS since {date} / RESOLVED, with file:line}

## Recommended Actions

1. **[CRITICAL]** {action}
2. **[IMPORTANT]** {action}
3. **[SUGGESTION]** {action}

## Where the findings went

| Finding | Destination |
|---------|-------------|
| {short title} | `FIXES.md` / `BACKLOG.md` / `ROUTE.md` QUEUE / declined by user |
```

### Route the Findings — the report is not a destination

An audit that only writes a file produces a pile of paper. **Every finding the user accepts gets
routed**, and the destination depends on what it is — the bug registry and the inventory are not
interchangeable:

| Finding | Destination | Why |
|---|---|---|
| Unprotected endpoint, injection risk, exposed secret | `context/FIXES.md` → Pending, **severity high** | A live defect, not pending work |
| Any defect in shipped behaviour | `context/FIXES.md` → Pending | That is the bug registry |
| Missing tests, missing docs, oversized file, anti-pattern | `context/BACKLOG.md` → Next or Ideas | Tech debt, that is the inventory |
| Duplicated business rule (R25, module G) | `context/BACKLOG.md` as *"extract {rule} + make all consumers import it"* | It is one job, not one per copy |
| Something that must be done before current work | `context/ROUTE.md` → QUEUE, at the agreed position | That is the queue |
| A finding the user declines | Nowhere — but **record the decision in the report** | So the next audit does not re-litigate it |

Present the proposed destination per finding and ask once. Each written item carries its
`file:line` and a reference back to this report (`from audit {date}`).

**PERSISTS findings already routed in a previous audit do not get written again** — check FIXES
and BACKLOG before adding. Report them as *"already tracked in {file} since {date}"*. Duplicating
them is how a backlog becomes unreadable.

## Rules

- **Read-only analysis** — Never modify source code during audit. Writing the report and routing
  findings to FIXES/BACKLOG/ROUTE is the only writing allowed.
- **Concrete evidence** — Every finding must include a file:line reference
- **Skip gracefully** — If a module doesn't apply (e.g., no TypeScript), mark as SKIP
- **SKIP is not PASS** — An unmeasured threshold is not a met threshold. Say what was not
  measured and what would be needed to measure it.
- **Count before truncating** — Report totals from complete output; samples are labelled samples
- **Configurable thresholds** — Use values from project.config.json, per file type where the
  config is per type
- **No false positives** — Verify each finding is genuine before reporting
- **Every finding gets a destination** — the report alone is not one

## Error Recovery

| Problem | Recovery |
|---------|----------|
| TypeScript not installed | Skip Module A, mark as SKIP |
| No test framework detected | Skip Module E.1, run E.2, mark coverage as SKIP |
| `{coverageCmd}` not configured | Run E.2 only, state coverage was not measured, mark SKIP |
| Coverage command fails | Report the actual error, fall through to E.2 labelled as fallback |
| Project runs in Docker (`{dockerEnabled}`) | Run test/coverage commands inside `{dbContainer}` or the app container (R18) |
| No API endpoints found | Skip Modules B, C, F, mark as SKIP |
| `context/auditorias/` missing | Create directory before writing report |
| Previous audit report unreadable or malformed | Treat this run as a new baseline and say so — do not silently drop the comparison |
| Audit report exceeds 400 lines | Split into separate module reports, one per module, sharing the same date prefix |
