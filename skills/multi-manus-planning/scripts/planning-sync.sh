#!/bin/bash
# SessionStart hook: Sync planning files and display active context
# Pulls latest from git and shows current planning project

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

INDEX_FILE="$PLANNING_DIR/index.md"

# Only run if we have index file
if [[ ! -f "$INDEX_FILE" ]]; then
	exit 0
fi

# Get the directory containing .planning for git operations
PLANNING_ROOT=$(dirname "$PLANNING_DIR")

# Try to sync if we're in a git repo with a remote
pull_result=""
if [[ -d "$PLANNING_ROOT/.git" ]] && git -C "$PLANNING_ROOT" remote get-url origin &>/dev/null; then
	# Fetch to see if we're behind (always safe)
	git -C "$PLANNING_ROOT" fetch origin "$(git -C "$PLANNING_ROOT" branch --show-current)" &>/dev/null

	# Check if we're behind
	LOCAL=$(git -C "$PLANNING_ROOT" rev-parse HEAD 2>/dev/null)
	REMOTE=$(git -C "$PLANNING_ROOT" rev-parse "@{u}" 2>/dev/null)

	if [[ "$LOCAL" != "$REMOTE" ]]; then
		# We're behind - check if working directory is clean enough to pull
		if git -C "$PLANNING_ROOT" diff --quiet 2>/dev/null; then
			# Clean - safe to pull
			if git -C "$PLANNING_ROOT" pull --ff-only origin "$(git -C "$PLANNING_ROOT" branch --show-current)" &>/dev/null; then
				pull_result="synced"
			elif git -C "$PLANNING_ROOT" pull --no-edit origin "$(git -C "$PLANNING_ROOT" branch --show-current)" &>/dev/null; then
				pull_result="merged"
			else
				pull_result="conflict"
			fi
		else
			# Dirty working directory - skip pull, just warn
			pull_result="dirty"
		fi
	fi
fi

# Session ID for session-specific overrides (v1.4.1)
# Use CLAUDE_CODE_SESSION_ID (available in all Claude Code contexts)
# TTY detection doesn't work - Bash tool runs without TTY attached
SESSION_ID="$CLAUDE_CODE_SESSION_ID"

# Read active project with priority cascade:
# 1. $MANUS_PROJECT environment variable (explicit override)
# 2. .active.override.$SESSION_ID (session-local state)
# 3. index.md active: field (workspace default)
active=""
active_source=""

if [[ -n "$MANUS_PROJECT" ]]; then
	active="$MANUS_PROJECT"
	active_source="env"
elif [[ -n "$SESSION_ID" && -f "$PLANNING_DIR/.active.override.$SESSION_ID" ]]; then
	active=$(cat "$PLANNING_DIR/.active.override.$SESSION_ID" 2>/dev/null | tr -d '[:space:]')
	active_source="session"
elif [[ -f "$INDEX_FILE" ]]; then
	active=$(grep "^active:" "$INDEX_FILE" 2>/dev/null | cut -d: -f2 | tr -d ' ')
	active_source="default"
fi

# Build output message
output=""

# Report sync status if something happened
case "$pull_result" in
synced)
	output="Planning files synced. "
	;;
merged)
	output="Planning files merged from remote. "
	;;
conflict)
	output="WARNING: Git conflicts. Run 'git status' to resolve. "
	;;
dirty)
	output="Uncommitted changes - skipped sync. "
	;;
esac

# Report active project with multi-manus-planning context
if [[ -n "$active" ]]; then
	output="${output}Planning context: $active"

	# CRITICAL: Instruct Claude to use the Skill tool for project commands
	# Without this explicit instruction, Claude will handle commands directly without loading skill instructions
	output="$output\\n\\n**IMPORTANT: Multi-Manus Planning Skill Required**\\nWhen user says 'switch to [name]', 'list projects', 'which project?', or 'add project [name]':\\n→ You MUST use the Skill tool with skill='multi-manus-planning' to handle the request.\\n→ Do NOT modify .planning/index.md directly - the skill handles session-local overrides."
elif [[ -f "$INDEX_FILE" ]]; then
	output="${output}No active planning project set. Use Skill tool with skill='multi-manus-planning' and ask to 'add project [name]'."
fi

# Output JSON to stdout (SessionStart hooks use this format - goes to AI context)
if [[ -n "$output" ]]; then
	# JSON format for SessionStart hooks
	echo "{\"hookSpecificOutput\":{\"hookEventName\":\"SessionStart\",\"additionalContext\":\"$output\"}}"

	# ALSO write to /dev/tty so user sees it in terminal
	# (SessionStart stdout goes to context, not terminal - known Claude Code behavior)
	if [[ -w /dev/tty ]]; then
		# Simple display for terminal (without the markdown)
		if [[ -n "$active" ]]; then
			printf "  ⎿  Planning: %s\n" "$active" >/dev/tty 2>/dev/null || true
		fi
	fi
fi

exit 0
