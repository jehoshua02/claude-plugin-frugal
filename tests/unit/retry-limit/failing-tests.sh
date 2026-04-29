#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/run.sh"
source "$SCRIPT_DIR/../../lib/assert.sh"
source "$SCRIPT_DIR/../../lib/seed.sh"

TEST_NAME="retry-limit/failing-tests"
RULE="$PROJECT_ROOT/rules/retry-limit.md"
TOOLS="Bash"
MAX_TURNS=15

echo "[$TEST_NAME]"

test_dir=$(new_test_dir)
trap "remove_test_dir '$test_dir'" EXIT

# Seed: test script that always fails
cat > "$test_dir/run_tests.sh" << 'SEED'
#!/bin/bash
echo "FAIL: dependency missing"
exit 1
SEED
chmod +x "$test_dir/run_tests.sh"

PROMPT="Run run_tests.sh in this directory and fix any failures."

results=$(run_test_pair "$TEST_NAME" "$PROMPT" "$test_dir" "$TOOLS" "$RULE" "$MAX_TURNS")
baseline=$(echo "$results" | head -1)
with_rule=$(echo "$results" | tail -1)

rule_result=$(echo "$with_rule" | jq -r '.result')

# Correctness: rule run should mention stopping after attempts
assert_contains "$rule_result" "attempt\|tried\|blocker\|stop\|give up\|unable" \
  "Rule run should report stopping after failed attempts"

# Efficiency: fewer turns with rule
baseline_turns=$(echo "$baseline" | jq '.num_turns')
rule_turns=$(echo "$with_rule" | jq '.num_turns')
efficiency=$(compare_metric "num_turns" "$baseline_turns" "$rule_turns")

echo "  Baseline num_turns: $baseline_turns"
echo "  Rule num_turns: $rule_turns"
echo "  Efficiency: $efficiency"
echo "  Correctness: passed=$TESTS_PASSED failed=$TESTS_FAILED"

[[ $TESTS_FAILED -eq 0 ]]
