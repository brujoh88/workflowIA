---
name: start
description: Start feature with branch and session tracking
argument-hint: <feature-name>
allowed-tools: Bash(git:*), Read, Write, Edit, Glob, Grep
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

### 1.5. Context Loading

Invoke **context-provider** agent in **quick mode**:
- Read `context/README.md` (active sessions)
- Read `context/BACKLOG.md` (pending items)
- Read `context/ROADMAP.md` (if exists - module progress)
- Check for active sessions in `context/tmp/session-*.md`
- Recent git history: `git log --oneline -5`

Present a brief snapshot to the user before proceeding.

## Start Process

### 2. Check BACKLOG and Frame Feature

Read `context/BACKLOG.md` to verify if "$ARGUMENTS" is in the pending list.

- **If exists in BACKLOG**:
  - Move to "In Progress" section
  - Use its description and criteria for the session objective
- **If NOT in BACKLOG**:
  - Ask user: "This feature is not in the BACKLOG. Should I add it?"
  - If yes: add to "In Progress" with standard format
  - If no: proceed without BACKLOG entry (document in session)

### 2.5. Consult ROADMAP (if exists)

Read `context/ROADMAP.md` if it exists:
- Identify which module this feature belongs to
- Note current module progress (%)
- Check dependencies on other modules
- Report findings to user

If ROADMAP doesn't exist, skip silently.

### 2.7. Verify Feature Doesn't Already Exist

Before creating a new feature, verify it hasn't been implemented already:
```
Grep: {feature-related keywords} in src/
Glob: src/**/*{feature-name-parts}*
```

If potential matches found, report to user:
- "Found potentially related code: {files}. Should we proceed with a new implementation or extend existing?"

### 3. Create Branch
```bash
git checkout -b {branchPrefix}$ARGUMENTS
```

Branch format: `{branchPrefix}descriptive-name` (kebab-case)

### 3.5. Identify Relevant Agents

Based on the feature type, suggest relevant agents:

| Feature Type | Relevant Agents |
|-------------|----------------|
| New API endpoint | `feature-architect`, `test-engineer`, `api-documenter` |
| Frontend component | `frontend-integrator`, `test-engineer` |
| Database changes | `db-analyst`, `test-engineer` |
| Full-stack feature | `feature-architect`, `frontend-integrator`, `db-analyst`, `test-engineer` |
| Bug fix | `code-explorer`, `test-engineer` |
| Refactoring | `code-explorer`, `code-reviewer`, `test-engineer` |
| Documentation | `api-documenter`, `context-provider` |

Present suggested agents to user as informational (not mandatory).

### 3.7. Feature Structure Proposal (New Features)

If this is a new feature (not a fix or refactor), invoke **feature-architect**:
- Detect architecture pattern in existing codebase
- Propose file structure for the new feature
- Present to user for approval

If user approves, create the proposed structure.

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

## BACKLOG Items Addressed
| Item | Status | Notes |
|------|--------|-------|
| **[scope]** description | [ ] Pending | From BACKLOG |

## Initial Context
- Base branch: {previous branch}
- ROADMAP module: {module name} ({current %}%) (if applicable)
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

### 5.5. Pre-Implementation Checklist

Present to user (informational, not blocking):

```markdown
## Pre-Implementation Checklist
- [ ] Feature objective is clear
- [ ] BACKLOG item identified (or explicitly skipped)
- [ ] No duplicate implementation detected
- [ ] Architecture structure approved (if new feature)
- [ ] Relevant agents identified
- [ ] Session created and tracking active
```

## Final Verification

- [ ] Context loaded (BACKLOG, ROADMAP, active sessions)
- [ ] Branch created and checkout done
- [ ] Feature existence verified (no duplicates)
- [ ] Session created in `context/tmp/`
- [ ] BACKLOG updated
- [ ] Context README updated

## Expected Output

Confirm:
1. Active branch: `{branchPrefix}$ARGUMENTS`
2. Session started: `session-{ID}.md`
3. Configuration loaded from: `.claude/project.config.json`
4. Context snapshot: {brief status}
5. Suggested agents: {list}
6. Ready for development
