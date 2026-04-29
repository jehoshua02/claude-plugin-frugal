#!/bin/bash
# Query test metrics from SQLite
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DB="$SCRIPT_DIR/metrics.db"

if [[ ! -f "$DB" ]]; then
  echo "No metrics database found. Run tests first."
  exit 1
fi

case "${1:-summary}" in
  summary)
    echo "=== Metrics Summary ==="
    echo ""
    sqlite3 -header -column "$DB" <<'SQL'
SELECT
  test,
  arm,
  COUNT(*) as runs,
  ROUND(AVG(cost), 4) as avg_cost,
  ROUND(AVG(total_input)) as avg_input,
  ROUND(AVG(output_tokens)) as avg_output,
  ROUND(AVG(num_turns), 1) as avg_turns,
  ROUND(AVG(wall_time)) as avg_wall
FROM metrics
GROUP BY test, arm
ORDER BY test, arm;
SQL
    ;;
  compare)
    echo "=== Rule vs Baseline Comparison ==="
    echo ""
    sqlite3 -header -column "$DB" <<'SQL'
SELECT
  b.test,
  COUNT(*) as runs,
  ROUND(AVG(b.cost), 4) as base_cost,
  ROUND(AVG(r.cost), 4) as rule_cost,
  ROUND((AVG(r.cost) - AVG(b.cost)) / AVG(b.cost) * 100, 1) as cost_pct,
  ROUND(AVG(b.total_input)) as base_input,
  ROUND(AVG(r.total_input)) as rule_input,
  ROUND((AVG(r.total_input) - AVG(b.total_input)) / AVG(b.total_input) * 100, 1) as input_pct,
  ROUND(AVG(b.output_tokens)) as base_output,
  ROUND(AVG(r.output_tokens)) as rule_output,
  ROUND((AVG(r.output_tokens) - AVG(b.output_tokens)) / AVG(b.output_tokens) * 100, 1) as output_pct
FROM metrics b
JOIN metrics r ON b.test = r.test AND b.arm = 'baseline' AND r.arm = 'rule'
  AND b.timestamp = r.timestamp
GROUP BY b.test
ORDER BY cost_pct;
SQL
    ;;
  raw)
    sqlite3 -header -column "$DB" "SELECT * FROM metrics ORDER BY timestamp DESC LIMIT ${2:-20};"
    ;;
  sql)
    shift
    sqlite3 -header -column "$DB" "$@"
    ;;
  *)
    echo "Usage: $0 [summary|compare|raw [N]|sql 'QUERY']"
    ;;
esac
