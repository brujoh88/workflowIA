---
name: finish
description: Finish feature with tests, commit, and session closure
allowed-tools: Bash(git:*), Bash(*test*), Bash(*lint*), Read, Write, Edit, Glob
---

# Finish Feature

## Prerequisites

### 0. Load Configuration

Read `.claude/project.config.json` to get project configuration.

**Variables to use**:
- `{testCmd}` = `config.commands.test` (default: `npm test`)
- `{lintCmd}` = `config.commands.lint` (default: `npm run lint`)
- `{mainBranch}` = `config.git.mainBranch` (default: `main`)
- `{quarter}` = current quarter (Q1-Q4)
- `{year}` = current year

**Validation**: If `config.initialized === false`, warn but continue with defaults.

### 1. Identify Active Session
!`git branch --show-current`

Find active session in `context/tmp/session-*.md` matching the current branch.

**IMPORTANT**: If no active session exists, create one retroactively before continuing.

## Finish Process

### 2. Run Tests
```bash
{testCmd}
```

- If fail: STOP and report errors to user
- If pass: continue

### 3. Check Linting (if available)
```bash
{lintCmd} 2>/dev/null || echo "Lint not configured"
```

### 4. Changes Status
!`git status`
!`git diff --stat`

### 5. Update Session

In the active session file, update:
- Status: `COMPLETED`
- Add "Final Summary" section:

```markdown
## Final Summary
- **End**: {date and time}
- **Commits**: {count}
- **Modified files**: {list}

### Main Changes
- [List significant changes]

### Tests
- Status: PASSED/FAILED
- Coverage: {if available}
```

### 6. Update BACKLOG

Move item from "In Progress" to remove (documented in COMPLETED).

### 7. Register in COMPLETED

Add entry to `context/archive/COMPLETED.md`:

```markdown
| {date} | {description} | {branch} | {session-id} | {impact} |
```

### 8. Create Commit

Conventional Commits - determine type based on changes:
- `feat` - New feature
- `fix` - Bug fix
- `refactor` - Refactoring
- `test` - Tests
- `docs` - Documentation
- `chore` - Maintenance

```bash
git add -A
git commit -m "type(scope): description

- Main changes detail
- Session reference: {session-id}
"
```

### 9. Archive Session

Move session from `context/tmp/` to `context/archive/{year}-{quarter}/sessions/`:

First create directory if not exists:
```bash
mkdir -p context/archive/{year}-{quarter}/sessions/
```

Then move:
```bash
mv context/tmp/session-{ID}.md context/archive/{year}-{quarter}/sessions/
```

### 10. Update Context README

Remove from "Active Sessions" in `context/README.md`.

### 11. Commit Log

Register in `context/.pending-commits.log`:
```
{date} | {branch} | {hash} | {message}
```

## Final Verification

- [ ] Tests passed
- [ ] Commit created with descriptive message
- [ ] Session archived
- [ ] BACKLOG updated
- [ ] COMPLETED updated
- [ ] Context README updated

## Expected Output

Confirm:
1. Configuration: loaded from `.claude/project.config.json`
2. Tests (`{testCmd}`): PASSED
3. Lint (`{lintCmd}`): OK
4. Commit: `{short hash}` - `{message}`
5. Session archived: `context/archive/{year}-{quarter}/sessions/`
6. Suggested next step: merge to `{mainBranch}` or continue development
