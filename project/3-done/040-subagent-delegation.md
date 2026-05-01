# Subagent Delegation Rule

## Abstract

New rule: always delegate to subagents, main thread orchestrates only. Keeps main context lean.

## Priority: 040

- Value: 7/10 — Big token saver on complex tasks, keeps main context lean
- Momentum: 4/10 — Rule doesn't exist yet, same untestable-in-headless problem
- Effort: 5/10 — Rule is easy to write, testing needs real session with subagent spawning
- Risk: 4/10 — Over-delegating could slow down simple tasks or add unnecessary overhead

## Timeline

- Captured: 2026-04-29
- Refined: 2026-04-29
- Started: 2026-04-30
- Done: 2026-05-01

## Details

Tested multiple rule phrasings across 5+ test runs:
1. "delegate independent steps" — baseline already does this
2. "MANDATORY: delegate all implementation" — Claude ignored it
3. "MANDATORY: You must use the Agent tool" with explicit violation clause — still ignored
4. Stronger wording eventually triggered delegation, but cost 2x more than baseline

Key findings:
- Claude already delegates to subagents naturally for multi-step tasks (baseline used 2 models)
- Forcing more delegation increased cost without measurable benefit
- The rule adds overhead without changing behavior meaningfully

**Decision: rule dropped.** No rule file or test shipped. Reverted all changes to run.sh and assert.sh.

## Verification

Rule provides no value — baseline already delegates. Confirmed across multiple test runs showing baseline model_count=2 (subagents used without the rule).
