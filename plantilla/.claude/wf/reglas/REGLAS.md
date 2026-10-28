# wf — framework rules (WF-R…)

The rules of the workflowIA framework. They come with the `wf` plugin: a project never copies
them. At session start `scripts/claude-reglas.sh` injects a short index built from this file —
the `### WF-R…` heading plus the `>` line under it — and the routing table. The full text below is
read on demand.

**Editing this file**: every rule keeps its `>` line right under the heading, one sentence, under
~110 characters. That line *is* the index: the hook re-injects it on every start, resume and
compaction, so its length is paid again each time.

**Numbering**: framework rules are `WF-R1…WF-R26`. A project's own rules live in its `CLAUDE.md`
and start at `R27`, so "R25" is never ambiguous. WF-R17 (sync the MANUAL) was retired in F2: it
is a rule for whoever maintains the workflowIA, and lives in that repo's `CLAUDE.md` (as its R27).

## Document routing

| Task Type | Read First | Then Check |
|-----------|-----------|------------|
| What do I work on next? | `context/ROUTE.md` (section NOW) | `context/BACKLOG.md` |
| New feature | `context/BACKLOG.md`, `context/ROADMAP.md` | Active session |
| New feature idea, not yet framed | `/discover` (mode B) | then `/start` |
| New project, nothing framed yet | `/discover` | then `/setup` |
| Bug fix | Active session, `context/FIXES.md`, git log | `context/BACKLOG.md` |
| Code review | `context/tmp/session-*.md` | `/review-code` |
| Architecture question | `context/ROADMAP.md` | `context/consolidated/` |
| Context/status query | `context/ROUTE.md`, `context/README.md` | `context/BACKLOG.md`, `context/ROADMAP.md` |
| Environment / access / DB / API traps | `context/ENVIRONMENT.md` | `.claude/project.config.json` |
| First interaction | `.claude/project.config.json` | `context/README.md`, the wf manual |
| Audit | `/audit` | `context/auditorias/` |
| Metrics/dashboard | `/metrics` | `context/ROADMAP.md`, `context/BACKLOG.md` |
| Memory/lessons | `.claude/MEMORY.md` | Active session |
| Plan review | `.claude/plan/*.md` | `context/ROADMAP.md` |

## Rules

### WF-R1. Language
> Chat in `language.chat`, code in `language.code` (both in `.claude/project.config.json`).

- Respond in the language configured in `project.config.json → language.chat`
- Write code in the language configured in `project.config.json → language.code`

### WF-R2. Git Flow
> Never commit or push on the protected branch; branch from `git.devBranch` if set, else main.

- `main` branch is protected: never push directly
- If `git.devBranch` is configured, branch from there instead of `main`
- Always create feature/fix branches with configured prefixes

### WF-R3. Commits
> AI attribution / Co-Authored-By only when `git.coAuthoredBy` is true.

- If `true`: include `Co-Authored-By: Claude <noreply@anthropic.com>`
- If `false` (default): do NOT include any AI attribution in commits

### WF-R4. File Size Enforcement
> Source files ≤ `workflow.maxFileLines`, functions ≤ `maxFunctionLines`; docs and config exempt.

- Max file lines: read from `workflow.maxFileLines` (default: 400)
- Max function lines: read from `workflow.maxFunctionLines` (default: 50)
- If exceeded: suggest splitting before proceeding
- **Applies to source code only.** Documentation, config, data, schemas and generated files are
  exempt — a long MANUAL or migration is not technical debt, and capping it only teaches people
  to bypass the hook.

### WF-R5. Testing Coverage
> Measure coverage before and after writing tests; never report a number that was not measured.

- Target: `workflow.coverageThreshold`% (default: 80)
- **MANDATORY**: Run coverage BEFORE and AFTER writing tests, using `commands.coverage`
- Tests must exercise real code — if coverage doesn't increase, tests don't add value
- **Never report a coverage number that was not measured.** Counting files that have a test file
  next to them is not coverage — an empty test file passes that check and covers nothing. If
  `commands.coverage` is not configured, say coverage was not measured. Unmeasured is not met.

### WF-R6. No Assumptions — Verify First
> Glob + Grep before creating a file or claiming something is missing.

- Before creating any file: `Glob` + `Grep` to check it doesn't already exist
- Before claiming something is missing: search the codebase
- Use concrete sources, not inference

### WF-R7. BACKLOG Compaction
> BACKLOG stays under `workflow.backlogMaxLines`; `/finish` archives `[x]` items.

