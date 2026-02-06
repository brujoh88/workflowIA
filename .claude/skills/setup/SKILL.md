---
name: setup
description: Interactive wizard to configure the project
allowed-tools: Read, Write, Edit, Bash(mkdir:*), AskUserQuestion
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

#### 2.5 Git Configuration

Ask:
- Main branch: main / master
- Branch prefixes (offer defaults):
  - feature: `feature/`
  - fix: `fix/`
  - hotfix: `hotfix/`

#### 2.6 Code Conventions

Confirm or adjust conventions:
- Files: kebab-case / camelCase / PascalCase
- Commits: conventional / free

#### 2.7 Folder Structure

Ask locations:
- Source code: `src/` (default)
- Tests: `tests/` or `__tests__/` or `src/__tests__/`
- Docs: `docs/` (default)

### 3. Save Configuration

Update `.claude/project.config.json` with all collected values.

Set `"initialized": true`.

### 4. Update CLAUDE.md

Replace placeholders in `CLAUDE.md`:

| Placeholder | Value |
|-------------|-------|
| `[NOMBRE]` | project.name |
| `[Backend/Frontend/DB]` | project.stack |
| `[Descripción breve de la aplicación]` | project.description |
| Hardcoded commands | Use values from commands.* |

### 5. Install Git Hooks

```bash
cp scripts/hooks/post-commit .git/hooks/post-commit && chmod +x .git/hooks/post-commit
```

This installs the post-commit hook that auto-registers commits in `context/.pending-commits.log`.

### 6. Create Folder Structure

If they don't exist, create configured folders:
- `{structure.src}`
- `{structure.tests}`
- `{structure.docs}`
- `context/tmp/`
- `context/archive/{year}-Q{quarter}/sessions/`

### 7. Suggest MCP Servers

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

Save suggestions in `project.config.json` → `mcp.suggested`.

Ask user:
> Based on your stack ({stack}), these MCPs could be useful:
> - {list of suggested MCPs}
>
> Want to install any now? (You can do it later with `/mcp install`)

If user wants to install, run `/mcp install` flow for each selected.

### 8. Final Summary

Show summary of applied configuration:

```
Project configured successfully

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

Git:
- Main branch: {git.mainBranch}
- Feature prefix: {git.branchPrefixes.feature}

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
