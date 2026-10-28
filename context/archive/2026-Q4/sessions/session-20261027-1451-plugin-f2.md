# Session: 20261027-1451-plugin-f2

- **Branch**: feature/plugin-f2
- **Date**: 2026-10-27
- **Start**: 2026-10-27 14:51
- **Status**: COMPLETED
- **ROADMAP Module**: N/A (el ROADMAP de este repo sigue en plantilla)
- **Plan**: `.claude/plan/2026-10-27-workflow-como-plugin.md` → F2

## Objective
F2 del plugin `wf`: partir el CLAUDE.md en dos.

- **Del framework** (`reglas/`, inyectadas por un hook `SessionStart` del plugin): R1–R26 renombradas
  `WF-R1…`, la tabla de ruteo de documentos, la delegación a agentes, la forma de responder.
- **Del proyecto** (`plantillas/CLAUDE.md`): arquitectura, comandos, convenciones, contexto de
  negocio, reglas propias (desde `R27`).

Criterios (BACKLOG):
- `plantillas/CLAUDE.md` sin reglas del framework.
- Las reglas `WF-R…` llegan por hook.
- El CLAUDE.md raíz deja de importar la plantilla.
- Resolver dónde viven MANUAL y QUALITY-SKILLS-CONTRACT en un proyecto con plugin (hoy la plantilla
  los importa con `@` y quedan colgados).

Restricción (D1 de F0): la inyección se suma entera en cada resume → reglas cortas.

## BACKLOG Items Addressed
| Item | Status | Notes |
|------|--------|-------|
| **[plugin]** F2 — partir el CLAUDE.md | [x] Done | Los 4 criterios cumplidos; "forma de responder" pasó a BACKLOG |

## Initial Context
- Base branch: `feature/plugin-f1` (F1 todavía no está en main; decidido con el usuario: F2 sale
  de F1 y se mergean juntas)
- ROADMAP module: N/A
- Relevant files: `plantillas/CLAUDE.md`, `CLAUDE.md`, `hooks/hooks.json`,
  `scripts/claude-session-context.sh`, `.claude/MANUAL.md`

## Quality Skills
- External skills to consult: none configured

## Progress
- `reglas/REGLAS.md`: texto completo de WF-R1…WF-R26 (sin R17) + tabla de ruteo + delegación
  (dentro de WF-R8). Cada regla lleva una línea `>` bajo el título: de ahí sale el índice.
- `scripts/claude-reglas.sh` + entrada en `hooks/hooks.json` (SessionStart, sin matcher). Salida
  medida: 48 líneas, 4,7 KB (antes ~15 KB de framework en el CLAUDE.md).
- `plantillas/CLAUDE.md`: solo esqueleto del proyecto (334 → ~60 líneas), sección `Project Rules`
  desde R27, sin `@` a MANUAL ni contrato.
- `CLAUDE.md` raíz: ya no importa la plantilla; R17 vive acá como R27 del repo.
- MANUAL y QUALITY-SKILLS-CONTRACT → `docs/` del plugin; el hook imprime sus rutas absolutas.
- Renumeración R1–R26 → WF-R en 20 archivos (skills, agentes, scripts, git hooks, plantillas).
  El "R30" de ejemplo del candado de la verdad quedó intacto (es regla de proyecto).
- MANUAL: la tabla de reglas se reemplazó por un puntero a `reglas/REGLAS.md` (sería otra copia).
- Verificado: `claude -p --plugin-dir .` en un repo vacío devolvió la línea de WF-R22 y la ruta
  de REGLAS.md sin usar herramientas. `claude plugin validate .` pasa (solo el aviso del README, F5).
- `/wf:review-code` (2026-10-28): CONDICIONAL, 0 críticos. Ruteo aprobado: archivos nuevos van en el
  commit de F2 (ya en el índice); migración de reglas → plan F6 + BACKLOG Next; forma de responder →
  BACKLOG Next (pospuesta, no entra en F2); aviso de línea `>` y reglas repetidas al compactar →
  BACKLOG Ideas; lista de hooks del MANUAL corregida.

## Decisions
- Rama base `feature/plugin-f1` en lugar de `main` (F1 sin mergear).
- Se inyecta un índice corto, no el texto completo (decidido con el usuario: 4,7 KB vs ~15 KB por
  cada arranque/resume).
- El índice se genera de `REGLAS.md` (título + línea `>`): una sola casa para cada regla.
- R17 sale del framework: es de quien mantiene el workflowIA. Numeración WF-R17 queda vacía.
- MANUAL y contrato son documentación del framework → `docs/` del plugin, no del proyecto.

## Session Pending Items
- Los proyectos existentes (caluprobeauty, fiscoStock-saas) siguen con las reglas enteras y la
  numeración vieja en su CLAUDE.md → va en F6 (migración).
- `claude-session-context.sh` (compact) repite 5 reglas críticas que ahora también trae el índice:
  solapamiento chico, se puede recortar más adelante.
- No se probó el resume con este hook nuevo (D1 de F0 ya probó que SessionStart llega en resume).

## Final Summary
- **End**: 2026-10-28
- **Duration**: ~1 día calendario (arranque 2026-10-27 14:51)
- **Objective**: partir el CLAUDE.md en reglas del framework (hook) y esqueleto del proyecto
- **Result**: reglas `WF-R…` en `reglas/REGLAS.md`, inyectadas como índice de 4,7 KB por `claude-reglas.sh`; plantilla solo con el proyecto; MANUAL y contrato en `docs/`
- **Commits**: 1 de código + 1 de documentación
- **Files modified**: 30 (2 nuevos, 2 movidos)
- **Tests**: N/A (repo sin suite); `bash -n` de scripts y hooks OK, `hooks.json` válido, `claude plugin validate .` pasa con el aviso conocido del README (F5)
- **BACKLOG items**: 1 completado; 4 nuevos desde la revisión
- **Link**: branch `feature/plugin-f2`, session `20261027-1451-plugin-f2`
