# WorkflowIA - User Manual

Guide for using the workflowIA development framework (v2.2).

## Setup on New Machine

1. **Clone the repository**
2. **Run `/setup`** — Interactive wizard configures everything
3. **Git hooks**: Setup configures `core.hooksPath` (installs pre-commit + post-commit hooks)
4. **LSP**: Enable TypeScript plugin in `.claude/settings.json`
5. **MEMORY.md**: Created during setup for persistent lessons

## Configuration Architecture

```
.claude/
├── project.config.json          # All project settings (single source of truth)
├── settings.json                # Claude Code plugin settings
├── settings.local.json          # Local permissions (gitignored)
├── MANUAL.md                    # This file
├── MEMORY.md                    # Persistent lessons and preferences
├── plan/                        # Implementation plans (gitignored except .gitkeep)
│   ├── .gitkeep
│   ├── YYYY-MM-DD-desc.md      # Active plans
│   └── completados/             # Archived plans
│       └── .gitkeep
├── docs/                        # Framework documentation
│   └── QUALITY-SKILLS-CONTRACT.md # Quality skill interface contract
├── skills/                      # Slash commands
│   ├── setup/                   # /setup - Configuration wizard
│   ├── start/                   # /start - Begin feature
│   ├── finish/                  # /finish - End feature
│   ├── review-code/             # /review-code - Code audit
│   ├── audit/                   # /audit - System-wide audit
│   ├── explore-code/            # /explore-code - Code exploration
│   ├── fix-issue/               # /fix-issue - Bug fix workflow
│   ├── deploy/                  # /deploy - Deployment
│   ├── metrics/                 # /metrics - Project metrics dashboard (NEW)
│   ├── mcp/                     # /mcp - MCP server management
│   ├── architecture-ref/        # Auto-loaded architecture patterns
│   ├── development-protocol-ref/ # Auto-loaded development protocol
│   └── ui-design-system-ref/    # Auto-loaded UI design reference
├── agents/                      # 9 specialized agents
│   ├── session-tracker.md       # Session lifecycle + anti-loop commits
│   ├── context-provider.md      # Project snapshot + suggested paths
│   ├── feature-architect.md     # Feature structure + anatomy docs
│   ├── code-reviewer.md         # Standalone structured audit
│   ├── code-explorer.md         # Codebase navigation
│   ├── test-engineer.md         # Tests + coverage BEFORE/AFTER protocol
│   ├── db-analyst.md            # Schema design + migrations + queries
│   ├── api-documenter.md        # API documentation audit
│   └── frontend-integrator.md   # Components + a11y + dark mode
└── rules/                       # Context-specific rules
    ├── api.md
    ├── database.md
    └── frontend.md
```

## Skills (Slash Commands)

| Skill | Trigger | Description |
|-------|---------|-------------|
| `/setup` | First-time configuration | Interactive wizard: project metadata, git, hooks, MEMORY |
| `/start <feature>` | Begin new work | Module framing + branch + session + Context7 + quality skills |
| `/finish` | End current work | Quality check + tests + compact summary + BACKLOG cleanup + rotation |
| `/review-code` | Pre-merge review | Multi-category audit + frontend/E2E + quality skill integration |
| `/audit [module]` | System-wide audit | 8 modules: types, security, validation, size, coverage, docs, arch, quality |
| `/explore-code` | Understand codebase | Navigate and understand code structure |
| `/fix-issue` | Bug fix workflow | Guided debugging with 3 hypotheses |
| `/deploy` | Deployment workflow | Environment-aware deploy with pre/post checks |
| `/metrics` | Project dashboard | Session, commit, BACKLOG, ROADMAP, and FIXES metrics |
| `/mcp` | MCP server management | Search, install, configure MCP servers |

## Agents

| Agent | Specialty | Invoked Via |
|-------|-----------|-------------|
| `session-tracker` | Session lifecycle, anti-loop commits | `/start`, `/finish` |
| `db-analyst` | Schema design, migrations, queries, indexes | Direct delegation |
| `code-explorer` | Codebase navigation and understanding | `/explore-code` |
| `code-reviewer` | Standalone structured multi-category review | `/review-code` |
| `context-provider` | Project snapshot, suggested paths, stale session detection | `/start` (auto), direct |
| `feature-architect` | Feature structure, anatomy docs, size limits | `/start` (new features) |
| `test-engineer` | Test creation with coverage BEFORE/AFTER protocol | `/finish` (auto), direct |
| `api-documenter` | API documentation completeness audit | Direct delegation |
| `frontend-integrator` | Component scaffolding, a11y, dark mode | Direct delegation |

## Workflows

### Feature Development
```
1. /start feature-name          # Module framing + branch + session + context
2. ... implement feature ...     # Code, test, iterate
3. /review-code                  # Pre-merge quality check (invokes quality skills)
4. /finish                       # Tests + commit + archive + rotation
```

