#!/bin/bash
# claude-reglas.sh - Claude Code SessionStart hook (every source: startup, resume, clear, compact).
# Its STDOUT is injected into Claude's context: the framework rules (WF-R…) arrive this way,
# because a plugin cannot bring a CLAUDE.md.
#
# It injects an INDEX, not the full text: one line per rule (the "### WF-R…" heading plus the
# ">" line under it in reglas/REGLAS.md) and the routing table. Every resume adds the output
# again (verified in F0, D1), so it has to stay short. The full text is read on demand.
#
# Receives the event via stdin (JSON). Always exits 0.
# Registered in the plugin's hooks/hooks.json (SessionStart, no matcher).

set -uo pipefail
cat >/dev/null 2>&1 || true   # consume stdin

ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
REGLAS="$ROOT/reglas/REGLAS.md"
[ -f "$REGLAS" ] || exit 0

echo "=== wf framework rules (injected by the wf plugin) ==="
echo "Framework rules are WF-R…; the project's own rules live in its CLAUDE.md and start at R27."
echo "Full text of each rule: $REGLAS — read it before applying a rule you are unsure about."
echo "Manual: $ROOT/docs/MANUAL.md · Quality skills contract: $ROOT/docs/QUALITY-SKILLS-CONTRACT.md"
echo
awk '
  /^### WF-R/ { sub(/^### /, ""); titulo = $0; next }
  titulo != "" && /^> / { sub(/^> /, ""); print "- " titulo " — " $0; titulo = ""; next }
  titulo != "" && NF { print "- " titulo; titulo = "" }
' "$REGLAS"
echo
echo "Document routing:"
sed -n '/^## Document routing/,/^## /p' "$REGLAS" | grep '^|' | grep -v '^|--'
echo "==============================================================="
exit 0
