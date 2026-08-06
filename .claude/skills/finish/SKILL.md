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
- **Session date**: (the `Date` field in the session file — drives quarter archiving, R22)
- **Duration**: calculated from session start to now
- **Plan**: (the `Plan` field in the session file — a path, or why there is none)

If the session file has a `## Size signals accepted` section, note it: the work was flagged as
big and started without a plan. At step 7.5 (feature completeness), state plainly whether it
actually got finished or is shipping partial — that is the question those signals were about.

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
- `{parallelEnabled}` = `config.parallel.enabled` (default: `true`)
- `{sharedBranchEnabled}` = `config.parallel.sharedBranch.enabled` (default: `true`)
- `{sharedBranchDirectory}` = `config.parallel.sharedBranch.directory` (default: `context/.parallel`)
- `{atomicCommits}` = `config.parallel.sharedBranch.atomicCommits` (default: `true`)
- `{baseBranch}` = `config.git.devBranch` if set, otherwise `config.git.mainBranch`
- `{testMaxWorkers}` = `config.workflow.testMaxWorkers` (default: `2`)

**Validation**: If `config.initialized === false`, warn but continue with defaults.

### 0.3. Acquire Context Lock (Parallel Sessions)

If `{parallelEnabled}` is true:
```bash
./scripts/context-lock.sh acquire "{session-id}" "/finish"
```
- If lock is held: retry up to 3 times every 5 seconds
- If fails: inform user and wait
- **CRITICAL**: Lock MUST be released in step 11.7, even if errors occur

### 0.5. Pre-verification: Quality Skills Check

Detect the type of changes made:
```bash
git diff --stat {mainBranch}..HEAD
```

- If changes include frontend files AND `quality.externalSkills` has frontend-related skills:
  - Check if those skills were consulted during the session (look in session file Progress section)
  - For each configured skill:
    1. Check if `.claude/skills/{skill-name}/SKILL.md` exists (via symlink or direct)
    2. If exists and not consulted: **WARN** user: "Quality skill `{name}` is installed but was not consulted. Run now? (recommended)"
    3. If not exists: note as "configured but not installed — skip"
  - If user declines, note in session as "Quality skills skipped"

### 1. Identify Active Session
!`git branch --show-current`

Find active session in `context/tmp/session-*.md` matching the current branch.

**IMPORTANT**: If no active session exists, create one retroactively before continuing.

## Finish Process

### 2. Run Tests

```bash
{testCmd} --maxWorkers={testMaxWorkers}   # R19: limit CPU usage (default: 2)
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

### 6.75. Update FIXES Registry

If current branch is a fix branch (starts with `fix/`):
1. Read `context/FIXES.md`
2. Find matching In Progress item
3. Move to Resolved (Recent) with:
   - Fixed date: {current date}
   - Root cause: from session Decisions section
   - Fix description: from commit message
   - Session reference: `session-{ID}`
4. If fix was for a Pending item never moved to In Progress, move directly to Resolved

If current branch is NOT a fix branch but fixes were done:
- Check session file for any FIXES references
- Update FIXES.md accordingly

### 6.7. Update ROADMAP (if exists)

Read `context/ROADMAP.md` and update if it exists:
- Update module percentage based on completed items
- Update dependency status if this feature unblocks other modules
- Add session reference to module history
- Update global metrics

If ROADMAP doesn't exist, skip silently.

### 6.8. Cross-Section Consistency & Propagate Dependencies

**Cross-section consistency**: When a module completes, propagate across all tracking files:
1. Search ROADMAP for modules that had dependencies on the completed module/feature
2. For each dependency now satisfied: update `❌` → `✅` (or equivalent marker)
3. Search BACKLOG for items that referenced the completed module as a blocker
4. If a blocked module is now unblocked, note it in the output
5. Update any "Depends on" fields in ROADMAP that reference the completed work

This ensures the dependency map stays accurate across BACKLOG, ROADMAP, and session files.

### 6.85. Update ROUTE (the work queue)

Read `context/ROUTE.md`. If it does not exist, skip silently.

1. **Move the finished item out of `## NOW`** into `## DONE (last 5)`, one line:
   `- [x] **{session number}** · {what shipped, plain language} — {TICKET-ID} ({YYYY-MM-DD})`
   Trim DONE back to 5 entries — older ones already live in `archive/COMPLETED.md`.
2. **Promote the first `## QUEUE` item to `## NOW`.**
3. **Add findings discovered during the session** to the QUEUE right away, one line each, with
   their `file:line` pointer. Do not defer them to "sort later" — that is how they get lost.
   If a finding has evidence, write it to `context/verifications/YYYY-MM-DD-*.md` and point to it.
4. **Re-order if what shipped changed the picture** (e.g. an item that was blocked is now free,
   or a fix revealed a bigger problem underneath). State the reason in one line.
5. Update the header: `**Updated**: {date} · **Next session**: {new NOW item ID}`.

If the session **partially** completed its item, the item stays in NOW with the remaining scope
rewritten — do not move it to DONE.

### 6.9. Suggest Next Session

