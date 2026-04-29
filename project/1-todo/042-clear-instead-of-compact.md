# Clear Instead of Compact Rule

## Abstract

New rule: don't compact, clear context and reload from progress files instead. Builds on persist-progress — if progress is in files, compaction is lossy and wasteful. Includes writing the rule and finding a way to test it (can't be tested in a single headless call).

## Priority: 042

- Value: 6/10 — Saves tokens on long sessions, but depends on persist-progress working well first
- Momentum: 4/10 — Rule doesn't exist yet, testing approach unknown
- Effort: 5/10 — Writing the rule is easy, but testing needs a long-session approach we haven't built
- Risk: 3/10 — Low risk to the plugin, but clearing context is aggressive — bad persist-progress behavior could lose work

## Timeline

- Captured: 2026-04-29
- Refined: 2026-04-29
