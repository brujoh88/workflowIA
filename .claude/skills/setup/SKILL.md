---
name: setup
description: Interactive wizard to configure the project
allowed-tools: Read, Write, Edit, Bash(mkdir:*), Bash(git:*), Bash(chmod:*), Bash(cp:*), AskUserQuestion
---

# Project Setup

Interactive wizard to configure the workflowIA template.

## Process

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

#### 2.6 Code Conventions

Confirm or adjust conventions:
- Files: kebab-case / camelCase / PascalCase
- Commits: conventional / free

#### 2.7 Folder Structure

Ask locations:
- Source code: `src/` (default)
- Tests: `tests/` or `__tests__/` or `src/__tests__/`
- Docs: `docs/` (default)

#### 2.8 Quality & Workflow (NEW)

Ask:
- **Coverage threshold** (default: 80%): minimum test coverage target
- **External quality skills** (optional): list of external skill names to install via symlinks
  - Example: `["accessibility-checker", "performance-audit"]`
  - These will be checked by `/review-code` and `/finish`

### 3. Save Configuration

Update `.claude/project.config.json` with all collected values, including new fields:
- `git.devBranch`
- `git.coAuthoredBy`
- `commands.syncTypes`
- `workflow.coverageThreshold`
- `workflow.backlogMaxLines` (default: 300)
- `workflow.recentSessionsToKeep` (default: 3)
- `quality.externalSkills`

Set `"initialized": true`.

### 4. Update CLAUDE.md

Replace placeholders in `CLAUDE.md`:

| Placeholder | Value |
|-------------|-------|
| `[NAME]` | project.name |
| `[Backend/Frontend/DB]` | project.stack |
| `[Brief app description]` | project.description |
| Hardcoded commands | Use values from commands.* |

### 5. Install Git Hooks

Preferred method (global for repo):
```bash
git config core.hooksPath scripts/hooks
```

Fallback method:
```bash
cp scripts/hooks/post-commit .git/hooks/post-commit && chmod +x .git/hooks/post-commit
```

This installs the post-commit hook that auto-registers commits in `context/.pending-commits.log`.

### 6. Create MEMORY.md (if not exists)

Check if `.claude/MEMORY.md` exists. If not, it was already created by the template.
Confirm to user that MEMORY.md is ready for persistent lessons.

### 7. Create settings.json (if not exists)

Check if `.claude/settings.json` exists. If not, create with:
```json
{
  "enabledPlugins": { "typescript-lsp@claude-plugins-official": true },
  "plansDirectory": ".claude/plan"
}
```

### 8. Create Folder Structure

If they don't exist, create configured folders:
- `{structure.src}`
- `{structure.tests}`
- `{structure.docs}`
- `context/tmp/`
- `context/auditorias/`
- `context/archive/{year}-Q{quarter}/sessions/`
- `.claude/plan/`
- `.claude/plan/completados/`

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
- .claude/settings.json (plugin config)
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