### Bug Fix
```
Quick fix (1-2 files):
1. Fix directly → test → commit
2. Log in context/FIXES.md

Complex fix:
1. /start fix-description        # Branch + session
2. ... debug with 3 hypotheses ...
3. ... implement fix ...
4. /finish                       # Tests + commit + archive

Batch fix:
1. Group related small fixes
2. Fix all → test → single commit
3. Log in context/FIXES.md
```

### System Audit
```
/audit              # Full audit (all 8 modules)
/audit A            # Types only
/audit B C          # Security + Validation
```

Modules: A=Types, B=Security, C=Validation, D=FileSize, E=Coverage, F=APIDocs, G=Architecture, H=Quality

### Code Review Only
```
/review-code        # Structured multi-category review with quality skill integration
```

### Quick Context Check
```
Ask: "What's the project status?"  # Triggers context-provider with suggested paths
```

## Context Structure

```
context/
├── README.md                    # Index of active sessions and status
├── BACKLOG.md                   # Prioritized pending items (<300 lines target)
├── ROADMAP.md                   # Module status and progress tracking
├── FIXES.md                     # Centralized bug/fix registry
├── .pending-commits.log         # Auto-registered commits (via hook)
├── tmp/                         # Active session files
│   ├── session-*.md             # Active sessions
│   └── resumen-actual.md        # Latest context snapshot
├── archive/
│   ├── COMPLETED.md             # History of completed items
│   └── YYYY-QN/
│       ├── sessions/            # Archived session files
│       └── SUMMARY.md           # One-line per session summary
├── auditorias/                  # Audit reports from /audit
└── consolidated/                # Per finished feature documentation
```

## MEMORY.md

Persistent memory for lessons learned across sessions.

**Purpose**: Store lessons, preferences, and patterns that should persist between conversations.

**When to consult**:
- At the start of each session (loaded by context-provider)
- When making decisions that might have been addressed before
- When the user says "remember" or "don't do X again"

**Location**: `.claude/MEMORY.md`

## Implementation Plans

Plans live in `.claude/plan/` with naming format `YYYY-MM-DD-description.md`.

**Workflow**:
1. Create plan → get user approval
2. Once approved → `/start` as first step
3. On `/finish` → plan archived to `completados/`

Plans are gitignored (local only) except for `.gitkeep` files.

## Rotation Rules

Files are automatically rotated to prevent bloat:

| Trigger | Action |
|---------|--------|
| >3 completed blocks in COMPLETED.md | Summarize oldest to SUMMARY.md |
| >N archived sessions in a quarter | Keep N most recent, compress rest |
| Feature 100% complete | Consolidate to `consolidated/` |
| `.pending-commits.log` after /finish | Mark entries as PROCESSED |
| BACKLOG > 300 lines | Move oldest completed to archive |
| Plan completed | Move to `completados/` |

## Parallel Sessions

Multiple Claude instances can work on different branches simultaneously.

**Architecture**:
- Code work is 100% parallelizable (each instance works on its own branch)
- Context writes (README, BACKLOG, ROADMAP) are serialized via lock
- Lock file: `context/.context.lock` (auto-created, auto-expired)
- Lock script: `scripts/context-lock.sh`

**Lock operations**:
```bash
./scripts/context-lock.sh acquire "session-id" "/start"   # Acquire lock
./scripts/context-lock.sh release                          # Release lock
./scripts/context-lock.sh check                            # Check status
```

**Configuration** in `project.config.json`:
```json
"parallel": {
  "enabled": true,
  "lockTimeoutSeconds": 60,
  "lockFile": "context/.context.lock"
}
```

**When is the lock held?**
- `/start`: during session file creation, README update, BACKLOG update
- `/finish`: during session archive, BACKLOG cleanup, ROADMAP update
- Released immediately after context writes complete

**Timeout safety**: If a crash leaves the lock, it auto-expires after `lockTimeoutSeconds`.

## Configuration

All project settings live in `.claude/project.config.json`:
- Project metadata (name, stack, description)
- Language preferences (code + chat)
- Commands (test, lint, dev, build, syncTypes)
- Git configuration (branch prefixes, main/dev branch, coAuthoredBy)
- Code conventions (naming, commits)
- Workflow thresholds (max file lines per type, rotation triggers, coverage, BACKLOG max lines, staleSessionThreshold, testMaxWorkers)
- Quality settings (external skills — see Quality Skills Contract)
- Parallel sessions (enabled, lock timeout, lock file path)
- MCP settings (installed, suggested)

Run `/setup` to configure interactively.

## Context7 Integration

Context7 provides up-to-date documentation for libraries:
- `/start` auto-queries docs for detected technologies
- `test-engineer` queries test framework docs
- `feature-architect` queries framework structure patterns
- `db-analyst` queries ORM documentation
- `frontend-integrator` queries frontend framework patterns

Requires Context7 MCP server to be installed.

## Quality Skills Contract

External quality skills can be integrated via `.claude/docs/QUALITY-SKILLS-CONTRACT.md`.

- **What**: Specialized quality checks (accessibility, performance, design compliance)
- **Interface**: Skills produce findings with severity/file/line/description
- **Installation**: Symlink or copy to `.claude/skills/`, register in `config.quality.externalSkills`
- **Integration**: Checked by `/review-code` (Step 1.5) and `/finish` (Step 0.5)
- **Reference**: See `.claude/docs/QUALITY-SKILLS-CONTRACT.md` for full specification

