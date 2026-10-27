#!/usr/bin/env bash
# PreToolUse (Bash): deja rastro de cada llamada y deniega un comando testigo (D2).
set -euo pipefail
entrada=$(cat)
comando=$(printf '%s' "$entrada" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))')
echo "$(date '+%F %T') wf PreToolUse cmd=${comando}" >> "${CLAUDE_PROJECT_DIR:-.}/.wf-spike.log"
if [[ "$comando" == *WF_BLOQUEAME* ]]; then
  echo "wf: comando bloqueado por el guard del plugin (spike F0)" >&2
  exit 2
fi
exit 0
