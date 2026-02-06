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

## Required Patterns
- Input validation in controllers
- Business logic in services, not controllers
- Error handling with try/catch and logging
- Tests for critical functionality

## Business Context
- **What it does**: [Brief app description]
- **Main entities**: [User, Product, etc.]
- **Critical flows**: [Registration, Checkout, etc.]

## Document Routing Table

Read these documents based on task type:

| Task Type | Read First | Then Check |
|-----------|-----------|------------|
| New feature | `context/BACKLOG.md`, `context/ROADMAP.md` | Active session, `MANUAL.md` |
| Bug fix | Active session, git log | `context/BACKLOG.md` |
| Code review | `context/tmp/session-*.md` | `MANUAL.md` (review checklist) |
| Architecture question | `docs/architecture.md`, `context/ROADMAP.md` | `context/consolidated/` |
| Context/status query | `context/README.md`, `context/BACKLOG.md` | `context/ROADMAP.md` |
| First interaction | `.claude/project.config.json` | `context/README.md`, `MANUAL.md` |

## Enforced Rules

### Debugging Protocol
Before modifying code to fix a bug:
1. Formulate **at least 3 hypotheses** about the root cause
2. Validate each hypothesis with evidence (logs, tests, code reading)
3. Only then propose a fix targeting the confirmed root cause

### No Premature Action
- **Read before writing**: Always read a file before editing it
- **Understand before changing**: Understand the context of the code you are modifying
- **Ask before assuming**: If requirements are unclear, ask the user

### Session Discipline
- Every `/start` creates a session; every `/finish` closes it
- Never leave orphan sessions (IN_PROGRESS without active work)
- Document decisions and progress in the session file

### Code Size Limits
- **Max file length**: ~400 lines (suggest splitting if exceeded)
- **Max function length**: ~50 lines (suggest extraction if exceeded)
- These are guidelines configurable in `project.config.json`

## Tracking System

### Development Workflow
```
/start <feature>    # Creates branch + session + loads context + updates BACKLOG
  ... development ...
/finish             # Tests + commit + closes session + updates ROADMAP
```

### Task Delegation

| Agent | Specialty | When to Use |
|-------|-----------|-------------|
| **session-tracker** | Session management and tracking | Creating, updating, closing sessions |
| **db-analyst** | Database analysis and design | Schema design, queries, migrations |
| **code-explorer** | Code exploration and understanding | Understanding codebase, finding patterns |
| **code-reviewer** | Structured code review | Pre-merge reviews, quality audits |
| **context-provider** | Project snapshot and status | Quick context loading, status queries |
| **feature-architect** | Feature structure planning | New feature scaffolding, architecture |
| **test-engineer** | Test creation and coverage | Writing tests, coverage analysis |
| **api-documenter** | API documentation auditing | Endpoint docs, completeness checks |
| **frontend-integrator** | Frontend component scaffolding | UI components, accessibility |

### Project Context
See `context/README.md` for:
- Active sessions
- Pending BACKLOG
- Completed features history

## References
- @context/README.md
- @context/BACKLOG.md
- @context/ROADMAP.md
- @docs/architecture.md
- @src/api/README.md
- @.claude/MANUAL.md
