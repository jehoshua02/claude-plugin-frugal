# Switch to stdout-based rule injection

## Abstract

Replace file-copy hook with SessionStart + SubagentStart hooks that cat rules to stdout. No files written to user environment.

## Priority: 028

- Value: 8/10 — Eliminates untracked files, clean uninstall
- Momentum: 7/10 — Research done, approach decided, comparison complete
- Effort: 3/10 — Update hooks.json, remove file-copy logic, add SubagentStart hook
- Risk: 3/10 — 10k cap, SubagentStart stdout unverified

## Timeline

- Captured: 2026-04-29
- Refined: 2026-04-29
- Done: 2026-05-01

## Details

### Decision

Use SessionStart + SubagentStart hooks to cat rules to stdout instead of copying files to ~/.claude/rules/.

### Approaches considered

1. **cat to stdout via hooks** (chosen) — Clean provenance, nothing to clean up on uninstall. Two hooks needed. 10k char cap.
2. **Copy files to ~/.claude/rules/** (current) — Proven but creates orphaned files. Messy uninstall.
3. **@import in CLAUDE.md** (rejected) — Modifies user files, stale reference persists after uninstall.

## Closed

Already implemented. hooks.json has both SessionStart and SubagentStart hooks using `cat rules/*.md`.
