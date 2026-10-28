---
name: metrics
description: Project metrics and observability dashboard
allowed-tools: Read, Glob, Grep, Bash(wc:*), Bash(git:*)
---

# Project Metrics Dashboard

## Step 0: Load Configuration

Read `.claude/project.config.json` for project name and settings.

## Step 1: Session Metrics

### 1.1 Count Sessions

Scan session archives:
```
Glob: context/archive/*/sessions/session-*.md
Glob: context/tmp/session-*.md
```

Calculate:
- **Total sessions**: all archived + active
- **By quarter**: count per `context/archive/{YYYY-QN}/sessions/` directory
- **Active sessions**: count in `context/tmp/`

### 1.2 Session Duration

For each archived session with Final Summary:
- Extract Start and End timestamps
- Calculate duration
- Compute average duration across all sessions

### 1.3 Sessions by Type

Categorize by branch prefix:
- `feature/` → Feature sessions
- `fix/` → Fix sessions
- `hotfix/` → Hotfix sessions
- Other → Miscellaneous

## Step 2: Commit Metrics

### 2.1 Total Commits
```bash
git log --oneline | wc -l
```

### 2.2 Commits per Session

Read `context/.pending-commits.log` (if exists):
- Count commits by branch
- Calculate average commits per session

### 2.3 Recent Activity
```bash
git log --oneline --since="30 days ago" | wc -l
```

## Step 3: BACKLOG Metrics

Read `context/BACKLOG.md`:
- **Pending** (`[ ]`): count items
- **In Progress** (`[~]`): count items
- **Completed** (`[x]`): count items in "Completed (Recent)"
- **Ideas**: count items in "Ideas / Future"
- **Total lines**: `wc -l` of BACKLOG file
- **Health**: lines vs `config.workflow.backlogMaxLines` (default: 300)

### BACKLOG Velocity

Read `context/archive/COMPLETED.md` (if exists):
- Count completed items per month (from date references)
- Calculate completion rate (items/month)

## Step 4: ROADMAP Metrics

Read `context/ROADMAP.md` (if exists):
- **Total modules**: count module entries
- **Completed** (100%): count
- **In Progress** (1-99%): count with percentages
- **Not Started** (0%): count
- **Overall progress**: weighted average of all module percentages

## Step 5: FIXES Metrics

Read `context/FIXES.md` (if exists):
- **Pending**: count items in Pending section
- **In Progress**: count items in In Progress section
- **Resolved**: count items in Resolved section
- **Resolution ratio**: resolved / (pending + in progress + resolved)

## Step 6: Code Metrics

### 6.1 Source File Count
```
Glob: src/**/*.{ts,tsx,js,jsx,py,go,rs}
```
Count total source files.

### 6.2 Test File Count
```
Glob: tests/**/*.*, src/**/*.test.*, src/**/*.spec.*
```
Count total test files.

### 6.3 Test-to-Source Ratio
Calculate: test files / source files

## Step 7: Generate Report

Output formatted report:

```markdown
## Project Metrics: {project name}
**Generated**: {date}

### Session Activity
| Metric | Value |
|--------|-------|
| Total sessions | {N} |
| Active sessions | {N} |
| This quarter | {N} |
| Average duration | {Xh Ym} |
| By type | {N} features, {N} fixes, {N} hotfixes |

### Commits
| Metric | Value |
|--------|-------|
| Total commits | {N} |
| Last 30 days | {N} |
| Avg per session | {N} |

### BACKLOG Health
| Metric | Value |
|--------|-------|
| Pending items | {N} |
| In Progress | {N} |
| Completed (recent) | {N} |
| Ideas | {N} |
| File size | {N}/{max} lines ({health}) |
| Velocity | ~{N} items/month |

### ROADMAP Progress
| Metric | Value |
|--------|-------|
| Total modules | {N} |
| Completed | {N} ({%}) |
| In Progress | {N} |
| Not Started | {N} |
| Overall progress | {%} |

### FIXES Status
| Metric | Value |
|--------|-------|
| Pending | {N} |
| In Progress | {N} |
| Resolved | {N} |
| Resolution ratio | {%} |

### Codebase
| Metric | Value |
|--------|-------|
| Source files | {N} |
| Test files | {N} |
| Test:Source ratio | {ratio} |

### Trends
- {observation about velocity}
- {observation about BACKLOG health}
- {observation about fix rate}
```

## Rules

- **Read-only**: This skill never modifies files
- **Graceful degradation**: If a file doesn't exist, report "N/A" and continue
- **No assumptions**: Only report data that can be verified from files
- **Concrete numbers**: Always use actual counts, never estimates
