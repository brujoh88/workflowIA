# Backlog

Single source of pending items for the project.

**Last updated**: 2026-10-27
**Target**: <300 lines (cleanup on `/finish`)

## In Progress

_None currently_

## Next (Prioritized)

- [ ] **[plugin]** F2 — partir el CLAUDE.md: reglas del framework (`reglas/`, inyectadas por `SessionStart`) y esqueleto del proyecto (`plantillas/CLAUDE.md`)
  - Context: plan, fase F2. D1 probó que la inyección llega en arranque, resume y compact; cada resume la suma entera → reglas cortas
  - Criteria: `plantillas/CLAUDE.md` sin reglas del framework; reglas `WF-R…` llegan por hook; el CLAUDE.md raíz deja de importar la plantilla
  - Notes: resolver también dónde viven MANUAL y QUALITY-SKILLS-CONTRACT para un proyecto con plugin (hoy la plantilla los importa con `@` y quedan colgados)
- [ ] **[plugin]** Generador de `plantilla/` (la versión clonable sin plugin) + candado en `pre-commit` que corta si quedó distinta
  - Context: decisión 3 del plan; carpeta `plantilla/` en este repo (decidido 2026-10-27). Va después de F2 porque mete las reglas en el CLAUDE.md
  - Criteria: `scripts/armar-plantilla.sh` la genera; el pre-commit la regenera y corta si difiere
- [ ] **[plugin]** Textos de los skills: prefijo `/wf:` y sin la opción "Lo escribo yo" que repite "Type something"
  - Context: visto en la prueba de `/wf:setup` (2026-10-27); el modelo a veces pone el prefijo solo, a veces no
  - Criteria: ningún skill nombra `/start`, `/finish`… sin `wf:`; las preguntas de texto libre no ofrecen una opción duplicada
- [ ] **[plugin]** `plantillas/.mcp.json` trae el servidor `db`: en un proyecto sin base falla al conectar
  - Criteria: la plantilla viene sin `db`, o `/wf:setup` lo saca cuando no hay base de datos
- [ ] **[plugin]** README raíz con la instalación por plugin (F5)
  - Notes: esperar a devolver el stash de la R27 (CodeGraph) en main, que toca los mismos README


<!-- Add items with format:
- [ ] **[SCOPE]** Brief description
  - Context: why it's needed
  - Acceptance criteria: what defines "done"
-->

## Completed (Recent)

- [x] **[plugin]** F1 — reordenar el repo como plugin `wf` *(session-20261027-1327-plugin-f1)*

- [x] **[plugin]** F0 — probar D1–D4 del plugin `wf` *(session-20261027-1218-plugin-f0)*

<!-- Items completed in recent sessions. Moved here by /finish.
Format: - [x] **[scope]** Description *(session-ID)*
Rotated to archive/COMPLETED.md when section grows large.
-->

## Ideas / Future

- [ ] **[plugin]** Hook `SessionStart` del proyecto que avise si falta el plugin (D4: hoy quien clona no ve ningún aviso)
- [ ] **[plugin]** Decidir si se borran los tags `wf--v0.1.0` / `wf--v0.2.0` del spike de F0

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
