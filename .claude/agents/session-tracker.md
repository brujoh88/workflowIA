# Agent: Session Tracker

Manages the session tracking system.

## Project Root Detection

Dynamically detect PROJECT_ROOT by searching upward for `CLAUDE.md`:
```
Start from current directory, traverse up until finding CLAUDE.md
PROJECT_ROOT = directory containing CLAUDE.md
```

All paths below are relative to PROJECT_ROOT.

## Responsibilities

1. **Session Management**
   - Create new sessions
   - Update active session status
   - Archive completed sessions
   - Verify "BACKLOG Items Addressed" table exists in every session

2. **Commit Documentation**
   - Register commits in `.pending-commits.log`
   - Manage commit states: `PENDING` → `PROCESSED` | `DOCUMENTED`
   - Clean log after successful push
   - **Anti-loop pattern**: Use `docs(session-{ID}):` prefix for session-specific commits

3. **File Maintenance**
   - Rotate sessions to archive by quarter
   - Update quarterly summaries
   - Keep README index updated

4. **BACKLOG Synchronization**
   - Verify consistency between sessions and BACKLOG
   - Report orphan items
   - Mark BACKLOG items with session references

5. **FIXES Synchronization**
   - For fix sessions: verify FIXES.md entry exists and is consistent
   - On session close: ensure FIXES item moved to Resolved with root cause and fix description
   - Report orphan FIXES items (In Progress without active session)

## Pending Commits Log Management

### Format
```
STATUS|DATE|HASH|BRANCH|MESSAGE
```

### States
| State | Meaning | Transition |
|-------|---------|------------|
| `PENDING` | Commit registered, not yet documented | → PROCESSED (on /finish) |
| `PROCESSED` | Included in session summary | → (archived with session) |
| `DOCUMENTED` | Auto-docs commit, no action needed | → (stays) |

### Anti-Loop Protection (Reinforced)

When creating administrative commits, the commit message MUST use one of these prefixes:
- `docs(context): ...` — General context updates
- `chore(session): ...` — Session maintenance
- `docs(session): ...` — Session documentation
- `docs(session-{ID}): ...` — Session-specific documentation (preferred)

These are auto-marked as `DOCUMENTED` by the post-commit hook, preventing infinite loops.

**CRITICAL**: Never create a commit that would trigger another session-tracker invocation. The pattern `docs(session-{ID}):` is the safest because it's the most specific.

## Session Structure

```markdown
# Session: {ID}

- **Branch**: {name}
- **Start**: {timestamp}
- **Status**: IN_PROGRESS | PAUSED | COMPLETED
- **ROADMAP Module**: {module name} ({%}) | N/A

## Objective
{Clear description of the objective}

## BACKLOG Items Addressed
| Item | Status | Notes |
|------|--------|-------|
| **[scope]** description | [ ] Pending / [~] Partial / [x] Done | Details |

## Initial Context
{Code state at start}

## Quality Skills
- External skills to consult: {list or "none configured"}

## Progress
{Progress log}

## Decisions
{Technical decisions and their justification}

## Session Pending Items
{Items that arise during work}

## Final Summary (on completion)
- **End**: {timestamp}
- **Duration**: {calculated}
- **Objective**: {one-line}
- **Result**: {one-line what was achieved}
- **Commits**: {count}
- **Files modified**: {count}
- **Tests**: PASSED/FAILED (coverage: {%})
- **BACKLOG items**: {N} completed, {M} partial
- **Link**: branch `{branch}`, session `{ID}`
```

## Automatic Commit on Close

When closing a session, the session-tracker MUST create a documentation commit:

```bash
git add context/ .claude/
git commit -m "docs(session-{ID}): close session {ID}

- Session archived to {year}-{quarter}
- BACKLOG updated: {N} items completed, {M} partial
- ROADMAP updated: {module} → {new %}%
"
```

This commit uses the anti-loop prefix and is auto-marked as `DOCUMENTED`.

## Available Commands

### Create Session
```
Create session for branch {name} with objective {description}
```

### Update Session
```
Update session {ID}: add progress "{text}"
Update session {ID}: change status to PAUSED
```

### Close Session
```
Close session {ID} with summary: {description}
```

### Query Status
```
What is the active session?
List sessions from last month
```

### Maintenance
```
Archive completed sessions
Generate quarterly summary
Clean pending commits (after push)
```

## Business Rules

1. **One active session per branch** - Don't duplicate sessions for the same branch
2. **Session required for commit** - `/finish` requires active session
3. **Automatic archiving** - COMPLETED sessions move to archive
4. **ID format**: `YYYYMMDD-HHMM-{feature-name}`
5. **Anti-loop commits** - Use `docs(session-{ID}):` prefix (preferred) or `docs(context):` / `chore(session):`
6. **BACKLOG Items table** - Every session MUST have the "BACKLOG Items Addressed" table
7. **Compact summaries** - Final Summary block should be 8-12 lines max

## Rotation Rules

| Trigger | Action |
|---------|--------|
| >3 completed blocks in COMPLETED.md | Summarize oldest blocks to quarterly SUMMARY.md |
| >15 archived sessions in a quarter | Generate quarterly summary, compress old sessions |
| Feature reaches 100% | Consolidate to `context/consolidated/{feature}.md` |

## File Locations

| Type | Location |
|------|----------|
| Active | `context/tmp/session-*.md` |
| Archived | `context/archive/{YEAR}-Q{N}/sessions/` |
| Commit log | `context/.pending-commits.log` |
| Index | `context/README.md` |
| History | `context/archive/COMPLETED.md` |

## Integration with Skills

- `/start` → Calls create session
- `/finish` → Calls close session + archive + update pending-commits + documentation commit

## Flow Example

```
1. User: /start auth-login
2. Session-tracker:
   - Creates session-20260126-1430-auth-login.md
   - Updates context/README.md
   - Updates context/BACKLOG.md

3. [... development ...]

4. User: /finish
5. Session-tracker:
   - Closes session with compact summary
   - Marks BACKLOG items [x] with session reference
   - Moves to archive/2026-Q1/sessions/
   - Updates COMPLETED.md
   - Marks .pending-commits.log entries as PROCESSED
   - Creates docs(session-20260126-1430-auth-login): commit
```
