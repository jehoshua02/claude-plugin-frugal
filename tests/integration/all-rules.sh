#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/run.sh"
source "$SCRIPT_DIR/../lib/assert.sh"
source "$SCRIPT_DIR/../lib/seed.sh"

TEST_NAME="integration/all-rules"
TOOLS="Read,Write,Bash"

echo "[$TEST_NAME]"

test_dir=$(new_test_dir)
trap "remove_test_dir '$test_dir'" EXIT

# Seed all test files

cat > "$test_dir/config.json" << 'SEED'
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
} > "$test_dir/app.py"

cat > "$test_dir/run_tests.sh" << 'SEED'
#!/bin/bash
echo "FAIL: dependency missing"
exit 1
SEED
chmod +x "$test_dir/run_tests.sh"

PROMPT="You have a codebase in this directory. Do all of the following:
1. What is the entry-point function at the top of app.py?
2. Run run_tests.sh and handle any failures.
3. What info is needed to complete config.json?"

# Build combined rules file for integration
combined_rules=$(mktemp)
cat "$PROJECT_ROOT"/rules/*.md > "$combined_rules"
trap "remove_test_dir '$test_dir'; rm -f '$combined_rules'" EXIT

results=$(run_test_pair "$TEST_NAME" "$PROMPT" "$test_dir" "$TOOLS" "$combined_rules" 20)
baseline=$(echo "$results" | head -1)
with_rule=$(echo "$results" | tail -1)

baseline_result=$(echo "$baseline" | jq -r '.result')
rule_result=$(echo "$with_rule" | jq -r '.result')

# Correctness assertions
assert_contains "$rule_result" "main" "Should identify main function"
assert_contains "$rule_result" "fail\|error\|dependency\|blocker" "Should mention test failure"
assert_contains "$rule_result" "?" "Should ask about config"

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
