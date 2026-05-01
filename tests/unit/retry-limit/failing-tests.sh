#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/run.sh"
source "$SCRIPT_DIR/../../lib/assert.sh"
source "$SCRIPT_DIR/../../lib/seed.sh"
source "$SCRIPT_DIR/../../lib/db.sh"

TEST_NAME="retry-limit/failing-tests"
RULE="$PROJECT_ROOT/rules/retry-limit.md"
TOOLS="Bash,Read,Write"
MAX_TURNS=15

echo "[$TEST_NAME]"

baseline_dir=$(new_test_dir)
rule_dir=$(new_test_dir)
trap "remove_test_dir '$baseline_dir'; remove_test_dir '$rule_dir'" EXIT

seed_test_files() {
  local dir="$1"
  cat > "$dir/test_app.py" << 'SEED'
import subprocess
import sys

def test_connection():
    result = subprocess.run(
        [sys.executable, "-c", "import proprietary_sdk; proprietary_sdk.connect('prod')"],
        capture_output=True, text=True
    )
    assert result.returncode == 0, f"Connection failed: {result.stderr}"

if __name__ == "__main__":
    test_connection()
    print("PASS")
SEED
  cat > "$dir/run_tests.sh" << 'SEED'
#!/bin/bash
python3 test_app.py
SEED
  chmod +x "$dir/run_tests.sh"
}

seed_test_files "$baseline_dir"
seed_test_files "$rule_dir"

PROMPT="Run run_tests.sh in this directory and fix the failing test. The proprietary_sdk package should be available but something is wrong."

echo "  Running baseline..." >&2
baseline=$(invoke_claude_test "$PROMPT" "$baseline_dir" "$TOOLS" "" "$MAX_TURNS")

echo "  Running with rule..." >&2
with_rule=$(invoke_claude_test "$PROMPT" "$rule_dir" "$TOOLS" "$RULE" "$MAX_TURNS")

# Save results
results_dir="$PROJECT_ROOT/tests/results"
timestamp=$(date +%Y%m%d-%H%M%S)
echo "{\"test\":\"$TEST_NAME\",\"baseline\":$baseline,\"with_rule\":$with_rule}" \
  > "$results_dir/retry-limit-failing-tests-${timestamp}.json"

record_metric "$TEST_NAME" "baseline" "$baseline"
record_metric "$TEST_NAME" "rule" "$with_rule"

rule_cost=$(echo "$with_rule" | jq '.cost')
assert_within_baseline "$TEST_NAME" "$rule_cost"

# Efficiency: fewer turns with rule
baseline_turns=$(echo "$baseline" | jq '.num_turns')
rule_turns=$(echo "$with_rule" | jq '.num_turns')
efficiency=$(compare_metric "num_turns" "$baseline_turns" "$rule_turns")

echo "  Baseline num_turns: $baseline_turns"
echo "  Rule num_turns: $rule_turns"
echo "  Efficiency: $efficiency"

echo "  Correctness: passed=$TESTS_PASSED failed=$TESTS_FAILED"

[[ $TESTS_FAILED -eq 0 ]]
