# Project Context

Tracking system to document development sessions.

## Active Sessions

| ID | Branch | Status | Start | Description |
|----|--------|--------|-------|-------------|

<!-- Last session: 20261027-1451-plugin-f2 completed 2026-10-28 on branch feature/plugin-f2 -->

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
├── ROUTE.md                     # THE work queue — read this first (NOW / QUEUE / DONE)
├── README.md                    # This file (index)
├── BACKLOG.md                   # Unordered inventory of pending items (<300 lines target)
├── ROADMAP.md                   # Module progress and dependencies
├── FIXES.md                     # Centralized bug/fix registry
├── ENVIRONMENT.md               # Access, DB, API traps, environment gotchas
├── .pending-commits.log         # Log of commits (auto via hook, gitignored)
├── tmp/                         # Active session files
│   ├── session-*.md             # Active sessions
│   └── pre-compact-snapshot.md  # Auto state snapshot before compaction (gitignored)
├── verifications/               # Versioned evidence of manual testing rounds
├── archive/
│   ├── COMPLETED.md             # History of completed items
│   └── YYYY-QN/
│       ├── sessions/            # Archived session files (quarter from SESSION date, R22)
│       └── SUMMARY.md           # One line per session
├── auditorias/                  # Audit reports from /audit
└── consolidated/                # Per finished feature documentation
```

## Three files, three questions

| Question | File |
|----------|------|
| **What do I work on next?** | `ROUTE.md` → section NOW. One item, one page, 30 seconds. |
| **What is still pending overall?** | `BACKLOG.md` — the full inventory, unordered. |
| **Where is the product going?** | `ROADMAP.md` — modules, progress, dependencies. |

Keeping them separate is the point: ROUTE stays short enough to actually read at the start of
every session, which is what makes it useful.

## References

- `ROUTE.md` - The work queue (single source of "what's next")
- `BACKLOG.md` - Full pending inventory (<300 lines target)
- `ROADMAP.md` - Module status and progress tracking
- `FIXES.md` - Centralized bug/fix registry
- `ENVIRONMENT.md` - Operational data needed to work (access, DB, traps)
- `verifications/` - Evidence behind findings
- `archive/COMPLETED.md` - History of completed features
- `auditorias/` - System audit reports from `/audit`
