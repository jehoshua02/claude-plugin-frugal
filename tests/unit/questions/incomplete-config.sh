#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/run.sh"
source "$SCRIPT_DIR/../../lib/assert.sh"
source "$SCRIPT_DIR/../../lib/seed.sh"
source "$SCRIPT_DIR/../../lib/db.sh"

TEST_NAME="questions/incomplete-config"
RULE="$PROJECT_ROOT/rules/questions.md"
TOOLS="Read"

echo "[$TEST_NAME]"

baseline_dir=$(new_test_dir)
rule_dir=$(new_test_dir)
trap "remove_test_dir '$baseline_dir'; remove_test_dir '$rule_dir'" EXIT

seed_config() {
  cat > "$1/config.json" << 'SEED'
{
  "database": {},
  "api": {},
  "cache": {},
  "auth": {},
  "logging": {},
  "notifications": {},
  "storage": {},
  "queue": {}
}
SEED
}

seed_config "$baseline_dir"
seed_config "$rule_dir"

PROMPT="Read config.json in this directory. This config is incomplete — every section is empty. I need you to fill in all sections. What information do you need from me?"

echo "  Running baseline..." >&2
baseline=$(invoke_claude_test "$PROMPT" "$baseline_dir" "$TOOLS")

echo "  Running with rule..." >&2
with_rule=$(invoke_claude_test "$PROMPT" "$rule_dir" "$TOOLS" "$RULE")

# Save results
results_dir="$PROJECT_ROOT/tests/results"
timestamp=$(date +%Y%m%d-%H%M%S)
echo "{\"test\":\"$TEST_NAME\",\"baseline\":$baseline,\"with_rule\":$with_rule}" \
  > "$results_dir/questions-incomplete-config-${timestamp}.json"

record_metric "$TEST_NAME" "baseline" "$baseline"
record_metric "$TEST_NAME" "rule" "$with_rule"

baseline_result=$(echo "$baseline" | jq -r '.result')
rule_result=$(echo "$with_rule" | jq -r '.result')

# Correctness: rule run should ask at least one question
assert_contains "$rule_result" "?" "Rule run should ask a question"

# Efficiency: fewer question marks with rule
baseline_questions=$(count_occurrences "$baseline_result" "?")
rule_questions=$(count_occurrences "$rule_result" "?")

echo "  Baseline questions: $baseline_questions"
echo "  Rule questions: $rule_questions"
efficiency=$(compare_metric "question_count" "$baseline_questions" "$rule_questions")
echo "  Efficiency: $efficiency"
echo "  Correctness: passed=$TESTS_PASSED failed=$TESTS_FAILED"

[[ $TESTS_FAILED -eq 0 ]]
