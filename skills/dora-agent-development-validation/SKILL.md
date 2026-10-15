---
name: dora-agent-development-validation
description: Develop, test, benchmark, and iteratively validate Dora Agent changes with evidence from the current implementation, real `.agent` histories, controlled LLM trials, Dora in-engine tests, and human-visible acceptance. Use for changes to Agent prompts, tool schemas or execution, edit recovery, memory compression, sub-agent lifecycle, cancellation and handoff, usage reporting, Web IDE Agent UX, or game-generation quality; also use when comparing baseline and improved Agent behavior across models such as GLM or DeepSeek.
---

# Dora Agent Development Validation

Treat Dora Agent as an interactive product, not only a code path. Validate the implementation, deterministic runtime behavior, actual LLM sessions, and what a human user can see and operate before calling an iteration effective.

For exact engine build and game-run commands, also follow the project skills `dora-engine-development` and `dora-cli-game-development`. Use this skill for experiment design, evidence standards, and the iteration loop around those commands.

For end-to-end game creation through Dora Agent, read [references/game-iteration-playbook.md](references/game-iteration-playbook.md) before starting. It defines how to turn a user-level brief into a plan, conduct multiple development sessions, play the result as a user, and convert observations into the next bounded prompt.

## 1. Establish The Real Baseline

1. Inspect the current checkout. Record the branch, commit, working-tree state, Agent configuration, model configuration, and Web IDE build.
2. Read the implementation path that owns the behavior. Distinguish prompt guidance from enforced runtime behavior.
3. Inspect relevant real records under the tested project's `.agent/` directory, especially `.agent/main/PROJECT_MEMORY.md`, `.agent/main/SESSION_SUMMARY.md`, task/session histories, and test-result artifacts.
4. Verify summary claims against source, logs, diffs, and runnable artifacts. A summary saying “passed” is not proof of visual correctness or user acceptance.
5. Preserve unrelated work. Use separate worktrees, copies, or explicit commits for baseline and improved variants; never obtain a baseline by destructively resetting user changes.

Trace these owners first when relevant:

- `Assets/Script/Lib/Agent/AgentConfig.ts`: central limits and ratios.
- `AgentToolRegistry.ts`: tool schemas, role availability, and parallel safety.
- `CodingAgent.ts`: decision loop, prompts, execution guidance, completion checks, and streamed responses.
- `AgentSession.ts`: task/session lifecycle, cancellation, sub-agent handoff, and persistence.
- `Memory.ts`: consolidation and compression behavior.
- `Tools.ts`: file, command, checkpoint, and recovery operations.
- `Utils.ts`: LLM transport, stream aggregation, usage extraction, and parsing.
- `Assets/Script/Dev/WebServer.yue`: Agent and run/build routes.
- `Tools/dora-dora/src/AgentPanel.tsx`: user-visible Agent state and controls.
- `Assets/Doc/skills/dora-engine-coding/SKILL.md`: instructions injected for Dora runtime work.

Patch authored TypeScript/YueScript first. Regenerate matching Lua through the normal build path when generated Lua is tracked.

## 2. State A Testable Hypothesis

Express each iteration as one behavioral claim, for example:

- “A truncated whole-file overwrite keeps the recoverable prefix, while a truncated replacement leaves the target unchanged.”
- “Spawning a sub-agent does not block the main user session or force a join.”
- “Model-aware compression thresholds prevent premature compaction without overflow.”
- “The improved game-generation flow increases first-pass playable results under the same prompt and time limit.”

Define before editing:

- The observable success condition.
- The regression condition.
- Which evidence layer can prove each condition.
- The smallest implementation change expected to affect it.

Avoid bundling unrelated optimizations into one comparison. If several changes ship together, retain per-feature tests so later regressions can be localized.

## 3. Validate In Layers

Use every relevant layer. Passing an earlier layer never substitutes for a later one.

### Layer A: Static And Build Integrity

- Run `git diff --check` for the intended scope.
- Build only the Agent subtree first:

```sh
env -u http_proxy -u https_proxy -u HTTP_PROXY -u HTTPS_PROXY \
  -u ALL_PROXY -u all_proxy -u NO_PROXY -u no_proxy \
  dora ts build -f /path/to/Dora-SSR/Assets/Script/Lib/Agent
```

- Check generated Lua with `luac -p` when Lua artifacts changed.
- Use the explicit Agent project root for `/ts/build`. An unrelated active Web IDE tab must not determine TSTL module lookup.
- Inspect per-file messages; a successful HTTP request can still contain failed compilation items.

### Layer B: Deterministic Unit And Policy Tests

Exercise success and refusal paths without an LLM where possible. Include malformed, boundary, interruption, and repeated-call cases.

