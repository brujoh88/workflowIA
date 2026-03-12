---
name: development-protocol-ref
description: Development protocol and session workflow reference
---

# Development Protocol Reference

Auto-loaded reference for development workflows, session templates, and conventions.

## Context Directory Structure

```
context/
├── README.md                    # Index of active sessions and status
├── BACKLOG.md                   # Single source of pending items (<300 lines)
├── ROADMAP.md                   # Module progress tracking with dependencies
├── FIXES.md                     # Centralized bug/fix registry
├── .pending-commits.log         # Auto-registered commits (via hook)
├── tmp/                         # Active session files + current snapshot
│   ├── session-*.md             # Active sessions
│   └── resumen-actual.md        # Latest context snapshot
├── archive/
│   ├── COMPLETED.md             # History of completed items
│   └── YYYY-QN/
│       ├── sessions/            # Archived session files
│       └── SUMMARY.md           # One-line per session summary
├── auditorias/                  # Audit reports from /audit
└── consolidated/                # Per-feature documentation (100% complete)
```

## Session Template

```markdown
# Session: YYYYMMDD-HHMM-feature-name

- **Branch**: feature/feature-name
- **Start**: YYYY-MM-DD HH:MM
- **Status**: IN_PROGRESS
- **ROADMAP Module**: Module Name (X%) | N/A

## Objective
[Description based on BACKLOG or feature name]

## BACKLOG Items Addressed
| Item | Status | Notes |
|------|--------|-------|
| **[scope]** description | [ ] Pending | From BACKLOG |

## Initial Context
- Base branch: main (or dev)
- ROADMAP module: Module Name (X%)
- Relevant files: [to be determined]

## Quality Skills
- External skills to consult: [list or "none configured"]

## Progress
<!-- Update during development -->

## Decisions
<!-- Document important technical decisions -->
<!-- Use ADR format for significant decisions:
### ADR: [Title]
- **Status**: Accepted | Rejected | Superseded
- **Context**: Why this decision was needed
- **Decision**: What was decided
- **Consequences**: Positive and negative implications
-->

## Session Pending Items
<!-- Items that arise during work -->
```

## Feature Anatomy Template

```markdown
# Feature: {name}

## Overview
{Brief description of what this feature does}

## File Structure
| File | Responsibility | Status | Size Target |
|------|---------------|--------|-------------|
| `service.ts` | Business logic | Planned | ~100 lines |
| `controller.ts` | HTTP handling | Planned | ~100 lines |
| `types.ts` | Type definitions | Planned | ~50 lines |
| `service.test.ts` | Unit tests | Planned | ~150 lines |

## Design Decisions
- {key decision 1}: {rationale}

## Dependencies
- Depends on: {list}
- Blocks: {list}
```

## Session Workflow

### Starting (`/start feature-name`)
1. Load config → context snapshot → check BACKLOG → frame module
2. Verify no duplicates → create branch → identify agents
3. Create session → update README → sync types → consult Context7

### During Development
- Update session Progress section regularly
- Document decisions in session Decisions section
- Track BACKLOG items in the session table
- Consult quality skills for frontend changes

### Finishing (`/finish`)
1. Quality skills check → run tests → run lint
2. Update session (compact summary) → update BACKLOG (cleanup)
3. Bidirectional consistency → update ROADMAP → propagate dependencies
4. Register in COMPLETED → evaluate feature completeness
5. Create commit → archive session → rotate → archive plan
6. Update pending commits → suggest next session

## Commit Format

```
type(scope): brief description

- Detail of main changes
- Session reference: session-YYYYMMDD-HHMM-name
```

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`

Co-Authored-By: only if `git.coAuthoredBy: true` in config.

## Periodic Rotation

| Trigger | Action | Files Affected |
|---------|--------|----------------|
| >3 completed blocks in COMPLETED.md | Summarize oldest to SUMMARY.md | `archive/COMPLETED.md`, `archive/{Q}/SUMMARY.md` |
| >N sessions in quarter folder | Keep N most recent, compress rest | `archive/{Q}/sessions/`, `archive/{Q}/SUMMARY.md` |
| Feature reaches 100% | Consolidate to feature doc | `consolidated/{feature}.md` |
| `.pending-commits.log` on /finish | Mark PENDING → PROCESSED | `.pending-commits.log` |
| BACKLOG > 300 lines | Move oldest completed to archive | `BACKLOG.md`, `archive/COMPLETED.md` |
