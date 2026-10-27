# Backlog

Single source of pending items for the project.

**Last updated**: 2026-10-27
**Target**: <300 lines (cleanup on `/finish`)

## In Progress

_None currently_

## Next (Prioritized)

- [ ] **[plugin]** F1 — reordenar el repo como plugin `wf`
  - Context: plan `.claude/plan/2026-10-27-workflow-como-plugin.md`; F0 cerrada (`context/verifications/2026-10-27-plugin-f0.md`)
  - Criteria: estructura de F1 del plan; `spike/wf/` borrado; canales `wf` y `wf-estable` en la tienda (D3 por canal); paso de instalación para quien clona en el README que genera `/setup` (D4)
  - Notes: decidir si se borran los tags `wf--v0.1.0`/`wf--v0.2.0` del spike; evaluar el hook de proyecto que avisa si falta el plugin

<!-- Add items with format:
- [ ] **[SCOPE]** Brief description
  - Context: why it's needed
  - Acceptance criteria: what defines "done"
-->

## Completed (Recent)

- [x] **[plugin]** F0 — probar D1–D4 del plugin `wf` *(session-20261027-1218-plugin-f0)*

<!-- Items completed in recent sessions. Moved here by /finish.
Format: - [x] **[scope]** Description *(session-ID)*
Rotated to archive/COMPLETED.md when section grows large.
-->

## Ideas / Future

<!-- Items without defined priority -->

## Suggested Next Session

_Evaluated on `/finish` based on BACKLOG priorities and ROADMAP dependencies._

---

## Item Format

```markdown
- [ ] **[scope]** Descriptive title
  - Context: Why it's needed
  - Criteria: What defines "done"
  - Notes: Technical considerations
```

## Completion Markers

| Marker | Meaning |
|--------|---------|
| `[ ]` | Pending - not started |
| `[~]` | Partially completed - work in progress |
| `[x]` | Fully completed |

Completed items include session reference: `*(session-YYYYMMDD-HHMM-name)*`

## How to Use

1. **Add**: New items go to "Ideas / Future"
2. **Prioritize**: Move to "Next" when priority is defined
3. **Start**: `/start` moves item to "In Progress"
4. **Partial**: `/finish` marks as `[~]` if not fully done
5. **Complete**: `/finish` marks as `[x]` and moves to "Completed (Recent)"
6. **Archive**: Rotated to `archive/COMPLETED.md` when section grows large
