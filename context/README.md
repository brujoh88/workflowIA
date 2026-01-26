# Project Context

Tracking system to document development sessions.

## Active Sessions

| ID | Branch | Status | Start | Description |
|----|--------|--------|-------|-------------|
| _none_ | - | - | - | Use `/start` to begin |

## Workflow

```
/start feature-name    # Creates branch + session
  ... development ...
/finish                # Tests + commit + closes session
```

## Session States

- `IN_PROGRESS` - Active work
- `PAUSED` - Work interrupted (document reason)
- `COMPLETED` - Merged and archived

## Structure

```
context/
├── README.md                    # This file (index)
├── BACKLOG.md                   # Single source of pending items
├── .pending-commits.log         # Log of unpushed commits
├── tmp/                         # Temporary summaries
├── archive/
│   ├── COMPLETED.md             # History of completed items
│   └── 2026-Q1/
│       ├── sessions/            # Archived sessions
│       └── SUMMARY.md           # One line per session
└── consolidated/                # Per finished feature
```

## References

- `BACKLOG.md` - Prioritized pending list
- `archive/COMPLETED.md` - History of completed features
