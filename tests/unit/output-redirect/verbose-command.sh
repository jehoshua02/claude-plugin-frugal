#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/run.sh"
source "$SCRIPT_DIR/../../lib/assert.sh"
source "$SCRIPT_DIR/../../lib/seed.sh"
source "$SCRIPT_DIR/../../lib/db.sh"

TEST_NAME="output-redirect/verbose-command"
RULE="$PROJECT_ROOT/rules/output-redirect.md"
TOOLS="Read,Bash,Grep"

echo "[$TEST_NAME]"

baseline_dir=$(new_test_dir)
rule_dir=$(new_test_dir)
trap "remove_test_dir '$baseline_dir'; remove_test_dir '$rule_dir'" EXIT

seed_script() {
  local dir="$1"
  cat > "$dir/build.sh" << 'SEED'
#!/bin/bash
echo "=== Build started at $(date) ==="
echo "Configuration: release, target=x86_64-linux, jobs=8"
echo ""

for mod in $(seq 1 60); do
  name="module_$(printf '%03d' $mod)"
  echo "--- Building module: $name ---"
  for dep in libc libssl libcrypto libpthread libz libcurl libxml2 libsqlite3 libuv libnghttp2 libfmt libspdlog libboost libprotobuf libgrpc; do
    echo "  Checking $dep for $name... found /usr/lib/$dep.so.$(( RANDOM % 3 + 1 )).$(( RANDOM % 10 )).$(( RANDOM % 5 ))"
  done
  for src in init handlers utils config routes models migrations seeds fixtures validators; do
    echo "  Compiling src/$name/$src.c -> build/$name/$src.o [$(( RANDOM % 500 + 50 ))ms]"
  done
  echo "  Linking build/$name/$name.so ($(( RANDOM % 900 + 100 ))KB)"
  if [ "$mod" -eq 47 ]; then
    echo "  [WARNING] Deprecated API call in src/$name/handlers.c:142 — migrate to v2"
    echo "  [WARNING] Unused variable 'ctx' in src/$name/config.c:89"
    echo "  [ERROR] src/$name/crypto.c:87: undefined reference to 'crypt_gensalt'"
    echo "  [ERROR] src/$name/crypto.c:103: undefined reference to 'crypt_checksalt'"
    echo "  [ERROR] Failed to link module $name: missing dependency libcrypt (required by crypto.c)"
    echo "  Module $name: FAILED"
  else
    echo "  [INFO] Static analysis: 0 issues in $name"
    echo "  Module $name: OK ($(( RANDOM % 200 + 50 ))ms)"
  fi
  echo ""
done

echo "=== Build Summary ==="
echo "  Modules built: 59/60"
echo "  Modules failed: 1 (module_047)"
echo "  Total warnings: 2"
echo "  Total errors: 3"
echo "  Build time: 127.3s"
exit 1
SEED
  chmod +x "$dir/build.sh"
}

seed_script "$baseline_dir"
seed_script "$rule_dir"

PROMPT="Run build.sh and tell me which module failed and why."

echo "  Running baseline..." >&2
baseline=$(invoke_claude_test "$PROMPT" "$baseline_dir" "$TOOLS")

echo "  Running with rule..." >&2
with_rule=$(invoke_claude_test "$PROMPT" "$rule_dir" "$TOOLS" "$RULE")

results_dir="$PROJECT_ROOT/tests/results"
timestamp=$(date +%Y%m%d-%H%M%S)
echo "{\"test\":\"$TEST_NAME\",\"baseline\":$baseline,\"with_rule\":$with_rule}" \
  > "$results_dir/output-redirect-verbose-command-${timestamp}.json"

record_metric "$TEST_NAME" "baseline" "$baseline"
record_metric "$TEST_NAME" "rule" "$with_rule"

rule_cost=$(echo "$with_rule" | jq '.cost')
assert_within_baseline "$TEST_NAME" "$rule_cost"

baseline_result=$(echo "$baseline" | jq -r '.result')
rule_result=$(echo "$with_rule" | jq -r '.result')

# Correctness: both should identify the failed module
assert_contains "$baseline_result" "module_047\|047" "Baseline should find the failed module"
assert_contains "$rule_result" "module_047\|047" "Rule run should find the failed module"
assert_contains "$rule_result" "libcrypt" "Rule run should identify the missing dependency"

# Efficiency: rule should cost less
baseline_cost=$(echo "$baseline" | jq '.cost')
rule_cost=$(echo "$with_rule" | jq '.cost')

echo "  Baseline cost: \$$baseline_cost"
echo "  Rule cost: \$$rule_cost"
echo "  Cost efficiency: $(compare_metric "cost" "$baseline_cost" "$rule_cost")"
echo "  Correctness: passed=$TESTS_PASSED failed=$TESTS_FAILED"

[[ $TESTS_FAILED -eq 0 ]]
