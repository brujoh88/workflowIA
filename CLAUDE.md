# Project [NAME]

## Architecture
- Stack: [Backend/Frontend/DB]
- Folder structure:
  - `src/` - Main source code
  - `src/api/` - API endpoints
  - `src/database/` - Models and migrations
  - `src/services/` - Business logic
  - `tests/` - Unit and integration tests

## Development Commands
- `npm run dev` - Local server
- `npm test` - Tests
- `npm run build` - Production build
- `npm run lint` - Check code style
- `npm run migrate` - Run DB migrations

## Code Conventions
- **Files**: kebab-case (`user-service.ts`)
- **Classes**: PascalCase (`UserService`)
- **Functions/variables**: camelCase (`getUserById`)
- **Constants**: UPPER_SNAKE_CASE (`MAX_RETRIES`)
- **Commits**: Conventional Commits (`feat(auth): add login endpoint`)

## Document Routing Table

Read these documents based on task type:

| Task Type | Read First | Then Check |
|-----------|-----------|------------|
| New feature | `context/BACKLOG.md`, `context/ROADMAP.md` | Active session, `MANUAL.md` |
| Bug fix | Active session, `context/FIXES.md`, git log | `context/BACKLOG.md` |
| Code review | `context/tmp/session-*.md` | `MANUAL.md` (review checklist) |
| Architecture question | `context/ROADMAP.md` | `context/consolidated/` |
| What do I work on next? | `context/ROUTE.md` (section NOW) | `context/BACKLOG.md` |
| Context/status query | `context/ROUTE.md`, `context/README.md` | `context/BACKLOG.md`, `context/ROADMAP.md` |
| Environment / access / DB / API traps | `context/ENVIRONMENT.md` | `.claude/project.config.json` |
| First interaction | `.claude/project.config.json` | `context/README.md`, `MANUAL.md` |
| New project, nothing framed yet | `/discover` skill | then `/setup` |
| Fix (quick) | `context/FIXES.md` | Related source files |
| Audit | `.claude/skills/audit/SKILL.md` | `context/auditorias/` |
| Metrics/dashboard | `/metrics` skill | `context/ROADMAP.md`, `context/BACKLOG.md` |
| Memory/lessons | `.claude/MEMORY.md` | Active session |
| Plan review | `.claude/plan/*.md` | `context/ROADMAP.md` |

## Enforced Rules

### R1. Language
- Respond in the language configured in `project.config.json → language.chat`
- Write code in the language configured in `project.config.json → language.code`

### R2. Git Flow
- `main` branch is protected: never push directly
- If `git.devBranch` is configured, branch from there instead of `main`
- Always create feature/fix branches with configured prefixes

### R3. Commits
- Check `git.coAuthoredBy` in config:
  - If `true`: include `Co-Authored-By: Claude <noreply@anthropic.com>`
  - If `false` (default): do NOT include any AI attribution in commits

### R4. File Size Enforcement
- Max file lines: read from `workflow.maxFileLines` (default: 400)
- Max function lines: read from `workflow.maxFunctionLines` (default: 50)
- If exceeded: suggest splitting before proceeding
- **Applies to source code only.** Documentation, config, data, schemas and generated files are
  exempt — a long MANUAL or migration is not technical debt, and capping it only teaches people
  to bypass the hook.

### R5. Testing Coverage
- Target: `workflow.coverageThreshold`% (default: 80)
- **MANDATORY**: Run coverage BEFORE and AFTER writing tests, using `commands.coverage`
- Tests must exercise real code — if coverage doesn't increase, tests don't add value
- **Never report a coverage number that was not measured.** Counting files that have a test file
  next to them is not coverage — an empty test file passes that check and covers nothing. If
  `commands.coverage` is not configured, say coverage was not measured. Unmeasured is not met.

### R6. No Assumptions — Verify First
- Before creating any file: `Glob` + `Grep` to check it doesn't already exist
- Before claiming something is missing: search the codebase
- Use concrete sources, not inference

### R7. BACKLOG Compaction
- BACKLOG must stay under `workflow.backlogMaxLines` lines (default: 300)
- On `/finish`: clean up `[x]` items, move to archive
- Report line count before/after

### R8. Mandatory Agent/Skill Delegation
- For session management → session-tracker agent
- For test creation → test-engineer agent
- For feature structure → feature-architect agent
- For database work → db-analyst agent
- For frontend work → frontend-integrator agent
- For system audit → `/audit` skill
- For code review → `/review-code` skill

### R9. Plans
- Implementation plans go in `.claude/plan/YYYY-MM-DD-description.md`
- Approved plan → `/start` as the first step (it loads the plan as the session objective)
- Completed plans → move to `.claude/plan/completados/`
- **A plan is written, read and corrected BEFORE any code.** Never write a plan and create the
  session in the same run — that defeats its purpose.
- `/start` step 2.8 checks size before creating anything and offers a plan when the work looks
  big (large item, no acceptance criteria, 3+ modules, new business rule, schema change).
  It asks once; the user decides. Skipping is recorded in the session file.
