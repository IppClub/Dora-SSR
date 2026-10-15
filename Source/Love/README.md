# Dora LOVE Integration

This directory owns Dora-specific LOVE integration code. The upstream LOVE
11.5 tree is kept separately in `Source/3rdParty/Love/`.

Directory responsibilities:

- `LoveRuntime.*`: ownership of one isolated Lua 5.5 state.
- `Backend/`: Dora implementations of LOVE platform, rendering, input, audio,
  filesystem, and virtual-window boundaries.
- `Source/3rdParty/Love/DORA_SOURCE.md`: pinned upstream provenance, retained
  source boundary, and vendor refresh procedure. Dora-specific changes are
  maintained directly in the vendored tree and reviewed through Git history.

Build and test entry points are owned by the repository-root xmake project.
`Projects/xmake/engine.lua` builds the native Dora integration and depends on
`Source/3rdParty/Love/xmake.lua` for the vendored LOVE libraries. For example,
run from the Dora-SSR repository root:

```sh
xmake dora-build --platform=macosx --mode=debug
```

Web LOVE runtime/support and compile/link/graphics/shader/audio probes are
specified in `Projects/xmake/web/manifest.lua` and `targets.lua`. Build the
external fixtures and probes with `xmake dora-web --tests`; build the standalone
LOVE pthread Player with `xmake dora-web --pthreads`. These are xmake targets,
not a standalone CMake project in this directory. Android Studio retains an
xmake-generated CMake bridge for its Gradle/NDK native model; see
[the Android integration guide](../../Projects/xmake/android/README.md).

Tests live in the external [Dora-Example](https://github.com/IppClub/Dora-Example)
repository, under `Test/` (including `Test/Web/` fixtures and `Test/BuildScripts/`
checks), not under `Source/Love/Tests/`. `Test/manifest.json` and `Test/run.mjs`
provide the test inventory and runner. For example:

```sh
xmake dora-test --suite=web --list
xmake dora-test --case=check_web_love_capabilities
xmake dora-test --case=check_web_love_player_output -- result/love-pthread-player
```

`xmake dora-test` resolves the latest remote default-branch HEAD by default and
runs from a revision-specific snapshot. Use `--repo=/path/to/Dora-Example` for
an existing local checkout, or set `DORA_TEST_REPO` for both fixture builds and
test runs; local edits are preserved. Listing tests still requires the test
repository and Node.js. Individual checks have their own build, browser and
package prerequisites; listing or compiling probes does not establish runtime
or lifecycle acceptance. See [the Web build guide](../../Projects/xmake/web/README.md)
for output directories and prerequisites.
