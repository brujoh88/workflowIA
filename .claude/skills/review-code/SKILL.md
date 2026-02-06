---
name: review-code
description: Revisar código para calidad y bugs
context: fork
agent: Explore
allowed-tools: Read, Grep, Glob
---

# Code Review

## Step 0: Load Context

Read `.claude/project.config.json` for project conventions and limits.

Check for active session in `context/tmp/session-*.md`:
- If exists: read session objective for context on what the changes are about
- If not: review without session context

## Step 1: Identify Changes

!`git diff --stat HEAD~5`

Group changes by category:

| Category | Files | Count |
|----------|-------|-------|
| Backend (API/services) | `src/api/`, `src/services/` | {N} |
| Frontend (UI/components) | `src/components/`, `src/pages/` | {N} |
| Tests | `tests/`, `*.test.*`, `*.spec.*` | {N} |
| Database (models/migrations) | `src/database/`, `migrations/` | {N} |
| Configuration | `*.config.*`, `.env*`, `package.json` | {N} |
| Documentation | `docs/`, `*.md`, `context/` | {N} |

## Step 2: Multi-Category Audit

For each changed file, apply the relevant checklists:

### 2.1 Correctness (Priority: CRITICAL)
- [ ] Logic is correct for all code paths
- [ ] Edge cases handled (null, empty, boundary values)
- [ ] Error handling is appropriate and consistent
- [ ] Types are correct (if TypeScript/typed language)
- [ ] No race conditions or async issues
- [ ] Return values are used correctly

### 2.2 Security (Priority: CRITICAL)
- [ ] All user inputs validated and sanitized
- [ ] No injection vulnerabilities (SQL, XSS, command injection)
- [ ] Authentication/authorization checks in place
- [ ] No sensitive data exposed (secrets, tokens, passwords)
- [ ] No hardcoded credentials
- [ ] CORS/CSP properly configured (if applicable)

### 2.3 Performance (Priority: IMPORTANT)
- [ ] No N+1 query patterns
- [ ] No unnecessary loops or re-computations
- [ ] Appropriate use of caching
- [ ] No memory leaks (event listeners, subscriptions cleaned up)
- [ ] Algorithmic complexity is reasonable for data size
- [ ] Database indexes used appropriately (if new queries)

### 2.4 Tests (Priority: IMPORTANT)
- [ ] Critical paths have test coverage
- [ ] Tests are meaningful (test behavior, not implementation)
- [ ] Edge cases have tests
- [ ] Test names are descriptive (`should {action} when {condition}`)
- [ ] Mocks are appropriate (not over-mocking)
- [ ] No test-only code in production files

### 2.5 Documentation (Priority: SUGGESTION)
- [ ] Public APIs are documented
- [ ] Complex logic has explanatory comments
- [ ] README updated if behavior changed
- [ ] API docs updated if endpoints changed
- [ ] Breaking changes documented

### 2.6 Maintainability (Priority: SUGGESTION)
- [ ] Code follows project naming conventions
- [ ] No unnecessary code duplication
- [ ] Functions are single-responsibility
- [ ] File length within limits (~400 lines)
- [ ] Function length within limits (~50 lines)
- [ ] Imports are clean (no unused imports)

## Step 3: Produce Report

### Report Format

```markdown
## Code Review Report

**Scope**: {N} files across {categories}
**Branch**: {current branch}
**Session**: {session ID if active}

### Summary
| Category | Critical | Important | Suggestion |
|----------|----------|-----------|------------|
| Correctness | {N} | {N} | {N} |
| Security | {N} | {N} | {N} |
| Performance | {N} | {N} | {N} |
| Tests | {N} | {N} | {N} |
| Documentation | {N} | {N} | {N} |
| Maintainability | {N} | {N} | {N} |
| **Total** | **{N}** | **{N}** | **{N}** |

### Issues

| # | Category | Priority | File:Line | Description |
|---|----------|----------|-----------|-------------|
| 1 | {cat} | CRITICAL | `file:line` | {description} |
| 2 | {cat} | IMPORTANT | `file:line` | {description} |

### Issue Details

#### Issue #1: [{PRIORITY}] {Title}
**File**: `{path}:{line}`
**Category**: {category}
**Problem**: {clear description}
**Solution**: {actionable suggestion}

---

### Verdict: **READY** | **PENDING** | **CONDITIONAL**

- **READY**: No critical issues found. Safe to merge.
- **PENDING**: {N} critical issues must be resolved before merge.
- **CONDITIONAL**: No critical issues, but {N} important issues should be tracked. Can merge with follow-up plan.
```

## Verdict Criteria

| Verdict | Condition |
|---------|-----------|
| **READY** | 0 CRITICAL issues AND 0-2 IMPORTANT issues |
| **CONDITIONAL** | 0 CRITICAL issues AND >2 IMPORTANT issues |
| **PENDING** | Any CRITICAL issue present |
