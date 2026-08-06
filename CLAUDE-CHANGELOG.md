# CLAUDE.md — Framework Changelog

> Change history of the workflowIA development framework.
> Kept **outside CLAUDE.md** so it does not consume context on every session
> (context engineering: "smallest set of high-signal tokens").

### v2.5 — 2026-08-06

Adapted from the battle-tested harness of a downstream project (200+ sessions).

- **Deterministic guardrails (R23)**: rules that used to depend on remembering now run as hooks.
  - `claude-guard-main.sh` (PreToolUse): blocks `git commit`/`git push` on the protected branch
    before the command executes. Reads `git.mainBranch` from config.
  - `claude-guard-db.sh` (PreToolUse): blocks destructive DB operations always; blocks
    migrations/seeds outside Docker when `docker.enabled` is true. Covers Prisma, TypeORM,
    Sequelize, Knex, Alembic, Django and Rails entrypoints.
  - `commit-msg` (git hook): blocks AI attribution when `git.coAuthoredBy` is false, and enforces
    conventional commit format when `conventions.commits` is `conventional`.
  - `pre-commit`: gained the protected-branch guard. Two bugs fixed while testing it: a missing
    lint setup no longer blocks every commit (only real lint failures do, and the output is now
    shown instead of discarded), and the R4 size limit no longer applies to documentation,
    config, data, schemas or generated files — only to source code.
- **Anti context-rot**: `claude-precompact.sh` (PreCompact) writes a state snapshot before the
  conversation is summarized; `claude-session-context.sh` (SessionStart/compact) re-injects
  branch, active session, recent commits, the current ROUTE item and the rules most often lost.
- **`context/ROUTE.md`**: single work queue — NOW (one item), QUEUE, IN PARALLEL, DONE (last 5).
  Read first by `/start`, maintained by `/finish` (new step 6.85). BACKLOG stays the unordered
  inventory; ROADMAP stays the macro picture.
- **`context/ENVIRONMENT.md`**: access, DB, API traps and environment gotchas — anything looked
  up twice.
- **`context/verifications/`**: versioned evidence of manual testing rounds, with stable finding
  IDs that feed ROUTE.
- **R22 quarter detection**: archive by the session's own date, never by today's.
- **R24 `/fast` mode**: user-only toggle; Claude suggests, never activates.
- **R25 one business rule, one home**: "is this allowed?" lives in a single pure function every
  consumer imports — the orchestrator, the endpoint and the view builder included. Enforced at
  two points: `/review-code` step 2.6.5 (cheapest — the diff is right there) and `/audit` module
  G step 4 (grep the *condition*, not the identifier). No script: semantic duplication cannot be
  detected reliably in a stack-agnostic template.
- **R26 Engram (optional, off by default)**: persistent recall via MCP. `post-commit` exports to
  versioned `.engram/chunks/`, `post-merge` imports, `claude-precompact.sh` exports before a
  compaction, `/finish` stages it. Every integration point is a no-op when disabled or when the
  binary is missing.
- **`/discover` skill**, three modes:
  - **Mode A** (new project, before `/setup`): five rounds — what breaks today, who touches it,
    the invariants, the edges, the scope — and the stack is **derived** from the answers rather
    than asked for, with the ruled-out alternatives stated. Writes CLAUDE.md business context,
    `docs/adr/001-stack.md`, ROADMAP, BACKLOG and the first ROUTE item.
  - **Mode B** (running project, any new feature idea — the one meant to be run often): four
    short rounds — what it solves and for whom, what it touches and could break (including the
    R25 duplicate-rule check), where it belongs, what it displaces. Produces BACKLOG items,
    ROADMAP placement and a ROUTE position; a plan only when the item is large. Never rewrites
    the Business Context.
  - **Mode C** (the product itself changed): re-frames with prior answers pre-loaded.
  Kept separate from `/setup` so product thinking does not drag technical configuration along.
- **`git.allowCommitsOnMain`** (default `false`): escape hatch for repos whose main branch *is*
  the working branch — this template itself. Honoured by `claude-guard-main.sh` and `pre-commit`.
  `/setup` forces it to `false` on derived projects.
