#!/usr/bin/env bash
# Claude Code PreToolUse entry point.
#
# Fires before every Bash tool call. If the command is a git commit or push, it
# runs the deterministic scan first and BLOCKS (exit 2) when anything trips, so an
# autonomous agent cannot commit/push data or secrets without it surfacing. Any
# other command is allowed through untouched (exit 0).
#
# Needs `jq` (to read the tool command from the hook's JSON stdin). If jq is
# missing the hook fails open rather than blocking all Bash calls.
set -uo pipefail

input=$(cat)
command -v jq >/dev/null 2>&1 || exit 0
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)
[ -z "$cmd" ] && exit 0

case "$cmd" in
  *"git commit"*) mode=staged ;;
  *"git push"*)   mode=tracked ;;
  *) exit 0 ;;
esac

scan="${CLAUDE_PLUGIN_ROOT:-.}/scripts/scan.sh"
[ -x "$scan" ] || { echo "clean-repo: scan.sh not found, allowing." >&2; exit 0; }

if out=$("$scan" "$mode" 2>&1); then
  exit 0
fi

{
  echo "clean-repo guard BLOCKED this $mode operation before it ran:"
  echo "$out"
  echo "Resolve the findings, or get explicit human sign-off, before retrying."
} >&2
exit 2
