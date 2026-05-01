#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/run.sh"
source "$SCRIPT_DIR/../../lib/assert.sh"
source "$SCRIPT_DIR/../../lib/seed.sh"
source "$SCRIPT_DIR/../../lib/db.sh"

TEST_NAME="read-sections/full-read"
RULE="$PROJECT_ROOT/rules/read-sections.md"
TOOLS="Read,Grep"

echo "[$TEST_NAME]"

rule_dir=$(new_test_dir)
trap "remove_test_dir '$rule_dir'" EXIT

cat > "$rule_dir/app.py" << 'SEED'
class OrderProcessor:
    def __init__(self, db, mailer):
        self.db = db
        self.mailer = mailer

    def create_order(self, user_id, items):
        order = self.db.insert("orders", user_id=user_id, items=items)
        self.mailer.send_confirmation(user_id, order.id)
        return order

    def cancel_order(self, order_id):
        order = self.db.get("orders", order_id)
        if order.status == "shipped":
            raise ValueError("Cannot cancel shipped order")
        self.db.update("orders", order_id, status="cancelled")
        self.mailer.send_cancellation(order.user_id, order_id)

    def refund_order(self, order_id):
        order = self.db.get("orders", order_id)
        if order.status not in ("cancelled", "returned"):
            raise ValueError("Order must be cancelled or returned")
        amount = sum(item.price for item in order.items)
        self.db.insert("refunds", order_id=order_id, amount=amount)
        return amount
SEED

PROMPT="Summarize what this class in app.py does. Cover all methods."

echo "  Running with rule..." >&2
with_rule=$(invoke_claude_test "$PROMPT" "$rule_dir" "$TOOLS" "$RULE")

# Save results
results_dir="$PROJECT_ROOT/tests/results"
timestamp=$(date +%Y%m%d-%H%M%S)
echo "{\"test\":\"$TEST_NAME\",\"with_rule\":$with_rule}" \
  > "$results_dir/read-sections-full-read-${timestamp}.json"

record_metric "$TEST_NAME" "rule" "$with_rule"

rule_cost=$(echo "$with_rule" | jq '.cost')
assert_within_baseline "$TEST_NAME" "$rule_cost"

rule_result=$(echo "$with_rule" | jq -r '.result')

# Correctness: should mention key methods (proves it read the whole file)
assert_contains "$rule_result" "create\|order" "Should mention order creation"
assert_contains "$rule_result" "cancel" "Should mention cancellation"
assert_contains "$rule_result" "refund" "Should mention refund"

echo "  Correctness: passed=$TESTS_PASSED failed=$TESTS_FAILED"

[[ $TESTS_FAILED -eq 0 ]]
