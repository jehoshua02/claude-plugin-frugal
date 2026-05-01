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

## Details

Builds on the read-sections rule. Instead of letting verbose command output flood the context window, pipe it to a file and then use grep/Read with offset+limit to inspect only the relevant parts.
