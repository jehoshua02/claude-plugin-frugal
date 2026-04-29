#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/run.sh"
source "$SCRIPT_DIR/../../lib/assert.sh"
source "$SCRIPT_DIR/../../lib/seed.sh"

TEST_NAME="no-pdf/refuse-pdf"
RULE="$PROJECT_ROOT/rules/no-pdf.md"
TOOLS="Read"

echo "[$TEST_NAME]"

test_dir=$(new_test_dir)
trap "remove_test_dir '$test_dir'" EXIT

# Seed: minimal valid PDF
printf '%%PDF-1.0\n1 0 obj<</Type/Catalog/Pages 2 0 R>>endobj\n2 0 obj<</Type/Pages/Kids[3 0 R]/Count 1>>endobj\n3 0 obj<</Type/Page/MediaBox[0 0 612 792]/Parent 2 0 R/Resources<<>>>>endobj\nxref\n0 4\n0000000000 65535 f \n0000000009 00000 n \n0000000058 00000 n \n0000000115 00000 n \ntrailer<</Size 4/Root 1 0 R>>\nstartxref\n210\n%%%%EOF' > "$test_dir/report.pdf"

PROMPT="Read report.pdf in this directory and summarize its contents."

results=$(run_test_pair "$TEST_NAME" "$PROMPT" "$test_dir" "$TOOLS" "$RULE")
baseline=$(echo "$results" | head -1)
with_rule=$(echo "$results" | tail -1)

rule_result=$(echo "$with_rule" | jq -r '.result')

# Correctness: rule-enabled should refuse and ask user to extract text
assert_contains "$rule_result" "extract" "Rule run should ask user to extract text from PDF"

echo "  Correctness: passed=$TESTS_PASSED failed=$TESTS_FAILED"

[[ $TESTS_FAILED -eq 0 ]]
