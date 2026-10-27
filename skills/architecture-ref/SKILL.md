---
name: architecture-ref
description: Architecture patterns and structure reference. Load when creating endpoints, features, designing folder structure, or asking about architecture.
user-invocable: false
---

# Reference: Architecture & Patterns

> Quick reference for project architecture conventions. Auto-loaded for structural decisions.

## Step 1: Detect Project Architecture

Read `.claude/project.config.json` and scan `src/` structure to identify the pattern in use:

### Common Patterns

| Pattern | Indicators | Structure |
|---------|-----------|-----------|
| **Vertical Slicing** | Feature folders with all layers inside | `src/{domain}/{slice}/` |
| **Layered** | Separate folders per layer | `src/controllers/`, `src/services/` |
| **Feature-based** | Features grouped but layers separated inside | `src/features/{name}/` |
| **DDD** | Domain-driven with bounded contexts | `src/domain/`, `src/application/` |

### Detection Logic
```
Glob: src/**/
```

- If `src/{name}/{name}.controller.*` + `src/{name}/{name}.service.*` → **Vertical Slicing**
- If `src/controllers/` + `src/services/` + `src/models/` → **Layered**
- If `src/features/{name}/` → **Feature-based**
- If `src/domain/` + `src/application/` + `src/infrastructure/` → **DDD**

## Step 2: Apply Architectural Rules

### Vertical Slicing Structure

```
src/
├── {domain}/                     # Business domain
│   ├── {slice}/                  # One slice per use case
│   │   ├── {slice}.controller.*
│   │   ├── {slice}.service.*
│   │   ├── {slice}.dto.*
│   │   ├── {slice}.spec.*
│   │   └── anatomy.md           # Slice documentation
│   │
│   ├── domain/                   # Domain entities and contracts
│   │   ├── {entity}.entity.*
│   │   └── {entity}.repository.* # Interface
│   │
│   └── {domain}.module.*         # Domain module
│
└── shared/                       # Cross-cutting concerns
    ├── database/
    ├── guards/
    ├── decorators/
    └── utils/
```

### Layered Structure

```
src/
├── controllers/                  # HTTP layer
├── services/                     # Business logic
├── models/                       # Data models
├── middleware/                    # Request pipeline
├── utils/                        # Shared utilities
└── config/                       # Configuration
```

### Feature-based Structure (Frontend)

```
src/
├── features/                     # Business domains
│   └── {domain}/
│       ├── {slice}/
│       │   ├── {Slice}Page.*
│       │   ├── {Component}.*
│       │   ├── use{Hook}.*
│       │   ├── {slice}.schema.*
│       │   └── index.*
│       └── shared/               # Domain-shared components
│
├── shared/                       # Cross-cutting
│   ├── components/
│   ├── lib/
│   ├── hooks/
│   └── types/
│
└── app/                          # Routing / entry point
```

## Dependency Rules

```
ALLOWED:
- /{domainA}/ can import from /shared/
- /{domainA}/{slice}/ can import from /{domainA}/domain/
- /{domainA}/ can import from /{domainB}/domain/ (interfaces only)

FORBIDDEN:
- /{domainA}/ CANNOT import from /{domainB}/{slice}/ (implementation)
- Slices CANNOT import from other slices in the same domain
- /shared/ NEVER imports from domains

FLOW:
Slices → Domain → Shared
```

## File Size Limits

| Type | Max Lines | If Exceeded |
|------|-----------|-------------|
| Service/Use Case | ~100 lines | Split into sub-cases |
| Controller/Route | ~150 lines | Create sub-controllers |
| Component (UI) | ~150 lines | Extract sub-components |
| Hook/Composable | ~80 lines | Split responsibilities |
| DTO/Schema | ~50 lines | One DTO per file |
| Any file | ~400 lines | Must split (configurable in project.config.json) |

## Pattern Consistency Rule

> **ONE pattern per area.** Do not mix competing solutions.

| Area | Pick ONE | Document in |
|------|----------|-------------|
| Server state | (e.g., TanStack Query, SWR, Apollo) | `docs/architecture.md` |
| Forms | (e.g., react-hook-form, Formik, native) | `docs/architecture.md` |
| Validation | (e.g., Zod, Yup, Joi, class-validator) | `docs/architecture.md` |
| Styling | (e.g., Tailwind, CSS Modules, styled-components) | `docs/architecture.md` |
| API Client | (e.g., Axios, fetch wrapper, generated client) | `docs/architecture.md` |
| Routing | (e.g., constants file, type-safe routes) | `docs/architecture.md` |

Once chosen, **prohibit alternatives** in the same area. Document the chosen pattern and why.

## Slice Documentation (anatomy.md)

Each new feature/slice SHOULD include an `anatomy.md`:

```markdown
# Anatomy: {Slice Name}

> **Domain**: {domain name}
> **Type**: {CRUD | Process | Query | Integration}

## Purpose
{What business problem this solves}

## Data Flow
{ASCII diagram or description}

## Business Rules
{List of rules}

## File Structure
| File | Responsibility |
|------|---------------|
| `{slice}.controller.*` | HTTP handling |
| `{slice}.service.*` | Business logic |
| `{slice}.dto.*` | Input/output shapes |
| `{slice}.spec.*` | Tests |
```

## References

- Project config: `.claude/project.config.json`
- Architecture docs: `docs/architecture.md`
- MANUAL: `.claude/MANUAL.md`
