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
- Started: 2026-04-29

## Details

### Decisions

- **Execution:** `claude -p` headless, no `--bare` (breaks OAuth), no plugins installed in container
- **Model:** Sonnet for all tests (cost-effective)
- **Metrics:** JSON output gives total_cost_usd, usage.input_tokens, usage.output_tokens, num_turns
- **Rules:** Split into individual files in `rules/`. Tests reference directly.
- **Docker:** Alpine + claude CLI + jq. docker-compose with volume mounts for rules/tests and OAuth creds.
- **Hook change:** SessionStart + SubagentStart hooks now cat rules to stdout (no file copy).

### Current state: 5/8 tests passing

Passing: model-selection, no-pdf, questions, read-sections, responses

Failing:
- **document-decisions/fix-bug** — Assertion too strict ("zero"), shared test dir between runs
- **retry-limit/failing-tests** — Model recognizes unfixable problem too quickly, doesn't retry 7 times
- **integration/all-rules** — Didn't ask config question (assertion mismatch)

### Remaining work

- Fix shared test dir bug in document-decisions and integration tests
- Relax assertions to match actual model behavior
- Retry test needs a more convincing unfixable scenario
- Efficiency metrics show no improvement — rules may be too subtle for single-call tests, or system prompt dominates
- Consider dropping median-of-two strategy (not implemented yet, may not be needed)
