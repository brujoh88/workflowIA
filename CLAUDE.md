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

## Tracking System

### Development Workflow
```
/start <feature>    # Creates branch + session + updates BACKLOG
  ... development ...
/finish             # Tests + commit + closes session
```

### Task Delegation
- **session-tracker**: Session management and tracking
- **db-analyst**: Database analysis and design
- **code-explorer**: Code exploration and understanding
- **code-reviewer**: Code review and improvements

### Project Context
See `context/README.md` for:
- Active sessions
- Pending BACKLOG
- Completed features history

## References
- @context/README.md
- @context/BACKLOG.md
- @docs/architecture.md
- @src/api/README.md
