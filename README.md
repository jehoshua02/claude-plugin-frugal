# frugal

Cost efficiency rules for Claude Code. Lean responses, smart model selection, subagent delegation, context management.

## Installation

Add the jehoshua02 marketplace and install the plugin using the `/plugin` command in Claude Code:

```
/plugin add-marketplace jehoshua02
/plugin install frugal
```

## What it does

Injects cost efficiency rules via `CLAUDE.md`:

- **Terse responses** — no filler, no narration, results only
- **Model selection** — Haiku for simple tasks, Sonnet for code and analysis, Opus for complex decisions
- **Subagent delegation** — delegate to subagents with the right model; main thread orchestrates only
- **Context management** — read only what's needed, document as you go, /clear instead of /compact
