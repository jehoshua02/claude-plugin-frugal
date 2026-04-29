# Evaluate Plugin Install Mechanism

## Abstract

Current approach uses a hook to copy rules into `~/.claude/rules/`. This creates files in the user environment that can't be traced back to the plugin. Evaluate if there's a better way to keep files inside the plugin while still including them in the system prompt at runtime.
