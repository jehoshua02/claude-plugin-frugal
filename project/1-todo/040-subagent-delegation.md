# Subagent Delegation Rule

## Abstract

New rule: always delegate to subagents, main thread orchestrates only. Keeps main context lean. Includes writing the rule and finding a way to test it (can't be tested in a single headless call — subagents need a real session).

## Priority: 040

- Value: 7/10 — Big token saver on complex tasks, keeps main context lean
- Momentum: 4/10 — Rule doesn't exist yet, same untestable-in-headless problem
- Effort: 5/10 — Rule is easy to write, testing needs real session with subagent spawning
- Risk: 4/10 — Over-delegating could slow down simple tasks or add unnecessary overhead

## Timeline

- Captured: 2026-04-29
- Refined: 2026-04-29
