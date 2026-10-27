---
name: fix-issue
description: Bug fix workflow with 3-hypothesis debugging protocol
argument-hint: [issue-number|description]
disable-model-invocation: true
allowed-tools: Bash(git:*), Bash(*test*), Read, Write, Edit, Glob, Grep
---

# Fix Issue: $ARGUMENTS

## Step 0: Load Configuration

Read `.claude/project.config.json` to get project configuration.

**Variables to use**:
- `{testCmd}` = `config.commands.test` (default: `npm test`)
- `{mainBranch}` = `config.git.mainBranch` (default: `main`)
- `{fixPrefix}` = `config.git.branchPrefixes.fix` (default: `fix/`)
- `{coAuthoredBy}` = `config.git.coAuthoredBy` (default: `false`)

Read `context/FIXES.md` for existing bug reports and fix history.

## Step 1: Issue Context

Determine the issue source based on `$ARGUMENTS`:

**If numeric** (e.g., `42`):
```bash
gh issue view $ARGUMENTS --json title,body,labels,comments
```
- Extract: title, description, reproduction steps, labels
- Note issue number for commit reference

**If text description** (e.g., `login-timeout`):
- Treat as a description of the problem
- Ask user for reproduction steps if not clear

## Step 2: Consult FIXES Registry

Read `context/FIXES.md` and search for existing reports matching the issue:
- Check Pending section for matching entries
- Check In Progress section for related work
- Check Resolved (Recent) for similar past fixes

**If match found in Pending**:
- Pre-load context (reproduction steps, severity, related files)
- Move item from Pending → In Progress in FIXES.md

**If match found in Resolved**:
- Report: "A similar fix was applied before: {details}. This may be a regression."

**If no match found**:
- Ask user: "This issue is not in FIXES.md. Should I register it? (recommended)"
- If yes: add to In Progress with standard format

## Step 3: Locate Affected Code

Search for code related to the issue:

1. **Keyword search**: Grep for terms from the issue description in `src/`
2. **File search**: Glob for files matching module/component names
3. **Trace the flow**: Read identified entry points and follow the execution path
4. **Related tests**: Find existing tests for the affected code

Report findings:
```markdown
### Affected Code
| File | Line | Relevance |
|------|------|-----------|
| `{file}` | {line} | {why this file is relevant} |
```

## Step 4: 3-Hypothesis Debugging Protocol (R12)

**MANDATORY**: Before writing any fix, formulate and validate hypotheses.

### 4.1 Formulate Hypotheses

Based on the issue context and code analysis, formulate **at least 3 hypotheses** about the root cause:

```markdown
### Hypotheses
| # | Hypothesis | Confidence | Validation Method |
|---|-----------|------------|-------------------|
| 1 | {description} | HIGH/MED/LOW | {how to verify} |
| 2 | {description} | HIGH/MED/LOW | {how to verify} |
| 3 | {description} | HIGH/MED/LOW | {how to verify} |
```

### 4.2 Validate Each Hypothesis

For each hypothesis, gather evidence:
- Read relevant code sections
- Check logs if available
- Run targeted tests
- Trace data flow

```markdown
### Validation Results
| # | Hypothesis | Evidence | Verdict |
|---|-----------|----------|---------|
| 1 | {description} | {what was found} | CONFIRMED / REJECTED / INCONCLUSIVE |
| 2 | {description} | {what was found} | CONFIRMED / REJECTED / INCONCLUSIVE |
| 3 | {description} | {what was found} | CONFIRMED / REJECTED / INCONCLUSIVE |
```

### 4.3 Confirm Root Cause

- If one hypothesis is CONFIRMED: proceed with fix targeting that cause
- If multiple CONFIRMED: determine the primary cause and address all
- If all INCONCLUSIVE: gather more evidence or formulate new hypotheses
- **Never proceed without a confirmed root cause**

## Step 5: Implement Fix

Fix the confirmed root cause:
- **Minimal change**: only modify what's necessary to fix the issue
- **Follow conventions**: use project naming and patterns
- **No refactoring**: don't clean up unrelated code
- **Add guards**: prevent the same issue from recurring if appropriate

## Step 6: Test

Run tests to verify the fix:
```bash
{testCmd}
```

- If tests fail: investigate whether the failure is related to the fix
- If tests pass: verify the fix actually addresses the issue
- Add new tests if the bug wasn't covered by existing tests

## Step 7: Update FIXES Registry

Read and update `context/FIXES.md`:

**If item was in Pending/In Progress**:
- Move to Resolved (Recent) with:
  ```markdown
  ### FIX-{NNN}: {title}
  - **Severity**: {severity}
  - **Root cause**: {confirmed hypothesis}
  - **Fix**: {what was changed}
  - **Files**: {list of modified files}
  - **Date resolved**: {date}
  - **Session**: {session-ID if applicable}
  ```

**If item was not registered**:
- Add directly to Resolved (Recent) with the same format

## Step 8: Commit

Create commit with fix prefix:

**If from GitHub issue** (numeric $ARGUMENTS):
```bash
git add {modified files}
git commit -m "fix(scope): description (closes #$ARGUMENTS)

- Root cause: {confirmed hypothesis}
- Fix: {what was changed}
"
```

**If from description**:
```bash
git add {modified files}
git commit -m "fix(scope): description

- Root cause: {confirmed hypothesis}
- Fix: {what was changed}
"
```

**Co-Authored-By**: Check `config.git.coAuthoredBy`:
- If `true`: add `Co-Authored-By: Claude <noreply@anthropic.com>`
- If `false` (default): do NOT include AI attribution

## Error Recovery

| Problem | Recovery |
|---------|----------|
| GitHub CLI not installed | Skip `gh issue view`, ask user for issue details manually |
| Issue not found on GitHub | Treat as text description, proceed with manual context |
| All hypotheses rejected | Formulate 3 new hypotheses with broader scope |
| Tests fail after fix | Revert fix, re-examine root cause, try alternative approach |
| FIXES.md not found | Create it with standard template from `context/FIXES.md` |
| Fix introduces new failures | Check if failure is pre-existing; if new, investigate before committing |

## Workflow Decision

| Complexity | Approach |
|-----------|----------|
| **Quick fix** (1-2 files, clear cause) | Complete this flow directly |
| **Complex fix** (multi-file, unclear) | Use `/start fix-{name}` for full session tracking |
| **Batch fix** (multiple small related) | Group fixes, single commit, log all in FIXES.md |
