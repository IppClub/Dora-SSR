# Web build

The root xmake project owns the production Player, engine/vendor objects, Love
support/probes, AudioWorklet mixer, generated features, fixtures and staging.
Android's generated CMake bridge is unrelated to this Web pipeline.

```sh
xmake dora-web
xmake dora-web --pthreads
xmake dora-package --platform=web --mode=release
```

Emscripten (including its Node runtime), Go and Rust/rustup are xmake-managed
host packages. Host Python is required to bootstrap Emscripten; install Node.js
separately only when running the retained JavaScript checks/frontend tooling.
`Tools/build-scripts/build_web.sh` is a compatibility dispatcher to `dora-web`.

The default is Release, `dora-preset`, single-threaded. Set `--profile=core` or
`custom`, and `DORA_WEB_FEATURE_<NAME>=AUTO|ON|OFF` for PHYSICS_2D, ENTITY,
PLATFORMER, BUILTIN_LIBS, ML, YUE, LOVE, MODEL_3D and MUSIC. PLATFORMER requires
ENTITY and PHYSICS_2D. LOVE/MODEL_3D/MUSIC default OFF even in `dora-preset`.
Rust is compiled only when MODEL_3D/MUSIC is enabled; pthread Rust rebuilds
its standard library with atomics in a separate Cargo target directory.

Build/config/object/generated files are isolated under
`build/web-xmake/<profile>/<single|pthread>/<mode>`; override using
`DORA_WEB_BUILD_DIR`. Packages keep the established paths:

- `result/dora-web-build-probe`
- `result/dora-web-player` (or `result/dora-web-player-pthreads`)
- `result/love-pthread-player` (pthread mode)

Existing `DORA_WEB_PACKAGE_DIR`, `DORA_WEB_PLAYER_PACKAGE_DIR`,
`DORA_WEB_LOVE_PLAYER_PACKAGE_DIR`, `DORA_WEB_BUILTIN_FONT`, `JOBS`,
`DORA_WEB_BUILD_ENGINE`, `DORA_WEB_LINK_PLAYER`, `DORA_WEB_BUILD_LOVE_PROBE`,
`DORA_WEB_BUILD_LOVE_PTHREAD_PLAYER` and `DORA_WEB_LOVE_COMPLEX_PACKAGE` remain
supported. Complex fixtures require an explicitly supplied licensed package;
the build does not download it. The experimental main worker remains opt-in
and requires `DORA_WEB_SDL2_PORT_SOURCE_DIR` from the active SDK. It is not a
production-readiness claim.

Trusted Studio host builds require explicit, separate build/probe/player
directories and cannot overwrite public output paths. They expose Agent
callbacks and must never be distributed as public game Players.

Serve packages over HTTP. Pthread packages require COOP/COEP response headers.
Static checkers and real-browser fixtures remain under `Tools/build-scripts`:

```sh
node Tools/build-scripts/check_web_player_output.mjs result/dora-web-player
node Tools/build-scripts/check_web_forbidden_deps.mjs result/dora-web-player
node Tools/build-scripts/check_web_browser.mjs result/dora-web-player
node Tools/build-scripts/check_web_love_player_output.mjs result/love-pthread-player
```

Pre-JS, shell and preload input changes invalidate the executable link; fixture
and manifest generation use content/config dependency tracking. CI installs
xmake latest and calls the same task, without CMake or a second SDK installer.

`--jobs` (or `JOBS`) also limits Binaryen's optimizer worker count. Release
symbol maps stay in the build directory for stack diagnosis, not in public
packages. Lua bindings use a shared locked generation record; host generator
executables are separated by build mode.

Local acceptance on 2026-10-01 covered core Debug and core/preset/custom
Release, pthread Player/Love Player, full preset browser input/render/network/
storage/audio/lifecycle checks, and independent Worklet DSP tests. See
`Docs/design/xmake-build-migration/PROGRESS.md` for exact evidence and remaining
release gates; remote CI, licensed complex games and experimental main-worker
runtime are not implied by local builds.
