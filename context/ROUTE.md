# ROUTE — the work queue

> **This is the only file you need to read to know what comes next.** One line per item, in order.
> Maintained by `/finish`. It does not explain: it points. Detail lives in the ticket or the evidence.
>
> Not to be confused with [BACKLOG.md](BACKLOG.md) (the inventory of everything pending, unordered)
> nor [ROADMAP.md](ROADMAP.md) (the macro picture of the product).

**Updated**: 2026-10-27 · **Next session**: F1 del plugin `wf`

---

## NOW

**[plugin] F1 — reordenar el repo como plugin `wf`** · large (tiene plan) · `.claude/plan/2026-10-27-workflow-como-plugin.md` → F1
      → arrastra: borrar `spike/wf/`, canales `wf`/`wf-estable` (D3), paso de instalación en el README de `/setup` (D4)
      ⚠️ leer antes `context/verifications/2026-10-27-plugin-f0.md`

<!-- One item only. Format:
- [ ] **A1** · Plain-language statement of the problem · `TICKET-ID` · **small|medium|large**
      → where it lives: `file.ts:120-135` + the query feeding it
      → carried over: any related debt this drags along
      ⚠️ anything to verify before touching it
-->

---

## QUEUE (in order)

<!-- Same format as NOW. Ordered by what unblocks the most / what hurts the most. -->

---

## IN PARALLEL (do not take a turn)

<!-- Small items that can be done alongside the main one: seeds, one-line fixes,
     environment chores. They do not consume a session. -->

---

## DONE (last 5)

- [x] **20261027-1218** · F0 del plugin: las cuatro dudas probadas; fijar versión queda por canal — `context/verifications/2026-10-27-plugin-f0.md` (2026-10-27)

<!-- - [x] **042** · One-line statement of what shipped — `TICKET-ID` (YYYY-MM-DD) -->

---

## Where the detail lives

| What I need | Where |
|---|---|
| Evidence for a finding (what was tested, what happened) | `verifications/YYYY-MM-DD-*.md` |
| Access, DB, API traps, environment gotchas | [ENVIRONMENT.md](ENVIRONMENT.md) |
| Full inventory of pending work | [BACKLOG.md](BACKLOG.md) |
| Module progress and dependencies | [ROADMAP.md](ROADMAP.md) |
| Bug registry | [FIXES.md](FIXES.md) |
| Past decisions and lessons | [.claude/MEMORY.md](../.claude/MEMORY.md) |

## How to use it

1. **When opening a session**, read **NOW** and nothing else. Take **one item**.
2. **New finding → it enters the QUEUE right away**, with its ID and one line (if you do not know
   where it goes, at the end with `?`). Its evidence goes to its own document in `verifications/`.
   Never pile findings up to sort them later.
3. **When closing**, `/finish` moves the item to DONE and promotes the next one to NOW.

## Sizing

| Size | Means |
|------|-------|
| **small** | One session, one or two files, cause already known |
| **medium** | One session, several files, or the cause needs confirming first |
| **large** | Multiple sessions or needs a plan in `.claude/plan/` first |
| **?** | Unknown — the first step is to find out |
