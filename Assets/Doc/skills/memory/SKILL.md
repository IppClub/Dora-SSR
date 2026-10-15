---
name: memory
description: Agent memory files with grep-based scoped recall.
always: true
---

# Memory

## Structure

- `.agent/main/MEMORY.md` — Core memory: user preferences, stable facts, decisions, known issues.
- `.agent/main/PROJECT_MEMORY.md` — Project facts, build/run notes, files/architecture, project decisions and issues.
- `.agent/main/SESSION_SUMMARY.md` — Current goal, recent progress, and open issues.
- `.agent/main/HISTORY.jsonl` — Consolidated action history. Search it when older details are needed.
- `.agent/main/SESSION.jsonl` — Crash-safe session tail. Do not edit manually.

Sub-agents use `.agent/subagents/<id>/...` for scoped memory.

## When to Update Memory

Write important facts immediately using `edit_file`:
- User preferences ("I prefer dark mode")
- Project context ("The API uses OAuth2")
- Relationships ("Alice is the project lead")

Put transient task state in `SESSION_SUMMARY.md`, not `MEMORY.md`.

## Auto-consolidation

Old conversations are automatically summarized into `HISTORY.jsonl` and the memory markdown files when the session grows large. You usually don't need to manage this.
