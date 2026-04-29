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

baseline_dir=$(new_test_dir)
rule_dir=$(new_test_dir)
trap "remove_test_dir '$baseline_dir'; remove_test_dir '$rule_dir'" EXIT

echo "  Running baseline..." >&2
baseline=$(invoke_claude_test "$PROMPT" "$baseline_dir" "$TOOLS")

echo "  Running with rule..." >&2
with_rule=$(invoke_claude_test "$PROMPT" "$rule_dir" "$TOOLS" "$RULE")

# Save results
local_results_dir="$PROJECT_ROOT/tests/results"
timestamp=$(date +%Y%m%d-%H%M%S)
echo "{\"test\":\"$TEST_NAME\",\"baseline\":$baseline,\"with_rule\":$with_rule}" \
  > "$local_results_dir/responses-create-file-${timestamp}.json"

# Correctness: check the file was created
assert_file_exists "$baseline_dir/hello.txt" "Baseline should create hello.txt"
assert_file_exists "$rule_dir/hello.txt" "Rule run should create hello.txt"

# Efficiency: fewer output tokens with rule
baseline_output=$(echo "$baseline" | jq '.output_tokens')
rule_output=$(echo "$with_rule" | jq '.output_tokens')
efficiency=$(compare_metric "output_tokens" "$baseline_output" "$rule_output")

echo "  Baseline output_tokens: $baseline_output"
echo "  Rule output_tokens: $rule_output"
echo "  Efficiency: $efficiency"
echo "  Correctness: passed=$TESTS_PASSED failed=$TESTS_FAILED"

[[ $TESTS_FAILED -eq 0 ]]
