# Project [NAME]

> The workflow rules (`WF-R1…WF-R26`), the document routing table and the agent delegation live
> in `.claude/wf/reglas/REGLAS.md`: a SessionStart hook injects their index at the start of every session. Do not copy them here.
> This file holds only what belongs to this project. Its own rules start at **R27**.

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
- Dark mode support for all frontend components
- Audit fields (createdAt, updatedAt) for all database tables

## Project Rules

<!-- Rules that only apply to this project, numbered from R27 so they never collide with the
     framework's WF-R… Format:
### R27. Title
- What it requires, and why (the defect or decision that produced it)
-->

## Business Context
- **What it does**: [Brief app description]
- **Main entities**: [User, Product, etc.]
- **Critical flows**: [Registration, Checkout, etc.]

## References
- @context/ROUTE.md
- @context/README.md
- @context/BACKLOG.md
- @context/ROADMAP.md
- @context/FIXES.md
- @context/ENVIRONMENT.md
- @.claude/MEMORY.md
