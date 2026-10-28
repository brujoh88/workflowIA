---
name: setup
description: Interactive wizard to configure the project
allowed-tools: Read, Write, Edit, Bash(mkdir:*), Bash(git:*), Bash(chmod:*), Bash(cp:*), AskUserQuestion
---

# Project Setup

Interactive wizard to configure a project cloned from the workflowIA template (no plugin).

## Process

### 0. Hook Up the Git Hooks

This project was cloned from the workflowIA template (no plugin): every file is already in place,
and the framework lives in `.claude/wf/` (rules, hook scripts, docs). Only the git hooks need
enabling, since git never carries that setting with a clone:

```bash
chmod +x scripts/hooks/* .claude/wf/scripts/* .claude/wf/bin/*
git config core.hooksPath scripts/hooks
```

### 0.5. Check if the Project is Framed

Read `CLAUDE.md`. If the `## Business Context` section still contains `[placeholder]` markers,
the project has not been framed yet.

Tell the user:
> This configures the technical side (commands, branches, limits). What the project *is* — the
> problem, the entities, the flows that cannot break — is not filled in yet. `/discover` covers
> that in a conversation and writes it, including a stack recommendation derived from the answers.

Ask whether to run `/discover` first (recommended) or continue with `/setup` alone.
Either answer is fine — `/setup` works standalone.

### 1. Check Current State

Read `.claude/project.config.json` to verify if already initialized.

If `initialized: true`, ask user if they want to reconfigure.

### 2. Collect Project Information

Use `AskUserQuestion` for each section:

#### 2.1 Project Metadata

Ask:
- **Project name**: technical name (kebab-case recommended)
- **Description**: brief description of what the app does
- **Tech stack**: main technologies (e.g., "Node.js + PostgreSQL", "React + Firebase")

#### 2.2 Language

Ask language preferences:
- **Code language** (variables, functions, code comments):
  - English (en) - Recommended for open source projects
  - Spanish (es)
- **Chat language** (Claude responses, documentation):
  - Spanish (es) - Default
  - English (en)

#### 2.3 Package Manager

Ask which package manager the project uses:
- npm (default)
- yarn
- pnpm
- bun

#### 2.4 Development Commands

Ask for main commands (offer defaults based on package manager):
- Test command (default: `{pm} test`)
- **Coverage command** (e.g. `{pm} test -- --coverage`): leave empty if there is none.
  Without it `/audit` cannot measure coverage and reports SKIP instead of a number — it will
  never invent a percentage from counting test files.
- Lint command (default: `{pm} run lint`)
- Dev server command (default: `{pm} run dev`)
- Build command (default: `{pm} run build`)
- **Sync types command** (optional, e.g., `npx prisma generate`): leave empty if not needed

#### 2.5 Git Configuration

Ask:
- Main branch: main / master
- **Development branch** (optional): leave empty for direct-from-main flow, or set `dev`/`develop` for gitflow
- Branch prefixes (offer defaults):
  - feature: `feature/`
  - fix: `fix/`
  - hotfix: `hotfix/`
- **Include Co-Authored-By in commits?** (default: no) — whether to attribute AI in commit messages

**Always set `git.allowCommitsOnMain: false`** for a derived project — no question asked. It is
inherited as `true` from the template repository (whose own main branch *is* its working branch)
and must be turned off, or WF-R2 is silently disabled. Report it in the final summary:
`Protected branch: {mainBranch} (commits blocked)`.

#### 2.6 Code Conventions

Confirm or adjust conventions:
- Files: kebab-case / camelCase / PascalCase
- Commits: conventional / free

#### 2.7 Folder Structure

Ask locations:
- Source code: `src/` (default)
- Tests: `tests/` or `__tests__/` or `src/__tests__/`
- Docs: `docs/` (default)

#### 2.8 Quality & Workflow

Ask:
- **Coverage threshold** (default: 80%): minimum test coverage target
- **Test max workers** (default: 2): limit CPU usage during tests (WF-R19)
- **Per-type file limits** (defaults: services 500, components 300, hooks 150, default 400)
- **External quality skills** (optional): list of external skill names to install via symlinks
  - Example: `["accessibility-checker", "performance-audit"]`
  - These will be checked by `/review-code` and `/finish`

#### 2.9 Parallel Sessions

