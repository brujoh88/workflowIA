# Session: 20261027-1327-plugin-f1

- **Branch**: feature/plugin-f1
- **Date**: 2026-10-27
- **Start**: 2026-10-27 13:27
- **Status**: COMPLETED
- **ROADMAP Module**: N/A (el ROADMAP es todavía la plantilla vacía)
- **Plan**: `.claude/plan/2026-10-27-workflow-como-plugin.md` — fase F1

## Objective
F1 del plan: reordenar el repo del workflowIA como plugin `wf` (estructura `.claude-plugin/`,
`skills/`, `agents/`, `hooks/hooks.json`, `scripts/`, `bin/`, `reglas/`, `plantillas/`).

Arrastra de F0 (`context/verifications/2026-10-27-plugin-f0.md`):
- borrar `spike/wf/`
- canales `wf` y `wf-estable` en la tienda — fijar versión es **por canal** (D3, decidido 2026-10-27)
- paso de instalación para quien clona en el README que genera `/setup` (D4); evaluar un hook
  `SessionStart` del proyecto que avise si falta el plugin
- decidir si se borran los tags `wf--v0.1.0` / `wf--v0.2.0` del spike
- decidir dónde vive la plantilla generada (decisión abierta 3 del plan)

Fuera de esta sesión: partir el CLAUDE.md (F2), pasar cosas a la config (F3), inventario (F4).

## BACKLOG Items Addressed
| Item | Status | Notes |
|------|--------|-------|
| **[plugin]** F1 — reordenar el repo como plugin `wf` | [x] Done | From BACKLOG |

## Initial Context
- Base branch: `feature/plugin-f0` (no `main`: F0 y F1 entran juntas a `main`, sin el spike)
- Stash pendiente en main: "README: R27 CodeGraph (apartado durante F0 plugin)"

## Quality Skills
- External skills to consult: none configured

## Progress
- Repo reordenado como plugin (`4078d86`): `skills/`, `agents/`, `hooks/hooks.json`, `scripts/`, `bin/`
  (`context-lock`, `wf-plantillas`), `plantillas/`. Spike de F0 borrado. Versión `3.0.0-alpha.1`.
- `wf-plantillas` completa el `settings.json` mínimo que crea la instalación (`0cad72f`).
- Probado con `--plugin-dir` y **instalado desde GitHub** (`#feature/plugin-f1`) en repos vacíos:
  12 skills + 9 agentes `wf:`, `bin/` en el PATH, plantillas copiadas sin pisar (idempotente),
  guard-main frena commit en main, git hooks del proyecto andan (commit-msg frena atribución),
  verdad-al-escribir, precompact, session-context y context-lock corren sobre el proyecto aunque
  se llamen desde otra carpeta.
- `/wf:setup` probado de punta a punta por el usuario (instalado desde GitHub). Encontró que R2 no
  protegía `main` en un repo sin commits → arreglado (`bd9546e`, FIXES).

## Decisions
- Plantilla generada: carpeta `plantilla/` en este mismo repo (usuario, 2026-10-27). El generador
  se arma después de F2, porque mete las reglas en el CLAUDE.md.
- Hasta F2, `plantillas/CLAUDE.md` es la única casa de las reglas; el CLAUDE.md raíz la importa.
- Git hooks: se copian a `scripts/hooks/` del proyecto (versionados) + `core.hooksPath`, como hasta
  ahora. El plan decía `.git/hooks`; se mantiene lo de hoy porque viaja con el clon.
- El candado de la verdad vive una vez en `plantillas/git-hooks/`; el hook de Claude usa la copia
  del proyecto, así al escribir y al commitear contesta el mismo.
- `.mcp.json` pasa a `plantillas/`: en la raíz viajaba con el plugin a todos los proyectos.
- Canal `wf-estable`: entra con la primera versión publicada (F5); hoy no hay qué fijar.

## Session Pending Items
- Hallazgo (arreglado): 7 de 9 agentes no tenían frontmatter → nunca se registraban (R8 no podía andar).
- F2: los proyectos con plugin no tienen `.claude/MANUAL.md` ni `QUALITY-SKILLS-CONTRACT.md`, y la
  plantilla del CLAUDE.md los importa con `@` (queda colgado).
- Textos de los skills todavía dicen `/start`, `/finish` sin el prefijo `wf:`.
- README raíz (instalación por plugin): esperar al stash de la R27 en main → F5.
- Tags `wf--v0.1.0`/`wf--v0.2.0` del spike: decidir si se borran.
- Idea D4: hook del proyecto que avise si falta el plugin (no se hizo).

## Final Summary
- **End**: 2026-10-27 14:48
- **Duration**: ~1h20
- **Objective**: F1 — reordenar el workflowIA como plugin `wf`
- **Result**: plugin instalable desde GitHub; `/wf:setup` arma un proyecto de cero; agentes registrados; R2 cubre el repo recién creado
- **Commits**: 3 (`4078d86`, `0cad72f`, `bd9546e`) + 1 de documentación
- **Tests**: el repo no tiene suite; pruebas manuales en repos descartables (detalle en Progress)
- **BACKLOG items**: 1 completed; 6 pendientes nuevos cargados
- **Link**: branch `feature/plugin-f1`, session `20261027-1327-plugin-f1`
