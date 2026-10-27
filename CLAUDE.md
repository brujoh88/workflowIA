# workflowIA — el plugin `wf`

Este repo **es** el plugin `wf` de Claude Code y su tienda (`.claude-plugin/`). También se usa a sí
mismo: sus sesiones, ruta y backlog viven en `context/`, como en cualquier proyecto que use el plugin.

## Cómo se trabaja acá

- Abrir Claude cargando el plugin desde este directorio: `claude --plugin-dir .`
  Los comandos son los del plugin: `/wf:start`, `/wf:finish`, `/wf:review-code`…
- Lo que viaja a los proyectos es lo de la raíz del plugin: `skills/`, `agents/`, `hooks/`,
  `scripts/` (los que llaman los hooks de Claude), `bin/` y `plantillas/`.
- `plantillas/` es lo que `/wf:setup` copia **una vez** a cada proyecto (con `wf-plantillas`).
  `context/`, `.claude/project.config.json` y `.claude/MEMORY.md` de la raíz son **de este repo**,
  no plantillas: no se editan pensando en los proyectos.
- Archivos de proyecto en la raíz del repo viajan con el plugin si Claude Code los reconoce
  (pasó con `.mcp.json`): antes de agregar uno, `claude plugin validate .`.
- Plan vigente: `.claude/plan/2026-10-27-workflow-como-plugin.md`.

## Reglas del framework

Hasta F2 (partir el CLAUDE.md), las reglas viven en una sola casa: la plantilla.

@plantillas/CLAUDE.md

## Referencias de este repo

- @context/ROUTE.md
- @context/README.md
- @context/BACKLOG.md
- @context/ENVIRONMENT.md
- @.claude/MANUAL.md
- @.claude/MEMORY.md
