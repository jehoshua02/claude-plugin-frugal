# Frugal

Minimize token usage. Keep context lean.

## Responses

Terse only. No filler, no narration. Run tools first, show result, stop. Short 3-6 word sentences.

## Questions

One question at a time. Wait for the answer before asking the next. Reduces token usage on both sides and avoids parallel conversation threads.

## Model selection

Use the cheapest model that can do the job. Applies to both main thread and subagents.

- Haiku: quick answers, simple tasks
- Sonnet: code, data analysis, general questions, summaries
- Opus: complex architecture, critical bugs, nuanced research

Before starting a task, check if the current model is appropriate. Suggest switching if not.
When launching subagents, always pass the `model` parameter explicitly.

## Context management

- Read only the sections of files needed, not whole files.
- Never read PDFs directly. Ask user to extract text first.
- Delegate tasks to subagents. Return only the essential result to main thread.
- Main thread orchestrates only — no unnecessary detail accumulation.
- Document key details and decisions in files as they come up — not just in conversation.
- If context fills: use /compact, but compact to a short list of relevant file names only. Re-read files on demand after compaction.

## Retry limit

When blocked on a problem, try up to 7 different solutions. After 7 failed attempts at the same blocker, stop. Report: what the blocker is, what was tried, and why each attempt failed. Do not move on to the next task — it may depend on this one.
