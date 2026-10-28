# Verifications

Versioned evidence of what was actually tested and what happened.

**Why it exists**: a finding without evidence is an opinion. When a bug is reported from staging,
from a demo, or from a manual round of testing, the raw observation lands here — so the decision
made later can be traced back to what was actually seen, not to what was remembered.

## Naming

```
YYYY-MM-DD-short-description.md
```

Examples: `2026-03-20-staging.md`, `2026-03-22-cross-route-findings.md`

## What goes here

| Yes | No |
|---|---|
| Manual testing rounds (what was clicked, what happened) | The decision of what to do about it (that is ROUTE.md) |
| Findings with a stable ID (`H-01`, `H-S12`) | Bug tracking status (that is FIXES.md) |
| Reasoning behind a work ordering | Feature documentation (that is `consolidated/`) |
| Screenshots, logs, request/response dumps | Anything that becomes stale (env access → ENVIRONMENT.md) |

## Format

```markdown
# {What was verified} — YYYY-MM-DD

> Scope: {what was covered} · Environment: {local | staging | prod} · User: {which account}

## Findings

### H-01 · {one-line statement in plain language}
- **Expected**: what should have happened
- **Observed**: what actually happened
- **Reproduce**: exact steps
- **Evidence**: log excerpt, status code, screenshot path
- **Where it likely lives**: `file.ts:120` (or "unknown — needs digging")

## Not reproduced / no longer happening

<!-- Things checked that turned out fine. Worth recording: prevents re-checking. -->
```

## Lifecycle

1. A testing round produces a document here with its findings, each with an ID.
2. The IDs enter `ROUTE.md` as queue items (one line each, pointing back here).
3. When a finding is fixed, `FIXES.md` records the fix and references the finding ID.
4. The evidence document is **never edited to reflect the fix** — it is a snapshot of that day.