Ask:
- **Enable parallel sessions?** (default: yes): allow multiple Claude instances on different branches
- **Lock timeout** (default: 60s): how long before a stuck lock auto-expires

### 3. Save Configuration

Update `.claude/project.config.json` with all collected values, including new fields:
- `git.devBranch`
- `git.coAuthoredBy`
- `commands.syncTypes`
- `workflow.coverageThreshold`
- `workflow.backlogMaxLines` (default: 300)
- `workflow.recentSessionsToKeep` (default: 3)
- `quality.externalSkills`
- `workflow.testMaxWorkers`
- `workflow.maxFileLines` (object with per-type limits)
- `parallel.enabled`
- `parallel.lockTimeoutSeconds`
- `parallel.lockFile`

Set `"initialized": true`.

### 4. Update CLAUDE.md

Replace placeholders in `CLAUDE.md`:

| Placeholder | Value |
|-------------|-------|
| `[NAME]` | project.name |
| `[Backend/Frontend/DB]` | project.stack |
| `[Brief app description]` | project.description |
| Hardcoded commands | Use values from commands.* |

### 5. Verify Git Hooks

Step 0 already copied them to `scripts/hooks/` and set `core.hooksPath`. Confirm:
```bash
git config core.hooksPath   # expected: scripts/hooks
```

The git hooks in `scripts/hooks/`:
- **post-commit**: auto-registers commits in `context/.pending-commits.log`
- **pre-commit**: protected branch (WF-R2), quality validation (lint, file size WF-R4, TS errors WF-R16)
- **commit-msg**: blocks AI attribution (WF-R3) + enforces commit format

They are versioned with the project, so a teammate who clones gets them — but each clone still has
to run `git config core.hooksPath scripts/hooks` once (git never enables hooks on its own). That
line goes in the README (step 7.6).

The **Claude Code** hooks (guard-main, guard-db, verdad-al-escribir, precompact, session-context)
live in `.claude/wf/scripts/` and are declared in `.claude/settings.json`.

### 6. Create MEMORY.md (if not exists)

Check if `.claude/MEMORY.md` exists. If not, it was already created by the template.
Confirm to user that MEMORY.md is ready for persistent lessons.

### 6.5. Docker Environment

Ask: **Does the project run its database in Docker?** (default: no)

If yes, ask for the container name used to run DB commands (e.g. `app-backend-dev`) and save to
`config.docker = { enabled: true, dbContainer: "..." }`.

This drives `claude-guard-db.sh` (WF-R18): with `enabled: true`, migrations and seeds attempted
outside Docker are blocked before they run. Destructive operations are blocked either way.

### 6.7. Persistent Memory (Engram) — optional

Ask: **Enable Engram persistent memory?** (default: no)

> Engram is an MCP server (SQLite + full-text search) for decisions and non-obvious root causes.
> Memories export to `.engram/chunks/`, which is versioned — so they travel with the repo across
> machines. It complements `context/` and `MEMORY.md`, it does not replace them.
> Requires installing the `engram` binary on each machine.

If yes:
1. Set `config.memory.engram.enabled = true`
2. Add `engram` to `config.mcp.installed`
3. Tell the user to install the binary and register the MCP server

Everything degrades to a no-op when disabled or when the binary is missing: `post-commit`,
`post-merge` and `claude-precompact.sh` all check before running. Nobody is blocked for not
having it installed.

### 7. Check settings.json

`.claude/settings.json` declares the workflow's Claude Code hooks (`hooks` block, pointing at
`.claude/wf/scripts/`). Keep that block. Do **not** install the wf plugin on top of this copy:
every guard would fire twice. Moving to the plugin means removing `.claude/wf/`, the `hooks` block,
`.claude/skills/` and `.claude/agents/` first.

### 7.5. Create settings.local.json template (if not exists)

Check if `.claude/settings.local.json` exists. If not, create a starter template:
```json
{
  "permissions": {
    "allow": [
      "Bash(npm:*)",
      "Bash(git:*)",
      "Bash(mkdir:*)",
      "Bash(chmod:*)",
      "Read",
      "Write",
      "Edit",
      "mcp__context7__resolve-library-id",
      "mcp__context7__query-docs"
    ]
  }
}
```

Inform user: "Created `.claude/settings.local.json` with recommended permissions. Customize as needed. This file is gitignored."

### 7.6. README: how someone who clones gets started