If `ROUTE.md` exists, the suggestion is simply the item now sitting in `## NOW` — say it in one
line and skip the ranking below.

Otherwise, evaluate BACKLOG + ROADMAP to suggest what to work on next:
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

**8.0. Detect if we're in parallel mode (shared branch)**:

```bash
# Check if THIS session is registered in parallel mode
# Use quotes for exact match (prevent "session-14" matching "session-142")
SESSION_ID="session-XXX"  # Replace with actual session ID
if [ -f {sharedBranchDirectory}/state.json ] && grep -q "\"$SESSION_ID\"" {sharedBranchDirectory}/state.json; then
  echo "PARALLEL"
else
  echo "NORMAL"
fi
```

> **IMPORTANT**: It's not enough that `state.json` exists. THIS session must be registered in it.
> If `state.json` exists but this session is NOT registered, follow the NORMAL flow (8.b).

---

**8.a. If in parallel mode (shared branch)**:

Conventional Commits - determine type based on changes:
- `feat` - New feature
- `fix` - Bug fix
- `refactor` - Refactoring
- `test` - Tests
- `docs` - Documentation
- `chore` - Maintenance

1. Identify files owned by this session (do NOT include files from other session):
   ```bash
   # List modified/created files
   git status --porcelain
   ```
   Verify against `state.json` that files belong to this session's domain.
   If files are outside this session's domain, ask user before including them.

2. Atomic commit (stage + commit in one command to avoid conflicts with other session):
   ```bash
   git commit file1 file2 context/tmp/session-XXX.md -m "feat(scope): description"
   ```
   - **NEVER** use `git add .` or `git add -A` in parallel mode
   - Commit scope MUST match this session's feature name
   - Context shared files (BACKLOG.md, ROADMAP.md, README.md) are included in this commit

3. Write closing message in `channel.md`:
   ```markdown
   ### [HH:MM] session-XXX → all
   Session finished. Commits: {list of commits}. Feature: {name}.
   Context files updated: BACKLOG, ROADMAP.
   ```

4. Update `{sharedBranchDirectory}/state.json`: remove this session from the `sessions` object.

5. If this session is the LAST in `state.json` (sessions object is empty or has no active sessions):
   ```bash
   rm -rf {sharedBranchDirectory}
   ```
   **Ask user if they want to merge to `{baseBranch}`** (like any feature branch):
   - If yes:
     ```bash
     git checkout {baseBranch}
     git merge {branchPrefix}{A}--{B}
     git branch -d {branchPrefix}{A}--{B}
     ```
   - If no: leave on the shared branch

6. If **NOT the last session** → do not merge, the other session is still working on the branch.

**IMPORTANT on Co-Authored-By**: Check `config.git.coAuthoredBy`:
- If `true`: Add `Co-Authored-By: Claude <noreply@anthropic.com>` to commit message
- If `false` (default): Do NOT include any AI attribution in the commit message

---

**8.b. Normal flow (no parallel, on feature branch)**:

Conventional Commits - determine type based on changes:
- `feat` - New feature
- `fix` - Bug fix
- `refactor` - Refactoring
- `test` - Tests
- `docs` - Documentation
- `chore` - Maintenance

```bash
git add file1 file2   # Specific files, do NOT use -A without reviewing
git commit -m "type(scope): description

- Main changes detail
- Session reference: {session-id}
"
```

**IMPORTANT on Co-Authored-By**: Check `config.git.coAuthoredBy`:
- If `true`: Add `Co-Authored-By: Claude <noreply@anthropic.com>` to commit message
- If `false` (default): Do NOT include any AI attribution in the commit message

Ask user if they want to merge to `{baseBranch}`:
- If yes:
  ```bash
  git checkout {baseBranch}
  git merge {branchPrefix}{feature}
  git branch -d {branchPrefix}{feature}
  ```
- If no: leave on feature branch

### 9. Archive Session

Move session from `context/tmp/` to `context/archive/{year}-{quarter}/sessions/`.

**R22 — derive the quarter from the SESSION's date, never from today's**:
```bash
grep -m1 "^\*\*Date\*\*:" context/tmp/session-{ID}.md
# month 1-3 → Q1, 4-6 → Q2, 7-9 → Q3, 10-12 → Q4
```
A session started in March and closed in April files under **Q1**, not Q2.

First create directory if not exists:
```bash
mkdir -p context/archive/{year}-{quarter}/sessions/
```

Then move:
```bash
mv context/tmp/session-{ID}.md context/archive/{year}-{quarter}/sessions/
```

### 9.5. Smart Archive Rotation

Check rotation triggers (act on first exceeded):

| Trigger | Threshold | Action |
|---------|-----------|--------|
| Completed blocks in COMPLETED.md | > `{blockRotationThreshold}` (3) | Summarize oldest to quarterly SUMMARY.md |
| Sessions in quarter archive | > `{archiveRotationThreshold}` (15) | Keep `{recentSessionsToKeep}` recent, compress rest |
| BACKLOG lines | > `{backlogMaxLines}` (300) | Move oldest completed items to `archive/COMPLETED.md` |

### 10. Update Context README

Remove from "Active Sessions" in `context/README.md`.

