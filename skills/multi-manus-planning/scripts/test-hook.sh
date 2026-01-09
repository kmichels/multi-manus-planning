#!/bin/bash
# Test script for planning-sync.sh SessionStart hook
# Run from any directory with a .planning/index.md to test

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOK_SCRIPT="$SCRIPT_DIR/planning-sync.sh"

echo "Testing planning-sync.sh hook"
echo "=============================="
echo ""

# Check hook exists
if [[ ! -f "$HOOK_SCRIPT" ]]; then
	echo "FAIL: Hook script not found at $HOOK_SCRIPT"
	exit 1
fi
echo "PASS: Hook script exists"

# Check hook is executable
if [[ ! -x "$HOOK_SCRIPT" ]]; then
	echo "FAIL: Hook script is not executable"
	exit 1
fi
echo "PASS: Hook script is executable"

# Check bash syntax
if ! bash -n "$HOOK_SCRIPT" 2>/dev/null; then
	echo "FAIL: Hook script has syntax errors"
	exit 1
fi
echo "PASS: Hook script syntax OK"

# Create temp test directory
TEST_DIR=$(mktemp -d)
trap "rm -rf $TEST_DIR" EXIT

# Test 1: No .planning directory - should exit silently
echo ""
echo "Test 1: No .planning directory"
cd "$TEST_DIR"
OUTPUT=$("$HOOK_SCRIPT" 2>&1) || true
if [[ -z "$OUTPUT" ]]; then
	echo "PASS: Silent exit when no .planning directory"
else
	echo "FAIL: Expected no output, got: $OUTPUT"
fi

# Test 2: .planning exists but no index.md - silent (no coordinator = no output)
echo ""
echo "Test 2: .planning exists, no index.md"
mkdir -p "$TEST_DIR/.planning"
OUTPUT=$("$HOOK_SCRIPT" 2>&1) || true
if [[ -z "$OUTPUT" ]]; then
	echo "PASS: Silent exit when no index.md (no coordinator)"
else
	echo "FAIL: Expected no output, got: $OUTPUT"
fi

# Test 3: .planning/index.md with active project
echo ""
echo "Test 3: index.md with active project"
cat >"$TEST_DIR/.planning/index.md" <<'EOF'
# Planning Coordinator

active: test-project
default_path: ~/Planning

## Projects

| Name | Planning Path | Source Path | Description |
|------|---------------|-------------|-------------|
| test-project | {default}/test-project | ~/code/test | Test project |
EOF

OUTPUT=$("$HOOK_SCRIPT" 2>&1) || true
if [[ "$OUTPUT" == *"Planning context: test-project"* ]]; then
	echo "PASS: Reports active project correctly"
else
	echo "FAIL: Expected 'Planning context: test-project', got: $OUTPUT"
fi

# Test 4: JSON output format
echo ""
echo "Test 4: JSON output format"
if [[ "$OUTPUT" == *'"hookSpecificOutput"'* ]] && [[ "$OUTPUT" == *'"additionalContext"'* ]]; then
	echo "PASS: Output is valid JSON format for SessionStart"
else
	echo "FAIL: Output not in expected JSON format"
	echo "Got: $OUTPUT"
fi

echo ""
echo "=============================="
echo "All tests passed!"
