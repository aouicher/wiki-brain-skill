#!/usr/bin/env bash
# wiki-brain SessionEnd hook
# Runs after every Claude Code session ends. Handles:
#   - Conditional Graphify rebuild (if cadence due AND files changed)
#   - Cadence reminder for lint (macOS notification only)
# Logging the session itself is handled by Claude during the session, per
# instructions in the user's CLAUDE.md. This hook is shell-only — it cannot
# summarize or ingest conversations by itself.

set -u

CONFIG="${HOME}/.claude/skills/wiki-brain/config.json"
[ ! -f "$CONFIG" ] && exit 0  # not set up yet, do nothing

# Read config fields without requiring jq
get() {
  python3 -c "
import json, sys
try:
    c = json.load(open('$CONFIG'))
    v = c.get('$1')
    print(v if v is not None else '')
except Exception:
    print('')
" 2>/dev/null
}

VAULT="$(get vaultPath)"
REBUILD_DAYS="$(get rebuildCadenceDays)"
LINT_DAYS="$(get lintCadenceDays)"
LAST_REBUILD="$(get lastRebuild)"
LAST_LINT="$(get lastLint)"

[ -z "$VAULT" ] && exit 0
[ ! -d "$VAULT" ] && exit 0

NOW_EPOCH=$(date +%s)
DAY_SECONDS=86400

notify() {
  # macOS notification; silently no-op elsewhere
  if command -v osascript >/dev/null 2>&1; then
    osascript -e "display notification \"$2\" with title \"wiki-brain\" subtitle \"$1\"" 2>/dev/null || true
  fi
}

days_since() {
  # $1 = ISO date or ""; prints integer days since, or 99999 if empty
  local d="$1"
  [ -z "$d" ] && echo 99999 && return
  local then_epoch
  then_epoch=$(python3 -c "
import sys, time, datetime
try:
    dt = datetime.datetime.fromisoformat('$d'.replace('Z','+00:00'))
    print(int(dt.timestamp()))
except Exception:
    print(0)
" 2>/dev/null)
  [ -z "$then_epoch" ] || [ "$then_epoch" = "0" ] && echo 99999 && return
  echo $(( (NOW_EPOCH - then_epoch) / DAY_SECONDS ))
}

update_config_field() {
  # $1 = field, $2 = value
  python3 -c "
import json
c = json.load(open('$CONFIG'))
c['$1'] = '$2'
json.dump(c, open('$CONFIG','w'), indent=2)
" 2>/dev/null || true
}

# --- Graphify rebuild check ---
if [ -n "$REBUILD_DAYS" ] && [ "$REBUILD_DAYS" != "0" ]; then
  SINCE_REBUILD=$(days_since "$LAST_REBUILD")
  if [ "$SINCE_REBUILD" -ge "$REBUILD_DAYS" ]; then
    # Check if anything has actually changed in wiki/ or raw/ since last rebuild
    STAMP="$VAULT/graphify-out/.last-rebuild-stamp"
    CHANGED=0
    if [ -f "$STAMP" ]; then
      if find "$VAULT/wiki" "$VAULT/raw" -type f -newer "$STAMP" 2>/dev/null | grep -q .; then
        CHANGED=1
      fi
    else
      CHANGED=1  # no stamp yet, first real rebuild
    fi

    if [ "$CHANGED" = "1" ]; then
      notify "Rebuilding knowledge graph" "Running in background…"
      (
        cd "$VAULT" && graphify . --wiki --update >/tmp/wiki-brain-rebuild.log 2>&1
        RC=$?
        mkdir -p "$VAULT/graphify-out"
        touch "$STAMP"
        TODAY=$(date +%Y-%m-%d)
        update_config_field lastRebuild "$TODAY"
        if [ "$RC" = "0" ]; then
          notify "Graph rebuilt" "Wiki is up to date."
        else
          notify "Rebuild failed" "See /tmp/wiki-brain-rebuild.log"
        fi
      ) &
    fi
  fi
fi

# --- Lint cadence reminder ---
# Lint needs Claude judgment, so we can't run it from a shell hook.
# Instead, notify the user that it's due.
if [ -n "$LINT_DAYS" ] && [ "$LINT_DAYS" != "0" ]; then
  SINCE_LINT=$(days_since "$LAST_LINT")
  if [ "$SINCE_LINT" -ge "$LINT_DAYS" ]; then
    notify "Wiki lint is due" "Run /wiki-brain lint next session."
  fi
fi

exit 0