Add closure metadata:
```markdown
<!-- Last session: {ID} completed {date} on branch {branch} -->
```

### 10.5. Close the Plan (if there was one)

**Read the `Plan` field from the session file** (written by `/start` step 2.8). That is the
authority — do not guess by filename.

| `Plan` field says | Do this |
|---|---|
| A path | Follow the steps below |
| `none — no size signals` | Skip silently. There was nothing to plan. |
| `none — signals fired, user chose to continue` | Skip archiving, but say so in the summary: this shipped without a plan, and step 7.5 already reported whether it actually got finished. |
| Field missing (session predates this) | Fall back to `Glob: .claude/plan/*$ARGUMENTS*` and confirm the match with the user before touching anything |

When there is a plan file:

1. **Read it and compare against what shipped.** For each step: done, dropped, or changed?
2. **Report the difference in one short block** — this is the most useful thing `/finish` says
   about a planned feature:
   ```
   Plan: {name}
   - Done as planned: {N} of {M} steps
   - Changed on the way: {step} → {what was actually done, and why}
   - Left pending: {step} → moved to BACKLOG as {item}
   ```
3. **Anything left pending goes to BACKLOG before archiving.** A plan step that quietly
   disappears with the plan file is the whole failure mode this step exists to prevent.
4. **Then ask**: "Archive `{name}` to `completados/`?"
   - Yes → move to `.claude/plan/completados/`
   - No → leave it (the work continues in another session)
   - If steps are still pending and the user archives anyway, confirm those steps made it to
     BACKLOG first.

### 11. Update Pending Commits Log

Read `context/.pending-commits.log` and update entries for this branch:
- Change `PENDING` → `PROCESSED` for all commits on this branch
- This marks them as included in the session summary

### 11.5. Release Context Lock

If lock was acquired in step 0.3:
```bash
./scripts/context-lock.sh release
```
**CRITICAL**: This MUST execute even if previous steps failed. The lock protects context writes only.

### 11.6. Document Commits

Invoke **session-tracker** agent to create the documentation commit (filter commits by current branch for parallel safety):
- This ensures proper anti-loop patterns are used
- The agent handles the `docs(context):` commit prefix

### 12. Documentation Commit

Create a separate commit for all context/documentation changes:
```bash
git add context/ .claude/
# If memory.engram.enabled is true, also stage the exported memory chunks:
# git add .engram/
git commit -m "docs(context): close session {ID}

- Session archived to {year}-{quarter}
- ROUTE updated (next item: {new NOW})
- BACKLOG updated
- COMPLETED updated
"
```

**Note**: This commit uses `docs(context):` prefix so the post-commit hook auto-marks it as `DOCUMENTED`.

## Final Verification

- [ ] Tests passed
- [ ] Quality skills check completed
- [ ] Commit created with descriptive message (Co-Authored-By per config)
- [ ] Session archived with compact summary (quarter from SESSION date, R22)
- [ ] ROUTE updated (item moved to DONE, next promoted to NOW, new findings queued)
- [ ] BACKLOG updated (items marked [x] or [~])
- [ ] BACKLOG cleanup done (under {backlogMaxLines} lines)
- [ ] Bidirectional consistency verified
- [ ] COMPLETED updated
- [ ] FIXES updated (if fix branch)
- [ ] ROADMAP updated (if exists)
- [ ] Dependencies propagated
- [ ] Feature completeness evaluated
- [ ] Context README updated
- [ ] Archive rotation checked (keeping {recentSessionsToKeep} recent)
- [ ] Plan closed: steps compared against what shipped, pending ones moved to BACKLOG, file archived
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
8. FIXES: {N} items resolved (if fix branch)
9. Feature completeness: {X}%
10. Plan: {N}/{M} steps done | {K} changed | {P} moved to BACKLOG — or "none (no size signals)"
11. ROUTE: item {ID} → DONE | next up: {new NOW item}
12. Suggested next step: merge to `{mainBranch}` or continue development

## Error Recovery

| Problem | Recovery |
|---------|----------|
| Tests fail | Fix tests before finishing. Do NOT skip with --no-verify |
| Commit created but archive failed | Manually move session: `mv context/tmp/session-*.md context/archive/{Q}/sessions/` |
| Session not found | Create retroactive session, then continue /finish |
| BACKLOG update failed | Re-read BACKLOG, manually mark items, retry |
| Branch deleted before merge | Session is archived — recover from archive for context |
| Merge conflicts | Resolve conflicts, commit, then re-run /finish |
| Partial /finish (died mid-process) | Check which steps completed (commits? archive? BACKLOG?), resume from incomplete step |
| FIXES.md update failed | Manually update FIXES.md entries after /finish completes |
| Context lock not released | Run `./scripts/context-lock.sh release` manually |
| Lock script not found | Skip lock (parallel protection unavailable) |
| Parallel session conflict on shared files | Verify domain in state.json, ask user before including disputed files |
| state.json corrupted | Delete `{sharedBranchDirectory}/state.json`, proceed as normal flow |
| Shared branch merge conflicts | Resolve conflicts, commit, then re-run /finish |