## Git Hooks

Two hooks are installed via `git config core.hooksPath scripts/hooks`:

| Hook | Purpose | Bypass |
|------|---------|--------|
| `pre-commit` | Lint, per-type file size (R4), TypeScript errors (R16) | `git commit --no-verify` |
| `post-commit` | Auto-register commits in `.pending-commits.log` | N/A |

## Enforced Rules (21 total)

| # | Rule | Summary |
|---|------|---------|
| R1 | Language | Respond/code in configured language |
| R2 | Git Flow | main protected, branch from dev if configured |
| R3 | Commits | Co-Authored-By only if configured |
| R4 | File Size | Enforce per-type maxFileLines/maxFunctionLines |
| R5 | Testing | Coverage BEFORE/AFTER, target threshold |
| R6 | Verify First | Glob+Grep before creating, no assumptions |
| R7 | BACKLOG Compaction | Stay under backlogMaxLines |
| R8 | Delegation | Mandatory agent/skill delegation |
| R9 | Plans | Plans in .claude/plan/, archived when done |
| R10 | Fix Workflows | Quick/complex/batch fix patterns |
| R11 | No Premature Action | Read → understand → ask |
| R12 | Debugging Protocol | 3 hypotheses before fixing |
| R13 | Session Discipline | Every /start creates, every /finish closes |
| R14 | Zero Inference | Concrete sources only |
| R15 | Quality Skills | Frontend changes require quality skill check |
| R16 | LSP Diagnostics | Type errors are blockers |
| R17 | Sync MANUAL | Update MANUAL when modifying .claude/ |
| R18 | Docker Environment | DB commands inside container, non-interactive migrations |
| R19 | CPU Limiting | Test workers capped at `testMaxWorkers` (default: 2) |
| R20 | Migrations Protocol | Generate diff → review SQL → deploy (non-interactive) |
| R21 | Parallel Sessions | Context writes serialized via lock, code work parallelizable |

## Architecture Decision Records (ADR)

When making significant architectural decisions, document them in the session file:

```markdown
### ADR: [Title]
- **Status**: Accepted | Rejected | Superseded
- **Context**: Why this decision was needed
- **Decision**: What was decided
- **Consequences**: Positive and negative implications
- **Alternatives considered**: Other options evaluated
```

ADRs are preserved in session archives and consolidated feature docs.

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| Orphan session (IN_PROGRESS, no activity) | Forgot `/finish` | Close manually or `/finish` from the branch |
| BACKLOG inconsistent with sessions | Manual edits bypassed workflow | Run context-provider deep mode to reconcile |
| Branch deleted but session exists | Force-deleted branch | Archive session manually, update README |
| Hook not running (no .pending-commits.log entries) | `core.hooksPath` not set | Run `/setup` or `git config core.hooksPath scripts/hooks` |
| Session file corrupted | Partial write during error | Delete and create new session with `/start` |
| FIXES.md out of sync | Fixes done without FIXES update | Manually update FIXES.md entries |
| Plan files accumulating | Plans not archived after completion | Move completed plans to `.claude/plan/completados/` |
| Archive too large | Rotation not triggered | Manually run rotation: move old sessions to SUMMARY |
| Stale sessions not detected | `staleSessionThreshold` not set | Add to config: `workflow.staleSessionThreshold: 24` |
| Quality skill not found | Configured but not installed | Install via symlink or copy to `.claude/skills/` |
| Context lock stuck | Crash during `/start` or `/finish` | Run `./scripts/context-lock.sh release` manually |
| Parallel sessions conflict | Two operations writing context | Lock auto-expires after `lockTimeoutSeconds` (default: 60s) |

## Tips

- Always use `/start` before beginning work to maintain tracking
- Use `/review-code` before `/finish` for quality assurance
- Run `/audit` periodically for system-wide health checks
- Check `context/BACKLOG.md` for prioritized work items
- Check `context/ROADMAP.md` for module progress and dependencies
- Check `context/FIXES.md` for pending bug fixes
- The debugging protocol (3 hypotheses) prevents premature fixes
- Agents are read-only by default unless they need to write
- MEMORY.md persists lessons between conversations
- Plans in `.claude/plan/` are for implementation strategy alignment

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| v2.2 | 2026-03-13 | 10 improvements from 127+ sessions: parallel sessions, per-type file limits, enhanced hooks, Docker/CPU/migrations rules, cross-section consistency, enhanced rotation |
| v2.1 | 2026-03-12 | /metrics skill, pre-commit hook, quality skills contract, stale session detection, FIXES integration, error recovery sections, troubleshooting, skill rewrites (fix-issue, deploy, explore-code) |
| v2.0 | 2026-03-12 | 17 rules, /audit, MEMORY, plans, FIXES, Context7, improved agents |
| v1.0 | 2026-02-06 | Initial release with 9 agents and 5 core skills |
