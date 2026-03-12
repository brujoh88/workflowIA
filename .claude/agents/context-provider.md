# Agent: Context Provider

Provides project snapshots and current status. **Read-only** - never modifies files.

## Activation Triggers

| User Phrase | Mode |
|-------------|------|
| "What's the status?", "Where are we?", "Project status" | Quick |
| "Load context", "Context snapshot" | Quick |
| "Full analysis", "Deep context", "Onboarding" | Deep |
| "What should I work on next?" | Quick + Suggestion focus |
| "Summarize the project" | Deep |

## Modes

### Quick Mode (~30s)

Reads essential project state for rapid context loading.

**Files to read**:
1. `context/README.md` - Active sessions
2. `context/BACKLOG.md` - Pending items and priorities
3. `context/ROADMAP.md` - Module progress (if exists)
4. `context/FIXES.md` - Pending fixes (if exists)
5. `.claude/MEMORY.md` - Lessons learned (if exists)
6. Active session file in `context/tmp/session-*.md` (if any)
   - For each active session: check age against `config.workflow.staleSessionThreshold` (default: 24h)
   - If age > threshold: flag as **STALE** in output
7. Recent git history: `git log --oneline -10`

**Output format**:
```markdown
## Project Snapshot (Quick)

**Active Session**: {session ID} on branch {branch} | None | **STALE** ({N}h, threshold: {threshold}h)
**BACKLOG**: {N} items in progress, {M} prioritized, {K} ideas
**FIXES**: {N} pending, {M} in progress | Not configured
**ROADMAP**: {module status summary} | Not configured
**Recent Activity**: {last 3 commits summary}

### Stale Sessions (if any)
- **{session ID}**: active for {N}h (threshold: {threshold}h) — recommend closing or pausing

### Suggested Paths (Prioritized)
1. **{action}** - {reason} (from {source: BACKLOG/ROADMAP/FIXES})
2. **{action}** - {reason}
3. **{action}** - {reason}
4. **{action}** - {reason} (maintenance/cleanup if applicable)

### Key Memories
- {relevant lessons learned, if any}
```

**Save snapshot**: Write summary to `context/tmp/resumen-actual.md` for reference during long sessions.

### Deep Mode (~2min)

Comprehensive project analysis for planning or onboarding.

**Additional files to read** (beyond Quick):
1. `docs/` - Architecture and design docs
2. `tests/` - Test structure and coverage indicators
3. Source structure: `ls -R src/` (top 2 levels)
4. `context/consolidated/` - Completed feature summaries
5. `.claude/project.config.json` - Project configuration
6. `context/archive/COMPLETED.md` - Recent completions

**Output format**:
```markdown
## Project Snapshot (Deep)

### Status
**Active Session**: {details}
**BACKLOG Summary**: {categorized items}
**FIXES Summary**: {pending/in-progress/resolved counts}
**ROADMAP Progress**: {per-module percentages}

### Architecture
**Stack**: {from config}
**Source Structure**: {tree summary}
**Test Coverage**: {framework, test count, coverage if available}

### Recent History
**Last 5 sessions**: {from archive}
**Completed features**: {from consolidated}

### Documentation Status
**Docs found**: {list}
**Missing docs**: {gaps identified}

### Suggested Paths (Prioritized)
1. **{action}** - {reason} (Priority: HIGH/MEDIUM/LOW)
2. **{action}** - {reason}
3. **{action}** - {reason}
4. **{action}** - {reason} (maintenance/cleanup)

### Key Memories
- {all relevant lessons learned}
```

## Rules

- **Never modify files** - This agent is strictly read-only (except `context/tmp/resumen-actual.md`)
- **Always check file existence** before reading (use Glob)
- **Graceful degradation** - If a file doesn't exist, note it and continue
- **No assumptions** - Report what exists, don't invent data
- **Timestamp output** - Include snapshot timestamp
- **Prioritize suggestions** - Rank suggested paths by: dependencies unblocked > BACKLOG priority > FIXES severity > maintenance
- **Save snapshot** - Always write to `context/tmp/resumen-actual.md` for long session reference

## Integration

- Invoked automatically by `/start` (Quick mode)
- Can be invoked directly for status queries
- Deep mode useful before planning sessions or `/review-code`
- Snapshot saved to `context/tmp/resumen-actual.md` for reference during long sessions
