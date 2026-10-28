# Session: 20261028-0914-generador-plantilla

- **Branch**: feature/generador-plantilla
- **Date**: 2026-10-28
- **Start**: 2026-10-28 09:14
- **Status**: COMPLETED
- **ROADMAP Module**: N/A (el ROADMAP de este repo sigue en plantilla)
- **Plan**: `.claude/plan/2026-10-27-workflow-como-plugin.md` → decisión 3

## Objective
Generar `plantilla/` (la versión que se clona sin plugin) a partir del plugin, y un candado que no
deje commitear si quedó distinta de lo que sale del plugin.

- `scripts/armar-plantilla.sh`: `skills/` → `.claude/skills/`, `agents/` → `.claude/agents/`,
  `${CLAUDE_PLUGIN_ROOT}` → `$CLAUDE_PROJECT_DIR`, las reglas de `reglas/REGLAS.md` adentro del
  CLAUDE.md, y lo de `plantillas/` en su lugar.
- Candado en el pre-commit **de este repo**: regenera y corta si difiere.

Criterios (BACKLOG): `scripts/armar-plantilla.sh` la genera; el pre-commit la regenera y corta si difiere.

## BACKLOG Items Addressed
| Item | Status | Notes |
|------|--------|-------|
| **[plugin]** Generador de `plantilla/` + candado | [x] Done | Los dos criterios cumplidos; 3 ítems nuevos de la revisión |

## Initial Context
- Base branch: `main`
- Ojo: en este repo `core.hooksPath` apunta a `plantillas/git-hooks/`, que viaja a los proyectos.
  El candado no puede ir ahí.
- Relevant files: `scripts/`, `hooks/hooks.json`, `plantillas/`, `reglas/REGLAS.md`, `bin/`

## Quality Skills
- External skills to consult: none configured

## Progress
- `scripts/armar-plantilla.sh`: genera `plantilla/` (60 archivos). Idempotente (dos corridas, `diff -r` vacío).
  Skills/agentes → `.claude/`; reglas, docs, scripts de hooks y `context-lock` → `.claude/wf/`; hooks del
  plugin → `settings.json` con `$CLAUDE_PROJECT_DIR/.claude/wf`; sin tienda ni `wf@workflowia`; `/wf:` → `/`;
  paso 0 de `/setup` reemplazado por "habilitar git hooks".
- Probado en un clon (scratchpad): el índice de reglas sale desde `.claude/wf`; con `allowCommitsOnMain`
  en false, guard-main deniega el push (exit 2) y el git pre-commit frena el commit en main.
- `.githooks/` propio de este repo (pre-commit = el de `plantillas/` + candado; los otros delegan).
  `core.hooksPath` de este repo → `.githooks`. Probados los 5 casos: al día pasa; plugin tocado sin
  regenerar, plantilla editada a mano y regenerada sin agregar cortan con su mensaje.
- Bug encontrado y corregido en `plantillas/git-hooks/pre-commit`: el control de tamaño sólo reconocía
  git hooks en `scripts/hooks/` de la raíz; `plantilla/scripts/hooks/` caía en el límite de 150 de
  "hooks de React". Ahora también `*/scripts/hooks/*`.
- MANUAL (sección "Without the Plugin") y CLAUDE.md del repo actualizados.
- `/wf:review-code` (2026-10-28): CONDICIONAL, 0 críticos, 6 importantes. Arreglados en la sesión:
  candado contra el índice (no el disco) y con permisos de ejecución (#1, #7); seguro antes de
  `rm -rf` (#2); `/setup` de la plantilla sin los pasos del plugin (pasos 0, 7, 7.6 y frases sueltas)
  y sin `Bash(wf-plantillas:*)` (#3, #9); permiso de `context-lock` en `/start` (#4); reemplazos que
  cortan si no encuentran el texto, y el CLAUDE.md cambia solo la oración, sin números fijos (#5);
  "viene con el plugin" fuera de las reglas y de las cabeceras de los scripts (#8).
  A BACKLOG: helper compartido de mapeo (#6), CI + aviso de `core.hooksPath` + script de casos (#10, #11).
- Probado: candado A) al día pasa; C) plugin tocado sin agregar pasa; B) plugin agregado sin regenerar,
  D) plantilla editada a mano y E) hook sin `+x` cortan; F) el generador corta si cambia un texto ancla;
  el seguro no borra una carpeta ajena.
- Hallazgo: Claude Code descubre `plantilla/.claude/skills/` y ofrece 12 skills `plantilla:*` en este
  repo → BACKLOG (decidir si la plantilla sale a rama/repo aparte).

## Decisions
- Candado en `.githooks/` propio del repo, no en `plantillas/git-hooks/` (decidido con el usuario):
  así no viaja a los proyectos.
- Las reglas llegan a la plantilla por el mismo hook que en el plugin (índice al arrancar), no
  "metidas en el CLAUDE.md" como decía el plan: una sola forma de recibirlas y el CLAUDE.md no se
  infla ~300 líneas por sesión.
- Se clona con `npx degit brujoh88/workflowIA/plantilla` (GitHub no clona subcarpetas).

## Session Pending Items
- Quien clone el repo workflowIA tiene que hacer `git config core.hooksPath .githooks` a mano; no hay
  aviso si no lo hace (el candado simplemente no corre).
- Un clon de la plantilla no recibe actualizaciones; el camino para actualizar es pasarse al plugin.
- No se probó un `claude` real dentro del clon (solo los scripts de hooks a mano).

## Final Summary
- **End**: 2026-10-28
- **Duration**: una jornada (arranque 09:14)
- **Objective**: generar `plantilla/` desde el plugin y un candado que corte si quedó distinta
- **Result**: `scripts/armar-plantilla.sh` + `.githooks/pre-commit` (contra el índice); probado en un clon con Claude real
- **Commits**: 2 de código + 1 de documentación
- **Files modified**: 70 (62 son la plantilla generada)
- **Tests**: N/A (repo sin suite); 7 casos del candado/generador a mano, `bash -n`, `claude plugin validate .` OK
- **BACKLOG items**: 1 completado; 3 nuevos (skills duplicados, mapeo compartido, CI)
- **Link**: branch `feature/generador-plantilla`, session `20261028-0914-generador-plantilla`
