---
name: deploy
description: Environment-aware deployment with pre/post checks
argument-hint: [staging|production|custom]
disable-model-invocation: true
allowed-tools: Bash(npm:*), Bash(yarn:*), Bash(pnpm:*), Bash(bun:*), Bash(git:*), Read
---

# Deploy to $ARGUMENTS

## Step 0: Load Configuration

Read `.claude/project.config.json` to get project configuration.

**Variables to use**:
- `{packageManager}` = `config.commands.packageManager` (default: `npm`)
- `{testCmd}` = `config.commands.test` (default: `npm test`)
- `{buildCmd}` = `config.commands.build` (default: `npm run build`)
- `{mainBranch}` = `config.git.mainBranch` (default: `main`)

**Environment detection** from `$ARGUMENTS`:
- `staging` / `stg` → staging environment
- `production` / `prod` → production environment
- Other → custom environment name
- Empty → ask user which environment

**Deploy command resolution** (in order of precedence):
1. `config.commands.deploy:{env}` if defined (e.g., `commands.deploy:staging`)
2. `{packageManager} run deploy:{env}` (e.g., `npm run deploy:staging`)
3. `{packageManager} run deploy` (generic, if environment-specific not found)

## Step 1: Pre-deploy Checks

### 1.1 Working Directory
```bash
git status --porcelain
```
- If dirty: **STOP** — "Uncommitted changes detected. Commit or stash before deploying."

### 1.2 Branch Verification
```bash
git branch --show-current
```

**Branch rules by environment**:
| Environment | Allowed Branches | Action if Wrong |
|-------------|-----------------|-----------------|
| production | `{mainBranch}` only | **STOP** — "Production deploys must be from `{mainBranch}`" |
| staging | `{mainBranch}`, `develop`, feature branches | **WARN** — "Deploying from non-main branch: {branch}" |
| custom | Any | **INFO** — "Deploying from branch: {branch}" |

### 1.3 Up-to-date Check
```bash
git fetch origin {currentBranch} 2>/dev/null
git log HEAD..origin/{currentBranch} --oneline 2>/dev/null
```
- If behind remote: **WARN** — "Local branch is behind remote. Pull latest changes? (recommended)"

### 1.4 Active Session Check
Check for active sessions in `context/tmp/session-*.md`:
- If found: **WARN** — "Active session {ID} found. Finish it before deploying? (recommended)"

## Step 2: Run Tests

```bash
{testCmd}
```

- If tests **fail**: **STOP** — "Tests must pass before deployment. Fix failing tests first."
- If tests **pass**: continue

## Step 3: Run Build

```bash
{buildCmd}
```

- If build **fails**: **STOP** — "Build failed. Fix build errors before deploying."
- If build **succeeds**: continue
- Report build output size if available

## Step 4: Deploy

### 4.1 Confirmation

Before deploying, present summary:
```markdown
### Deploy Confirmation
- **Environment**: {env}
- **Branch**: {current branch}
- **Last commit**: {short hash} - {message}
- **Tests**: PASSED
- **Build**: SUCCESS
- **Deploy command**: {resolved deploy command}

Proceed with deployment? (yes/no)
```

### 4.2 Execute Deploy

```bash
{resolved deploy command}
```

Report deployment output.

## Step 5: Post-deploy Validation

Present checklist for the user to verify:

```markdown
### Post-deploy Checklist
- [ ] Application is accessible at {env} URL
- [ ] Health check endpoint responds (if applicable)
- [ ] Critical user flows work (login, main actions)
- [ ] No new errors in application logs
- [ ] Database migrations ran successfully (if applicable)
- [ ] Static assets loading correctly
- [ ] Environment variables set correctly
```

## Step 6: Rollback Guide

If deployment fails or post-deploy checks reveal issues:

```markdown
### Rollback Options

**Option A: Redeploy previous version**
git log --oneline -5  # Find the previous good commit
git checkout {previous-commit}
{deploy command}

**Option B: Revert commit**
git revert HEAD
git push origin {branch}
{deploy command}

**Option C: Package manager rollback** (if supported)
{packageManager} run rollback:{env}
```

## Error Recovery

| Problem | Recovery |
|---------|----------|
| Deploy command not found | Check `package.json` scripts for deploy variants; ask user for the correct command |
| Permission denied | Check credentials/tokens for the target environment |
| Build succeeds but deploy fails | Check deploy target configuration (URLs, keys, regions) |
| Partial deploy (some services up, some down) | Check deploy logs for the failing service; may need manual intervention |
| DNS/SSL issues after deploy | These often need time to propagate; wait 5-10 minutes before escalating |
| Database migration failure | Do NOT retry blindly; check migration status and fix the specific migration |

## Expected Output

```markdown
## Deploy Summary

- **Environment**: {env}
- **Branch**: {branch} ({commit hash})
- **Tests**: PASSED
- **Build**: SUCCESS
- **Deploy**: SUCCESS | FAILED
- **Command used**: {deploy command}
- **Timestamp**: {date and time}
- **Post-deploy**: {checklist status}
```
