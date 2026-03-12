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
| Context/status query | `context/README.md`, `context/BACKLOG.md` | `context/ROADMAP.md` |
| First interaction | `.claude/project.config.json` | `context/README.md`, `MANUAL.md` |
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

### R5. Testing Coverage
- Target: `workflow.coverageThreshold`% (default: 80)
- **MANDATORY**: Run coverage BEFORE and AFTER writing tests
- Tests must exercise real code — if coverage doesn't increase, tests don't add value

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
- Approved plan → `/start` as the first step
- Completed plans → move to `.claude/plan/completados/`

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
- @context/README.md
- @context/BACKLOG.md
- @context/ROADMAP.md
- @context/FIXES.md
- @.claude/MANUAL.md
- @.claude/MEMORY.md
- @.claude/docs/QUALITY-SKILLS-CONTRACT.md

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| v2.1 | 2026-03-12 | 9 improvements: /metrics, pre-commit hook, quality skills contract, stale detection, FIXES integration, error recovery, troubleshooting, skill rewrites |
| v2.0 | 2026-03-12 | Backport from 124+ sessions: 17 rules, /audit skill, MEMORY, plans, FIXES, improved agents |
| v1.0 | 2026-02-06 | Initial template from 45+ sessions |
