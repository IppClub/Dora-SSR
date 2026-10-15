# Dora Agent Evaluation Template

Use one copy per controlled experiment group. Do not mix models, prompts, time limits, tool configurations, or acceptance criteria within a group.

## Experiment Contract

- Hypothesis:
- User-level prompt:
- Evaluator-only acceptance criteria:
- Starting project or fixture:
- Baseline commit/config:
- Improved commit/config:
- Model/provider:
- Context window:
- Tool configuration:
- Time limit per trial:
- Trial count per variant:
- Run ordering/randomization:
- Dora executable and asset root:
- Web IDE build/config:
- Date:

## Environment Preflight

- [ ] Exactly one Dora engine process.
- [ ] Exact intended Dora executable and asset root confirmed.
- [ ] Exactly one Edge Web IDE tab connected.
- [ ] Command tool availability matches schema and prompt.
- [ ] Model, limits, and provider options confirmed.
- [ ] Starting project is isolated and free of prior trial artifacts.
- [ ] Baseline/improved variants are immutable commits/configs.

## Trial Ledger

| Variant | Trial | Task/session IDs | Main sessions | Sub-agent sessions | Agent steps | LLM calls | Time to runnable | Time to accepted | Tokens local/provider | Build | Runtime | Visual | Playable | First-pass accepted | User-found regressions | Notes |
|---|---:|---|---:|---:|---:|---:|---:|---:|---|---|---|---|---|---|---:|---|
| baseline | 1 | | | | | | | | | | | | | | | |
| baseline | 2 | | | | | | | | | | | | | | | |
| baseline | 3 | | | | | | | | | | | | | | | |
| improved | 1 | | | | | | | | | | | | | | | |
| improved | 2 | | | | | | | | | | | | | | | |
| improved | 3 | | | | | | | | | | | | | | | |

Use `not_run`, `pass`, or `fail` for Build, Runtime, and Visual. “Playable” requires a human to complete or meaningfully exercise the core loop, not only launch the entry.

## Acceptance Ledger Per Trial

| Acceptance item | Evidence path | Status | Notes |
|---|---|---|---|
| Authored source builds | | | |
| Entry starts and stops cleanly | | | |
| Core state transition works | | | |
| Initial frame is understandable | | | |
| Primary control works | | | |
| Hit region matches visual | | | |
| HUD/overlay z-order is correct | | | |
| Success/failure/retry state works | | | |
| Target resolution/layout works | | | |
| Agent completion claim matches evidence | | | |

## Failure Classification

- Earliest wrong decision:
- Final symptom:
- Category: implementation / prompt / provider / tool contract / environment / validation / evaluator.
- Was the failure visible before Agent finish?
- Why did the Agent continue or finish?
- Narrow proposed correction:
- Regression test added:

## Comparison Summary

| Metric | Baseline | Improved | Difference | Confidence |
|---|---:|---:|---:|---|
| First-pass accepted | | | | |
| Playable/usable | | | | |
| Visual acceptance passed | | | | |
| User-found regressions | | | | |
| Median Agent steps | | | | |
| Median session starts | | | | |
| Median wall time | | | | |
| Median total tokens | | | | |
| Tool/LLM failures | | | | |

Show raw counts alongside percentages, especially for small samples.

## Decision

- Confirmed effective:
- Directionally positive:
- Implemented but unproven:
- Failed or regressed:
- Invalid trials excluded:
- Next smallest iteration:
- Additional trials required:
