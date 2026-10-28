#!/bin/bash
# claude-guard-main.sh - Claude Code PreToolUse hook (live deterministic layer).
# Blocks dangerous git operations on the protected branch BEFORE they run (WF-R2).
#
# Receives the event via stdin (JSON). Hook convention:
#   exit 0 -> allow   |   exit 2 -> DENY and return stderr to Claude as feedback.
# Registered in the plugin's hooks/hooks.json (PreToolUse, matcher "Bash").
#
# NOTE: complements the pre-commit git hook. This one runs inside the agent loop
# (before the command executes); the git hook runs at commit time.

input=$(cat)
cd "${CLAUDE_PROJECT_DIR:-$PWD}" || exit 0

CONFIG_FILE=".claude/project.config.json"
MAIN_BRANCH="main"
ALLOW_ON_MAIN="false"
if command -v jq >/dev/null 2>&1 && [ -f "$CONFIG_FILE" ]; then
  MAIN_BRANCH=$(jq -r '.git.mainBranch // "main"' "$CONFIG_FILE" 2>/dev/null)
  [ -z "$MAIN_BRANCH" ] || [ "$MAIN_BRANCH" = "null" ] && MAIN_BRANCH="main"
  # Escape hatch for repos whose main branch IS the working branch (a framework/template repo
  # with no downstream deployment). `/setup` sets this to false for derived projects.
  ALLOW_ON_MAIN=$(jq -r '.git.allowCommitsOnMain // false' "$CONFIG_FILE" 2>/dev/null)
fi

[ "$ALLOW_ON_MAIN" = "true" ] && exit 0

# Extract the bash command from the event
if command -v jq >/dev/null 2>&1; then
  cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)
else
  cmd="$input"   # fallback: inspect raw payload (fail-open when jq is missing)
fi

[ -z "$cmd" ] && exit 0

# symbolic-ref names the branch even before the first commit; rev-parse answers "HEAD" there
# and let a commit on main through unnoticed.
branch=$(git symbolic-ref --short -q HEAD 2>/dev/null || git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
# A repo with no commits yet: the first commit is the one that creates main, and nothing can
# branch from a main that does not exist. It is let through on purpose — /setup makes it.
has_history=1
git rev-parse --verify -q HEAD >/dev/null 2>&1 || has_history=0

# Detect git commit / git push (tolerating intermediate flags: git -c x commit, git push --force, ...)
is_commit=0
is_push=0
printf '%s' "$cmd" | grep -qE '(^|[;&|[:space:]])git[[:space:]]+([^;&|]*[[:space:]])?commit' && is_commit=1
printf '%s' "$cmd" | grep -qE '(^|[;&|[:space:]])git[[:space:]]+([^;&|]*[[:space:]])?push'   && is_push=1

# 1) commit while standing on the protected branch
if [ "$is_commit" = "1" ] && [ "$branch" = "$MAIN_BRANCH" ] && [ "$has_history" = "1" ]; then
  echo "BLOCKED (WF-R2): direct commit on '$MAIN_BRANCH'. Switch to a feature/fix branch first." >&2
  exit 2
fi

# 2) dangerous push to/from the protected branch
if [ "$is_push" = "1" ]; then
  # a) any push while standing on main (covers bare 'git push', 'git push origin HEAD', ...)
  if [ "$branch" = "$MAIN_BRANCH" ]; then
    echo "BLOCKED (WF-R2): push from '$MAIN_BRANCH'." >&2
    exit 2
  fi
  # b) push whose target is main: origin main, dev:main, +main (force), HEAD:main...
  #    Quotes are stripped to neutralize 'dev:main' / "HEAD:main".
  norm=$(printf '%s' "$cmd" | tr -d "\"'")
  if printf '%s' "$norm" | grep -qE "(^|[[:space:]:+/])${MAIN_BRANCH}([[:space:]:]|$)"; then
    echo "BLOCKED (WF-R2): push targeting '$MAIN_BRANCH'. It only receives merges with explicit consent." >&2
    exit 2
  fi
fi

exit 0
