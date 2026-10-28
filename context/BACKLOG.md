# Backlog

Single source of pending items for the project.

**Last updated**: 2026-10-28
**Target**: <300 lines (cleanup on `/finish`)

## In Progress

_nada_

## Next (Prioritized)

- [ ] **[plugin]** Publicar: push de main y apuntar la tienda `workflowia` de esta máquina a main
  - Context: el README nuevo describe la instalación desde GitHub, que hoy falla ("Marketplace file not found") porque los commits del plugin no están pusheados; la tienda local apunta a `feature/plugin-f1`. *(session-20261028-1341-readme-plugin)*
  - Criteria: `claude plugin install wf --marketplace brujoh88/workflowIA -s project` anda en una carpeta vacía; `npx degit brujoh88/workflowIA/plantilla` trae la copia
- [ ] **[plugin]** Decidir qué hacer con el stash "README: R27 CodeGraph" (apartado en F0)
  - Context: habla de una regla CodeGraph y de `scripts/codegraph.sh` que no existen en el repo; el README nuevo ya no lista reglas. *(session-20261028-1341-readme-plugin)*
  - Criteria: o CodeGraph entra como ítem propio (regla + script), o el stash se descarta

- [ ] **[plugin]** Textos de los skills: prefijo `/wf:` y sin la opción "Lo escribo yo" que repite "Type something"
  - Context: visto en la prueba de `/wf:setup` (2026-10-27); el modelo a veces pone el prefijo solo, a veces no
  - Criteria: ningún skill nombra `/start`, `/finish`… sin `wf:`; las preguntas de texto libre no ofrecen una opción duplicada
- [ ] **[plugin]** `plantillas/.mcp.json` trae el servidor `db`: en un proyecto sin base falla al conectar
  - Criteria: la plantilla viene sin `db`, o `/wf:setup` lo saca cuando no hay base de datos
- [ ] **[plugin]** F6: migrar las reglas del `CLAUDE.md` de caluprobeauty y fiscoStock-saas (R1–R26 → fuera; referencias → `WF-R…`; propias desde R27 intactas)
  - Context: sin esto, al instalar el plugin las reglas llegan dos veces y con dos numeraciones. *(from review on feature/plugin-f2, 2026-10-28)*
  - Criteria: el `CLAUDE.md` de cada proyecto sin reglas del framework; ningún `R1`–`R26` suelto en sus archivos
- [ ] **[plugin]** Decidir si "la forma de responder" (*Avance / Necesito de vos*) entra al framework como `WF-R…`
  - Context: el F2 del plan la incluía, pero nunca se escribió. Hoy vive como preferencia personal en el CLAUDE.md global; como regla del framework se le impondría a cualquiera que instale el plugin. *(from review on feature/plugin-f2, 2026-10-28)*
  - Criteria: decidido; si entra, regla con su línea `>` en `reglas/REGLAS.md`
- [ ] **[plugin]** Una sola regla de "dónde va cada archivo de `plantillas/`" para `armar-plantilla.sh` y `wf-plantillas` *(from review on feature/generador-plantilla, 2026-10-28)*
  - Context: hoy los dos deciden por su cuenta (`git-hooks/` → `scripts/hooks/`, `gitignore` → `.gitignore`); un mapeo nuevo en uno no llega al otro y el candado no lo nota
  - Criteria: un helper compartido que usan los dos
- [ ] **[plugin]** Chequeo automático (CI) de la plantilla + aviso si `core.hooksPath` no es `.githooks` *(from review on feature/generador-plantilla, 2026-10-28)*
  - Context: quien clona este repo sin `git config core.hooksPath .githooks` no corre el candado y no se entera; los casos del candado se probaron a mano
  - Criteria: un job que corre el generador y `git diff --exit-code plantilla/`; los casos del candado en un script


<!-- Add items with format:
- [ ] **[SCOPE]** Brief description
  - Context: why it's needed
  - Acceptance criteria: what defines "done"
-->

## Completed (Recent)

- [x] **[plugin]** README raíz con la instalación por plugin, la copia sin plugin y cómo mejorar el workflow (F5) *(session-20261028-1341-readme-plugin)*
- [x] **[plugin]** Skills `plantilla:*` duplicados: la plantilla se queda en este repo. Una sesión nueva no los ve; aparecen solo si se lee algo de `plantilla/`. Anotado en el `CLAUDE.md` que se ignoran *(2026-10-28, sin sesión: era una decisión)*
- [x] **[plugin]** Generador de `plantilla/` + candado: `scripts/armar-plantilla.sh` y `.githooks/pre-commit` *(session-20261028-0914-generador-plantilla)*
- [x] **[plugin]** F2 — partir el CLAUDE.md: reglas `WF-R…` por hook, plantilla solo con el proyecto *(session-20261027-1451-plugin-f2)*

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

- [ ] **[plugin]** `claude-reglas.sh` avisa por stderr si una regla de `REGLAS.md` no tiene línea `>` (hoy sale solo el título, sin aviso) *(from review on feature/plugin-f2, 2026-10-28)*
- [ ] **[plugin]** `claude-session-context.sh` deja de repetir las 5 reglas que ya trae el índice: solo estado de sesión y líneas que dependen de la config (Docker, workers) *(from review on feature/plugin-f2, 2026-10-28)*

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
