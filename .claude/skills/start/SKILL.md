---
name: start
description: Start feature with branch and session tracking
argument-hint: <feature-name>
allowed-tools: Bash(git:*), Read, Write, Edit, Glob
---

# Start Feature: $ARGUMENTS

## Prerequisites

### 0. Load Configuration

Read `.claude/project.config.json` to get project configuration.

**Variables to use**:
- `{branchPrefix}` = `config.git.branchPrefixes.feature` (default: `feature/`)
- `{mainBranch}` = `config.git.mainBranch` (default: `main`)

**Validation**: If `config.initialized === false`, suggest running `/setup` first.

### 1. Check Git Status
!`git status --short`
!`git branch --show-current`

**IMPORTANT**: If there are uncommitted changes, STOP and ask the user.

## Start Process

### 2. Check BACKLOG
Read `context/BACKLOG.md` to verify if "$ARGUMENTS" is in the pending list.

- If exists: move to "In Progress"
- If not exists: add to "In Progress" with standard format

### 3. Create Branch
```bash
git checkout -b {branchPrefix}$ARGUMENTS
```

Branch format: `{branchPrefix}descriptive-name` (kebab-case)

### 4. Create Session

Generate session ID: `YYYYMMDD-HHMM-$ARGUMENTS`

Create session file in `context/tmp/session-{ID}.md`:

```markdown
# Session: {ID}

- **Branch**: {branchPrefix}$ARGUMENTS
- **Start**: {date and time}
- **Status**: IN_PROGRESS

## Objective
[Description based on BACKLOG or $ARGUMENTS]

## Initial Context
- Base branch: {previous branch}
- Relevant files: [to be determined]

## Progress
<!-- Update during development -->

## Decisions
<!-- Document important technical decisions -->

## Session Pending Items
<!-- Items that arise during work -->
```

### 5. Update Context README

Add entry to "Active Sessions" table in `context/README.md`:

```markdown
| {ID} | {branchPrefix}$ARGUMENTS | IN_PROGRESS | {date} | {description} |
```

## Final Verification

- [ ] Branch created and checkout done
- [ ] Session created in `context/tmp/`
- [ ] BACKLOG updated
- [ ] Context README updated

## Expected Output

Confirm:
1. Active branch: `{branchPrefix}$ARGUMENTS`
2. Session started: `session-{ID}.md`
3. Configuration loaded from: `.claude/project.config.json`
4. Ready for development
