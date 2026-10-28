# ROUTE — the work queue

> **This is the only file you need to read to know what comes next.** One line per item, in order.
> Maintained by `/finish`. It does not explain: it points. Detail lives in the ticket or the evidence.
>
> Not to be confused with [BACKLOG.md](BACKLOG.md) (the inventory of everything pending, unordered)
> nor [ROADMAP.md](ROADMAP.md) (the macro picture of the product).

**Updated**: 2026-10-28 · **Next session**: F3

---

## NOW

**[plugin] F3 — lo que los proyectos editaban pasa a la config** · large (tiene plan)
      → `.claude/plan/2026-10-27-workflow-como-plugin.md`

---

## QUEUE (in order)

<!-- Same format as NOW. Ordered by what unblocks the most / what hurts the most. -->
- **[plugin] Una sola regla de "dónde va cada archivo" para el generador y `wf-plantillas`** · small · `context/BACKLOG.md` (Next)
- **[plugin] CI de la plantilla + aviso si `core.hooksPath` no es `.githooks`** · medium · `context/BACKLOG.md` (Next)

---

## IN PARALLEL (do not take a turn)

- **[plugin]** Textos de skills con prefijo `/wf:` · small
- **[plugin]** `plantillas/.mcp.json` sin el servidor `db` · small
- **[plugin]** Decidir si "la forma de responder" entra como `WF-R…` · small · `context/BACKLOG.md` (Next)

<!-- Small items that can be done alongside the main one: seeds, one-line fixes,
     environment chores. They do not consume a session. -->

---

## DONE (last 5)

- [x] **decisión** · La plantilla para clonar se queda en este repo; los skills `plantilla:*` solo aparecen si se toca la plantilla y se ignoran — `chore/plantilla-se-queda` (2026-10-28)
- [x] **20261028-0914** · La plantilla para clonar sin plugin se genera sola y un candado no deja commitearla desactualizada — `feature/generador-plantilla` (2026-10-28)
- [x] **20261027-1451** · F2: las reglas del framework llegan por hook como índice corto; la plantilla queda solo con el proyecto — `feature/plugin-f2` (2026-10-28)
- [x] **20261027-1327** · F1: el workflowIA es un plugin instalable; `/wf:setup` arma un proyecto de cero — `feature/plugin-f1` (2026-10-27)
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
