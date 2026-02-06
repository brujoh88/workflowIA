# Project Context

Tracking system to document development sessions.

## Active Sessions

| ID | Branch | Status | Start | Description |
|----|--------|--------|-------|-------------|
| _none_ | - | - | - | Use `/start` to begin |

## Workflow

```
/start feature-name    # Creates branch + session + loads context
  ... development ...
/finish                # Tests + commit + closes session + updates tracking
```

## Session States

- `IN_PROGRESS` - Active work
- `PAUSED` - Work interrupted (document reason)
- `COMPLETED` - Merged and archived

## Rotation Rules

| Trigger | Action | Files Affected |
|---------|--------|----------------|
| >3 completed blocks in COMPLETED.md | Summarize oldest to SUMMARY.md | `archive/COMPLETED.md`, `archive/{Q}/SUMMARY.md` |
| >15 sessions in a quarter folder | Generate quarterly summary | `archive/{Q}/sessions/`, `archive/{Q}/SUMMARY.md` |
| Feature reaches 100% completion | Consolidate to feature doc | `consolidated/{feature}.md` |
| `.pending-commits.log` on /finish | Mark PENDING → PROCESSED | `.pending-commits.log` |

## Consolidated Features

| Feature | Sessions | Date Completed | Doc |
|---------|----------|----------------|-----|
| _none yet_ | - | - | - |

<!-- Add entries when features reach 100% completion and are consolidated -->

## Structure

```
context/
├── README.md                    # This file (index)
├── BACKLOG.md                   # Single source of pending items
├── ROADMAP.md                   # Module progress and dependencies
├── .pending-commits.log         # Log of commits (auto via hook)
├── tmp/                         # Active session files
├── archive/
│   ├── COMPLETED.md             # History of completed items
│   └── YYYY-QN/
│       ├── sessions/            # Archived session files
│       └── SUMMARY.md           # One line per session
└── consolidated/                # Per finished feature documentation
```

## References

- `BACKLOG.md` - Prioritized pending list
- `ROADMAP.md` - Module status and progress tracking
- `archive/COMPLETED.md` - History of completed features