- BACKLOG must stay under `workflow.backlogMaxLines` lines (default: 300)
- On `/finish`: clean up `[x]` items, move to archive
- Report line count before/after

### WF-R8. Mandatory Agent/Skill Delegation
> Sessions, tests, feature structure, DB, frontend, audit and review go to their wf agent or skill.

| Work | Goes to |
|------|---------|
| Session management | `session-tracker` agent |
| Test creation | `test-engineer` agent |
| Feature structure | `feature-architect` agent |
| Database work | `db-analyst` agent |
| Frontend work | `frontend-integrator` agent |
| System audit | `/audit` |
| Code review | `/review-code` |

The other agents: `context-provider` (project snapshot, stale sessions — `/start` and "what's
the status?"), `code-reviewer` (standalone structured audit), `code-explorer` (codebase
navigation, `/explore-code`), `api-documenter` (API documentation audit).

### WF-R9. Plans
> Big work gets a plan in `.claude/plan/` first; never write the plan and start coding in one run.

- Implementation plans go in `.claude/plan/YYYY-MM-DD-description.md`
- Approved plan → `/start` as the first step (it loads the plan as the session objective)
- Completed plans → move to `.claude/plan/completados/`
- **A plan is written, read and corrected BEFORE any code.** Never write a plan and create the
  session in the same run — that defeats its purpose.
- `/start` step 2.8 checks size before creating anything and offers a plan when the work looks
  big (large item, no acceptance criteria, 3+ modules, new business rule, schema change).
  It asks once; the user decides. Skipping is recorded in the session file.
- Small work needs no plan. A plan for something that fits in one session is overhead.

### WF-R10. Fix Workflows
> Quick fix (1-2 files) direct; complex fix through `/start`; every fix logged in FIXES.md.

- **Quick fix** (1-2 files, clear cause): fix → test → commit directly
- **Complex fix** (multi-file, unclear cause): use `/start fix-description` with debugging protocol
- **Batch fix** (multiple small related fixes): group → fix all → single commit
- Track all fixes in `context/FIXES.md`

### WF-R11. No Premature Action
> Read before writing, understand before changing, ask when requirements are unclear.

- **Read before writing**: Always read a file before editing it
- **Understand before changing**: Understand the context of the code you are modifying
- **Ask before assuming**: If requirements are unclear, ask the user

### WF-R12. Debugging Protocol
> Before fixing a bug: three hypotheses, each checked against evidence.

1. Formulate **at least 3 hypotheses** about the root cause
2. Validate each hypothesis with evidence (logs, tests, code reading)
3. Only then propose a fix targeting the confirmed root cause

### WF-R13. Session Discipline
> Every `/start` opens a session, every `/finish` closes it; no orphan sessions.

- Every `/start` creates a session; every `/finish` closes it
- Never leave orphan sessions (IN_PROGRESS without active work)
- Document decisions and progress in the session file

### WF-R14. Zero Inference
> Back every claim with a concrete source: file, grep, git log, test output.

- Use concrete sources: file reads, grep results, git log, test output
- Never say "this probably..." without evidence
- If unsure, verify before stating

### WF-R15. Quality Skills for Frontend
> Frontend changes consult the skills in `quality.externalSkills`; review and finish check it.

- If `quality.externalSkills` are configured and changes involve frontend:
  - Consult them during development
  - `/review-code` checks if they were invoked
  - `/finish` warns if they were skipped
- The expected output of a quality skill: `.claude/wf/docs/QUALITY-SKILLS-CONTRACT.md`.

### WF-R16. LSP Diagnostics Block Development
> Type errors are blockers: fix them before writing new code.

- If TypeScript LSP reports errors: fix them before proceeding with new code
- Type errors are blockers, not warnings

### WF-R18. Docker Environment
> If the DB runs in Docker, migrations and seeds run inside the container, non-interactive.

- Run all DB commands (migrations, seeds, queries) inside the container
- Use non-interactive mode for migrations (no TTY): `docker exec` without `-it`
- Never run `prisma migrate dev` or equivalent directly on host if DB is in Docker

### WF-R19. CPU Limiting in Tests
> Test runners use at most `workflow.testMaxWorkers` workers (default 2).

- Jest: `--maxWorkers={testMaxWorkers}`
- Vitest: `--maxForks={testMaxWorkers}` or `--poolOptions.forks.maxForks={testMaxWorkers}`
- Prevents CPU saturation on development machines

### WF-R20. Database Migrations Protocol
> Migrations: generate the diff, review the SQL, apply with the deploy command; never interactive.

