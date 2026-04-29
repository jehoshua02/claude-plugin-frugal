#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/run.sh"
source "$SCRIPT_DIR/../../lib/assert.sh"
source "$SCRIPT_DIR/../../lib/seed.sh"

TEST_NAME="model-selection/simple-task"
RULE="$PROJECT_ROOT/rules/model-selection.md"
TOOLS="Read"

echo "[$TEST_NAME]"

test_dir=$(new_test_dir)
trap "remove_test_dir '$test_dir'" EXIT

PROMPT="What model should be used for this task: read a file and report its line count?"

results=$(run_test_pair "$TEST_NAME" "$PROMPT" "$test_dir" "$TOOLS" "$RULE")
baseline=$(echo "$results" | head -1)
with_rule=$(echo "$results" | tail -1)

rule_result=$(echo "$with_rule" | jq -r '.result')

# Correctness: rule-enabled should recommend haiku
assert_contains "$rule_result" "haiku" "Rule run should suggest haiku for simple task"

echo "  Correctness: passed=$TESTS_PASSED failed=$TESTS_FAILED"

[[ $TESTS_FAILED -eq 0 ]]