- Small work needs no plan. A plan for something that fits in one session is overhead.

### R10. Fix Workflows
- **Quick fix** (1-2 files, clear cause): fix → test → commit directly
- **Complex fix** (multi-file, unclear cause): use `/start fix-description` with debugging protocol
- **Batch fix** (multiple small related fixes): group → fix all → single commit
- Track all fixes in `context/FIXES.md`

### R11. No Premature Action
- **Read before writing**: Always read a file before editing it
- **Understand before changing**: Understand the context of the code you are modifying
- **Ask before assuming**: If requirements are unclear, ask the user

### R12. Debugging Protocol
Before modifying code to fix a bug:
1. Formulate **at least 3 hypotheses** about the root cause
2. Validate each hypothesis with evidence (logs, tests, code reading)
3. Only then propose a fix targeting the confirmed root cause

### R13. Session Discipline
- Every `/start` creates a session; every `/finish` closes it
- Never leave orphan sessions (IN_PROGRESS without active work)
- Document decisions and progress in the session file

### R14. Zero Inference
- Use concrete sources: file reads, grep results, git log, test output
- Never say "this probably..." without evidence
- If unsure, verify before stating

### R15. Quality Skills for Frontend
- If `quality.externalSkills` are configured and changes involve frontend:
  - Consult them during development
  - `/review-code` checks if they were invoked
  - `/finish` warns if they were skipped

### R16. LSP Diagnostics Block Development
- If TypeScript LSP reports errors: fix them before proceeding with new code
- Type errors are blockers, not warnings

### R17. Sync MANUAL on .claude/ Changes
- When modifying any file in `.claude/` (skills, agents, config):
  - Update `.claude/MANUAL.md` to reflect the change
  - Keep the MANUAL as the single source of truth for framework usage

### R18. Docker Environment
- If the project uses Docker for databases/services:
  - Run all DB commands (migrations, seeds, queries) inside the container
  - Use non-interactive mode for migrations (no TTY): `docker exec` without `-it`
  - Never run `prisma migrate dev` or equivalent directly on host if DB is in Docker

### R19. CPU Limiting in Tests
- Limit test runner workers to `workflow.testMaxWorkers` (default: 2)
- Prevents CPU saturation on development machines
- Jest: `--maxWorkers={testMaxWorkers}`
- Vitest: `--maxForks={testMaxWorkers}` or `--poolOptions.forks.maxForks={testMaxWorkers}`

### R20. Database Migrations Protocol
- For projects using ORMs (Prisma, TypeORM, etc.) with Docker:
  1. Generate migration diff (e.g., `prisma migrate diff`)
  2. Review the generated SQL manually
  3. Apply with deploy command (e.g., `prisma migrate deploy`)
  4. Never use interactive migration commands in CI/hooks

