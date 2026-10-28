#!/bin/bash
# claude-session-context.sh - Claude Code SessionStart hook (matcher "compact").
# Its STDOUT is re-injected into Claude's context after a compaction, to mitigate
# context-rot (detail lost when the conversation is summarized).
#
# Receives the event via stdin (JSON with .source). Always exits 0.
# Registered in the plugin's hooks/hooks.json (SessionStart, matcher "compact").

set -uo pipefail
cat >/dev/null 2>&1 || true   # consume stdin
cd "${CLAUDE_PROJECT_DIR:-$PWD}" || exit 0

CONFIG_FILE=".claude/project.config.json"
MAIN_BRANCH="main"
CHAT_LANG="es"
DOCKER_ENABLED="false"
TEST_WORKERS="2"
if command -v jq >/dev/null 2>&1 && [ -f "$CONFIG_FILE" ]; then
  MAIN_BRANCH=$(jq -r '.git.mainBranch // "main"' "$CONFIG_FILE" 2>/dev/null)
  CHAT_LANG=$(jq -r '.language.chat // "es"' "$CONFIG_FILE" 2>/dev/null)
  DOCKER_ENABLED=$(jq -r '.docker.enabled // false' "$CONFIG_FILE" 2>/dev/null)
  TEST_WORKERS=$(jq -r '.workflow.testMaxWorkers // 2' "$CONFIG_FILE" 2>/dev/null)
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "?")
ACTIVE=$(grep -lE "Status.*IN_PROGRESS" context/tmp/session-*.md 2>/dev/null | sed 's#context/tmp/##' | tr '\n' ' ')

echo "=== CONTEXT RE-INJECTED AFTER COMPACTION (SessionStart hook) ==="
echo "Current branch: $BRANCH"
echo "Sessions IN_PROGRESS: ${ACTIVE:-(none)}"
echo "Recent commits:"
git log --oneline -5 2>/dev/null | sed 's/^/  /' || true

# Current work item (single source of "what's next")
if [ -f "context/ROUTE.md" ]; then
  echo "Current item (context/ROUTE.md -> NOW):"
  sed -n '/^## NOW/,/^---/p' context/ROUTE.md 2>/dev/null | sed -n '2,8p' | sed 's/^/  /'
fi

if [ -f "context/tmp/pre-compact-snapshot.md" ]; then
  echo "Previous snapshot available at: context/tmp/pre-compact-snapshot.md"
fi

echo "Critical rules not to forget:"
echo "  - WF-R2: NEVER commit/push directly to '$MAIN_BRANCH' (merges only, with explicit consent)."
echo "  - WF-R3: commits WITHOUT AI attribution / Co-Authored-By."
if [ "$DOCKER_ENABLED" = "true" ]; then
  echo "  - WF-R18: DB commands (migrate/seed) ALWAYS inside Docker."
fi
echo "  - WF-R19: run tests with --maxWorkers=$TEST_WORKERS, never in background."
echo "  - WF-R14: zero inference - back every claim with a concrete source (file, grep, git, test output)."
echo "  - Language: always answer in '$CHAT_LANG'."
echo "==============================================================="
exit 0
