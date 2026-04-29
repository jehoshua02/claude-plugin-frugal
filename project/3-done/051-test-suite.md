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
- Verified: 2026-04-29
- Done: 2026-04-29

## Details

- 9 tests across 7 rules + 1 integration test, all passing
- Docker-based for isolation, Sonnet model, OAuth via credential mount
- Rules improved during testing: read-sections (mandatory grep-first), persist-progress (renamed, clearer wording)
- Key fixes: separate baseline/rule dirs, credentials-only mount, total_input metric, count_occurrences crash

## Verification

All 9 tests pass via `docker compose run --rm test`. Merged as PR #2, published as v1.3.0.
