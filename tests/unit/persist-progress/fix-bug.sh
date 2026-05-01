#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/run.sh"
source "$SCRIPT_DIR/../../lib/assert.sh"
source "$SCRIPT_DIR/../../lib/seed.sh"
source "$SCRIPT_DIR/../../lib/db.sh"

TEST_NAME="persist-progress/fix-bug"
RULE="$PROJECT_ROOT/rules/persist-progress.md"
TOOLS="Read,Edit,Write"

echo "[$TEST_NAME]"

rule_dir=$(new_test_dir)
trap "remove_test_dir '$rule_dir'" EXIT

seed_bug() {
  local dir="$1"
  cat > "$dir/bug.py" << 'SEED'
def divide(a, b):
    return a / b

result = divide(10, 0)
print(result)
SEED
}

seed_bug "$rule_dir"

PROMPT="Fix the bug in bug.py in this directory. Document your findings and decision in a notes file."

echo "  Running with rule..." >&2
with_rule=$(invoke_claude_test "$PROMPT" "$rule_dir" "$TOOLS" "$RULE")

# Save results
results_dir="$PROJECT_ROOT/tests/results"
timestamp=$(date +%Y%m%d-%H%M%S)
echo "{\"test\":\"$TEST_NAME\",\"with_rule\":$with_rule}" \
  > "$results_dir/document-decisions-fix-bug-${timestamp}.json"

record_metric "$TEST_NAME" "rule" "$with_rule"

rule_cost=$(echo "$with_rule" | jq '.cost')
assert_within_baseline "$TEST_NAME" "$rule_cost"

rule_result=$(echo "$with_rule" | jq -r '.result')

# Correctness: rule run should mention the fix
assert_contains "$rule_result" "divid\|zero\|bug\|fix" "Rule run should mention the bug fix"

# Check if any additional file was created (notes, decisions, findings, etc.)
notes_found=false
for f in "$rule_dir"/*; do
  fname=$(basename "$f")
  if [[ "$fname" != "bug.py" ]]; then
    notes_found=true
    echo "  Notes file created: $fname"
    break
  fi
done

if $notes_found; then
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  TESTS_FAILED=$((TESTS_FAILED + 1))
  echo "  FAIL: Rule run should create a notes/decisions file"
fi

echo "  Correctness: passed=$TESTS_PASSED failed=$TESTS_FAILED"

[[ $TESTS_FAILED -eq 0 ]]
