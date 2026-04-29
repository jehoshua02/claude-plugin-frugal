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

test_dir=$(new_test_dir)
trap "remove_test_dir '$test_dir'" EXIT

# Seed: 800-line file with entry point at top
{
  echo "def main():"
  echo "    print('Application starting')"
  echo "    setup_logging()"
  echo "    run_server()"
  echo ""
  for i in $(seq 6 800); do
    echo "# placeholder line $i — this is filler content to make the file large"
  done
} > "$test_dir/app.py"

PROMPT="What is the primary entry-point function defined at the top of app.py in this directory?"

results=$(run_test_pair "$TEST_NAME" "$PROMPT" "$test_dir" "$TOOLS" "$RULE")
baseline=$(echo "$results" | head -1)
with_rule=$(echo "$results" | tail -1)

baseline_result=$(echo "$baseline" | jq -r '.result')
rule_result=$(echo "$with_rule" | jq -r '.result')

# Correctness: both should identify main
assert_contains "$baseline_result" "main" "Baseline should find main function"
assert_contains "$rule_result" "main" "Rule run should find main function"

# Efficiency: fewer input tokens (partial read vs full file)
baseline_input=$(echo "$baseline" | jq '.input_tokens')
rule_input=$(echo "$with_rule" | jq '.input_tokens')
efficiency=$(compare_metric "input_tokens" "$baseline_input" "$rule_input")

echo "  Baseline input_tokens: $baseline_input"
echo "  Rule input_tokens: $rule_input"
echo "  Efficiency: $efficiency"
echo "  Correctness: passed=$TESTS_PASSED failed=$TESTS_FAILED"

[[ $TESTS_FAILED -eq 0 ]]
