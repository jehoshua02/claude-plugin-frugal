#!/bin/bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

total=0
passed=0
failed=0
warnings=0

run_test() {
  local test_script="$1"
  local test_name="${test_script#$SCRIPT_DIR/}"
  total=$((total + 1))

  if bash "$test_script"; then
    passed=$((passed + 1))
  else
    failed=$((failed + 1))
    echo "  FAILED: $test_name"
  fi
  echo ""
}

FILTER="${1:-}"

matches_filter() {
  [[ -z "$FILTER" ]] && return 0
  [[ "$1" == *"$FILTER"* ]]
}

echo "=== Frugal Plugin Test Suite ==="
echo ""

# Unit tests
for test_dir in "$SCRIPT_DIR"/unit/*/; do
  for test_script in "$test_dir"*.sh; do
    [[ -f "$test_script" ]] && matches_filter "$test_script" && run_test "$test_script"
  done
done

# Integration tests
for test_script in "$SCRIPT_DIR"/integration/*.sh; do
  [[ -f "$test_script" ]] && matches_filter "$test_script" && run_test "$test_script"
done

echo "=== Summary ==="
echo "Total: $total  Passed: $passed  Failed: $failed"

if [[ $failed -gt 0 ]]; then
  exit 1
fi
