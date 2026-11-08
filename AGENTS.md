# AGENTS.md — Dora SSR

One repo, many sub-projects: C++ engine (`Source/`), TS/Lua runtime libs (`Assets/Script/`), Web IDE (`Tools/dora-dora/`), Studio (`Studio/`), docs (`Docs/`).

## The build chain (read this first)

- TS/TSX/YueScript → **generated `.lua` sits next to the source**. The `.lua` is build output — **never edit it**; edit the `.ts/.tsx/.yue` and rebuild.
- TS is transpiled by TSTL **inside the running engine** (HTTP `8866`), not by `tsc`/`npm`. There is no project `tsconfig.json` by design.
- Bindings are generated from `Tools/WasmGen/Dora.h` and `Tools/tolua++/Dora.h` — patch the IDL/generator, never the generated bindings.
- TS here has **Lua runtime semantics**: multi-return values need destructuring, modern JS stdlib may be missing. See `Docs/design/tstl-coding-notes-for-llm.md`.
- Runtime imports use Lua-style module names (`"Dora"`, `"DoraX"`); `./` and `../` are rejected. No npm React, no DOM/Node.js APIs.

## Commands

```sh
xmake dora-run                                # engine: fast local run
xmake dora-build --platform=macosx --mode=debug
dora ts build -f <repo>/Assets/Script/Lib/Agent   # Agent TS (narrow scope only)
cd Tools/dora-dora && pnpm lint && pnpm build     # Web IDE frontend
cd Docs && pnpm exec docusaurus build             # docs
# Bindings (run in the generator's own dir): Tools/WasmGen ./gen.yue · Tools/tolua++ ./build.sh · Tools/dora-cs/CSharpGen ./gen.yue
```

If CLI output is empty or a JSON parse error: check the engine service first (`Dora cli status` / `doctor` / `doctor --fix`), inspect `127.0.0.1:8866`, and rerun with proxy env vars cleared — don't blame the source code.

## Rules

- Validate the smallest scope you touched; no repo-wide TS or cross-platform builds.
- Public API changes sync declarations (`Assets/Script/Lib/Dora/{en,zh-Hans}`) and docs (`Docs` + `Docs/i18n/zh-Hans`).
- Don't downgrade TSX tests to Lua; restore the service instead.

Details: `skills/dora-engine-development/`, `skills/dora-cli-game-development/`, `skills/dora-agent-development-validation/`.
