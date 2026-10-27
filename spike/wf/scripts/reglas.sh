#!/usr/bin/env bash
# SessionStart: inyecta las reglas del framework como contexto adicional.
# Deja rastro en .wf-spike.log del proyecto para tener evidencia de cuándo corrió (D1).
set -euo pipefail
entrada=$(cat)
origen=$(printf '%s' "$entrada" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("source","?"))')
version=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["version"])' "${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json")
echo "$(date '+%F %T') wf@${version} SessionStart source=${origen} root=${CLAUDE_PLUGIN_ROOT}" >> "${CLAUDE_PROJECT_DIR:-.}/.wf-spike.log"
python3 - "$version" "${CLAUDE_PLUGIN_ROOT}/reglas/REGLAS.md" "$origen" <<'PY'
import json, sys
version, ruta, origen = sys.argv[1], sys.argv[2], sys.argv[3]
texto = f"[wf@{version} inyectado en SessionStart:{origen}]\n" + open(ruta).read()
print(json.dumps({"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": texto}}))
PY
