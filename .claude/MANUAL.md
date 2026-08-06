# WorkflowIA - User Manual

Guide for using the workflowIA development framework (v2.5).

## Setup on New Machine

1. **Clone the repository**
2. **Run `/setup`** — Interactive wizard configures everything
3. **Git hooks**: Setup runs `git config core.hooksPath scripts/hooks` and `chmod +x scripts/hooks/*`
   (installs pre-commit + commit-msg + post-commit)
4. **Claude Code hooks**: Setup writes the `hooks` block into `.claude/settings.json`
   (guard-main, guard-db, precompact, session-context). Without it the guards never fire.
5. **LSP**: Enable TypeScript plugin in `.claude/settings.json`
6. **MEMORY.md**: Created during setup for persistent lessons

## Configuration Architecture

```
.claude/
├── project.config.json          # All project settings (single source of truth)
├── settings.json                # Claude Code plugin settings + hooks registration (R23)
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
│   ├── discover/                # /discover - Product framing (run before /setup)
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

scripts/
├── context-lock.sh              # Serializes context writes across parallel sessions
└── hooks/
    ├── pre-commit               # git: protected branch, file size, TS errors
    ├── commit-msg               # git: no AI attribution + conventional format
    ├── post-commit              # git: registers commits in .pending-commits.log
    ├── claude-guard-main.sh     # Claude: denies commit/push on protected branch
    ├── claude-guard-db.sh       # Claude: denies destructive DB ops / migrations outside Docker
    ├── claude-precompact.sh     # Claude: state snapshot before compaction
    └── claude-session-context.sh # Claude: re-injects context after compaction

CLAUDE.md                        # Rules and routing (loaded every session — keep it small)
CLAUDE-CHANGELOG.md              # Framework history (kept out of context on purpose)
```

## Skills (Slash Commands)

| Skill | Trigger | Description |
|-------|---------|-------------|
| `/discover` | New project **or** any new feature idea | Mode A frames a new project and derives its stack. **Mode B thinks through a feature on a running project** — what it solves, what it breaks, where it queues. Mode C re-frames after a pivot. |
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

### New Project (from zero)
```
1. /discover                     # Conversation: the problem, roles, invariants, edges
                                 # → stack recommendation + CLAUDE.md + ADR-001 + ROADMAP
                                 #   + BACKLOG + first ROUTE item
2. /setup                        # Technical config: commands, branches, hooks, limits
3. /start                        # Takes the item sitting in ROUTE.md → NOW
```

`/discover` asks about the **business**, never about technology — the stack is derived from the
answers and presented with its reasoning and what was ruled out. It writes documents only: no
code, no installs.

### New Feature on a Running Project
```
1. /discover                     # Mode B: what does it solve, what breaks, where does it queue
                                 # → BACKLOG item + ROADMAP placement + ROUTE position
                                 #   (+ a plan in .claude/plan/ only if it is large)
2. /start                        # Takes it from ROUTE → NOW
```

**Run Mode B every time a feature idea shows up** — it is the cheap way to find out that the
thing already exists, or duplicates an existing rule (R25), or should wait behind something else.
Four short rounds: what problem and for whom, what it touches and could break, where it belongs
in the ROADMAP, and what it displaces in the queue.

