#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/run.sh"
source "$SCRIPT_DIR/../../lib/assert.sh"
source "$SCRIPT_DIR/../../lib/seed.sh"

TEST_NAME="document-decisions/fix-bug"
RULE="$PROJECT_ROOT/rules/document-decisions.md"
TOOLS="Read,Write"

echo "[$TEST_NAME]"

test_dir=$(new_test_dir)
trap "remove_test_dir '$test_dir'" EXIT

# Seed: Python file with an obvious bug
cat > "$test_dir/bug.py" << 'SEED'
def divide(a, b):
    return a / b

result = divide(10, 0)
print(result)
SEED

PROMPT="Fix the bug in bug.py in this directory. Document your findings and decision in a notes file."

results=$(run_test_pair "$TEST_NAME" "$PROMPT" "$test_dir" "$TOOLS" "$RULE")
baseline=$(echo "$results" | head -1)
with_rule=$(echo "$results" | tail -1)

rule_result=$(echo "$with_rule" | jq -r '.result')

# Correctness: rule run should mention the fix
assert_contains "$rule_result" "zero" "Rule run should mention division by zero"

# Check if a notes/decisions file was created
notes_found=false
for f in "$test_dir"/*notes* "$test_dir"/*decision* "$test_dir"/*findings*; do
  if [[ -f "$f" ]]; then
    notes_found=true
    break
  fi
done

if $notes_found; then
  TESTS_PASSED=$((TESTS_PASSED + 1))
  echo "  Notes file created: yes"
else
  TESTS_FAILED=$((TESTS_FAILED + 1))
  echo "  FAIL: Rule run should create a notes/decisions file"
fi

echo "  Correctness: passed=$TESTS_PASSED failed=$TESTS_FAILED"

[[ $TESTS_FAILED -eq 0 ]]
