---
name: review-code
description: Review code for quality and bugs
context: fork
agent: Explore
allowed-tools: Read, Grep, Glob
---

# Code Review

## Step 0: Load Context

Read `.claude/project.config.json` for project conventions, limits, and quality settings.

**Variables to load**:
- `{maxFileLines}` = `config.workflow.maxFileLines` (default: 400)
- `{maxFunctionLines}` = `config.workflow.maxFunctionLines` (default: 50)
- `{externalSkills}` = `config.quality.externalSkills` (default: `[]`)

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

## Step 1.5: Proactive Quality Skill Invocation

If `externalSkills` are configured AND changes include relevant file types:

For each skill in `externalSkills`:
1. Check if `.claude/skills/{skill-name}/SKILL.md` exists (via symlink or direct)
2. If exists: note as "available, should invoke"
3. If not exists: note as "configured but not installed"

For each available skill that matches the change type (e.g., frontend skill for component changes):
- If the skill was already run during the session (check session Progress), note it as completed
- If not run: recommend running it before or after this review

Include the list of invoked/pending/missing quality skills in the final report.

See `.claude/docs/QUALITY-SKILLS-CONTRACT.md` for the expected output format of quality skills.

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
- [ ] File length within limits (~{maxFileLines} lines)
- [ ] Function length within limits (~{maxFunctionLines} lines)
- [ ] Imports are clean (no unused imports)

### 2.7 Frontend Audit (Conditional: if frontend files changed)
- [ ] Data fetching patterns are consistent (hooks, server components, etc.)
- [ ] Accessibility: semantic HTML, ARIA labels, keyboard navigation
- [ ] Dark mode: uses CSS variables or framework dark classes (not hardcoded colors)
- [ ] Separation of concerns: logic in hooks/services, not in components
- [ ] Loading/error states handled for async operations
- [ ] Responsive design considered

### 2.8 E2E Test Audit (Conditional: if E2E test files exist)
- [ ] Page Object Model pattern used (or equivalent abstraction)
- [ ] Selectors are stable (data-testid, roles, not CSS classes)
- [ ] Tests are independent (no order dependency)
- [ ] Proper waits used (not arbitrary sleeps)
- [ ] Test data cleanup handled

## Step 3: Produce Report

### Report Format

```markdown
## Code Review Report

**Scope**: {N} files across {categories}
**Branch**: {current branch}
**Session**: {session ID if active}

### Quality Skills Status
| Skill | Status | Notes |
|-------|--------|-------|
| {skill name} | Invoked / Pending / N/A | {details} |

### Summary
| Category | Critical | Important | Suggestion |
|----------|----------|-----------|------------|
| Correctness | {N} | {N} | {N} |
| Security | {N} | {N} | {N} |
| Performance | {N} | {N} | {N} |
| Tests | {N} | {N} | {N} |
| Documentation | {N} | {N} | {N} |
| Maintainability | {N} | {N} | {N} |
| Frontend | {N} | {N} | {N} |
| E2E Tests | {N} | {N} | {N} |
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

**Quality skills invoked**: {list of skills consulted during this review cycle}
```

## Verdict Criteria

| Verdict | Condition |
|---------|-----------|
| **READY** | 0 CRITICAL issues AND 0-2 IMPORTANT issues |
| **CONDITIONAL** | 0 CRITICAL issues AND >2 IMPORTANT issues |
| **PENDING** | Any CRITICAL issue present |

## Error Recovery

| Problem | Recovery |
|---------|----------|
| No recent commits to diff | Use `git diff --stat HEAD` or ask user for scope |
| Quality skill not installed | Note as "configured but not installed" and continue review |
| Session not found | Review without session context — note this in report |
| Too many files to review | Group by category, focus on CRITICAL checks first |