- **`/start` step 2.8 — size check before anything is created**: previously nothing in the flow
  asked whether a big piece of work deserved a plan; going straight to `/start` skipped the
  question entirely. Now it first looks for an existing plan (loads it as the session objective —
  the R9 path), and otherwise checks six size signals (large item, no acceptance criteria, 3+
  modules, new business rule, schema change, existing code to extend). It reports *which* signals
  fired and offers: write the plan and stop, split the item and stop, or continue. Continuing is
  recorded in the session file so review and finish know the scope was accepted as-is. It runs
  before the branch and session exist, so backing out costs nothing.
- **`/finish` step 10.5 — close the plan, do not just file it away**: it used to find the plan by
  globbing the feature name and offer to move the file, without ever opening it. Now the session
  file's `Plan` field is the authority (glob only as fallback for older sessions), and closing
  means reading the plan, comparing each step against what actually shipped, reporting done /
  changed / pending, and **moving anything pending to BACKLOG before archiving** — a plan step
  that vanishes with the plan file is exactly what this step exists to prevent.
- **Session file gained `Date` and `Plan` fields.** `Date` is what R22 greps to pick the archive
  quarter — the template did not have it, so that check had nothing to read.
- **`/review-code` and `/audit` — eight defects found by auditing the auditors:**
  - `/review-code` could not read the diff at all: its `allowed-tools` had no Bash, yet step 1
    starts with `git diff`. Added `Bash(git:*)`.
  - It diffed `HEAD~5`, a hardcoded commit count — reviewing strangers' commits on short
    sessions, missing work on long ones, and failing outright on repos with fewer than five
    commits. Now it diffs `{base}...HEAD` (the branch's own change set), with stated fallbacks.
  - Both skills read `workflow.maxFileLines` as a number when it has been an object keyed by
    file type — the same defect fixed in `pre-commit`, still live in these two.
  - `/audit` module E reported a coverage **percentage** derived from counting test files that
    exist. An empty test file counted as covered. It now runs a real coverage command
    (`commands.coverage`, new in config) and reports test-file presence separately, explicitly
    not as coverage. Unmeasured is SKIP, never PASS.
  - `/audit` module A truncated `tsc` output to 50 lines and then counted errors, reporting a
    fraction of the real number. It now counts over the full output and labels the sample.
  - Findings evaporated. `/review-code` step 4 (new) routes every issue to FIXES, BACKLOG or
    ROUTE before the verdict — which is what makes CONDITIONAL mean "tracked" and not "forgotten".
  - `/audit` had no memory: the fifth run repeated the first run's findings with no way to see
    what moved. New step 0.5 reads the previous report and classifies every finding NEW /
    PERSISTS (with first-seen date) / RESOLVED, and skips re-writing what is already tracked.
  - `/audit` routed everything to BACKLOG, including unprotected endpoints. Security defects and
    behaviour bugs now go to FIXES with severity; tech debt goes to BACKLOG.
- **Context engineering**: this changelog moved out of `CLAUDE.md`.
- **Config**: new `docker` section (`enabled`, `dbContainer`) and `memory.engram` section.
- **`context/.pending-commits.log` is no longer versioned.** It is a local buffer between the
  `post-commit` hook and `/finish`, not a record — versioning an append-only file guarantees a
  merge conflict on every branch merge, and worse under parallel sessions. The permanent record
  already lives in the archived sessions and `archive/COMPLETED.md`.

### v2.4 — 2026-03-20
Replace Git Worktree with Shared Branch for parallel sessions: combined feature branch
(`feature/A--B`), `state.json` + `channel.md` coordination, atomic commits per scope,
simplified `context-lock.sh`.

### v2.3 — 2026-03-13
Git Worktree support for parallel sessions: worktree creation/cleanup in `/start` and `/finish`,
worktree-aware lock script, config and documentation.

### v2.2 — 2026-03-13
10 improvements from 127+ sessions: parallel sessions, per-type file limits, enhanced hooks,
Docker/CPU/migrations rules, cross-section consistency, enhanced rotation.

### v2.1 — 2026-03-12
9 improvements: `/metrics`, pre-commit hook, quality skills contract, stale detection, FIXES
integration, error recovery, troubleshooting, skill rewrites.

### v2.0 — 2026-03-12
Backport from 124+ sessions: 17 rules, `/audit` skill, MEMORY, plans, FIXES, improved agents.

### v1.0 — 2026-02-06
Initial template from 45+ sessions.
