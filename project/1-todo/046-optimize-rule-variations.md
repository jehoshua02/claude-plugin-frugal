# Optimize rules by testing variations

## Abstract

Systematically test different phrasings of each rule to find the most effective wording.

## Priority: 46

- Value: 7/10 — Directly improves core output. Phrasing improvements compound across all users.
- Momentum: 3/10 — No work started, but test suite infrastructure is in place.
- Effort: 6/10 — Moderate. Each rule needs multiple phrasing variants tested and compared. Iterative, not complex.
- Risk: 2/10 — Low. Only adopt phrasings that measure better.

## Timeline

- Captured: 2026-04-30
- Refined: 2026-04-30

## Details

Use the existing test suite and SQLite metrics to measure rule effectiveness. Test alternative phrasings for each rule, compare metrics, keep the winners.

## Verification

Metrics show improvement (or at minimum no regression) for each changed rule phrasing.
