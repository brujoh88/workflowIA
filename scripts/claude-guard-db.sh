#!/bin/bash
# claude-guard-db.sh - Claude Code PreToolUse hook: database safety.
# Blocks destructive operations (always) and migrations/seeds run outside Docker
# (R18, only when docker.enabled is true) BEFORE they execute.
# exit 2 = deny (stderr -> Claude as feedback).
# Registered in the plugin's hooks/hooks.json (PreToolUse, matcher "Bash").
#
# NOTE: read-only / codegen commands (prisma generate, migrate diff, migrate status)
# are allowed on the host.

input=$(cat)
cd "${CLAUDE_PROJECT_DIR:-$PWD}" || exit 0
if command -v jq >/dev/null 2>&1; then
  cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)
else
  cmd="$input"
fi
[ -z "$cmd" ] && exit 0

low=$(printf '%s' "$cmd" | tr '[:upper:]' '[:lower:]')

CONFIG_FILE=".claude/project.config.json"
DOCKER_ENABLED="false"
DB_CONTAINER=""
if command -v jq >/dev/null 2>&1 && [ -f "$CONFIG_FILE" ]; then
  DOCKER_ENABLED=$(jq -r '.docker.enabled // false' "$CONFIG_FILE" 2>/dev/null)
  DB_CONTAINER=$(jq -r '.docker.dbContainer // ""' "$CONFIG_FILE" 2>/dev/null)
fi

# 1) Destructive operations ALWAYS blocked - they need EXPLICIT human confirmation
DESTRUCTIVE='migrate[[:space:]]+reset|--force-reset|--accept-data-loss|db[[:space:]]+push[[:space:]]+--force'
DESTRUCTIVE="$DESTRUCTIVE"'|drop[[:space:]]+(table|database|schema)|truncate[[:space:]]+'
DESTRUCTIVE="$DESTRUCTIVE"'|schema[[:space:]]+drop|migrate[[:space:]]+fresh|db:drop|dropdb'
if printf '%s' "$low" | grep -qE "$DESTRUCTIVE"; then
  echo "BLOCKED (R18): destructive database operation detected." >&2
  echo "These require EXPLICIT confirmation. If intentional, run it yourself manually." >&2
  exit 2
fi

# 2) Migration / seed outside Docker (R18) - only enforced when the project uses Docker for the DB
if [ "$DOCKER_ENABLED" = "true" ]; then
  # Common ORM migration/seed entrypoints across stacks
  MIGRATION='prisma[[:space:]]+(migrate|db[[:space:]]+(push|seed|execute)|seed)'
  MIGRATION="$MIGRATION"'|typeorm[[:space:]]+migration:(run|revert)|sequelize[[:space:]]+db:(migrate|seed)'
  MIGRATION="$MIGRATION"'|knex[[:space:]]+migrate|alembic[[:space:]]+upgrade'
  MIGRATION="$MIGRATION"'|manage\.py[[:space:]]+(migrate|loaddata)|rails[[:space:]]+db:(migrate|seed)'

  # Read-only exceptions that are fine on the host
  READONLY='prisma[[:space:]]+migrate[[:space:]]+(diff|status)|prisma[[:space:]]+generate'

  if printf '%s' "$low" | grep -qE "$MIGRATION" && ! printf '%s' "$low" | grep -qE "$READONLY"; then
    # "docker" must be invoked as a real executable (docker exec/compose/run), not as a
    # loose substring (a '# docker' comment or a ./docker/ path does not count).
    if ! printf '%s' "$low" | grep -qE '(^|[;&|[:space:]])docker[[:space:]]+(exec|compose|run)'; then
      echo "BLOCKED (R18): database commands (migrate/seed/push) must run INSIDE Docker." >&2
      if [ -n "$DB_CONTAINER" ] && [ "$DB_CONTAINER" != "null" ]; then
        echo "Use: docker exec $DB_CONTAINER sh -c '...'   or   docker compose exec ..." >&2
      else
        echo "Use: docker exec <container> sh -c '...'   or   docker compose exec ..." >&2
      fi
      exit 2
    fi
  fi
fi

exit 0
