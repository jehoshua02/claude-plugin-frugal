#!/bin/bash
# Test harness for running claude in headless mode and capturing metrics

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

invoke_claude_test() {
  local prompt="$1"
  local work_dir="$2"
  local tools="$3"
  local rules_file="${4:-}"
  local max_turns="${5:-20}"
  local max_budget="${6:-0.10}"

  local args=(
    --bare
    -p "$prompt"
    --output-format json
    --max-turns "$max_turns"
    --max-budget-usd "$max_budget"
    --allowedTools "$tools"
  )

  if [[ -n "$rules_file" ]]; then
    args+=(--append-system-prompt-file "$rules_file")
  fi

  local start_time=$SECONDS
  local output
  output=$(cd "$work_dir" && claude "${args[@]}" 2>/dev/null)
  local wall_time=$(( SECONDS - start_time ))

  local cost input_tokens output_tokens num_turns result
  cost=$(echo "$output" | jq -r '.total_cost_usd // 0')
  input_tokens=$(echo "$output" | jq -r '.usage.input_tokens // 0')
  output_tokens=$(echo "$output" | jq -r '.usage.output_tokens // 0')
  num_turns=$(echo "$output" | jq -r '.num_turns // 0')
  result=$(echo "$output" | jq -r '.result // ""')

  echo "{\"cost\":$cost,\"input_tokens\":$input_tokens,\"output_tokens\":$output_tokens,\"num_turns\":$num_turns,\"wall_time\":$wall_time,\"result\":$(echo "$result" | jq -Rs .)}"
}

run_test_pair() {
  local test_name="$1"
  local prompt="$2"
  local work_dir="$3"
  local tools="$4"
  local rules_file="$5"
  local max_turns="${6:-20}"

  echo "  Running baseline..."
  local baseline
  baseline=$(invoke_claude_test "$prompt" "$work_dir" "$tools" "" "$max_turns")

  echo "  Running with rule..."
  local with_rule
  with_rule=$(invoke_claude_test "$prompt" "$work_dir" "$tools" "$rules_file" "$max_turns")

  local results_dir="$PROJECT_ROOT/tests/results"
  local timestamp=$(date +%Y%m%d-%H%M%S)
  echo "{\"test\":\"$test_name\",\"baseline\":$baseline,\"with_rule\":$with_rule}" \
    > "$results_dir/${test_name}-${timestamp}.json"

  echo "$baseline"
  echo "$with_rule"
}

compare_metric() {
  local metric="$1"
  local baseline_val="$2"
  local rule_val="$3"

  if (( $(echo "$rule_val < $baseline_val" | bc -l) )); then
    local delta
    delta=$(echo "scale=1; ($rule_val - $baseline_val) / $baseline_val * 100" | bc -l)
    echo "PASS|${delta}%"
  else
    echo "WARN|no improvement"
  fi
}
