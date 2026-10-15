# Dora Agent Game Iteration Playbook

Use this playbook when creating or improving a game through the Dora Web IDE Agent. The evaluator acts as a normal player when giving feedback, while retaining technical evidence separately for diagnosis.

## 1. Define The Contract

Write a short, non-technical user brief covering:

- Player fantasy and intended feeling.
- One distinctive core mechanic.
- Input devices and target session length.
- Desired visual mood.
- What must be true for the game to count as complete.

Keep engine APIs, filenames, class names, test scripts, and expected implementation out of the brief. Put detailed acceptance criteria in the evaluator ledger, not in the generation prompt.

Reject scope that cannot be meaningfully played within the available trial time. Prefer a polished small game over a large collection of unverified systems.

## 2. Use Plan Mode For Product Design

Ask Dora Agent to plan before coding. Require the plan to identify:

1. The moment-to-moment player action.
2. The state transition that makes the action meaningful.
3. Success, failure, retry, and completion states.
4. How mechanics are introduced and combined.
5. Controls for keyboard/mouse and touch when required.
6. Visual hierarchy and feedback for every important action.
7. A vertical slice and a bounded path from slice to complete game.
8. Observable acceptance checks.

Resolve unclear rules in Plan mode. End planning when another developer could explain how one full play cycle works without inventing missing rules.

## 3. Develop In Playable Milestones

Use separate Agent sessions for bounded outcomes:

1. **Vertical slice:** one complete loop with input, feedback, success/failure, and restart or progression.
2. **Readability pass:** initial frame, instructions, scale, contrast, z-order, hit regions, and responsive layout.
3. **Content progression:** introduce, combine, and master mechanics; avoid levels that only move objects around.
4. **Completion pass:** title/start, pause or restart where appropriate, final state, cleanup, and regression checks.

At the start of each session, state what is already proven and what remains weak. Ask the Agent to preserve working behavior. Do not mix unrelated engine or Agent changes into a game iteration.

Let the Agent choose implementation details and use its available tools. Require it to build, run, and test its work, but treat those results as developer evidence rather than player acceptance.

## 4. Keep The Test Environment Valid

Before every run:

- Confirm exactly one intended Dora engine process.
- Confirm exactly one Microsoft Edge Web IDE tab connected to it.
- Confirm the executable, asset root, model, context limit, and command-tool configuration.
- Stop the previously loaded game before starting the next run.

Never launch a generic or installed Dora app when testing a workspace Debug build. If the wrong build, multiple engines, multiple tabs, or mismatched tool configuration appears, stop and invalidate that trial before drawing conclusions.

## 5. Play Like A User

Do not begin with source inspection or internal test hooks. First attempt the experience using only visible instructions and normal keyboard, mouse, or touch controls.

Exercise at least:

- The untouched initial screen.
- Start or first actionable state.
- Every core input at least once.
- A meaningful failure and recovery path.
- A success and progression path.
- One mechanic-introduction level.
- One combined-mechanics level.
- The final completion state.
- A representative resized or target-resolution layout.

For puzzle games, solve representative puzzles rather than merely moving pieces. For action games, play long enough to encounter pressure, failure, retry, and progression. For UI-heavy games, click near visual boundaries to check that hit regions match the controls.

Evaluate whether a player can answer without guessing:

- What am I controlling?
- What can I do now?
- What changed after my action?
- Why did I fail or succeed?
- What should I do next?

## 6. Turn Play Results Into The Next Prompt

Describe feedback as player-observable evidence:

- Good: “The title is readable, but after starting the instructions overlap the goal text and the selectable objects cover it.”
- Good: “I can complete the first two levels, but the later levels do not require the newly introduced mechanic.”
- Bad: “Change node z-order to 4 and move the label to y=220.”
- Bad: “The screenshot probe reports these pixels.”

Use this prompt shape:

1. State what the player successfully completed.
2. State the earliest confusing or broken moment.
3. Describe the visible effect and gameplay consequence.
4. State the desired player outcome.
5. Ask for actual run-through of the repaired path and preservation of working behavior.

Keep each repair prompt bounded. After the Agent finishes, replay the failing path first, then a previously passing path to detect regression.

## 7. Separate Evidence Levels

Maintain four independent statuses:

| Evidence | What it proves |
|---|---|
| Build | Authored source compiles. |
| Runtime | The real entry loads, transitions, stops, and cleans up. |
| Visual | Important frames are legible and correctly layered. |
| Playable | A human can understand and exercise the core loop through required states. |

Use `pass`, `fail`, or `not_run`. Never infer a later status from an earlier one. A build pass plus runtime pass is still not a playable pass.

## 8. Decide Whether To Continue

Continue iterating when any required path is broken, unclear, visually misleading, or only asserted by the Agent. Accept the game only when:

- The core loop works through success, failure, recovery, and progression.
- Representative early, combined, and final content has been played.
- The visible result is understandable at the target layout.
- Previously passing paths survive the last repair.
- Temporary test artifacts are removed.
- The remaining issues are explicitly non-blocking polish items.

Record the number of Agent steps, LLM calls, main and sub-agent sessions, elapsed time, tokens, repair sessions, and user-found defects. Judge quality first and efficiency second.

## 9. Compare Agent Variants Fairly

When evaluating an Agent change, use the same user brief, model, tools, starting project, time limit, and hidden acceptance ledger for baseline and improved variants. Run at least three trials per variant for directional evidence. A different model starts a new experiment group.

Score first-pass playability, visual acceptance, repair burden, and time to accepted result before comparing raw loop or session counts. Exclude invalid environment trials rather than treating them as model failures.
