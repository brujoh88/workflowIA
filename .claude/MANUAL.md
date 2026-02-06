# WorkflowIA - User Manual

Guide for using the workflowIA development framework.

## Skills (Slash Commands)

| Skill | Trigger | Description |
|-------|---------|-------------|
| `/setup` | First-time configuration | Interactive wizard to configure project |
| `/start <feature>` | Begin new work | Creates branch + session + loads context |
| `/finish` | End current work | Tests + commit + archive + update tracking |
| `/review-code` | Pre-merge review | Multi-category structured code audit |
| `/explore-code` | Understand codebase | Navigate and understand code structure |
| `/fix-issue` | Bug fix workflow | Guided debugging and fix process |
| `/deploy` | Deployment workflow | Build, verify, and deploy |
| `/mcp` | MCP server management | Search, install, configure MCP servers |

## Agents

| Agent | Specialty | Invoked Via |
|-------|-----------|-------------|
| `session-tracker` | Session lifecycle management | `/start`, `/finish` |
| `db-analyst` | Database design, queries, migrations | Direct delegation |
| `code-explorer` | Codebase navigation and understanding | `/explore-code` |
| `code-reviewer` | Structured multi-category review | `/review-code` |
| `context-provider` | Project snapshot and status | `/start` (auto), direct |
| `feature-architect` | Feature structure and scaffolding | `/start` (new features) |
| `test-engineer` | Test creation with coverage tracking | `/finish` (auto), direct |
| `api-documenter` | API documentation completeness audit | Direct delegation |
| `frontend-integrator` | Component scaffolding with a11y | Direct delegation |

## Workflows

### Feature Development
```
1. /start feature-name          # Branch + session + context
2. ... implement feature ...     # Code, test, iterate
3. /review-code                  # Pre-merge quality check
4. /finish                       # Tests + commit + archive
```

### Bug Fix
```
1. /start fix-description        # Branch + session
2. ... debug with 3 hypotheses ...
3. ... implement fix ...
4. /finish                       # Tests + commit + archive
```

### Code Review Only
```
1. /review-code                  # Structured multi-category review
```

### Quick Context Check
```
Ask: "What's the project status?"  # Triggers context-provider
```

## Context Structure

```
context/
├── README.md                    # Index of active sessions and status
├── BACKLOG.md                   # Prioritized pending items
├── ROADMAP.md                   # Module status and progress tracking
├── .pending-commits.log         # Auto-registered commits (via hook)
├── tmp/                         # Active session files
├── archive/
│   ├── COMPLETED.md             # History of completed items
│   └── YYYY-QN/
│       ├── sessions/            # Archived session files
│       └── SUMMARY.md           # One-line per session summary
└── consolidated/                # Per-feature consolidated docs
```

## Rotation Rules

Files are automatically rotated to prevent bloat:

| Trigger | Action |
|---------|--------|
| >3 completed blocks in COMPLETED.md | Summarize oldest to SUMMARY.md |
| >15 archived sessions in a quarter | Generate quarterly summary |
| Feature 100% complete | Consolidate to `consolidated/` |
| `.pending-commits.log` after push | Mark entries as PROCESSED |

## Configuration

All project settings live in `.claude/project.config.json`:
- Project metadata (name, stack, description)
- Commands (test, lint, dev, build)
- Git configuration (branch prefixes, main branch)
- Code conventions (naming, commits)
- Workflow thresholds (max file lines, rotation triggers)

Run `/setup` to configure interactively.

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

## Tips

- Always use `/start` before beginning work to maintain tracking
- Use `/review-code` before `/finish` for quality assurance
- Check `context/BACKLOG.md` for prioritized work items
- Check `context/ROADMAP.md` for module progress and dependencies
- The debugging protocol (3 hypotheses) prevents premature fixes
- Agents are read-only by default unless they need to write