### R21. Parallel Sessions (Shared Branch)
- **1 active session**: normal feature branch, no special handling
- **2+ active sessions**: sessions share a combined feature branch (e.g., `feature/A--B`)
- Context writes (README, BACKLOG, ROADMAP) are serialized via `scripts/context-lock.sh`
- Code work is 100% parallelizable (no lock needed for coding)
- Lock timeout: `parallel.lockTimeoutSeconds` (default: 60s)
- Coordination via `{parallel.sharedBranch.directory}/state.json` + `channel.md` (gitignored)
- Each session commits only its own files with atomic commits (`git commit <files> -m "..."`)
- **NEVER** use `git add .` or `git add -A` in parallel mode
- Verify file domain in `state.json` before editing (avoid stepping on other session's files)
- On `/finish`: last session cleans up coordination directory and optionally merges to base branch

### R22. Quarter Detection for Session Archiving
When archiving sessions on `/finish`, ALWAYS derive the quarter from the **session's own date**
(the `Date` field inside the `.md`), NOT from today's date.

| Quarter | Months | Folder |
|---------|--------|--------|
| Q1 | Jan, Feb, Mar | `archive/{year}-Q1/sessions/` |
| Q2 | Apr, May, Jun | `archive/{year}-Q2/sessions/` |
| Q3 | Jul, Aug, Sep | `archive/{year}-Q3/sessions/` |
| Q4 | Oct, Nov, Dec | `archive/{year}-Q4/sessions/` |

Mandatory check before moving a file:
```bash
grep -m1 "^\*\*Date\*\*:" context/tmp/session-XXX-*.md
# month 1-3 → Q1, 4-6 → Q2, 7-9 → Q3, 10-12 → Q4
```
If the quarter folder does not exist, create it with its `SUMMARY.md`.
**NEVER** file an April-June session under Q1, or a July-September one under Q2.

### R23. Deterministic Guardrails
Some rules are enforced by hooks, not by memory. They run before the command does and cannot be
talked out of it. Do not work around them — if one fires, the rule applies.

| Hook | Type | Enforces |
|------|------|----------|
| `claude-guard-main.sh` | PreToolUse (Bash) | R2 — no commit/push on the protected branch |
| `claude-guard-db.sh` | PreToolUse (Bash) | R18 — no destructive DB ops, no migrations outside Docker |
| `commit-msg` | git hook | R3 — no AI attribution + commit format |
| `pre-commit` | git hook | R2, R4, R16 — protected branch, file size, type errors |
| `claude-precompact.sh` | PreCompact | Snapshot of working state before context is summarized |
| `claude-session-context.sh` | SessionStart (compact) | Re-injects branch, active session, critical rules |

Registered in `.claude/settings.json` (Claude Code hooks) and via
`git config core.hooksPath scripts/hooks` (git hooks).
Emergency bypass for git hooks only: `git commit --no-verify`.

### R24. `/fast` Mode
`/fast` is a toggle the **user** turns on and off manually — Claude cannot activate it.
When output speed matters, suggest it; do not attempt to enable it.

### R25. One Business Rule, One Home
**CRITICAL**: a business rule is written **once** and everyone who needs it imports it.

Two questions that look alike but are not:

| Question | Where it lives | Shape |
|----------|---------------|-------|
| **"What comes next?"** | The orchestrator — whatever decides the next step or builds the screen state | Reads state, calls the rule |
| **"Is this allowed?"** | A **pure function** in the domain layer | No DB, no HTTP, no framework. Input → yes/no + reason |

Hard rules:
- No endpoint validates on its own what a domain function already answers. If it needs the
  answer, it **imports the function** — it does not reimplement it.
- The orchestrator is a consumer too, not the owner. It does not keep its own copy of the gate.
- Two orchestrators answering **different** questions is healthy. The bug is **two places
  answering the same one**.
- The frontend never recalculates a fact the backend can expose. If the UI needs to know "this is
  blocked" or "this is finished", the backend sends it as data — not as a list of states the
  frontend copies.

**Why it matters** (the defect that produced this rule): the screen showed the action button
enabled and the POST answered 400. Two authorities answered "is this allowed?" — the orchestrator
that built the screen, and the endpoint that validated on its own. One had drifted. The user saw
a button that lied. Fix: extract the gate as a pure function; all three callers import it.

**When you find a duplicated rule**: extract it to the domain layer as a pure function with its
spec, and make **every** consumer import it. Fixing only the divergent copy is not enough.

### R26. Engram — Persistent Memory (Optional Complement)
Active only when `memory.engram.enabled` is true. It **complements** `context/` — it does not
replace it.

**When to save** (`mem_save`):
- Architecture decisions and why the alternatives were rejected
- Bugs whose root cause was not obvious (the symptom lied)
- Reusable patterns discovered
- Domain conventions learned from the client/business

**When to search** (`mem_search`):
- Before a design decision — check whether it was already decided
- When a bug smells like one seen before
- To recover context after a compaction (`mem_context`)

**Does NOT replace**: sessions in `context/`, ROUTE, BACKLOG, ROADMAP, FIXES, or the
`/start → /review-code → /finish` workflow. Those are the record; Engram is recall.

**Sync**: `post-commit` exports to `.engram/chunks/` (versioned, travels with the repo),
`post-merge` imports after a pull, and `/finish` stages `.engram/`. All no-ops when disabled or
when the binary is missing — a teammate without Engram installed is never blocked.

## Task Delegation

| Agent | Specialty | When to Use |
|-------|-----------|-------------|
| **session-tracker** | Session lifecycle, commit tracking, rotation, FIXES sync | `/start`, `/finish` |
| **context-provider** | Project snapshot (quick/deep), stale session detection | `/start` (auto), "what's the status?" |
| **feature-architect** | Feature structure, anatomy docs, size limits | `/start` (new features) |
| **code-reviewer** | Standalone structured audit with verdicts | Direct delegation |
| **code-explorer** | Interactive codebase navigation and understanding | `/explore-code`, direct |
| **test-engineer** | Test creation with coverage BEFORE/AFTER protocol | `/finish` (auto), direct |
| **db-analyst** | Schema design, migrations, queries, indexes | Direct delegation |
| **api-documenter** | API documentation completeness audit | Direct delegation |
| **frontend-integrator** | Component scaffolding, a11y, dark mode | Direct delegation |

## Required Patterns
- Input validation in controllers
- Business logic in services, not controllers
- Error handling with try/catch and logging
- Tests for critical functionality
- Dark mode support for all frontend components
- Audit fields (createdAt, updatedAt) for all database tables

## Business Context
- **What it does**: [Brief app description]
- **Main entities**: [User, Product, etc.]
- **Critical flows**: [Registration, Checkout, etc.]

### Project Context
See `context/README.md` for:
- Active sessions
- Pending BACKLOG
- Completed features history

## References
- @context/ROUTE.md
- @context/README.md
- @context/BACKLOG.md
- @context/ROADMAP.md
- @context/FIXES.md
- @context/ENVIRONMENT.md
- @.claude/MANUAL.md
- @.claude/MEMORY.md
- @.claude/docs/QUALITY-SKILLS-CONTRACT.md

## Changelog

Lives in [CLAUDE-CHANGELOG.md](CLAUDE-CHANGELOG.md) — kept outside this file so it does not
consume context on every session (context engineering: smallest set of high-signal tokens).
