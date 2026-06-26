---
name: dora-engine-development
description: Use when developing the Dora-SSR engine itself, including C++ engine code, Lua/YueScript dev services, generated bindings, DoraX runtime, Web IDE integration, docs, tests, local validation, and release-facing engine changes.
---

# Dora Engine Development

Use this skill for work inside the Dora-SSR engine repository, not for ordinary game projects. First inspect the current checkout; do not answer from memory when source, scripts, or generated outputs can be checked locally.

## Start From The Real Owner

Trace behavior to the source that owns it before editing:

- Engine/runtime core: `Source/`.
- Lua/YueScript development services: `Assets/Script/Dev/`, especially `WebServer.yue` and `cli.lua`.
- TypeScript runtime libraries: `Assets/Script/Lib/`.
- DoraX TSX runtime: `Assets/Script/Lib/DoraX.ts`, generated `DoraX.lua`, and declarations under `Assets/Script/Lib/Dora/{en,zh-Hans}/`.
- Web IDE frontend: `Tools/dora-dora/src/`.
- Docs: `Docs/docs/` and matching `Docs/i18n/zh-Hans/` files.
- Generated API/binding sources: inspect the generator or IDL first, then regenerate or sync generated surfaces.

For generated or vendored surfaces, patch the source of truth rather than only the generated output. Examples: `Dora.h` IDL for binding surfaces, `Git.d.tl` for generated Git docs, `WebServer.yue` before generated Lua, and vendored compiler/runtime sources before copied artifacts.

## Change Boundaries

- Keep fixes scoped to the subsystem that decides the behavior.
- Prefer the smallest root-cause fix over UI-only patches or throttling symptoms.
- Do not edit unrelated unstaged work. If committing only staged files, validate only `git diff --cached`.
- When the user says a file or generated output should not be touched, treat that as a hard scope boundary.
- For Lua/TSTL special cases, check whether the repo intentionally uses manual Lua multi-return exports before changing generated binding code.
- Keep English and Chinese declaration/doc surfaces synchronized when changing public APIs.
- When two public API names do exactly the same thing, keep one name and remove the alias across source, declarations, docs, and tests.

## Engine APIs And Bindings

Use the repo's binding pipeline instead of hand-editing surfaces independently:

- Wasm/Rust/Wa/C# binding surfaces should come from the relevant `Dora.h` IDL/generator path.
- Lua/TSTL may intentionally use manual exports, especially for Lua multi-return contracts.
- If a generated surface disagrees with a manual Lua/TSTL surface, inspect the intended contract before changing either side.
- For file I/O or resource APIs, prefer engine-consistent abstractions already used nearby, such as SDL RWops or `Content`, over ad hoc host APIs.
- For asset paths that may come from ZIP/APK packages, account for chunked reads; do not assume one read covers the full detection window.

When documenting module rules, inspect the current resolver and diagnostics. Dora/TSTL runtime imports reject `./` and `../`; use Lua-style module names rooted from the project's init/search-path setup.

### Binding Generation Commands

Run generators from the directory that owns the generator; several scripts use relative input/output paths.

For Wasm/Rust/Wa bindings, edit `Tools/WasmGen/Dora.h`, then run:

```sh
cd Tools/WasmGen
./gen.yue
```

This generator writes Wasm C++ headers under `Source/Wasm/Dora/`, Rust bindings under `Tools/dora-rust/dora/src/`, Wa bindings under `Tools/dora-wa/vendor/dora/`, and copies Wa vendor bindings to `Assets/dora-wa/vendor` when LuaFileSystem is available.

For Lua bindings, edit `Tools/tolua++/Dora.h` or the `.pkg` files, then run:

```sh
cd Tools/tolua++
./build.sh
```

On Windows, run the batch variant from a Visual Studio Developer Command Prompt:

```bat
cd Tools\tolua++
build.bat
```

The tolua generator writes `Source/Lua/LuaBinding.cpp`, `Source/Lua/LuaCode.cpp`, and `Source/Lua/TealCompiler.cpp`. Keep manual Lua/TSTL exports such as `Source/Lua/LuaManual.cpp` separate unless the task explicitly requires changing them.

For C# binding updates, use the C# generator path separately:

```sh
cd Tools/dora-cs/CSharpGen
./gen.yue
```

## DoraX Runtime Work

DoraX has two distinct paths:

- `toNode()` is one-shot static scene construction.
- `createRoot(parent)`, `Root.render()`, `Root.update()`, `Root.unmount()`, and `signal(value)` are the dynamic diff/rendering path.

Do not replace static behavior when adding dynamic behavior. For dynamic DoraX changes, check:

- `Assets/Script/Lib/DoraX.ts`
- `Assets/Script/Lib/DoraX.lua` when the TS build regenerates it
- `Assets/Script/Lib/Dora/en/DoraX.d.ts`
- `Assets/Script/Lib/Dora/zh-Hans/DoraX.d.ts`
- `Assets/Script/Lib/Dora/en/jsx.d.ts`
- `Assets/Script/Lib/Dora/zh-Hans/jsx.d.ts`
- TSX tutorials and docs if public behavior changes

When validating DoraX semantics, keep authored tests/demos in TSX. Generated Lua is only the runnable artifact.

## Dora Agent And Web IDE Work

For Agent TypeScript changes, default validation is narrow:

```sh
dora ts build -f ~/Workspace/Dora-SSR/Assets/Script/Lib/Agent
```

Do not run a repo-wide Dora TS build for Agent work unless the user asks; it adds unrelated noise.

If `/ts/build` or Dora CLI returns JSON parse errors, first check whether the live WebServer is unhealthy:

- Inspect raw HTTP responses from `127.0.0.1:8866`.
- Check whether `/assets` or `/stop` also returns empty `502`.
- Read `~/Library/Application Support/IppClub/DoraSSR/log.txt`.
- If the engine server is unreachable or localhost requests look wrong, rerun the failing CLI command with proxy environment variables cleared before treating it as a source failure:

```sh
env -u http_proxy -u https_proxy -u HTTP_PROXY -u HTTPS_PROXY -u ALL_PROXY -u all_proxy -u NO_PROXY -u no_proxy \
  dora ts build -f ~/Workspace/Dora-SSR/Assets/Script/Lib/Agent
```

Web IDE service reload/disconnect bugs often belong in engine/dev-service boundaries, not in the frontend. For example, `Script.Dev.WebServer` must not be unloaded by normal project module cache clearing.

Treat persistent host service modules, especially `Script.Dev.WebServer`, as outside normal game hot-reload cleanup. If a build disconnects the Web IDE, fix the module-cache boundary first; do not leave throttles, reconnect queues, or frontend timing patches as the primary solution once the boundary is understood.

## Web IDE Frontend Work

Treat Web IDE features as workflow integrations, not isolated React components.

- New editor/file modes usually need updates across `App.tsx`, service typing such as `Service.ts`/`EditingInfo`, creation/opening UI, file-tree identity, preview/session refresh, run gating, icons, and i18n.
- Keep project run and single-file run semantics separate. Special editors should not silently turn `Run This` into project execution.
- Backend routes remain the authority for shared file contracts. For example, unknown text fallback must still reject folders in the `/read` path, even if the UI already hides or blocks folder editing.
- For editor keyboard shortcuts, prefer shell-level handling that leaves text inputs and selects to native behavior.

For dependency changes under `Tools/dora-dora`, `package.json` and `pnpm-lock.yaml` are the authority. Run the normal static checks, then smoke-test affected runtime surfaces. A successful build can still hide dependency compatibility breaks such as old editor APIs or asset-format expectations; pin exact versions when the code depends on that behavior.

For vendored TSTL/compiler work, compare against the upstream implementation when possible and fix the emit pipeline, dependency resolution, or save boundary directly. Do not patch only the visible symptom, such as a missing builtin helper, when the real issue is that a generated bundle file was never emitted.

When saving TypeScript sources that emit Lua, keep source-save success independent from derived Lua generation. Save the authored TS/TSX first; write generated Lua only after transpilation succeeds, and surface Lua-generation errors separately.

## CLI And Dev-Service Work

`status`, `doctor`, and `doctor --fix` have different jobs:

- `status`: terse, read-only, script-friendly snapshot.
- `doctor`: richer diagnostics for CLI/project/service/tooling state.
- `doctor --fix`: the mutating local recovery path.

Keep `status` small. Put detailed environment output in `doctor`. For local browser opening or Web IDE recovery, prefer engine-side `openURL` through the service instead of CLI-side platform guessing.

When adding CLI features, first inspect existing routes and dispatch:

- `Assets/Script/Dev/cli.lua`
- `Assets/Script/Dev/WebServer.yue`
- generated Lua only if the workflow expects it

Prefer folding checks into existing command flows, such as `build`, when that matches the current CLI shape. Avoid redundant top-level wrappers for filesystem or Git operations that local command-line tools already handle well.

For `--asset` and other lightweight CLI-only needs, avoid initializing full engine singletons just to expose one value. Support both `--asset path` and `--asset=path`, before or after `cli`, and use a minimal Lua-side table when that is enough for CLI script behavior.

## Native Runtime Debugging

For input, lifecycle, HTTP, and other native/runtime behavior, trace the real event or ownership path before patching symptoms:

- For input mapping, inspect the full backend path from platform event to engine/UI consumer. Do not assume button names or UI labels match the actual SDL/ImGui/controller mapping.
- Gate development-only behavior with the repo's existing platform/debug macros, such as `DORA_DEBUG` and desktop platform checks, instead of leaving test helpers enabled everywhere.
- For shutdown or interrupt crashes, reproduce the lifecycle path and inspect ownership/ordering at the lower layer. Do not hide a future/cancel or `Life::destroy` ordering bug with high-level retry or suppression code.
- For HTTP/streaming wrappers, distinguish transport reachability from protocol framing. A wrapper reporting network OK with HTTP status `0` is a protocol/status-settlement failure, not success.
- Use small focused harnesses when available or cheap to create. Standalone protocol/lifecycle tests are acceptable when a full platform build is unnecessary, but they must actually be run.

## Local Engine Validation

Separate local development from CI or release work. For engine work, prefer the native run/build scripts below as the local runtime path. Use Dora CLI health checks only when the task depends on the running Web IDE/dev-service state; keep detailed CLI command usage in `dora-cli-game-development`.

For macOS local engine runs, the native app serves the Web IDE on HTTP `8866` and WS `8868` through `Assets/Script/Dev/WebServer.yue`. `dora stop` stops the current Dora-run project, not the engine process.

When dev-service state is suspect, restore service health first, then rerun the narrow build or test command.

## Native Build Script Selection

Prefer the repo's wrapper scripts over entering third-party subdirectories manually.

- Fast local desktop loop: use `Tools/build-scripts/run_macos.sh`, `Tools\build-scripts\run_windows.bat`, or `Tools/build-scripts/run_linux.sh`. These check tools, build missing native dependencies, rebuild the Rust runtime and app, stop the old Dora process, and launch the Debug runtime with the repo `Assets`.
- Platform app build without launching: use `Tools/build-scripts/build_macos.sh`, `build_windows.bat`, `build_linux.sh`, `build_android.sh`, or `build_ios.sh` with `debug` or `release`.
- Native dependency rebuilds: use `Tools/build-scripts/build_lib_<platform>.*`. These are for missing/stale dependencies, CI/release preparation, or explicit dependency work.
- Do not manually build bgfx, SDL2, Wa, or Rust runtime from their nested directories unless the wrapper script is the thing being debugged.

When validating a local engine change, choose the script for the platform actually affected. Do not run expensive cross-platform builds unless the change touches shared build logic or release packaging.

## Testing Strategy

Choose the smallest meaningful validation:

- Source formatting/scope: `git diff --check` or `git diff --cached --check`.
- Web IDE frontend changes: `pnpm lint` and `pnpm build` under `Tools/dora-dora` when applicable.
- Docs changes: `pnpm exec docusaurus build` under `Docs` when applicable.
- Agent TS changes: Agent-only Dora build command above.
- DoraX runtime semantics: in-engine TSX tests with marker-file assertions.
- Native engine changes: the platform-specific Debug build/run path for the touched platform.
- Web IDE dependency/compiler changes: `pnpm install --frozen-lockfile`, `pnpm lint`, `pnpm build`, plus a smoke test of the affected editor/runtime surface.
- Protocol or lifecycle internals: a focused harness or reproduction path that exercises the failing state, followed by the narrow platform build only when the touched code needs it.

For in-engine TSX regression tests, prefer a runner that compiles TSX, runs the generated Lua in Dora, and waits for a writable-path marker such as `running`, `passed`, or a failure message saved with `Content.save(...)`. Marker files are more reliable than log tailing alone.

Do not downgrade TSX validation to Lua-only because the service is inconvenient to recover. Recover Dora/Web IDE health, keep the authored source in TSX, and treat generated Lua as the execution artifact.

## Docs And Public Surfaces

- Keep docs aligned with generated sources and real command help.
- For CLI docs, capture current `Dora cli --help` output before editing command references.
- Avoid explaining internal SDL/runtime mechanics in user docs unless the user asks for internals.
- If adding a public API, sync declarations, tutorials, and both languages where the repo already maintains both.

## Before Finishing

Check:

- The actual source owner was inspected.
- Generated files were updated only when they are part of the expected workflow.
- English and Chinese public surfaces are in sync when relevant.
- Local service failures were not mistaken for source failures.
- Validation command scope matches the subsystem changed.
- Unrelated worktree changes were left alone.
- The fix did not add duplicate API names, redundant CLI wrappers, or local UI workarounds before the real control point was checked.
- UI/frontend changes were integrated through the full workflow surface, not just the visible component.
- Dependency, compiler, networking, and lifecycle changes were verified against the runtime behavior that actually failed.