Git never enables hooks on its own, so the step goes in the project's README, near the top. Add
this section (create the README if there is none; do not duplicate it if it is already there):

```markdown
## Working on this project with Claude Code

Once per clone, from the project folder:

    git config core.hooksPath scripts/hooks

Then open Claude. The workflow commands are `/start`, `/finish`, `/review-code`.
```

### 8. Create Folder Structure

If they don't exist, create configured folders:
- `{structure.src}`
- `{structure.tests}`
- `{structure.docs}`
- `context/tmp/`
- `context/verifications/`
- `context/auditorias/`
- `context/consolidated/`
- `context/archive/{year}-Q{quarter}/sessions/`
- `.claude/plan/`
- `.claude/plan/completados/`

Validate and report: "Context structure verified" or "Created missing directories: {list}"

### 8.5. Initial Commit (only in a repo with no commits)

```bash
git rev-parse --verify -q HEAD >/dev/null || echo "no history"
```

If the repo has **no commits yet**, make the initial commit on `{mainBranch}` now, with what setup
created: the files that came with the template, `.gitignore`, `README.md`, and `.claude/settings.json`.
List them to the user before committing and stage them by name — never `git add -A`: an empty
repo can still hold files nobody meant to version (`.env`, dumps).

```bash
git add <files> && git commit -m "chore: initial project setup (workflowIA)"
```

Why here: the first commit is the one that **creates** `{mainBranch}`, so the guards let it through
on purpose (nothing can branch from a main that does not exist). Making it inside setup closes that
window right away — from the second commit on, `{mainBranch}` is protected (WF-R2).

If the repo already has history, skip this step: setup's changes go in through a branch like any
other change.

### 9. Suggest MCP Servers

Based on `project.stack` and `project.description`, suggest relevant MCPs:

**Automatic mapping**:
| Keyword in stack/description | Suggested MCP |
|------------------------------|---------------|
| PostgreSQL, Postgres | `@modelcontextprotocol/server-postgres` |
| MySQL, MariaDB | MySQL MCP if exists |
| SQLite | `@modelcontextprotocol/server-sqlite` |
| GitHub | `@modelcontextprotocol/server-github` |
| Slack | `@modelcontextprotocol/server-slack` |
| Google Drive | `@modelcontextprotocol/server-gdrive` |
| Puppeteer, Scraping, Browser | `@modelcontextprotocol/server-puppeteer` |
| Docker, Containers | `mcp-server-docker` |
| Any project | `context7` (documentation lookup) |

Save suggestions in `project.config.json` → `mcp.suggested`.

Ask user:
> Based on your stack ({stack}), these MCPs could be useful:
> - {list of suggested MCPs}
>
> Want to install any now? (You can do it later with `/mcp install`)

If user wants to install, run `/mcp install` flow for each selected.

### 10. Final Summary

Show summary of applied configuration:

```
Project configured successfully!

Name: {project.name}
Stack: {project.stack}
Package Manager: {commands.packageManager}

Language:
- Code: {language.code}
- Chat: {language.chat}

Commands:
- Test: {commands.test}
- Lint: {commands.lint}
- Dev: {commands.dev}
- Sync types: {commands.syncTypes || "not configured"}

Git:
- Main branch: {git.mainBranch}
- Dev branch: {git.devBranch || "none (branch from main)"}
- Feature prefix: {git.branchPrefixes.feature}
- Co-Authored-By: {git.coAuthoredBy}

Quality:
- Coverage threshold: {workflow.coverageThreshold}%
- External skills: {quality.externalSkills || "none"}

Files created:
- .claude/MEMORY.md (persistent lessons)
- .claude/settings.json (declares the workflow's Claude Code hooks)
- README section for whoever clones
- Initial commit on {mainBranch} (only if the repo had no history)
- .claude/plan/ (implementation plans)
- context/auditorias/ (audit reports)
- Git hooks configured

MCP Servers:
- Installed: {mcp.installed.length}
- Suggested: {mcp.suggested} (install with /mcp install)

Next steps:
1. Review updated CLAUDE.md
2. Install suggested MCPs with /mcp install <name>
3. Use /start <feature> to begin development
```

## Notes

- If user cancels at any step, don't save partial changes
- Default values are designed for typical Node.js projects
- User can run /setup again to reconfigure
- Context7 MCP is always recommended regardless of stack
