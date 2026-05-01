# Update README.md

## Abstract

Explain each rule with proof of benefit. Include instructions for running tests.

## Priority: 032

- Value: 7/10 — Drives adoption and trust, but no functional impact
- Momentum: 5/10 — Test results provide the proof data, but rules are still being tweaked
- Effort: 3/10 — Straightforward writing task
- Risk: 2/10 — Docs written too early get stale if rules keep changing

## Timeline

- Captured: 2026-04-29
- Refined: 2026-04-29
- Started: 2026-05-01
- Verified: 2026-05-01
- Done: 2026-05-01

## Details

- Removed stale "subagent delegation" mention (rule was dropped after testing showed no benefit)
- Documented all 8 active rules with one-paragraph descriptions
- Added test metrics for model-selection (89% output reduction, 3% cost savings) and output-redirect (5-10% cost savings)
- Added Testing section with docker compose commands and directory structure
- Kept it concise — no walls of text

## Verification

Verified README content matches current rules directory:

```
$ ls rules/
model-selection.md  no-pdf.md  output-redirect.md  persist-progress.md
questions.md  read-sections.md  responses.md  retry-limit.md
```

All 8 rules documented. Subagent delegation correctly omitted (dropped in task 040).
Test metrics sourced from `tests/query.sh compare` output.