For projects using ORMs (Prisma, TypeORM, etc.) with Docker:
1. Generate migration diff (e.g., `prisma migrate diff`)
2. Review the generated SQL manually
3. Apply with deploy command (e.g., `prisma migrate deploy`)
4. Never use interactive migration commands in CI/hooks

### WF-R21. Parallel Sessions (Shared Branch)
> 2+ sessions share one branch: context writes under `context-lock`, atomic commits, never `git add .`.

- **1 active session**: normal feature branch, no special handling
- **2+ active sessions**: sessions share a combined feature branch (e.g., `feature/A--B`)
- Context writes (README, BACKLOG, ROADMAP) are serialized via `.claude/wf/bin/context-lock`. Lock timeout: `parallel.lockTimeoutSeconds` (default: 60s)
- Code work is 100% parallelizable (no lock needed for coding)
- Coordination via `{parallel.sharedBranch.directory}/state.json` + `channel.md` (gitignored)
- Each session commits only its own files with atomic commits (`git commit <files> -m "..."`)
- **NEVER** use `git add .` or `git add -A` in parallel mode
- Verify file domain in `state.json` before editing (avoid stepping on other session's files)
- On `/finish`: last session cleans up coordination directory and optionally merges to base branch

### WF-R22. Quarter Detection for Session Archiving
> Archive a session under the quarter of its own `Date` field, never today's.

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

### WF-R23. Deterministic Guardrails
> Some rules are enforced by hooks; if one blocks a command, the rule applies — do not work around it.

| Hook | Type | Enforces |
|------|------|----------|
| `claude-guard-main.sh` | PreToolUse (Bash) | WF-R2 — no commit/push on the protected branch |
| `claude-guard-db.sh` | PreToolUse (Bash) | WF-R18 — no destructive DB ops, no migrations outside Docker |
| `claude-verdad-al-escribir.sh` | PostToolUse (Write/Edit) | WF-R25 — warns when a write copies a business truth |
| `commit-msg` | git hook | WF-R3 — no AI attribution + commit format |
| `pre-commit` | git hook | WF-R2, WF-R4, WF-R16, WF-R25 — protected branch, file size, type errors, one truth |
| `claude-precompact.sh` | PreCompact | Snapshot of working state before context is summarized |
| `claude-reglas.sh` | SessionStart | Injects this rule index |
| `claude-session-context.sh` | SessionStart (compact) | Re-injects branch, active session, critical rules |

The Claude Code hooks live in `.claude/wf/scripts/` and are declared in `.claude/settings.json`. The git hooks
live in the project's `scripts/hooks/`, enabled per clone with `git config core.hooksPath scripts/hooks`.
Emergency bypass for git hooks only: `git commit --no-verify`.

### WF-R24. `/fast` Mode
> `/fast` is a user-only toggle: suggest it when speed matters, never try to enable it.

### WF-R25. One Business Rule, One Home
> "Is this allowed?" is answered by one pure domain function that every caller imports.

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

**This rule is verified, not remembered.** In the project this came from, the rule was in
CLAUDE.md from day one and a delivery still added the fourth and fifth copy of the same list — in
the delivery whose whole promise was that rule. `scripts/hooks/check-una-sola-verdad.sh` blocks
the commit when a line enumerates two or more values of the same business truth outside its home.
It reads the values from the project's own authority (Prisma schema, TS union, SQL enum, Python
enum), so a new value enters its scope on its own. It comes **on by default**: with no
`truth.authority` declared it looks for a `schema.prisma` on its own. If it finds nothing to read
it says so loudly on every commit instead of passing green. Tune it (or switch it off) in the
`truth` block of `.claude/project.config.json` — see `./scripts/hooks/check-una-sola-verdad.sh --config`.

### WF-R26. Engram — Persistent Memory (Optional Complement)
> Only with `memory.engram.enabled`: save non-obvious decisions and causes; it complements `context/`.

**When to save** (`mem_save`): architecture decisions and why the alternatives were rejected; bugs
whose root cause was not obvious (the symptom lied); reusable patterns; domain conventions learned
from the client/business.

**When to search** (`mem_search`): before a design decision (was it already decided?); when a bug
smells like one seen before; to recover context after a compaction (`mem_context`).

**Does NOT replace**: sessions in `context/`, ROUTE, BACKLOG, ROADMAP, FIXES, or the
`/start → /review-code → /finish` workflow. Those are the record; Engram is recall.

**Sync**: `post-commit` exports to `.engram/chunks/` (versioned, travels with the repo),
`post-merge` imports after a pull, and `/finish` stages `.engram/`. All no-ops when disabled or
when the binary is missing — a teammate without Engram installed is never blocked.
