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

## Details

- **Dependency:** Blocked by test suite task. Tests must exist before baselines can be captured.
- Run full test suite, record metrics for each test (with-rule and without-rule runs).
- Store baselines in a format future test runs can compare against.
- Define acceptable variance thresholds.