Examples:

- A tool visible in schema is executable by the same role.
- A provider omits or rejects forced `tool_choice`.
- Empty `old_str` plus truncated `new_str` overwrites with exactly the recoverable prefix.
- Non-empty `old_str` plus truncated `new_str` fails and leaves the target byte-for-byte unchanged.
- Cancellation reaches `STOPPED` and remains `STOPPED` in final task state.
- “End and hand off” finishes an interrupted sub-agent with a coherent handoff.
- Compression preserves every active work item and its next checkpoint.

### Layer C: Dora In-Engine Validation

Use the Agent's `execute_command` path plus the Dora engine coding skill for runtime tests. Inject or reuse `Entry.yue` helpers such as `enterEntryAsync` and `stop` when supported.

Confirm:

- The authored entry builds.
- The actual project loads inside Dora.
- The expected state transition occurs.
- A deterministic marker or test result reports `passed`.
- The project stops and cleans up.

Treat lifecycle success as lifecycle evidence only. `running=true`, a clean stop, or a marker test cannot prove that the screen is understandable, buttons are aligned, hit areas match visuals, or gameplay feels usable.

### Layer D: Human-Visible And Interactive Acceptance

For games, rendering, and Web IDE UI, inspect at minimum:

1. Initial frame before input.
2. First actionable state after starting.
3. A representative primary interaction.
4. Success/failure/retry or next-level state.
5. A resized or target-resolution state when layout adapts.

Check object visibility, hierarchy, z-order, labels, contrast, button background/text order, hit regions, overlays, selected state, instructions, and whether the user can infer what to do.

Actually play enough of the game to exercise its core rule. A scripted logic test does not replace this. When reporting as a human acceptance tester, describe what a user can see and do; keep instrumentation details in the technical evidence section.

If no visual observation path exists, mark visual validation `not_run` and keep the task in “needs visual acceptance.” Do not finish it as fully verified. `execute_command` by itself does not give the model visual perception.

### Layer E: Real LLM Agent Sessions

Run the real Agent with the configured provider and the same tools a user receives. Record raw task/session artifacts rather than reconstructing behavior from the final answer.

Exercise:

- A fresh or nearly empty project.
- An existing project requiring a narrow edit.
- A compile failure followed by repair.
- A long edit that reaches output limits.
- A task that benefits from multiple asynchronous sub-agents.
- A user interruption, cancellation, resume, and handoff.
- A long conversation that crosses memory compression thresholds.
- A game task requiring deterministic and visual acceptance.

Keep session roles distinct during game work:

- Use Plan mode to settle the player fantasy, core loop, controls, progression, visual direction, scope, and acceptance criteria. Do not prescribe source files or engine APIs unless the user did.
- Use implementation sessions to deliver one playable milestone at a time. Preserve the proven core instead of repeatedly rewriting the whole game.
- Use acceptance sessions only after personally exercising the current build. Report player-observable problems and desired outcomes; do not leak evaluator instrumentation or dictate a patch.
- Start a repair session when a visible or playable defect remains. Do not accept an Agent's own completion statement as the final verdict.

## 4. Run Controlled Baseline/Improved Comparisons

Keep these fixed within one comparison group:

- User-level prompt.
- Model and provider configuration.
- Context-window and token limits.
- Tool availability.
- Starting project and assets.
- Time limit.
- Evaluator-only acceptance criteria.

Write prompts as normal user requirements. Do not leak implementation details, file names, API choices, test mechanics, or the expected fix into the generation prompt.

Use at least three trials per variant for a quick directional result and five or more for a stronger claim. Treat a model switch as a new comparison group; do not mix GLM and DeepSeek results into one baseline.

Alternate or randomize baseline/improved run order when practical. Use isolated copies or worktrees and clean derived artifacts between trials. Do not let later trials read earlier solutions, summaries, or test results.

Apply the same strict time limit to both variants. Ten minutes per trial is useful for fast game-generation comparisons, but choose a limit appropriate to the task.

Read [references/evaluation-template.md](references/evaluation-template.md) before running or reporting a controlled comparison.

## 5. Measure Product Outcomes And Cost

Record at least:

- First-pass acceptance without user-requested repair.
- Build and deterministic-test success.
- Playable/usable result count.
- Visual and interaction acceptance.
- Agent loop steps and total LLM calls.
- Main-session starts and sub-agent session starts.
- Wall-clock time to first build, first runnable result, and accepted result.
- Input, output, cached-input, and total token usage when available.
- Local token estimate used by runtime policy, separately from provider-reported usage.
- Tool failures, invalid calls, retries, compression rounds, and interrupted outputs.
- User-found regressions after the Agent declared completion.

