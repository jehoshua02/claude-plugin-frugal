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
- Done: 2026-05-01

## Details

Ran a 3-agent council (advocate, skeptic, pragmatist) plus a decision maker.

**Decision: rule dropped.** Does not belong in frugal.

Reasons:
1. Claude cannot clear its own context — it can only suggest /clear to the user. A rule framing this as Claude's action is unenforceable.
2. Task boundary detection is unreliable. Misjudging causes lost context or redundant re-reading, costing more than the tokens saved.
3. The pragmatist tried 3 candidate wordings — none scored well on both specificity (will Claude follow it?) and generality (workflow-agnostic?).
4. Already partially covered by persist-progress ("anything needed to resume after context is cleared").
5. Session length is a user-side workflow decision, not something a CLAUDE.md rule can safely govern.

## Verification

No rule shipped. Decision is "no action needed" — persist-progress already covers the state-preservation side.
