# frugal

Cost efficiency rules for Claude Code. Lean responses, smart model selection, context management.

## Installation

```
/plugin add-marketplace jehoshua02
/plugin install frugal
```

## Rules

### responses

Terse output only. No filler, no narration, no trailing summaries. Short 3-6 word sentences. Run tools first, show result, stop.

### model-selection

Use the cheapest model for the job. Haiku for quick answers, Sonnet for code and analysis, Opus for complex architecture. Suggests switching before starting a task. Forces explicit `model` parameter on subagent launches.

**Tested:** 89% reduction in output tokens, 3% cost reduction on simple tasks vs baseline.

### read-sections

Grep first, then Read with offset/limit around matches. Never read entire files unless the task requires it (summarization, full review).

### output-redirect

Redirect verbose command output to a file instead of flooding context. Check return code, grep the output file for errors, then Read relevant sections.

**Tested:** 5-10% cost reduction on verbose build output scenarios.

### questions

One question at a time. Wait for the answer before asking the next. Prevents parallel conversation threads and reduces token usage on both sides.

### persist-progress

Persist findings, decisions, and progress to files as you work. Ensures continuity after context clears or compaction.

### no-pdf

Never read PDFs directly. Ask the user to extract text first. Prevents wasted tokens on failed or garbled reads.

### retry-limit

Try up to 7 solutions when blocked. After 7 failures, stop and report what was tried. Prevents runaway loops that burn tokens without progress.

## Testing

Tests run inside Docker. Each test invokes Claude Code in headless mode with and without a rule, then compares cost and correctness.

```bash
docker compose run --rm test                          # run all tests
docker compose run --rm test bash tests/run-all.sh output-redirect  # filter by name
docker compose run --rm test bash tests/query.sh compare            # compare rule vs baseline
docker compose run --rm test bash tests/query.sh summary            # per-arm metrics
```

### Test structure

```
tests/
  unit/<rule-name>/<scenario>.sh   — one rule, one scenario, baseline vs rule
  integration/all-rules.sh         — all rules combined vs no rules
  lib/                             — shared helpers (run, assert, seed, db)
  metrics.db                       — SQLite results database
  results/                         — raw JSON per run
```

## License

MIT
