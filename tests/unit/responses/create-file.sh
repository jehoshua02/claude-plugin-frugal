#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/run.sh"
source "$SCRIPT_DIR/../../lib/assert.sh"
source "$SCRIPT_DIR/../../lib/seed.sh"

TEST_NAME="responses/create-file"
RULE="$PROJECT_ROOT/rules/responses.md"
PROMPT="Create a file called hello.txt containing 'hello world'."
TOOLS="Read,Write"

echo "[$TEST_NAME]"

test_dir=$(new_test_dir)
trap "remove_test_dir '$test_dir'" EXIT

results=$(run_test_pair "$TEST_NAME" "$PROMPT" "$test_dir" "$TOOLS" "$RULE")
baseline=$(echo "$results" | head -1)
with_rule=$(echo "$results" | tail -1)

baseline_result=$(echo "$baseline" | jq -r '.result')
rule_result=$(echo "$with_rule" | jq -r '.result')

# Correctness: both should create the file (check response mentions it)
assert_contains "$baseline_result" "hello" "Baseline should mention hello"
assert_contains "$rule_result" "hello" "Rule run should mention hello"

# Efficiency: fewer output tokens with rule
baseline_output=$(echo "$baseline" | jq '.output_tokens')
rule_output=$(echo "$with_rule" | jq '.output_tokens')
efficiency=$(compare_metric "output_tokens" "$baseline_output" "$rule_output")

echo "  Baseline output_tokens: $baseline_output"
echo "  Rule output_tokens: $rule_output"
echo "  Efficiency: $efficiency"
echo "  Correctness: passed=$TESTS_PASSED failed=$TESTS_FAILED"

[[ $TESTS_FAILED -eq 0 ]]
