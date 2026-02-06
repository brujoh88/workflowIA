# Agent: Session Tracker

Manages the session tracking system.

## Responsibilities

1. **Session Management**
   - Create new sessions
   - Update active session status
   - Archive completed sessions

2. **Commit Documentation**
   - Register commits in `.pending-commits.log`
   - Manage commit states: `PENDING` → `PROCESSED` | `DOCUMENTED`
   - Clean log after successful push

3. **File Maintenance**
   - Rotate sessions to archive by quarter
   - Update quarterly summaries
   - Keep README index updated

4. **BACKLOG Synchronization**
   - Verify consistency between sessions and BACKLOG
   - Report orphan items
   - Mark BACKLOG items with session references

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

### Anti-Loop Protection
When creating administrative commits (session updates, context docs), the commit message MUST use:
- `docs(context): ...` or `chore(session): ...` prefixes
- These are auto-marked as `DOCUMENTED` by the post-commit hook
- This prevents infinite loops of tracking commits about tracking

## Session Structure

```markdown
# Session: {ID}

- **Branch**: {name}
- **Start**: {timestamp}
- **Status**: IN_PROGRESS | PAUSED | COMPLETED

## Objective
{Clear description of the objective}

## BACKLOG Items Addressed
| Item | Status | Notes |
|------|--------|-------|
| **[scope]** description | [ ] Pending / [~] Partial / [x] Done | Details |

## Initial Context
{Code state at start}

## Progress
{Progress log}

## Decisions
{Technical decisions and their justification}

## Session Pending Items
{Items that arise during work}

## Final Summary (on completion)
- **End**: {timestamp}
- **Duration**: {calculated}
- **Commits**: {count}
- **Modified files**: {list}
- **BACKLOG items completed**: {count}
```

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
5. **Anti-loop commits** - Administrative commits use `docs(context):` or `chore(session):` prefix

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
- `/finish` → Calls close session + archive + update pending-commits

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
   - Closes session with summary and metadata
   - Marks BACKLOG items [x] with session reference
   - Moves to archive/2026-Q1/sessions/
   - Updates COMPLETED.md
   - Marks .pending-commits.log entries as PROCESSED
```
