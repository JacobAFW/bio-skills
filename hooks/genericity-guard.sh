#!/usr/bin/env bash
# Claude Code PostToolUse hook — the build-time genericity FLAG.
#
# Fires after a Write/Edit/MultiEdit. If the edited file is core pipeline code, it
# scans for untagged hardcoding and, on a hit, surfaces the findings to the agent
# via exit 2. PostToolUse can't undo the write (it already happened) — it flags,
# so the agent fixes in-loop rather than three phases later.
#
# Needs jq (to read the edited path from the hook's JSON stdin); fails open if absent.
set -uo pipefail

input=$(cat)
command -v jq >/dev/null 2>&1 || exit 0
f=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -z "$f" ] && exit 0
[ -f "$f" ] || exit 0

scan="${CLAUDE_PLUGIN_ROOT:-.}/scripts/genericity-scan.sh"
[ -x "$scan" ] || exit 0

if out=$("$scan" "$f" 2>&1); then
  exit 0
fi

{
  echo "genericity flag on $(basename "$f") — untagged hardcoding in core pipeline code:"
  echo "$out"
  echo "Lift these to config, or if genuinely necessary tag them '# HARDCODE(reason; date):' and log in DESIGN.md."
} >&2
exit 2
