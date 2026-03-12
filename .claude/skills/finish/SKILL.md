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
- `{coAuthoredBy}` = `config.git.coAuthoredBy` (default: `false`)
- `{quarter}` = current quarter (Q1-Q4)
- `{year}` = current year
- `{archiveRotationThreshold}` = `config.workflow.archiveRotationThreshold` (default: 15)
- `{blockRotationThreshold}` = `config.workflow.blockRotationThreshold` (default: 3)
- `{backlogMaxLines}` = `config.workflow.backlogMaxLines` (default: 300)
- `{recentSessionsToKeep}` = `config.workflow.recentSessionsToKeep` (default: 3)
- `{externalSkills}` = `config.quality.externalSkills` (default: `[]`)

**Validation**: If `config.initialized === false`, warn but continue with defaults.

### 0.5. Pre-verification: Quality Skills Check

Detect the type of changes made:
```bash
git diff --stat {mainBranch}..HEAD
```

- If changes include frontend files AND `quality.externalSkills` has frontend-related skills:
  - Check if those skills were consulted during the session (look in session file Progress section)
  - If NOT consulted: **WARN** user: "Quality skills {list} were not consulted for frontend changes. Run them now before finishing? (recommended)"
  - If user declines, note in session as "Quality skills skipped"

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
- Add "Final Summary" section with **compact format** (8-12 lines max):

```markdown
## Final Summary
- **End**: {date and time}
- **Duration**: {calculated from start}
- **Objective**: {one-line objective from session}
- **Result**: {one-line what was achieved}
- **Commits**: {count}
- **Files modified**: {count}
- **Tests**: PASSED | FAILED (coverage: {%} if available)
- **BACKLOG items**: {N} completed, {M} partial
- **Link**: branch `{branch}`, session `{ID}`
```

**IMPORTANT**: Keep the COMPLETED block compact. Do NOT include exhaustive lists of changes — the git log has that detail.

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

### 6.3. BACKLOG Cleanup

After updating items:
1. Remove `[x]` items from body sections (they're already in "Completed (Recent)")
2. Count total lines in BACKLOG
3. If > `{backlogMaxLines}` lines:
   - Move oldest "Completed (Recent)" items to `archive/COMPLETED.md`
   - Target: keep BACKLOG under `{backlogMaxLines}` lines
4. Report: "BACKLOG: {before} → {after} lines"

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

### 6.8. Propagate Dependencies

Search ROADMAP for modules that had dependencies on the completed module/feature:
- For each dependency that is now satisfied: update `❌` → `✅` (or equivalent marker)
- If a blocked module is now unblocked, note it in the output
- This ensures the dependency map stays accurate

### 6.9. Suggest Next Session

Evaluate BACKLOG + ROADMAP to suggest what to work on next:
- Look at "Next (Prioritized)" items in BACKLOG
- Check ROADMAP for unblocked modules with highest priority
- Consider dependency chains (what unblocks the most)
- Present 2-3 options ranked by priority

Format:
```markdown
### Suggested Next Session
1. **{item}** - {reason} (from BACKLOG/ROADMAP)
2. **{item}** - {reason}
3. **{item}** - {reason}
```

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

**IMPORTANT on Co-Authored-By**: Check `config.git.coAuthoredBy`:
- If `true`: Add `Co-Authored-By: Claude <noreply@anthropic.com>` to commit message
- If `false` (default): Do NOT include any AI attribution in the commit message

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

### 9.5. Smart Archive Rotation

Check if rotation is needed:

**Condition 1**: Count completed blocks in `context/archive/COMPLETED.md`
- If > `{blockRotationThreshold}` (default: 3): Summarize oldest blocks to `context/archive/{year}-{quarter}/SUMMARY.md`

**Condition 2**: Count sessions in `context/archive/{year}-{quarter}/sessions/`
- Keep the `{recentSessionsToKeep}` most recent sessions (by highest session number)
- Archive older sessions: compress their content into SUMMARY.md keeping only headers

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

### 10.5. Archive Plan (if exists)

Check if a plan file exists in `.claude/plan/` for this feature:
```
Glob: .claude/plan/*$ARGUMENTS* , .claude/plan/*.md
```

If found:
- Ask user: "Found plan file {name}. Archive to `completados/`?"
- If yes: move to `.claude/plan/completados/`
- If no: leave in place

### 11. Update Pending Commits Log

Read `context/.pending-commits.log` and update entries for this branch:
- Change `PENDING` → `PROCESSED` for all commits on this branch
- This marks them as included in the session summary

### 11.5. Document Commits

Invoke **session-tracker** agent to create the documentation commit:
- This ensures proper anti-loop patterns are used
- The agent handles the `docs(context):` commit prefix

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
- [ ] Quality skills check completed
- [ ] Commit created with descriptive message (Co-Authored-By per config)
- [ ] Session archived with compact summary
- [ ] BACKLOG updated (items marked [x] or [~])
- [ ] BACKLOG cleanup done (under {backlogMaxLines} lines)
- [ ] Bidirectional consistency verified
- [ ] COMPLETED updated
- [ ] ROADMAP updated (if exists)
- [ ] Dependencies propagated
- [ ] Feature completeness evaluated
- [ ] Context README updated
- [ ] Archive rotation checked (keeping {recentSessionsToKeep} recent)
- [ ] Plan archived (if exists)
- [ ] Pending commits log updated
- [ ] Next session suggested

## Expected Output

Confirm:
1. Configuration: loaded from `.claude/project.config.json`
2. Quality skills: {consulted or skipped}
3. Tests (`{testCmd}`): PASSED
4. Lint (`{lintCmd}`): OK
5. Commit: `{short hash}` - `{message}`
6. Session archived: `context/archive/{year}-{quarter}/sessions/`
7. BACKLOG: {N} items marked complete, {M} partial | Cleanup: {before}→{after} lines
8. Feature completeness: {X}%
9. Next suggested: {top suggestion}
10. Suggested next step: merge to `{mainBranch}` or continue development