It never rewrites the Business Context. If the idea turns out to be bigger than a feature, it
stops and offers Mode C (re-framing) rather than quietly redefining the product.

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
├── ROUTE.md                     # THE work queue — read first (NOW / QUEUE / DONE)
├── README.md                    # Index of active sessions and status
├── BACKLOG.md                   # Full pending inventory, unordered (<300 lines target)
├── ROADMAP.md                   # Module status and progress tracking
├── FIXES.md                     # Centralized bug/fix registry
├── ENVIRONMENT.md               # Access, DB, API traps, environment gotchas
├── .pending-commits.log         # Auto-registered commits (local, gitignored)
├── tmp/                         # Active session files
│   ├── session-*.md             # Active sessions
│   └── pre-compact-snapshot.md  # State snapshot before compaction (gitignored)
├── verifications/               # Versioned evidence of manual testing rounds
├── archive/
│   ├── COMPLETED.md             # History of completed items
│   └── YYYY-QN/
│       ├── sessions/            # Archived sessions (quarter from SESSION date, R22)
│       └── SUMMARY.md           # One-line per session summary
├── auditorias/                  # Audit reports from /audit
└── consolidated/                # Per finished feature documentation
```

### ROUTE.md — the work queue

The problem it solves: BACKLOG and ROADMAP grow until reading them at the start of a session
costs more than the session itself. ROUTE stays one page.

| Section | Holds |
|---------|-------|
| `NOW` | **One** item. What is being worked on right now. |
| `QUEUE` | The rest, in order. One line each, pointing at `file:line`. |
| `IN PARALLEL` | Small items that do not consume a session (seeds, one-liners). |
| `DONE (last 5)` | Recent closures. Older ones live in `archive/COMPLETED.md`. |

| Question | File |
|----------|------|
| What do I work on next? | `ROUTE.md` → NOW |
| What is still pending overall? | `BACKLOG.md` |
| Where is the product going? | `ROADMAP.md` |

`/start` reads NOW first; `/finish` (step 6.85) moves the item to DONE, promotes the next, and
queues anything found during the session. A finding never waits to be "sorted later".

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

## Parallel Sessions (Shared Branch)

Multiple Claude instances can work on different features simultaneously by sharing a combined feature branch with atomic commits per scope.

### Problem it solves

Two terminals sharing the same directory have a single git checkout. Instead of using git worktrees (which have Docker and integration test limitations), sessions share a single feature branch with a combined name and coordinate via `state.json` and `channel.md`.

### Shared branch rule

- **1 active session**: normal feature branch, no special handling
- **2+ active sessions**: sessions share a combined feature branch (e.g., `feature/A--B`)

### How it works

**Principle**: "Serialize context, parallelize code"

When parallel mode is activated, the existing feature branch is renamed to reflect both features (e.g., `feature/egreso-backend--dashboard-frontend`). Both sessions work on that branch and coordinate via files in `{sharedBranchDirectory}/`. When the last session finishes, the branch is merged to the base branch like any feature branch.

| Phase | Lock required | Parallel |
|-------|--------------|----------|
| `/start` (write session + README) | Yes | No |
| Implement code | No | Yes |
| Run tests | No | Yes |
| `/review-code` | No | Yes |
| `/finish` (BACKLOG/ROADMAP + commit) | Yes | No |

### Coordination between sessions

```
context/.parallel/           (gitignored)
├── state.json               # Active sessions, domains, shared branch
└── channel.md               # Messages between sessions
```

**state.json** — Each session registers which modules it touches:
```json
{
  "branch": "feature/feature-A--feature-B",
  "sessions": {
    "session-001": {
      "feature": "feature-A",
      "domain": ["src/module-a/"],
      "status": "active",
      "start": "2026-03-20T10:00:00"
    },
    "session-002": {
      "feature": "feature-B",
      "domain": ["src/module-b/"],
      "status": "active",
      "start": "2026-03-20T10:05:00"
    }
  }
}
```

**channel.md** — Messages to pass context between sessions:
```markdown
### [10:30] session-002 → all
Parallel mode activated. Branch renamed to `feature/feature-A--feature-B`.
My domain: src/module-b/. Commits with scope: `feat(module-b)`.
```

### Configuration

In `project.config.json`:
```json
"parallel": {
  "enabled": true,
  "lockTimeoutSeconds": 60,
  "lockFile": "context/.context.lock",
  "sharedBranch": {
    "enabled": true,
    "directory": "context/.parallel",
    "atomicCommits": true
  }
}
```

### Lock operations

```bash
./scripts/context-lock.sh acquire "session-id" "/start"   # Acquire lock
./scripts/context-lock.sh release                          # Release lock
./scripts/context-lock.sh check                            # Check status
```

Lock auto-expires after `lockTimeoutSeconds` (default: 60s).

### Typical flow with 2 sessions

```
Terminal 1                           Terminal 2
──────────                           ──────────
/start feature-A
  → creates feature/feature-A
  → works...
                                     /start feature-B
                                       → Detects active session
                                       → Asks: "Work in parallel?"
                                       → Renames branch to feature/feature-A--feature-B
                                       → Registers BOTH sessions in state.json
                                       → Writes to channel.md
                                       → "Inform Terminal 1 of branch rename"
