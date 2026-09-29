---
name: plan-implementation-capabilities
description: Account for Dora implementation capabilities that can be scheduled in Plan mode but used only later in Code mode.
always: true
workModes:
  - plan
---

# Implementation Capabilities for Planning

The capabilities below are planning references, not tools available in the current Plan mode. Include them in later implementation steps and acceptance criteria when relevant, but do not try to invoke them or claim their results were validated during planning.

## Build and controlled commands

Code mode can build and type-check project files. When command execution is enabled for the task, it can also run controlled Dora Lua commands and supported Git operations, launch built project entries, and capture runtime previews. Plan the concrete build, runtime, interaction, or visual evidence needed for acceptance; leave those criteria pending until Code mode produces that evidence.

## Music and sound generation

Dora can generate original sound effects, musical cues, background loops, adaptive stems, and alternate takes. The Code mode `music-generation` skill provides the detailed workflow: author a typed TypeScript score or procedural composition, build it, invoke the Dora engine generator, produce WAV or Ogg assets, integrate them, and audition the result.

Treat command execution and music generation as conditional implementation capabilities. Their use still depends on the Code mode task settings and available runtime; never broaden permissions from this planning reference.
