# Test Suite for Plugin Rules

## Abstract

Build a test suite that verifies each rule improves efficiency without sacrificing correctness. Unit tests isolate each rule; integration tests verify all rules together.

## Priority: 051

- Value: 9/10 — Validates the plugin works. Foundation for all future quality assurance.
- Momentum: 3/10 — Open questions resolved in conversation, some research still needed on metric extraction
- Effort: 8/10 — Test framework, task design for each rule, CLI orchestration, metric extraction, comparison logic
- Risk: 4/10 — Non-deterministic LLM output means flaky tests possible. Cost of running two agents per test.

## Timeline

- Captured: 2026-04-28
- Refined: 2026-04-29

## Details

### Approach

For each rule, define a task. Run the task twice via `claude -p` (CLI headless): once with the rule, once without. Assert both complete correctly. Assert the rule-enabled run is more efficient.

Integration tests: same idea, all rules loaded vs no rules.

### Decisions

- **Execution:** Claude Code CLI headless (`claude -p`). Tests real agent behavior with tools, hooks, file system.
- **Metrics:** Track everything easily extractable from CLI — tokens, tool calls, turns, wall time, etc.
- **Environment:** Temp dirs with seeded files, torn down after each run.
- **Correctness:** Deterministic assertions on task output (file exists, contains expected content, etc.).

### Open

- Metric extraction method from CLI — research needed.
- Flakiness strategy — multiple runs and average, or acceptable variance threshold.
