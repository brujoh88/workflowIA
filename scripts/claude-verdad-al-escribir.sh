#!/bin/bash
# claude-verdad-al-escribir.sh - Claude Code PostToolUse hook: R30 en el momento.
#
# Corre el mismo candado que el pre-commit, pero sobre el archivo que se acaba de
# escribir y en el acto. El commit sigue siendo la red final; esto es lo que evita
# el trabajo doble: enterarse al cerrar la sesión es enterarse cuando ya escribiste
# trescientas líneas alrededor de la copia.
#
# No hay dos candados que mantener sincronizados: este llama a
# check-una-sola-verdad.sh --archivo. Duplicar justo esta regla sería gracioso.
#
# exit 2 = stderr vuelve a Claude como feedback. El archivo ya se escribió: el
# aviso no lo deshace, lo corrige el modelo en el turno siguiente.
# Registrado en hooks/hooks.json del plugin (PostToolUse, matcher "Write|Edit|MultiEdit").
#
# Usa la copia del candado que /setup dejó en el proyecto: es la misma que corre el
# pre-commit, así que al escribir y al commitear contesta siempre el mismo candado.

input=$(cat)
command -v jq >/dev/null 2>&1 || exit 0

archivo=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -z "$archivo" ] && exit 0

RAIZ="${CLAUDE_PROJECT_DIR:-$PWD}"
CHECK="$RAIZ/scripts/hooks/check-una-sola-verdad.sh"
[ -x "$CHECK" ] || exit 0

cd "$RAIZ" || exit 0

# El check calla solo cuando el proyecto no declara el bloque "truth", cuando la
# extensión no se mira, cuando el archivo está fuera del alcance o cuando la copia
# ya está inventariada. Acá sólo se traduce su "hay algo" al código que Claude lee.
salida=$("$CHECK" --archivo "$archivo" 2>&1)
[ $? -eq 0 ] && exit 0

printf '%s\n' "$salida" >&2
exit 2
