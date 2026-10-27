# Fixes Registry

Centralized tracking for bug fixes and issues.

**Last updated**: -

## Fix Workflows

| Workflow | When to Use | Process |
|----------|-------------|---------|
| **Quick fix** | 1-2 files, clear cause | Fix → test → commit directly |
| **`/start`** | Complex, multi-file, unclear cause | Full session with debugging protocol |
| **Batch** | Multiple small related fixes | Group → fix all → single commit |

## Pending

<!-- Format:
- [ ] **[scope]** Brief description
  - **Reported**: YYYY-MM-DD
  - **Severity**: critical / high / medium / low
  - **Reproduction**: Steps or context
-->

## In Progress

<!-- Items being actively fixed (moved from Pending) -->

## Resolved (Recent)

<!-- Format:
- [x] **[scope]** Brief description *(session-ID or commit-hash)*
  - **Fixed**: YYYY-MM-DD
  - **Root cause**: What caused the issue
  - **Fix**: What was changed
-->

---

## How to Use

1. **Report**: Add new issues to "Pending" with severity
2. **Quick fix**: For simple fixes, fix directly and move to "Resolved"
3. **Complex fix**: Use `/start fix-description` for full debugging protocol
4. **Batch fix**: Group related small fixes, fix together, single commit
5. **Archive**: When "Resolved" section grows large, move oldest to `archive/COMPLETED.md`
