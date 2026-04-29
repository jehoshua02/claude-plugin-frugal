#!/bin/bash
# SQLite metrics storage

_DB_SH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
METRICS_DB="$_DB_SH_DIR/../metrics.db"

init_db() {
  sqlite3 "$METRICS_DB" <<'SQL'
CREATE TABLE IF NOT EXISTS metrics (
  id INTEGER PRIMARY KEY,
  timestamp TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%S', 'now')),
  test TEXT NOT NULL,
  arm TEXT NOT NULL,
  cost REAL,
  input_tokens INTEGER,
  cache_creation INTEGER,
  cache_read INTEGER,
  total_input INTEGER,
  output_tokens INTEGER,
  num_turns INTEGER,
  wall_time INTEGER
);
SQL
}

record_metric() {
  local test="$1"
  local arm="$2"
  local json="$3"

  local cost input_tokens cache_creation cache_read total_input output_tokens num_turns wall_time
  cost=$(echo "$json" | jq -r '.cost // 0')
  input_tokens=$(echo "$json" | jq -r '.input_tokens // 0')
  cache_creation=$(echo "$json" | jq -r '.cache_creation // 0')
  cache_read=$(echo "$json" | jq -r '.cache_read // 0')
  total_input=$(echo "$json" | jq -r '.total_input // 0')
  output_tokens=$(echo "$json" | jq -r '.output_tokens // 0')
  num_turns=$(echo "$json" | jq -r '.num_turns // 0')
  wall_time=$(echo "$json" | jq -r '.wall_time // 0')

  sqlite3 "$METRICS_DB" <<SQL
INSERT INTO metrics (test, arm, cost, input_tokens, cache_creation, cache_read, total_input, output_tokens, num_turns, wall_time)
VALUES ('$test', '$arm', $cost, $input_tokens, $cache_creation, $cache_read, $total_input, $output_tokens, $num_turns, $wall_time);
SQL
}

init_db
