---
name: finish
description: Finish feature with tests, commit, and session closure
allowed-tools: Bash(git:*), Bash(*test*), Bash(*lint*), Read, Write, Edit, Glob, Grep
---

# Finish Feature

## Prerequisites

### 0. Closure Metadata

Capture immediately:
- **Invoked by**: (current user/context)
- **Timestamp**: {current date and time}
- **Branch**: !`git branch --show-current`
- **Commit count**: !`git rev-list --count {mainBranch}..HEAD`
- **Session start**: (from session file)
- **Duration**: calculated from session start to now

### 0.1. Load Configuration

Read `.claude/project.config.json` to get project configuration.

**Variables to use**:
- `{testCmd}` = `config.commands.test` (default: `npm test`)
- `{lintCmd}` = `config.commands.lint` (default: `npm run lint`)
- `{mainBranch}` = `config.git.mainBranch` (default: `main`)
- `{quarter}` = current quarter (Q1-Q4)
- `{year}` = current year
- `{archiveRotationThreshold}` = `config.workflow.archiveRotationThreshold` (default: 15)
- `{blockRotationThreshold}` = `config.workflow.blockRotationThreshold` (default: 3)

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
- **Duration**: {calculated from start}
- **Commits**: {count}
- **Modified files**: {list}

### Main Changes
- [List significant changes]

### Tests
- Status: PASSED/FAILED
- Coverage: {if available}

### BACKLOG Items Completed
- [x] **[scope]** description *(session-{ID})*
```

### 6. Update BACKLOG

Read `context/BACKLOG.md` and update items related to this session:

**Completion markers**:
- `[x]` = Fully completed → Move to "Completed (Recent)" section with session reference
- `[~]` = Partially completed → Keep in current section, add note with progress
- `[ ]` = Not addressed → Leave as is

Format for completed items:
```markdown
- [x] **[scope]** Description *(session-{ID})*
```

Format for partial items:
```markdown
- [~] **[scope]** Description
  - Progress: {what was done} *(session-{ID})*
  - Remaining: {what's left}
```

### 6.5. CRITICAL: Bidirectional Consistency Check

Verify consistency between Session and BACKLOG:

1. **Session → BACKLOG**: Every item listed in session's "BACKLOG Items Addressed" table must have a corresponding entry in BACKLOG
2. **BACKLOG → Session**: Every "In Progress" item in BACKLOG that matches this branch should be in the session

If inconsistencies found:
- Report them to the user
- Suggest fixes
- Apply fixes after user confirmation

### 6.7. Update ROADMAP (if exists)

Read `context/ROADMAP.md` and update if it exists:
- Update module percentage based on completed items
- Update dependency status if this feature unblocks other modules
- Add session reference to module history
- Update global metrics

If ROADMAP doesn't exist, skip silently.

### 7. Register in COMPLETED

Add entry to `context/archive/COMPLETED.md`:

```markdown
| {date} | {description} | {branch} | {session-id} | {impact} |
```

### 7.5. Feature Completeness Evaluation

Evaluate overall feature completeness:

1. **Identify scope**: What % of the feature's BACKLOG items are done?
   - Count `[x]` items for this feature scope
   - Count total items for this feature scope
   - Calculate percentage

2. **If 100% complete**:
   - Create consolidated feature document in `context/consolidated/{feature-name}.md`
   - Include: objective, all sessions involved, key decisions, final architecture
   - This serves as permanent documentation of the feature

3. **If < 100%**:
   - Document remaining items clearly in BACKLOG
   - Note dependencies for next session

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

### 9.5. Archive Rotation Check

Check if rotation is needed:

**Condition 1**: Count completed blocks in `context/archive/COMPLETED.md`
- If > `{blockRotationThreshold}` (default: 3): Summarize oldest blocks to `context/archive/{year}-{quarter}/SUMMARY.md`

**Condition 2**: Count sessions in `context/archive/{year}-{quarter}/sessions/`
- If > `{archiveRotationThreshold}` (default: 15): Generate quarterly summary, move oldest session details to SUMMARY.md keeping only headers

**Rotation action**:
```markdown
## Quarterly Summary Entry
| Session ID | Date | Branch | Summary |
|-----------|------|--------|---------|
| {ID} | {date} | {branch} | {one-line summary} |
```

### 10. Update Context README

Remove from "Active Sessions" in `context/README.md`.

Add closure metadata:
```markdown
<!-- Last session: {ID} completed {date} on branch {branch} -->
```

### 11. Update Pending Commits Log

Read `context/.pending-commits.log` and update entries for this branch:
- Change `PENDING` → `PROCESSED` for all commits on this branch
- This marks them as included in the session summary

### 12. Documentation Commit

Create a separate commit for all context/documentation changes:
```bash
git add context/ .claude/
git commit -m "docs(context): close session {ID}

- Session archived to {year}-{quarter}
- BACKLOG updated
- COMPLETED updated
"
```

**Note**: This commit uses `docs(context):` prefix so the post-commit hook auto-marks it as `DOCUMENTED`.

## Final Verification

- [ ] Tests passed
- [ ] Commit created with descriptive message
- [ ] Session archived with complete metadata
- [ ] BACKLOG updated (items marked [x] or [~])
- [ ] Bidirectional consistency verified
- [ ] COMPLETED updated
- [ ] ROADMAP updated (if exists)
- [ ] Feature completeness evaluated
- [ ] Context README updated
- [ ] Archive rotation checked
- [ ] Pending commits log updated

## Expected Output

Confirm:
1. Configuration: loaded from `.claude/project.config.json`
2. Tests (`{testCmd}`): PASSED
3. Lint (`{lintCmd}`): OK
4. Commit: `{short hash}` - `{message}`
5. Session archived: `context/archive/{year}-{quarter}/sessions/`
6. BACKLOG: {N} items marked complete, {M} partial
7. Feature completeness: {X}%
8. Suggested next step: merge to `{mainBranch}` or continue development
