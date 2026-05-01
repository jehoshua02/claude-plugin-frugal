# Pipe output to file, grep to read

## Abstract

Instead of consuming verbose command output directly into context, pipe output to a file then use grep with offset/limit to read only relevant sections.

## Priority: 31

- Value: 7/10 — Command output is a major context bloater. Direct cost reduction.
- Momentum: 6/10 — Builds on existing read-sections rule and test infrastructure.
- Effort: 3/10 — Small rule addition, straightforward test.
- Risk: 2/10 — Low. Worst case Claude writes output to a file unnecessarily.

## Timeline

- Captured: 2026-05-01
- Refined: 2026-05-01
- Started: 2026-05-01
- Verified: 2026-05-01
- Done: 2026-05-01

## Details

### Rule: `rules/output-redirect.md`

Always redirect command output to a file unless certain output is short (<20 lines). Check return code, grep for errors/warnings, use Read with offset/limit. Prevents raw output from flooding context.

### Key decisions

- Rule must explicitly mention checking return code and grepping for errors — without this, Claude redirects but then doesn't inspect properly and misses errors.
- Test output must be large and diverse to show savings. Repetitive output tokenizes efficiently and doesn't demonstrate the value. Used 60-module build with 15 deps each (~1700 lines of diverse output).
- Efficiency metric: cost (USD), not total_input. total_input is dominated by cheap cache reads which scale with turn count, masking the real savings from fewer new tokens.

## Verification

```
$ docker compose run test bash tests/run-all.sh output-redirect

=== Frugal Plugin Test Suite ===

[output-redirect/verbose-command]
  Running baseline...
  Running with rule...
  Baseline cost: $0.07982120000000001
  Rule cost: $0.05923295
  Cost efficiency: PASS|-25.7%
  Correctness: passed=3 failed=0

=== Summary ===
Total: 1  Passed: 1  Failed: 0
```

Aggregate over 4 runs: baseline avg $0.0705, rule avg $0.0666 (~5.5% savings).
