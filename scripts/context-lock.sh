#!/bin/bash
# context-lock.sh — Lock for context operations (parallel sessions)
#
# Usage:
#   ./scripts/context-lock.sh acquire <session-id> <operation>
#   ./scripts/context-lock.sh release
#   ./scripts/context-lock.sh check
#
# Lock file: context/.context.lock
# Internal format: PID|TIMESTAMP|SESSION_ID|OPERATION
# Timeout: 60 seconds (configurable via project.config.json)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

LOCK_FILE="$PROJECT_ROOT/context/.context.lock"
TIMEOUT_SECONDS=60

# Read timeout from project.config.json if available
CONFIG_FILE="$PROJECT_ROOT/.claude/project.config.json"
if command -v jq >/dev/null 2>&1 && [ -f "$CONFIG_FILE" ]; then
  CUSTOM_TIMEOUT=$(jq -r '.parallel.lockTimeoutSeconds // 60' "$CONFIG_FILE" 2>/dev/null)
  if [ "$CUSTOM_TIMEOUT" -gt 0 ] 2>/dev/null; then
    TIMEOUT_SECONDS=$CUSTOM_TIMEOUT
  fi
fi

case "${1:-}" in
  acquire)
    SESSION_ID="${2:-unknown}"
    OPERATION="${3:-unknown}"

    if [ -f "$LOCK_FILE" ]; then
      LOCK_TIMESTAMP=$(cut -d'|' -f2 "$LOCK_FILE")
      NOW=$(date +%s)
      LOCK_AGE=$(( NOW - LOCK_TIMESTAMP ))

      if [ "$LOCK_AGE" -gt "$TIMEOUT_SECONDS" ]; then
        LOCK_OWNER=$(cat "$LOCK_FILE")
        echo "WARN: Expired lock (${LOCK_AGE}s). Forcing release."
        echo "  Previous lock: $LOCK_OWNER"
        rm -f "$LOCK_FILE"
      else
        LOCK_OWNER=$(cat "$LOCK_FILE")
        echo "ERROR: Active lock (${LOCK_AGE}s of ${TIMEOUT_SECONDS}s max)"
        echo "  Held by: $LOCK_OWNER"
        echo "  Retry in $(( TIMEOUT_SECONDS - LOCK_AGE ))s or wait for the other operation to finish."
        exit 1
      fi
    fi

    echo "$$|$(date +%s)|${SESSION_ID}|${OPERATION}" > "$LOCK_FILE"
    echo "OK: Lock acquired by session '${SESSION_ID}' (operation: ${OPERATION})"
    ;;

  release)
    if [ -f "$LOCK_FILE" ]; then
      rm -f "$LOCK_FILE"
      echo "OK: Lock released"
    else
      echo "OK: No active lock"
    fi
    ;;

  check)
    if [ -f "$LOCK_FILE" ]; then
      LOCK_TIMESTAMP=$(cut -d'|' -f2 "$LOCK_FILE")
      NOW=$(date +%s)
      LOCK_AGE=$(( NOW - LOCK_TIMESTAMP ))
      LOCK_OWNER=$(cat "$LOCK_FILE")
      echo "BUSY (${LOCK_AGE}s): $LOCK_OWNER"
      exit 1
    else
      echo "FREE"
      exit 0
    fi
    ;;

  *)
    echo "Usage: $0 {acquire|release|check} [session-id] [operation]"
    echo ""
    echo "Commands:"
    echo "  acquire <session-id> <operation>  Acquire context lock"
    echo "  release                           Release context lock"
    echo "  check                             Check lock status"
    exit 1
    ;;
esac
