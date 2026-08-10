---
name: love-game-development
description: Develop, fix, or review LÖVE 11.5 games hosted by Dora LoveNode, including Love TypeScript or Lua sources, Love API documentation lookup, isolated runtime boundaries, filesystem behavior, and log-based debugging.
---

# Love Game Development

Keep Dora host code and Love game code in their correct runtimes, then validate the authored source through the host entry that creates the `LoveNode`.

## Runtime Boundary

- A Dora host entry such as `init.ts` runs in Dora's main Lua State. It may import `LoveNode` from `Dora`, create a node for a game directory, `main.lua`, or `.love` package, and attach it to the Dora scene.
- Each `LoveNode` owns an isolated Love Lua State. Love game files such as `main.ts`, `main.lua`, and `conf.lua` run there and use Lua plus `love.*` APIs only.
- Never import or require `Dora`, instantiate `LoveNode`, or use Dora globals such as `Director`, `Node`, or `Content` inside Love game code. Those APIs are not exposed to the isolated Love State.
- Never use `love.*` APIs in the Dora host entry. When both sides need changes, classify every file as host-side or Love-side before editing it.
- Love module loading is confined to the game's source/save virtual filesystem. Do not depend on the process working directory, native Lua modules, or modules from Dora's main Lua State.

## Source And Build Workflow

1. Inspect the host entry and the path passed to `LoveNode` to locate the actual Love source root.
2. Edit authored sources. A Love TypeScript entry normally imports `"love"` and compiles to adjacent Lua; a Lua game uses `main.lua` directly. Do not hand-edit generated Lua when a corresponding TypeScript source exists.
3. Keep the standard callbacks (`love.load`, `love.update`, `love.draw`, and input callbacks) in the Love game state. Keep host scene composition and `LoveNode` creation in the Dora entry.
4. Build every changed TypeScript source, including both host and Love-side TypeScript when both changed. Inspect per-file diagnostics rather than relying only on a top-level success flag.
5. Launch the Dora host entry for runtime validation. Do not execute the Love `main.lua` directly as a Dora entry; the `LoveNode` must create and drive its isolated State.

## Search And Read Love Documentation

Do not guess Love signatures or substitute Dora API documentation for Love APIs.

1. Call `search_dora_doc` with `docType: "love-api"` and a bounded pattern. Use `programmingLanguage: "ts"` for Love TypeScript and `programmingLanguage: "lua"` for Love Lua.
2. Combine related names with `|` when one lookup can cover them, for example `filesystem.read|filesystem.write|getInfo`.
3. Read the exact `@dora-doc/love-api/...` file path returned by the search with `read_file`, focusing on the reported line range.
4. Follow the returned LÖVE 11.5 parameter order, return values, callback names, and object/function calling convention exactly.
5. Search `docType: "dora-api"` separately only for Dora host APIs such as `LoveNode`; do not use those results as APIs available inside the Love State.

## Love Filesystem

- Inside Love game code, use `love.filesystem`. Reads resolve within the Love save/mounted/source roots; writes go to the game's identity-specific save root.
- Pass Love virtual paths such as `settings.json` or `levels/one.json`. Do not pass absolute paths, `..`, Dora workspace paths, or host filesystem paths.
- Check the documented return values from `love.filesystem.read`, `write`, `createDirectory`, and related calls. Surface useful failure details with a temporary `print` when diagnosing a runtime issue.
- Agent file tools still edit and inspect workspace source files. They do not replace `love.filesystem` calls made by the running game.

## Debugging With Dora Logs

Love `print(...)`, Love thread prints, `LoveNode` startup/configuration failures, and Love callback errors are written to the Dora engine log. Read the virtual log file when:

- `LoveNode` fails to load `conf.lua`, `main.lua`, a module, or a resource;
- the game builds but fails during `love.load`, `love.update`, `love.draw`, input, or thread execution;
- a `love.filesystem` operation needs runtime evidence;
- a short temporary `print` probe was added to confirm state or control flow.

After launching or reproducing the issue, read recent entries with:

```text
read_file path="@dora_full_logs.txt" startLine=-200
```

Love prints are prefixed with `[Love:<identity>]`, which distinguishes the instance from Dora host output. Remove temporary probes after the issue is resolved. Do not read the full log by default, poll it without a new reproduction, or treat clean logs as visual/gameplay acceptance.

## Completion Checks

- Host files use Dora APIs; Love files use `love.*` APIs.
- Love API calls were checked through `love-api` documentation and the returned virtual document was read when details mattered.
- Authored TypeScript was built and generated Lua was retained.
- Runtime validation launched the Dora host entry, not the Love entry directly.
- Relevant Dora log entries were checked after runtime failures or explicit probes.
- Visual and input behavior was tested separately when the task affects gameplay or rendering.
