#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/run.sh"
source "$SCRIPT_DIR/../lib/assert.sh"
source "$SCRIPT_DIR/../lib/seed.sh"

TEST_NAME="integration/all-rules"
TOOLS="Read,Write,Bash"

echo "[$TEST_NAME]"

baseline_dir=$(new_test_dir)
rule_dir=$(new_test_dir)
combined_rules=$(mktemp)
trap "remove_test_dir '$baseline_dir'; remove_test_dir '$rule_dir'; rm -f '$combined_rules'" EXIT

seed_files() {
  local dir="$1"
  cat > "$dir/config.json" << 'SEED'
{
  "database": {},
  "api": {},
  "cache": {}
}
SEED

  {
    echo "def main():"
    echo "    print('Application starting')"
    echo "    setup_logging()"
    echo "    run_server()"
    echo ""
    for i in $(seq 6 800); do
      echo "# placeholder line $i"
    done
  } > "$dir/app.py"

  cat > "$dir/run_tests.sh" << 'SEED'
#!/bin/bash
echo "FAIL: dependency missing"
exit 1
SEED
  chmod +x "$dir/run_tests.sh"
}

seed_files "$baseline_dir"
seed_files "$rule_dir"

PROMPT="You have a codebase in this directory. Do all of the following:
1. What is the entry-point function at the top of app.py?
2. Run run_tests.sh and handle any failures.
3. What info is needed to complete config.json?"

cat "$PROJECT_ROOT"/rules/*.md > "$combined_rules"

echo "  Running baseline..." >&2
baseline=$(invoke_claude_test "$PROMPT" "$baseline_dir" "$TOOLS" "" 20)

echo "  Running with rule..." >&2
with_rule=$(invoke_claude_test "$PROMPT" "$rule_dir" "$TOOLS" "$combined_rules" 20)

# Save results
results_dir="$PROJECT_ROOT/tests/results"
timestamp=$(date +%Y%m%d-%H%M%S)
echo "{\"test\":\"$TEST_NAME\",\"baseline\":$baseline,\"with_rule\":$with_rule}" \
  > "$results_dir/integration-all-rules-${timestamp}.json"

baseline_result=$(echo "$baseline" | jq -r '.result')
rule_result=$(echo "$with_rule" | jq -r '.result')

# Correctness assertions
assert_contains "$rule_result" "main" "Should identify main function"
assert_contains "$rule_result" "fail\|error\|dependency\|blocker\|missing" "Should mention test failure"
assert_contains "$rule_result" "config\|database\|api\|cache" "Should address config"

# Efficiency: total cost
baseline_cost=$(echo "$baseline" | jq '.cost')
rule_cost=$(echo "$with_rule" | jq '.cost')
efficiency=$(compare_metric "total_cost_usd" "$baseline_cost" "$rule_cost")

echo "  Baseline cost: \$$baseline_cost"
echo "  Rule cost: \$$rule_cost"
echo "  Efficiency: $efficiency"

baseline_turns=$(echo "$baseline" | jq '.num_turns')
rule_turns=$(echo "$with_rule" | jq '.num_turns')
echo "  Baseline turns: $baseline_turns"
echo "  Rule turns: $rule_turns"

echo "  Correctness: passed=$TESTS_PASSED failed=$TESTS_FAILED"

[[ $TESTS_FAILED -eq 0 ]]
