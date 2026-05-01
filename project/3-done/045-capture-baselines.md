# Capture Efficiency Baselines

## Abstract

Record baseline metrics from initial test runs (with and without rules) to establish thresholds for future regression testing.

## Priority: 045

- Value: 7/10 — Without baselines, tests can't assert regressions. Essential for the test suite to be useful long-term.
- Momentum: 1/10 — Fresh, blocked by test suite
- Effort: 4/10 — Need to run all tests, record metrics, decide on threshold format/storage
- Risk: 2/10 — Low risk, worst case baselines need recalibrating

## Timeline

- Captured: 2026-04-28
- Refined: 2026-04-29
- Started: 2026-05-01
- Verified: 2026-05-01
- Done: 2026-05-01

## Details

- **Dependency:** Blocked by test suite task. Tests must exist before baselines can be captured.
- Run full test suite, record metrics for each test (with-rule and without-rule runs).
- Store baselines in a format future test runs can compare against.
- Define acceptable variance thresholds.

### Design decisions (from 3-agent council + decision maker)

1. Static JSON file (`tests/baselines.json`) over SQLite table — human-readable, diff-able in git, manually edited.
2. Cost metric only — output tokens and wall_time too noisy, cost is the bottom-line signal.
3. Rule arm only — goal is catching overall cost regressions, not baseline arm drift.
4. 3x multiplier — absorbs 2-5x LLM variance, catches true regressions (cost doubles+).
5. Manual updates — edit JSON, commit with explanation. No auto-updating.

### Initial plan pivoted after user clarification

First council designed same-run multiplier (rule vs baseline arm). User clarified the real goal: cross-run comparison to catch model version changes or rule changes that silently increase cost. Redesigned as static ceilings compared against each test's rule-arm cost.

## Verification

```
$ docker compose run --rm test bash -c '
source tests/lib/assert.sh
assert_within_baseline "model-selection/simple-task" 0.05
echo "pass=$TESTS_PASSED fail=$TESTS_FAILED"
assert_within_baseline "model-selection/simple-task" 0.09
echo "pass=$TESTS_PASSED fail=$TESTS_FAILED"
assert_within_baseline "nonexistent/test" 0.05
echo "pass=$TESTS_PASSED fail=$TESTS_FAILED"
'

--- Test 1: under ceiling ---
Result: passed=1 failed=0
--- Test 2: over ceiling ---
  FAIL: Cost 0.09 exceeds ceiling 0.08 for model-selection/simple-task
Result: passed=1 failed=1
--- Test 3: missing test ---
  WARN: no baseline for nonexistent/test
Result: passed=1 failed=1
```

All three cases verified: pass under ceiling, fail over ceiling, warn on missing entry.
