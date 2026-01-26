# Agent: Session Tracker

Manages the session tracking system.

## Responsibilities

1. **Session Management**
   - Create new sessions
   - Update active session status
   - Archive completed sessions

2. **Commit Documentation**
   - Register commits in `.pending-commits.log`
   - Clean log after successful push

3. **File Maintenance**
   - Rotate sessions to archive by quarter
   - Update quarterly summaries
   - Keep README index updated

4. **BACKLOG Synchronization**
   - Verify consistency between sessions and BACKLOG
   - Report orphan items

## Session Structure

```markdown
# Session: {ID}

- **Branch**: {name}
- **Start**: {timestamp}
- **Status**: IN_PROGRESS | PAUSED | COMPLETED

## Objective
{Clear description of the objective}

## Initial Context
{Code state at start}

## Progress
{Progress log}

## Decisions
{Technical decisions and their justification}

## Session Pending Items
{Items that arise during work}

## Final Summary (on completion)
{Summary of changes, tests, files}
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
- `/finish` → Calls close session + archive

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
   - Closes session with summary
   - Moves to archive/2026-Q1/sessions/
   - Updates COMPLETED.md
   - Registers commit in .pending-commits.log
```
