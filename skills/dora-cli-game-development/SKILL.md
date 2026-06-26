---
name: dora-cli-game-development
description: Use when building, running, testing, or debugging Dora engine games with the Dora CLI, including TypeScript, TSX/DoraX, Lua, YueScript, Teal, XML, Wa, Yarn, Rust WASM, Web IDE service recovery, and in-engine validation.
---

# Dora CLI Game Development

Use this skill for ordinary Dora game/workspace projects driven by the Dora CLI. Dora runtime code runs inside the Dora engine, not a browser or Node.js. Prefer TypeScript/TSX sources when present; generated Lua is the runtime artifact.

## First Checks

1. Locate the project root and entry file, usually `init.ts` or `init.lua`.
2. Check whether the project is TS, TSX/DoraX, Lua, YueScript, Teal, XML, Wa, Yarn, or Rust WASM.
3. Use Dora engine APIs and project module paths. Do not write DOM, Canvas, Node.js, npm-only, or browser timer code for runtime scripts.
4. For unfamiliar Dora APIs, read the local declarations or use the repo's Dora API search before inventing signatures.

Valid runtime imports use Dora module names such as:

```ts
import { Director, Node } from "Dora";
import { React, toNode, createRoot, signal } from "DoraX";
```

Do not import React from npm for DoraX runtime code.

## Dora Command Name

In this skill, `Dora` means the Dora engine executable. In local development it is often a shell alias or wrapper, not a separate CLI binary.

Example alias with a fake explanatory path:

```sh
alias Dora="/path/to/Dora.app/Contents/MacOS/Dora"
```

On Windows or Linux, use the corresponding Dora executable path for that platform. If `Dora` is not on `PATH` and no alias exists, replace `Dora` in examples with the local engine executable path.

## Service Health

Most CLI commands call the local Dora/Web IDE HTTP service. Start with:

```sh
Dora cli status
Dora cli doctor
```

If the local service or Web IDE is missing, use:

```sh
Dora cli doctor --fix
```

Use `status` for a short read-only snapshot and `doctor` for diagnostics. If localhost calls fail with JSON parse errors or empty output, check service health before changing game code:

```sh
env -u http_proxy -u https_proxy -u HTTP_PROXY -u HTTPS_PROXY -u ALL_PROXY -u all_proxy -u NO_PROXY -u no_proxy \
  Dora cli status --timeout 3
```

The local Web IDE service normally uses HTTP `8866`. A bad response from that service is often an engine/WebServer health issue, not a compiler bug.

Keep the recovery commands distinct:

- `status` is terse, read-only, and script-friendly.
- `doctor` prints broader CLI/project/service/tooling diagnostics.
- `doctor --fix` is the mutating local recovery path.

Do not treat `status` and `doctor` as synonyms. A status check should not open the Web IDE or trigger connection side effects.

## Project Setup

Install or refresh TypeScript definitions:

```sh
Dora cli ts install -p /path/to/project -l en
```

Install or refresh Wa support:

```sh
Dora cli wa install -p /path/to/project
```

Use `--asset` when the CLI should use a different Dora asset root:

```sh
Dora --asset /path/to/Assets cli status
Dora cli status --asset /path/to/Assets
Dora cli status --asset=/path/to/Assets
```

`--asset` is a lightweight CLI option. It should be accepted before or after `cli`; CLI-only handling should not require starting full engine content singletons.

## Build And Run

Build everything supported in a project:

```sh
Dora cli build -p /path/to/project
```

Build a single file:

```sh
Dora cli build -f src/main.ts -p /path/to/project
```

Build one language family:

```sh
Dora cli build --lang ts -p /path/to/project
Dora cli build --lang yarn -p /path/to/project
```

Supported build languages are `all`, `ts`, `yue`, `tl`, `xml`, `wa`, and `yarn`. Yarn syntax checking is part of the `build` command.

When build results contain per-file diagnostics, inspect those messages rather than trusting only a top-level success flag. A project build can complete the request but still report a failing file that must be fixed.

