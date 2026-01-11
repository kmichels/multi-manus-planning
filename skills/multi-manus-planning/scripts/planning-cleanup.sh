#!/bin/bash
# SessionEnd hook: Clean up session-local planning override file
# Removes .active.override.$SESSION_ID to prevent stale session state

# Read stdin (Claude Code sends JSON input to hooks)
read -t 1 -d '' INPUT 2>/dev/null || true

# Find .planning directory by walking up from CWD (like git finds .git)
find_planning_dir() {
	local dir="$PWD"
	while [[ "$dir" != "/" ]]; do
		if [[ -d "$dir/.planning" ]]; then
			echo "$dir/.planning"
			return 0
		fi
		dir=$(dirname "$dir")
	done
	return 1
}

PLANNING_DIR=$(find_planning_dir)
if [[ -z "$PLANNING_DIR" ]]; then
	exit 0
fi

# Use CLAUDE_CODE_SESSION_ID (available in all Claude Code contexts)
# TTY detection doesn't work - Bash tool runs without TTY attached
SESSION_ID="$CLAUDE_CODE_SESSION_ID"

# Clean up this session's override file if it exists
if [[ -n "$SESSION_ID" ]]; then
	OVERRIDE_FILE="$PLANNING_DIR/.active.override.$SESSION_ID"
	if [[ -f "$OVERRIDE_FILE" ]]; then
		rm -f "$OVERRIDE_FILE"
	fi
fi

exit 0
