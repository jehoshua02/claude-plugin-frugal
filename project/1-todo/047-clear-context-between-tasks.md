# Clear Context Between Tasks

## Abstract

Add a rule: clear/compact context when switching to unrelated work. Keep context when tasks are part of the same flow.

## Priority: 047

- Value: 6/10 — Saves tokens by dropping irrelevant context, but only matters in longer sessions with multiple tasks
- Momentum: 1/10 — Fresh idea
- Effort: 3/10 — Needs careful wording to capture the "related work" nuance
- Risk: 3/10 — Agent might misjudge relatedness and clear context prematurely, losing useful state

## Timeline

- Captured: 2026-04-28
- Refined: 2026-04-29

## Details

- Clear context when switching to unrelated work (different part of codebase, different feature).
- Keep context when tasks are part of the same flow: TDD cycle, bug found during verification, related implementation steps.
- Agent uses judgment to determine relatedness. Ask user when not confident.
- Examples of "keep": write test → implement → verify → fix bug found during verify. Examples of "clear": finish feature A → start unrelated bug fix B.
