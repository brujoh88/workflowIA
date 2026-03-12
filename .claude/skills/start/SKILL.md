---
name: start
description: Start feature with branch and session tracking
argument-hint: <feature-name>
allowed-tools: Bash(git:*), Read, Write, Edit, Glob, Grep, mcp__context7__resolve-library-id, mcp__context7__query-docs
---

# Start Feature: $ARGUMENTS

## Prerequisites

### 0. Load Configuration

Read `.claude/project.config.json` to get project configuration.

**Variables to use**:
- `{branchPrefix}` = `config.git.branchPrefixes.feature` (default: `feature/`)
- `{mainBranch}` = `config.git.mainBranch` (default: `main`)
- `{devBranch}` = `config.git.devBranch` (default: `""` → use mainBranch)
- `{baseBranch}` = devBranch if set, otherwise mainBranch
- `{syncTypes}` = `config.commands.syncTypes` (default: `""`)
- `{externalSkills}` = `config.quality.externalSkills` (default: `[]`)

**Validation**: If `config.initialized === false`, suggest running `/setup` first.

### 0.5. Module Framing (Auto-detect)

Read `context/ROADMAP.md` and try to auto-detect which module `$ARGUMENTS` belongs to:
- Search for keywords from `$ARGUMENTS` in ROADMAP module names and descriptions
- If match found: report module name, current progress %, and dependencies
- If no match found: ask user:
  - "This doesn't match any existing ROADMAP module. Is this: (a) part of an existing module, (b) a new module to add, or (c) not module-tracked?"
  - If new module: classify as **MVP** / **Post-MVP** / **Deferred** and add to ROADMAP

### 1. Check Git Status
!`git status --short`
!`git branch --show-current`

**IMPORTANT**: If there are uncommitted changes, STOP and ask the user.

### 1.5. Context Loading

Invoke **context-provider** agent in **quick mode**:
- Read `context/README.md` (active sessions)
- Read `context/BACKLOG.md` (pending items)
- Read `context/ROADMAP.md` (if exists - module progress)
- Read `context/FIXES.md` (if exists - pending fixes)
- Read `.claude/MEMORY.md` (if exists - lessons learned)
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
- Identify which module this feature belongs to (use result from step 0.5)
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

**MANDATORY**: Use Glob + Grep BEFORE creating branch. Never assume something doesn't exist.

If potential matches found, report to user:
- "Found potentially related code: {files}. Should we proceed with a new implementation or extend existing?"

### 3. Create Branch
```bash
git checkout {baseBranch}
git pull origin {baseBranch} 2>/dev/null || true
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
- **ROADMAP Module**: {module name} ({current %}%) | N/A

## Objective
[Description based on BACKLOG or $ARGUMENTS]

## BACKLOG Items Addressed
| Item | Status | Notes |
|------|--------|-------|
| **[scope]** description | [ ] Pending | From BACKLOG |

## Initial Context
- Base branch: {baseBranch}
- ROADMAP module: {module name} ({current %}%) (if applicable)
- Relevant files: [to be determined]

## Quality Skills
- External skills to consult: {externalSkills list or "none configured"}

## Progress
<!-- Update during development -->

## Decisions
<!-- Document important technical decisions -->

## Session Pending Items
<!-- Items that arise during work -->
```

### 4.5. Identify Quality Skills

Read `config.quality.externalSkills` from project config:
- If skills are configured, list them and note which apply to this feature type
- Example: if feature involves frontend and `["accessibility-checker", "performance-audit"]` are configured, note both
- Present to user: "These quality skills should be consulted during development: {list}"

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
- [ ] Quality skills identified (if configured)
- [ ] Session created and tracking active
```

### 5.7. Sync Types (Conditional)

If `config.commands.syncTypes` is defined and non-empty:
```bash
{syncTypes}
```

This ensures type definitions are up-to-date before starting development.

### 5.8. Consult Context7 (Conditional)

Detect main technologies from `config.project.stack` and `package.json` (if exists):
- For each major library/framework detected, use Context7 to fetch current documentation
- Focus on patterns relevant to the feature being started
- Present key findings to user as context

**Tools**: `mcp__context7__resolve-library-id` → `mcp__context7__query-docs`

Skip silently if Context7 is not available or stack is not configured.

## Final Verification

- [ ] Context loaded (BACKLOG, ROADMAP, FIXES, active sessions)
- [ ] Module framing completed
- [ ] Branch created and checkout done
- [ ] Feature existence verified (no duplicates)
- [ ] Session created in `context/tmp/`
- [ ] BACKLOG updated
- [ ] Context README updated
- [ ] Quality skills identified
- [ ] Types synced (if configured)

## Expected Output

Confirm:
1. Active branch: `{branchPrefix}$ARGUMENTS`
2. Session started: `session-{ID}.md`
3. Configuration loaded from: `.claude/project.config.json`
4. ROADMAP module: {module} ({%}) or N/A
5. Context snapshot: {brief status}
6. Suggested agents: {list}
7. Quality skills: {list or "none configured"}
8. Ready for development
