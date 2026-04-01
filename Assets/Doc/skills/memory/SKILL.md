---
name: memory
description: Two-layer memory system with grep-based recall.
always: true
---

# Memory

## Structure

- `.agent/MEMORY.md` — Long-term facts (preferences, project context, relationships). Always loaded into your context.
- `.agent/HISTORY.md` — Append-only event log. NOT loaded into context. Search it with grep_file tool. Each entry starts with [YYYY-MM-DD HH:MM].

## When to Update MEMORY.md

Write important facts immediately using `edit_file`:
- User preferences ("I prefer dark mode")
- Project context ("The API uses OAuth2")
- Relationships ("Alice is the project lead")

## Auto-consolidation

Old conversations are automatically summarized and appended to HISTORY.md when the session grows large. Long-term facts are extracted to MEMORY.md. You don't need to manage this.

