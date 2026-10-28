---
name: review-code
description: Review code for quality and bugs
context: fork
agent: Explore
allowed-tools: Read, Grep, Glob, Bash(git:*)
---

# Code Review

## Step 0: Load Context

Read `.claude/project.config.json` for project conventions, limits, and quality settings.

**Variables to load**:
- `{mainBranch}` = `config.git.mainBranch` (default: `main`)
- `{devBranch}` = `config.git.devBranch` (empty means branches come off `{mainBranch}`)
- `{maxFunctionLines}` = `config.workflow.maxFunctionLines` (default: 50)
- `{externalSkills}` = `config.quality.externalSkills` (default: `[]`)

**File size limits** — `config.workflow.maxFileLines` is an **object keyed by file type**, not a
number. Read each key: `default` (400), `services` (500), `components` (300), `hooks` (150).
If it is a plain number (older config), use it for every type.
Limits apply to **source code only** — documentation, config, data, schemas and generated files
are exempt, same as the `pre-commit` hook.

Check for active session in `context/tmp/session-*.md`:
- If exists: read the objective, the `Plan` field, and any `## Size signals accepted` section
- If not: review without session context

## Step 1: Identify Changes

Review **everything this branch changed**, not an arbitrary number of commits. Diff against the
point where the branch left its base:

```bash
BASE={devBranch:-mainBranch}
git merge-base --is-ancestor "$BASE" HEAD 2>/dev/null \
  && git diff --stat "$BASE"...HEAD \
  || git diff --stat HEAD
```

The three-dot form compares against the common ancestor, so commits landing on the base branch
meanwhile do not pollute the review.

**Fallbacks, in order** — say which one was used:
1. Already on the base branch, or it does not exist → `git diff --stat HEAD` (uncommitted work)
2. Nothing to compare → ask the user for the scope. Never guess a commit count.

Get the file list with `git diff --name-only "$BASE"...HEAD` and group by category:

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

See `docs/QUALITY-SKILLS-CONTRACT.md` in the wf plugin (`$CLAUDE_PROJECT_DIR/.claude/wf/docs/`; its
absolute path is in the rule index injected at session start) for the expected output format of
quality skills.

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
- [ ] File length within the limit **for its type** (services / components / hooks / default) —
      source code only, never documentation or config
- [ ] Function length within limits (~{maxFunctionLines} lines)
- [ ] Imports are clean (no unused imports)

### 2.6.4 Scope Accepted Without a Plan (Conditional)

If the session file has a `## Size signals accepted` section, `/start` flagged this work as big
and the user chose to proceed without a plan. Check what that cost:

- [ ] Did the change stay within the scope stated in the session objective, or did it sprawl?
- [ ] For each signal that fired, is the thing it warned about actually handled? (e.g. "new
      business rule" → is it a single pure function everyone imports, per 2.6.5?)
- [ ] Is anything half-built that should be its own BACKLOG item instead of shipping partial?

Report as an observation, not a violation — the user made an informed call. The point is to catch
sprawl while it is still one diff.

### 2.6.5 Single Source for Business Rules (Priority: CRITICAL) — WF-R25

For **every business condition** this diff introduces or changes ("can X be done?", "is X
finished?", "is X blocked?"), ask: **does something else already answer this?**

- [ ] Grep the codebase for the same condition expressed differently (the state names, the field
      comparison, the threshold — not the function name; a duplicated rule rarely shares a name)
- [ ] If a domain function already answers it: the new code **imports** it, not reimplements it
- [ ] If the condition now exists in 2+ places: flag as CRITICAL, propose extracting it to a pure
      function in the domain layer, and list **every** call site that must import it
- [ ] Frontend: no recalculating a fact the backend can expose (no copied lists of states)
- [ ] The extracted function has its own spec

This is the cheapest moment to catch it — the diff is right here. Once both copies ship, the
symptom shows up as a UI that promises something the API refuses.

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
- **CONDITIONAL**: No critical issues, but {N} important issues are now tracked (see below).

### Where each finding went

| # | Finding | Destination |
|---|---------|-------------|
| 1 | {short title} | Fixed now / `FIXES.md` / `BACKLOG.md` / `ROUTE.md` QUEUE |

**Quality skills invoked**: {list of skills consulted during this review cycle}
```

## Verdict Criteria

| Verdict | Condition |
|---------|-----------|
| **READY** | 0 CRITICAL issues AND 0-2 IMPORTANT issues |
| **CONDITIONAL** | 0 CRITICAL issues AND >2 IMPORTANT issues |
| **PENDING** | Any CRITICAL issue present |

## Step 4: Route the Findings — nothing is left in the report only

A finding that lives only in this report dies with the conversation. **Every issue gets a
destination before the review ends.** This is the step that makes CONDITIONAL mean something:
"can merge because the rest is tracked", not "can merge and forget".

Ask once, presenting the proposed destination per finding, then write:

| Finding is | Destination | Why |
|---|---|---|
| CRITICAL, and small | Fix now, in this session | It blocks the merge anyway |
| CRITICAL, and large | `context/FIXES.md` → Pending, severity high | Needs its own session; the merge waits |
| A defect in shipped behaviour | `context/FIXES.md` → Pending | That is the bug registry |
| Missing work / tech debt | `context/BACKLOG.md` → Next or Ideas | That is the inventory |
| Must be next, before other work | `context/ROUTE.md` → QUEUE, at the agreed position | That is the queue |
| SUGGESTION the user declines | Nowhere — say so explicitly in the report | Declining is a valid answer, but it must be visible |

Each written item carries the `file:line` and a reference back to this review
(`from review on {branch}, {date}`). If a session is active, list the destinations in its
Progress section so `/finish` picks them up.

**Write this before showing the verdict.** A verdict handed over while the findings are still
floating is the failure this step exists to prevent.

## Error Recovery

| Problem | Recovery |
|---------|----------|
| On the base branch, or it does not exist | `git diff --stat HEAD` (uncommitted work) — say so in the report |
| Branch has no common ancestor with base | Ask the user for the scope. Never fall back to a fixed commit count. |
| Quality skill not installed | Note as "configured but not installed" and continue review |
| Session not found | Review without session context — note this in report |
| Too many files to review | Group by category, focus on CRITICAL checks first |
| User does not want to route findings now | Record that decision in the report and, if a session is active, in its Progress section. Do not silently drop them. |
