# Agent stability regression checks

This suite covers the stable subset extracted from the context evaluation branch:

- Proactive shared-prefix checkpoints only when they fit, one attempt per task,
  preserved history on failure, and no nonshrinking loops.
- Persisting a compression boundary before publishing live history/workflow state.
- Bounded transport retries, cancellation, and retained recovery instructions.
- JSON/SSE provider error classification, GLM reasoning overrides, and a
  request-only continuation user message when compacted history has none.
- Failed compression returns zero covered messages and opens the breaker after
  three failures; it does not archive raw history and pretend compression passed.
- The memory selection is appended to the conversation when it is new, changed, or
  covered by a compression boundary, and the system prompt does not change with it.
  A selection is reference data, not a task instruction: a trailing one does not
  make a compressed chunk carry an older instruction, and it does not suppress the
  request-only continuation message. Its marker survives storage and reaches the
  compression projection, but not the provider request.

Run from the repository root:

```sh
node Tools/Tests/AgentStability/policy-tests.cjs "$PWD/Tools/dora-dora/node_modules/typescript"
```

These host checks execute selected authored TypeScript functions/methods with
explicit engine substitutes. They are policy tests, not engine integration or
live-model tests. The merge validation on 2026-11-14 passed all 23 checks, compiled
DoraAgent.ts, Utils.ts and Runtime/Memory.ts through the running engine, and passed
`luac -p` for the three regenerated Lua files. An initial directory compilation
timed out; the final individual-file builds all succeeded.

Earlier evaluation supplied live GLM long-game and frozen-context evidence.
Those experiments were not rerun for this merge. Shared-prefix handoff, its
feature flag, and its experimental evaluation harnesses are deliberately absent
from this stable change and remain on `dev/agent-context-evaluation`.