[user informs: branch renamed]
[implement A]                        [implement B]
  git commit files-A                   git commit files-B
  (scope: feat(feature-A))            (scope: feat(feature-B))
/review-code                         /review-code
/finish                              (wait if /finish lock)
  → final commit                     /finish
  → removes from state.json            → final commit
                                        → cleans up .parallel/ (last session)
                                        → merge feature/A--B to base branch?
```

### Rules in parallel mode

- **Both sessions registered**: `state.json` contains both sessions with their domains
- **Shared branch**: The feature branch has a combined name (e.g., `feature/A--B`)
- **Atomic commits**: `git commit <files> -m "feat(scope): ..."` (NEVER `git add .`)
- **Verify domain**: Before editing, check that the file is not in another session's domain
- **Communicate decisions**: Write to `channel.md` with format `### [HH:MM] session-XXX → all`
- **Local files**: `state.json` and `channel.md` are gitignored — NOT committed, coordination only
- **Merge at end**: The last session to finish merges the shared branch to base branch
- **Cleanup**: The last session deletes `context/.parallel/` completely
- Docker and tests work normally (same directory)

## Configuration

All project settings live in `.claude/project.config.json`:
- Project metadata (name, stack, description)
- Language preferences (code + chat)
- Commands (test, lint, dev, build, syncTypes)
- Git configuration (branch prefixes, main/dev branch, coAuthoredBy)
- Code conventions (naming, commits)
- Workflow thresholds (max file lines per type, rotation triggers, coverage, BACKLOG max lines, staleSessionThreshold, testMaxWorkers)
- Quality settings (external skills — see Quality Skills Contract)
- Parallel sessions (enabled, lock timeout, lock file path, shared branch config)
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

## Hooks — the deterministic layer (R23)

Some rules used to depend on remembering them. These run on their own, before the command does.

### Git hooks

Installed via `git config core.hooksPath scripts/hooks` (make them executable: `chmod +x scripts/hooks/*`).

| Hook | Purpose | Bypass |
|------|---------|--------|
| `pre-commit` | Protected branch (R2), lint, per-type file size (R4), TypeScript errors (R16) | `git commit --no-verify` |
| `commit-msg` | Blocks AI attribution when `git.coAuthoredBy` is false (R3) + conventional commit format | `git commit --no-verify` |
| `post-commit` | Auto-register commits in `.pending-commits.log` + Engram sync (if enabled) | N/A |
| `post-merge` | Import Engram memories after pull/merge (if enabled) | N/A |

### Claude Code hooks

Registered in `.claude/settings.json`. **Without that block they never fire** — `/setup` step 7
writes it.

| Hook | Event | Purpose |
|------|-------|---------|
| `claude-guard-main.sh` | PreToolUse (Bash) | Denies `git commit`/`git push` on the protected branch **before** it runs. Reads `git.mainBranch`. |
| `claude-guard-db.sh` | PreToolUse (Bash) | Denies destructive DB ops always; denies migrations/seeds outside Docker when `docker.enabled` is true. Covers Prisma, TypeORM, Sequelize, Knex, Alembic, Django, Rails. |
| `claude-precompact.sh` | PreCompact | Writes `context/tmp/pre-compact-snapshot.md` (branch, active sessions, uncommitted changes, recent commits) before the conversation is summarized. |
| `claude-session-context.sh` | SessionStart (`compact`) | Re-injects branch, active session, recent commits, current ROUTE item and the rules most often lost after a compaction. |

A PreToolUse hook exiting with code 2 denies the tool call and returns its stderr to Claude as
feedback. These are not warnings — the command does not run.

**Why both layers**: the git hooks catch the commit itself; the Claude Code hooks catch the intent
inside the agent loop, before anything happens.

## Persistent Memory (Engram) — optional

Off by default (`memory.engram.enabled: false`). Enable via `/setup` step 6.7.

**What it adds over `MEMORY.md`**: full-text search over past decisions, and memories that
**travel with the repo** — they export to `.engram/chunks/` (versioned), so a clone on another
machine gets them.