Do not optimize only for fewer turns. A shorter run that produces an unusable game is worse. Prioritize first-pass acceptance, correctness, repair burden, and stable interaction; use turns, time, and tokens as secondary efficiency measures.

## 6. Test High-Risk Agent Semantics Explicitly

### Tool Availability

- Ensure every tool shown in schema and prompt can execute for that role.
- Put recommendations in prompt/result guidance unless a true safety or capability boundary requires enforcement.
- Test providers that do not support forced `tool_choice`.
- Measure cache effects, but never sacrifice correct tool availability only to improve cache hit rate.

### Asynchronous Sub-Agents

- Verify the main Agent can dispatch several independent sub-agents without ending the turn after each spawn.
- Verify it can finish the user-facing turn without joining or polling background work.
- Verify the user can start another session while sub-agents continue.
- Verify handoffs arrive asynchronously and do not overwrite newer user instructions.
- Treat foreground-work limits as guidance unless the product deliberately defines a hard limit.
- Keep one task per sub-agent and measure duplicated discovery, conflicting edits, and abandoned interrupted agents.

### Memory Compression

- Derive thresholds from the configured model context window.
- Use local estimates for runtime decisions when that is the contract; show provider usage only as supplementary evidence.
- Test high message-count conversations separately from high token-count conversations.
- Verify compression retains active instructions, completed items, open items, paths, test failures, next action, and sub-agent state.
- Confirm the next turn resumes useful work instead of restarting broad discovery.

### Long Tool Output

- Preserve only content that can be decoded unambiguously.
- For a truncated whole-file `edit_file` (`old_str` empty), save the recoverable `new_str` prefix directly to the intended file, report actual saved state, and let the Agent inspect before continuing.
- For a truncated replacement (`old_str` non-empty), fail without modifying the target and without creating an extra draft file.
- Test trailing backslashes, partial UTF-8, escaped quotes, incomplete JSON, existing targets, and new targets.

### Completion And Handoff

- Require concrete build/test evidence for claims marked verified.
- Do not interpret “build attempted,” “entry running,” or “sub-agent said done” as completion.
- Preserve user cancellation as the terminal state.
- Let an interrupted sub-agent perform a bounded finish/handoff flow when the user requests it.

## 7. Control The Live Test Environment

For the maintained macOS setup:

- Keep exactly one Dora engine instance.
- Keep exactly one Microsoft Edge Web IDE tab connected to that instance.
- Confirm executable path, asset root, PID, and listening port before testing.
- Reuse the correct current Debug Dora instance when healthy.
- Never activate or launch a generic/default Dora application when the test requires the workspace Debug build.
- Before a necessary restart, close retained Dora Web IDE tabs, stop the old engine, wait for it to exit, then start the exact intended binary.
- Count engine processes after every launch or restart.
- Clear localhost proxy variables for Dora CLI/HTTP probes when required.
- Stop the tested project and clean temporary marker files after the run; do not kill the engine unless testing restart or shutdown behavior.

Environment mistakes invalidate a trial. Discard results from the wrong Dora build, multiple engine instances, multiple connected Web IDE tabs, a disabled command tool, or a changed model configuration.

## 8. Iterate From Failures

For each failed trial:

1. Save the raw prompt, model options, task/session IDs, tool events, output artifacts, and user-visible result.
2. Identify the earliest wrong decision, not only the final symptom.
3. Classify the cause as implementation, prompt, provider, tool contract, environment, validation, or evaluator error.
4. Prefer an enforceable state/result contract when correctness matters. Use prompt guidance for recommendations and strategy.
5. Make the smallest change that addresses the classified cause.
6. Add a deterministic regression test when possible.
7. Rerun the failing case first, then the controlled comparison group.
8. Keep, revise, or revert based on product outcomes rather than anecdotal impressions.

Avoid tuning only against one game or one model response. A fix that passes because the prompt describes the exact expected solution is not generalization.

## 9. Report Evidence Honestly

Separate the final report into:

- Confirmed effective: reproduced improvement with relevant acceptance evidence.
- Directionally positive: small-sample or partially controlled evidence.
- Implemented but not yet proven: code and static checks exist, but real sessions are insufficient.
- Failed or regressed: measurable worsening or new user-visible problems.
- Invalid trial: environment, prompt, model, time, or starting state differed.

Include exact baseline/improved commits, trial counts, model, time limit, metrics, user-visible failures, and uncertainty. State whether visual acceptance actually ran.

Do not claim Agent loop count, session count, cached-input percentage, or token usage improved without controlled measurement. Do not claim a generated game is complete until its core loop has been run and played.
