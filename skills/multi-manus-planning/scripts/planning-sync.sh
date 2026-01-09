#!/bin/bash
# SessionStart hook: Sync planning files and display active context
# Pulls latest from git and shows current planning project

# Read stdin (Claude Code sends JSON input to hooks)
read -t 1 -d '' INPUT 2>/dev/null || true

PLANNING_DIR=".planning"
INDEX_FILE="$PLANNING_DIR/index.md"

# Only run if we have planning directory
if [[ ! -d "$PLANNING_DIR" ]]; then
	exit 0
fi

# Try to sync if we're in a git repo with a remote
pull_result=""
if [[ -d ".git" ]] && git remote get-url origin &>/dev/null; then
	# Fetch to see if we're behind (always safe)
	git fetch origin "$(git branch --show-current)" &>/dev/null

	# Check if we're behind
	LOCAL=$(git rev-parse HEAD 2>/dev/null)
	REMOTE=$(git rev-parse "@{u}" 2>/dev/null)

	if [[ "$LOCAL" != "$REMOTE" ]]; then
		# We're behind - check if working directory is clean enough to pull
		if git diff --quiet 2>/dev/null; then
			# Clean - safe to pull
			if git pull --ff-only origin "$(git branch --show-current)" &>/dev/null; then
				pull_result="synced"
			elif git pull --no-edit origin "$(git branch --show-current)" &>/dev/null; then
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

# Read active project from index.md
active=""
if [[ -f "$INDEX_FILE" ]]; then
	active=$(grep "^active:" "$INDEX_FILE" 2>/dev/null | cut -d: -f2 | tr -d ' ')
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

# Report active project
if [[ -n "$active" ]]; then
	output="${output}Planning context: $active"
elif [[ -f "$INDEX_FILE" ]]; then
	output="${output}No active planning project set."
fi

# Output JSON to stdout (SessionStart hooks use this format)
if [[ -n "$output" ]]; then
	# JSON format for SessionStart hooks
	echo "{\"hookSpecificOutput\":{\"hookEventName\":\"SessionStart\",\"additionalContext\":\"$output\"}}"
fi

exit 0
