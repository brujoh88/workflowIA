# Quality Skills Contract

Defines the interface for external quality skills integrated into the workflowIA framework.

## What is a Quality Skill?

A quality skill is an external skill (not bundled with the framework) that performs specialized quality checks on code. Examples: accessibility auditing, performance analysis, design system compliance.

## Interface

### Input

Quality skills receive context through the standard skill mechanism:
- `$ARGUMENTS`: scope or file list (optional)
- Access to all Read/Glob/Grep tools for code analysis
- Access to `.claude/project.config.json` for project settings

### Expected Output

Skills MUST produce findings in this format:

```markdown
## Quality Report: {skill-name}

**Scope**: {files analyzed}
**Date**: {timestamp}

### Findings

| # | Severity | File:Line | Description | Suggestion |
|---|----------|-----------|-------------|------------|
| 1 | CRITICAL | `src/file.ts:42` | {what's wrong} | {how to fix} |
| 2 | IMPORTANT | `src/other.ts:15` | {what's wrong} | {how to fix} |
| 3 | SUGGESTION | `src/comp.tsx:88` | {what's wrong} | {how to fix} |

### Summary
- **Critical**: {N}
- **Important**: {N}
- **Suggestions**: {N}
- **Verdict**: PASS | FAIL | CONDITIONAL
```

### Severity Levels

| Level | Meaning | Blocks Merge? |
|-------|---------|---------------|
| CRITICAL | Must fix before merge | Yes |
| IMPORTANT | Should fix, track if not | No (but tracked) |
| SUGGESTION | Nice to have improvement | No |

## Integration Points

### During Development (`/start`)
- Quality skills listed in session file under "Quality Skills" section
- Developer reminded which skills to consult

### During Review (`/review-code`)
- Step 1.5 checks if configured skills exist:
  1. Look for `.claude/skills/{skill-name}/SKILL.md` (via symlink or direct)
  2. If exists: invoke and include results in review report
  3. If not installed: note as "configured but not installed"

### During Finish (`/finish`)
- Step 0.5 checks if quality skills were consulted during the session
- If frontend changes detected and frontend skills configured but not run: warn user

## Creating a Quality Skill

### 1. Skill File Structure

```
my-quality-skill/
└── SKILL.md
```

### 2. Skill Template

```markdown
---
name: {skill-name}
description: {what it checks}
context: fork
agent: Explore
allowed-tools: Read, Glob, Grep
---

# Quality Check: {skill-name}

## Step 1: Identify Scope
Find relevant files based on $ARGUMENTS or detect automatically.

## Step 2: Analyze
Run checks against identified files.

## Step 3: Report
Output findings in the standard Quality Report format (see contract).

## Rules
- Read-only: never modify source code
- Every finding must include file:line reference
- Use severity levels consistently
```

### 3. Installation

**Option A: Symlink** (recommended for shared skills)
```bash
ln -s /path/to/my-quality-skill .claude/skills/my-quality-skill
```

**Option B: Direct copy**
```bash
cp -r /path/to/my-quality-skill .claude/skills/
```

### 4. Registration

Add to `.claude/project.config.json`:
```json
{
  "quality": {
    "externalSkills": ["my-quality-skill"]
  }
}
```

## Verification

To verify a quality skill is correctly installed:
1. Check file exists: `.claude/skills/{skill-name}/SKILL.md`
2. Check registration: `config.quality.externalSkills` includes `{skill-name}`
3. Run the skill manually to verify output format matches the contract
