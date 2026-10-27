# Fixes Registry

Centralized tracking for bug fixes and issues.

**Last updated**: 2026-10-27

## Fix Workflows

| Workflow | When to Use | Process |
|----------|-------------|---------|
| **Quick fix** | 1-2 files, clear cause | Fix → test → commit directly |
| **`/start`** | Complex, multi-file, unclear cause | Full session with debugging protocol |
| **Batch** | Multiple small related fixes | Group → fix all → single commit |

## Pending

<!-- Format:
- [ ] **[scope]** Brief description
  - **Reported**: YYYY-MM-DD
  - **Severity**: critical / high / medium / low
  - **Reproduction**: Steps or context
-->

## In Progress

<!-- Items being actively fixed (moved from Pending) -->

## Resolved (Recent)

- [x] **R2 no protegía `main` en un repo sin commits** · severidad: media · 2026-10-27
  - Síntoma: en un repo recién creado, Claude commiteó en `main` sin que lo frenaran ni el guardia ni el `pre-commit`.
  - Causa raíz: los dos averiguaban la rama con `git rev-parse --abbrev-ref HEAD`, que sin commits responde `HEAD` y no `main`. Venía de la v2.5, no del plugin.
  - Arreglo: se usa `git symbolic-ref --short HEAD`, y el commit inicial pasa **a propósito** (es el que crea `main`). `/wf:setup` lo hace con las plantillas (paso 8.5), así la ventana se cierra al terminar el setup. Probado: sin historia pasa con aviso; con historia, el guardia y el `pre-commit` bloquean; en otra rama, pasa.
  - Sesión: session-20261027-1327-plugin-f1 (encontrado por el usuario probando `/wf:setup`).

<!-- Format:
- [x] **[scope]** Brief description *(session-ID or commit-hash)*
  - **Fixed**: YYYY-MM-DD
  - **Root cause**: What caused the issue
  - **Fix**: What was changed
-->

---

## How to Use

1. **Report**: Add new issues to "Pending" with severity
2. **Quick fix**: For simple fixes, fix directly and move to "Resolved"
3. **Complex fix**: Use `/start fix-description` for full debugging protocol
4. **Batch fix**: Group related small fixes, fix together, single commit
5. **Archive**: When "Resolved" section grows large, move oldest to `archive/COMPLETED.md`
