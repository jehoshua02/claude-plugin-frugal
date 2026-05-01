#!/bin/bash
# Assertion helpers for test suite

_ASSERT_SH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_PASSED=0
TESTS_FAILED=0

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local msg="${3:-Expected response to contain '$needle'}"

  if echo "$haystack" | grep -qi "$needle"; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "  FAIL: $msg"
    return 1
  fi
}

assert_not_contains() {
  local haystack="$1"
  local needle="$2"
  local msg="${3:-Expected response to NOT contain '$needle'}"

  if echo "$haystack" | grep -qi "$needle"; then
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "  FAIL: $msg"
    return 1
  else
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  fi
}

assert_file_exists() {
  local file="$1"
  local msg="${2:-Expected file '$file' to exist}"

  if [[ -f "$file" ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "  FAIL: $msg"
    return 1
  fi
}

assert_file_contains() {
  local file="$1"
  local needle="$2"
  local msg="${3:-Expected file '$file' to contain '$needle'}"

  if [[ -f "$file" ]] && grep -qi "$needle" "$file"; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "  FAIL: $msg"
    return 1
  fi
}

assert_less_than() {
  local actual="$1"
  local threshold="$2"
  local msg="${3:-Expected $actual < $threshold}"

  if (( $(echo "$actual < $threshold" | bc -l) )); then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "  FAIL: $msg"
    return 1
  fi
}

assert_within_baseline() {
  local test_name="$1"
  local actual_cost="$2"
  local baselines_file="$_ASSERT_SH_DIR/../baselines.json"
  local ceiling
  ceiling=$(jq -r --arg t "$test_name" '.[$t].ceiling // empty' "$baselines_file")

  if [[ -z "$ceiling" ]]; then
    echo "  WARN: no baseline for $test_name"
    return 0
  fi

  assert_less_than "$actual_cost" "$ceiling" "Cost $actual_cost exceeds ceiling $ceiling for $test_name"
}

count_occurrences() {
  local haystack="$1"
  local pattern="$2"
  echo "$haystack" | { grep -o "$pattern" || true; } | wc -l
}
