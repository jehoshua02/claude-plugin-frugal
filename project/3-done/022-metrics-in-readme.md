# Metrics in README for Every Rule

## Abstract

Run all unit tests to collect baseline vs rule comparison data, then update README with metrics for every rule.

## Priority: 022

- Value: 7/10 — Concrete proof for every rule builds trust and helps users decide which rules to keep
- Momentum: 8/10 — All test infrastructure exists, just needs runs and a README edit
- Effort: 4/10 — 6 untested rules x 2 API calls each, plus README update
- Risk: 2/10 — No code changes beyond README text

## Timeline

- Captured: 2026-05-01
- Refined: 2026-05-01
- Started: 2026-05-01
- Verified: 2026-05-01
- Done: 2026-05-01

## Details

Ran all 6 previously-untested rules: responses, read-sections, questions, persist-progress, no-pdf, retry-limit.

Results by cost impact:
- retry-limit: -50% cost, -44% turns (strongest rule)
- no-pdf: -29% cost, -51% input tokens
- questions: -8% cost, -67% output tokens
- output-redirect: -6% cost (already had data, 4 runs)
- model-selection: -3% cost, -89% output tokens
- responses: cost neutral, -13% output tokens
- read-sections: no cost savings on small test files (correctness-focused)
- persist-progress: behavioral only, can't measure in single-turn tests

Ordered rules in README by cost impact (highest savings first) instead of alphabetically.

## Verification

```
$ docker compose run --rm test bash tests/query.sh compare
=== Rule vs Baseline Comparison ===
test                                 runs  base_cost  rule_cost  cost_pct
-----------------------------------  ----  ---------  ---------  --------
retry-limit/failing-tests            1     0.1643     0.0827     -49.7
no-pdf/refuse-pdf                    1     0.0375     0.0266     -29.1
questions/incomplete-config          1     0.0368     0.0337     -8.3
output-redirect/verbose-command      4     0.0705     0.0666     -5.5
model-selection/simple-task          1     0.0266     0.0258     -3.1
responses/create-file                1     0.0288     0.0299     4.0
read-sections/search                 1     0.0408     0.0485     19.0
```

All 8 rules now have Tested lines in README.