Run the project:

```sh
Dora cli run -p /path/to/project
Dora cli run --entry Script/main.lua -p /path/to/project
```

Build and run in one step:

```sh
Dora cli buildrun -p /path/to/project
Dora cli buildrun -f src/main.ts -p /path/to/project
```

Stop the currently running project:

```sh
Dora cli stop
```

`Dora cli stop` stops the project running in Dora. It does not necessarily quit the Dora engine process.

## TSX And DoraX

Use TSX for declarative Dora node trees.

- `toNode(element)` is for one-shot scene construction.
- `createRoot(parent)` plus `signal(value)` is for dynamic UI or scene fragments.
- Use stable `key` values for sibling lists that can reorder, insert, delete, or filter.
- Call `root.unmount()` when a dynamic root is no longer needed.
- Keep authored tests and demos in `.tsx` when validating TSX behavior; generated `.lua` is only the runnable output.

When changing dynamic behavior, validate with an in-engine test, not only a host-side compile.

## In-Engine Validation Pattern

For gameplay/runtime behavior, prefer a deterministic marker file over visual inspection or log tailing alone:

```ts
import { Content } from "Dora";

const resultPath = "test-name.result";
Content.save(resultPath, "running");

// Run the scenario. On success:
Content.save(resultPath, "passed");

// On failure:
Content.save(resultPath, "failed: expected X, got Y");
```

A useful runner should:

- Build the changed `.ts` or `.tsx` source with Dora CLI.
- Run the generated Lua in Dora.
- Poll the marker file in Dora's writable path.
- Fail on timeout or any marker value other than `passed`.

This is especially important for scheduling, lifecycle, signal/diff rendering, physics, input, and action behavior.

Do not switch a TSX test to Lua just because the TSX build/run path is temporarily unhealthy. Restore the Dora/Web IDE service, build the TSX source, and run the generated Lua artifact.

## CLI Feature And Docs Work

Before adding a new CLI feature, inspect the existing command dispatch and service routes:

- `Assets/Script/Dev/cli.lua`
- `Assets/Script/Dev/WebServer.yue`

Fold new checks into existing flows when that keeps the CLI smaller. For example, Yarn syntax validation belongs in `build` through the existing service endpoint, not in a redundant top-level filesystem wrapper.

When editing CLI docs or tutorials, run the current help command first and copy the command shape from it:

```sh
Dora cli --help
```

Keep docs at the feature/command level. Avoid engine internals unless the user explicitly asks for them.

## Rust WASM

Build Rust WASM projects with the CLI:

```sh
Dora cli rust build -p /path/to/rust-project
```

Build and run a target in the Dora resource tree:

```sh
Dora cli rust run Hello -p /path/to/rust-project
```

Upload an existing WASM file, optionally running it:

```sh
Dora cli rust upload Hello -p /path/to/rust-project
Dora cli rust upload Hello --run -p /path/to/rust-project
```

## Debugging Failures

- If build output is malformed or empty, verify Dora/Web IDE service health first.
- If a CLI request to localhost fails, clear proxy environment variables and rerun the same command.
- If a CLI command reports a JSON parse error such as `Expecting value`, check raw HTTP responses and nearby endpoints such as `/assets` and `/stop`; empty `502` responses point to service health.
- If a TS/TSX build succeeds but behavior is wrong, run the generated artifact in Dora and assert behavior with marker files.
- If runtime code uses browser APIs, rewrite it to Dora APIs instead of trying to polyfill browser behavior.
- If CLI docs or commands seem stale, run `Dora cli --help` and use that as the source of truth.

## Before Finishing

Check:

- The project entry actually starts the game or test.
- Runtime code uses Dora APIs, not browser or Node.js APIs.
- TS/TSX source was edited instead of generated Lua when source exists.
- `Dora cli build`, `run`, or `buildrun` was used with the narrowest useful scope.
- In-engine behavior was verified for runtime semantics.
- Service/proxy problems were separated from source problems.
