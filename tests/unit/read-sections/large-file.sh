#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/run.sh"
source "$SCRIPT_DIR/../../lib/assert.sh"
source "$SCRIPT_DIR/../../lib/seed.sh"

TEST_NAME="read-sections/large-file"
RULE="$PROJECT_ROOT/rules/read-sections.md"
TOOLS="Read"

echo "[$TEST_NAME]"

baseline_dir=$(new_test_dir)
rule_dir=$(new_test_dir)
trap "remove_test_dir '$baseline_dir'; remove_test_dir '$rule_dir'" EXIT

seed_large_file() {
  local dir="$1"
  {
    echo "def initialize_xr7_reactor():"
    echo "    print('Reactor starting')"
    echo "    calibrate_flux_capacitor()"
    echo "    engage_containment_field()"
    echo ""
    for i in $(seq 6 800); do
      echo "# placeholder line $i — this is filler content to make the file large"
    done
  } > "$dir/app.py"
}

seed_large_file "$baseline_dir"
seed_large_file "$rule_dir"

PROMPT="Read app.py in this directory and tell me the exact name of the function defined on line 1."

echo "  Running baseline..." >&2
baseline=$(invoke_claude_test "$PROMPT" "$baseline_dir" "$TOOLS")

echo "  Running with rule..." >&2
with_rule=$(invoke_claude_test "$PROMPT" "$rule_dir" "$TOOLS" "$RULE")

# Save results
results_dir="$PROJECT_ROOT/tests/results"
timestamp=$(date +%Y%m%d-%H%M%S)
echo "{\"test\":\"$TEST_NAME\",\"baseline\":$baseline,\"with_rule\":$with_rule}" \
  > "$results_dir/read-sections-large-file-${timestamp}.json"

baseline_result=$(echo "$baseline" | jq -r '.result')
rule_result=$(echo "$with_rule" | jq -r '.result')

# Correctness: both should identify the function
assert_contains "$baseline_result" "initialize_xr7_reactor" "Baseline should find the function"
assert_contains "$rule_result" "initialize_xr7_reactor" "Rule run should find the function"

# Efficiency: fewer total input tokens (partial read vs full file)
baseline_input=$(echo "$baseline" | jq '.total_input')
rule_input=$(echo "$with_rule" | jq '.total_input')
efficiency=$(compare_metric "total_input" "$baseline_input" "$rule_input")

echo "  Baseline total_input: $baseline_input"
echo "  Rule total_input: $rule_input"
echo "  Efficiency: $efficiency"
echo "  Correctness: passed=$TESTS_PASSED failed=$TESTS_FAILED"

[[ $TESTS_FAILED -eq 0 ]]
