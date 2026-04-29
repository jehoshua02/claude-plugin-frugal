# Test Suite for Plugin Rules

## Abstract

Build a test suite that verifies each rule improves efficiency without sacrificing correctness. Unit tests isolate each rule; integration tests verify all rules together.

## Details

### Approach

For each rule, define a task. Run the task twice: once with the rule, once without. Assert both complete correctly. Assert the rule-enabled run is more efficient.

Integration tests: same idea, all rules loaded vs no rules.

### Open Questions

- Efficiency metric: tokens, tool calls, turns, wall time, or combo?
- Task completion verification: deterministic assertions, LLM-as-judge, or both?
- Agent execution: Claude Code CLI headless (`claude -p`), Anthropic API, or other?
- Environment isolation: temp dirs with seeded files, torn down after?
- Cost and flakiness: multiple runs and average? Acceptable variance threshold?
