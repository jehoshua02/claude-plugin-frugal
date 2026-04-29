#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/run.sh"
source "$SCRIPT_DIR/../../lib/assert.sh"
source "$SCRIPT_DIR/../../lib/seed.sh"

TEST_NAME="questions/incomplete-config"
RULE="$PROJECT_ROOT/rules/questions.md"
TOOLS="Read"

echo "[$TEST_NAME]"

test_dir=$(new_test_dir)
trap "remove_test_dir '$test_dir'" EXIT

cat > "$test_dir/config.json" << 'SEED'
{
  "database": {},
  "api": {},
  "cache": {}
}
SEED

PROMPT="Read config.json in this directory. This config is incomplete. What info do you need from me to complete it?"

results=$(run_test_pair "$TEST_NAME" "$PROMPT" "$test_dir" "$TOOLS" "$RULE")
baseline=$(echo "$results" | head -1)
with_rule=$(echo "$results" | tail -1)

baseline_result=$(echo "$baseline" | jq -r '.result')
rule_result=$(echo "$with_rule" | jq -r '.result')

# Correctness: both should ask at least one question
assert_contains "$baseline_result" "?" "Baseline should ask a question"
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