| Piece | Role |
|-------|------|
| `mem_save` | Record a decision, a non-obvious root cause, a domain convention |
| `mem_search` | Ask "did we already decide this?" before deciding again |
| `mem_context` | Recover context after a compaction |
| `post-commit` | Exports memories to `.engram/chunks/` |
| `post-merge` | Imports memories after a pull |
| `/finish` | Stages `.engram/` with the documentation commit |

**Requires**: the `engram` binary installed per machine, plus the MCP server registered.
Every integration point checks before running — if it is disabled or the binary is missing,
nothing happens and nobody is blocked.

**What it does not do**: replace `context/`. ROUTE, BACKLOG, ROADMAP, FIXES and the session files
are the record of the project. Engram is recall.

## Enforced Rules (26 total)

| # | Rule | Summary |
|---|------|---------|
| R1 | Language | Respond/code in configured language |
| R2 | Git Flow | main protected, branch from dev if configured |
| R3 | Commits | Co-Authored-By only if configured |
| R4 | File Size | Enforce per-type maxFileLines/maxFunctionLines — **source code only** |
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
| R21 | Parallel Sessions | Shared branch for 2+ sessions, context serialized via lock, atomic commits per scope |
| R22 | Quarter Detection | Archive by the SESSION's date, never by today's |
| R23 | Deterministic Guardrails | Hooks enforce R2/R3/R4/R16/R18 before the command runs |
| R24 | `/fast` Mode | User-only toggle; Claude suggests, never activates |
| R25 | One Business Rule, One Home | "Is this allowed?" lives in one pure function everyone imports |
| R26 | Engram (optional) | Persistent recall for decisions and non-obvious root causes |

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
| state.json corrupted | Crash during parallel session setup | Delete `context/.parallel/state.json`, proceed as normal |
| Parallel cleanup not done | `/finish` interrupted before cleanup | Delete `context/.parallel/` manually |
| File domain conflict | Two sessions editing same files | Check `state.json` domains, coordinate via `channel.md` |
| Guard hook never fires | `hooks` block missing from `.claude/settings.json`, or `git.allowCommitsOnMain` left at `true` after cloning the template | Re-run `/setup` (step 7 writes the block; git config sets the flag to `false`) |
| Guard hook blocks a legitimate command | Pattern matched too broadly (e.g. the word `main` in a path) | Run it yourself in the terminal — the guards only gate Claude's Bash calls |
| `commit-msg` rejects a valid message | Subject is not conventional format | Use `type(scope): description`, or set `conventions.commits` to something else |
| Hooks do nothing after clone | Not executable / hooksPath unset | `chmod +x scripts/hooks/*` and `git config core.hooksPath scripts/hooks` |
| ROUTE.md out of sync with reality | `/finish` interrupted before step 6.85 | Move the item to DONE and promote the next one manually |

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
| v2.5 | 2026-08-06 | Deterministic guardrails (guard-main, guard-db, commit-msg), anti context-rot hooks (PreCompact + SessionStart), `context/ROUTE.md` work queue, `ENVIRONMENT.md`, `verifications/`, R22/R23/R24, changelog moved to `CLAUDE-CHANGELOG.md` |
| v2.4 | 2026-03-20 | Replace Git Worktree with Shared Branch for parallel sessions: combined feature branch, state.json + channel.md coordination, atomic commits per scope, simplified context-lock.sh |
| v2.3 | 2026-03-13 | Git Worktree for parallel sessions: worktree creation/cleanup in /start and /finish, worktree-aware lock, config, limitations, troubleshooting |
| v2.2 | 2026-03-13 | 10 improvements from 127+ sessions: parallel sessions, per-type file limits, enhanced hooks, Docker/CPU/migrations rules, cross-section consistency, enhanced rotation |
| v2.1 | 2026-03-12 | /metrics skill, pre-commit hook, quality skills contract, stale session detection, FIXES integration, error recovery sections, troubleshooting, skill rewrites (fix-issue, deploy, explore-code) |
| v2.0 | 2026-03-12 | 17 rules, /audit, MEMORY, plans, FIXES, Context7, improved agents |
| v1.0 | 2026-02-06 | Initial release with 9 agents and 5 core skills |
