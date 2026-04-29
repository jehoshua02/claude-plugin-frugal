# Track test metrics for statistical significance

## Abstract

Store test metrics indefinitely in SQLite so we can query insights with statistical significance over many runs.

## Priority: 009

- Value: 9/10 — Enables statistical confidence in rule effectiveness, blocks further test runs
- Momentum: 7/10 — Test harness already captures the metrics, just needs a sink
- Effort: 3/10 — Add sqlite to Dockerfile, insert after each test, volume mount the db
- Risk: 2/10 — Additive, doesn't change existing test logic

## Timeline

- Captured: 2026-04-29
- Refined: 2026-04-29
