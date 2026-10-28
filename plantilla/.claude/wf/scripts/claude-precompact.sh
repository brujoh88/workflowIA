#!/bin/bash
# claude-precompact.sh - Claude Code PreCompact hook (anti context-rot).
# Runs BEFORE the context is compacted. Persists a deterministic snapshot of the
# working state so it survives the summary.
#
# Receives the event via stdin (JSON with .trigger = manual|auto). Always exits 0.
# Registered in the plugin's hooks/hooks.json (PreCompact).

set -uo pipefail
input=$(cat 2>/dev/null || true)
cd "${CLAUDE_PROJECT_DIR:-$PWD}" || exit 0

trigger="unknown"
if command -v jq >/dev/null 2>&1; then
  trigger=$(printf '%s' "$input" | jq -r '.trigger // "unknown"' 2>/dev/null || echo "unknown")
fi

SNAP="context/tmp/pre-compact-snapshot.md"
mkdir -p context/tmp 2>/dev/null || true

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "?")
ACTIVE=$(grep -lE "Status.*IN_PROGRESS" context/tmp/session-*.md 2>/dev/null | tr '\n' ' ')

{
  echo "# Pre-compaction snapshot"
  echo
  echo "> Generated automatically by the PreCompact hook (trigger: $trigger)."
  echo "> Breadcrumb in case compaction loses detail. NOT the same as an interrupted session."
  echo
  echo "- **Branch**: \`$BRANCH\`"
  echo "- **Sessions IN_PROGRESS**: ${ACTIVE:-(none)}"
  echo
  echo "## Uncommitted changes (git status)"
  echo '```'
  git status --short 2>/dev/null || echo "(git unavailable)"
  echo '```'
  echo
  echo "## Recent commits"
  echo '```'
  git log --oneline -8 2>/dev/null || echo "(git unavailable)"
  echo '```'
} > "$SNAP" 2>/dev/null || true

# Export Engram memories before the context is summarized (best-effort, no-op if disabled).
CONFIG_FILE=".claude/project.config.json"
if command -v jq >/dev/null 2>&1 && [ -f "$CONFIG_FILE" ]; then
  ENGRAM_ENABLED=$(jq -r '.memory.engram.enabled // false' "$CONFIG_FILE" 2>/dev/null)
  if [ "$ENGRAM_ENABLED" = "true" ] && command -v engram >/dev/null 2>&1; then
    engram sync >/dev/null 2>&1 || true
  fi
fi

exit 0
