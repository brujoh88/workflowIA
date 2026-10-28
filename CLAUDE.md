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

Viven en una sola casa: `reglas/REGLAS.md`. Llegan a cada sesión (también a las de este repo, si
se abre con `--plugin-dir .`) por el hook `SessionStart` del plugin (`scripts/claude-reglas.sh`),
como índice corto: el `### WF-R…` de cada regla más la línea `>` de abajo. Esa línea es lo que se
paga en cada arranque y resume: una oración, ~110 caracteres.

`plantillas/CLAUDE.md` es el esqueleto del proyecto: arquitectura, comandos, convenciones,
negocio y reglas propias desde `R27`. No lleva reglas del framework.

## Reglas de este repo

### R27. El MANUAL acompaña al plugin
Cuando cambia un skill, agente, hook o regla, se actualiza `docs/MANUAL.md` en el mismo commit.
Es la referencia de uso del framework y la que el hook le muestra a cada proyecto. (Era la R17 del
framework; en F2 pasó a ser de este repo porque los proyectos no tienen MANUAL propio.)

## Referencias de este repo

- @context/ROUTE.md
- @context/README.md
- @context/BACKLOG.md
- @context/ENVIRONMENT.md
- @docs/MANUAL.md
- @.claude/MEMORY.md
