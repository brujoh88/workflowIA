# Session: 20261028-1341-readme-plugin

- **Branch**: feature/readme-plugin
- **Date**: 2026-10-28
- **Start**: 2026-10-28 13:41
- **Status**: COMPLETED
- **ROADMAP Module**: N/A (este repo trackea por el plan del plugin, no por ROADMAP)
- **Plan**: none — no size signals (el ítem no tenía criterio; se escribió al arrancar)

## Objective
README raíz (inglés y español) con la forma nueva de usar el workflow: instalar el plugin `wf`,
o clonar `plantilla/` sin plugin. Más una sección "cómo mejorar el workflow": arreglar en este
repo, probar en el proyecto real con `--plugin-dir`, publicar. Se adelanta a F3 (pedido del usuario).

## BACKLOG Items Addressed
| Item | Status | Notes |
|------|--------|-------|
| **[plugin]** README raíz con la instalación por plugin (F5) | [ ] Pending | From BACKLOG |

## Initial Context
- Base branch: main
- El README actual dice "cloná este repo como plantilla": la forma vieja
- Stash en main "README: R27 CodeGraph (apartado durante F0 plugin)": solo toca los dos README
  (cuenta 27 reglas, agrega fila R27 CodeGraph y `scripts/codegraph.sh`). En el repo no existe ni
  la regla ni el script.
- Relevant files: `README.md`, `README.es.md`

## Quality Skills
- External skills to consult: none configured

## Progress
- Probado: `claude -p --plugin-dir ~/…/workflowIA` desde una carpeta vacía carga los 12 skills
  `wf:` y el índice de reglas.
- Probado: en un proyecto con `wf@workflowia` instalado (scope project), `--plugin-dir` reemplaza
  al instalado. El debug dice `Plugin "wf" from --plugin-dir overrides installed version`; un solo
  `wf:start`, un solo bloque de reglas.
- README.md y README.es.md reescritos: instalación por plugin, sin plugin (degit), día a día,
  "cómo mejorar el workflow", reglas por puntero a `reglas/REGLAS.md` (sin la tabla R1–R26).
- Probado: `claude plugin install wf --marketplace brujoh88/workflowIA -s project` **hoy falla**
  ("Marketplace file not found"): main en GitHub no tiene `.claude-plugin/` porque los 13 commits
  del plugin no se pushearon. Lo mismo vale para `npx degit …/plantilla`. El README describe cómo
  queda después del push.
- Probado: si la máquina ya tiene `workflowia` de otra fuente, la instalación corta con "already
  added from a different source". Se agregó al README cómo salir (`marketplace remove`).
- Los plugins instalados se guardan por versión (`~/.claude/plugins/cache/workflowia/wf/<versión>/`):
  por eso el paso "publicar" del README dice subir `version`. No se probó un `plugin update` real.
- `/wf:review-code`: READY, 0 críticos, 2 importantes, 2 sugerencias. Ruteo *(from review on feature/readme-plugin, 2026-10-28)*:
  1. "26 reglas" estaba mal (activas 25, WF-R17 retirada) → arreglado: el README ya no da número.
  2. La línea de `jq` decía que sin él no bloquean → arreglado en los dos idiomas: bloquean igual,
     con valores por defecto (verificado en `claude-guard-main.sh:28-32`, `claude-guard-db.sh:13-17`).
  3. Ejemplo de config con `allowCommitsOnMain: false` vs plantilla `true` → arreglado con una nota.
  4. La instalación depende del push → queda en Pending Items y pasa a la ROUTE al cerrar.

## Decisions
- El README no lista las reglas: apunta a `reglas/REGLAS.md` (una segunda lista se desactualiza,
  mismo criterio que el MANUAL).
- El stash "README: R27 CodeGraph" no se aplicó: su contenido (tabla de reglas, 27 reglas,
  `scripts/codegraph.sh`) no aplica al README nuevo y ni la regla ni el script existen. Queda el
  stash intacto hasta que el usuario decida.

## Session Pending Items
- La tienda `workflowia` de esta máquina apunta a `brujoh88/workflowIA@feature/plugin-f1`; al
  publicar hay que apuntarla a main (`claude plugin marketplace remove workflowia` + instalar).
- Push de main: lo decide el usuario. Sin él, nada de lo que dice el README funciona desde GitHub.

## Final Summary
- **End**: 2026-10-28 14:05
- **Duration**: ~25 min
- **Objective**: README con la instalación por plugin, la copia sin plugin y cómo mejorar el workflow
- **Result**: README.md y README.es.md reescritos; el ciclo "arreglar acá → probar con --plugin-dir → publicar" probado salvo el `plugin update`
- **Commits**: 2 (+ cierre)
- **Files modified**: 2 (README.md, README.es.md)
- **Tests**: N/A (el repo no tiene suite; `claude plugin validate .` pasa con los avisos ya conocidos de CLAUDE.md/CLAUDE.local.md en la raíz)
- **BACKLOG items**: 1 completed, 0 partial
- **Link**: branch `feature/readme-plugin`, session `20261028-1341-readme-plugin`
