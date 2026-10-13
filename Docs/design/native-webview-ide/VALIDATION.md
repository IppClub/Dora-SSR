# Native Web IDE validation — 2026-10-13

## Accepted single-window build

- macOS 26.6.2 arm64 (system WKWebView) and Windows 11 x86 (installed
  WebView2 Runtime) built and ran successfully. Both share the engine window.
- Actual TSTL compilation passed on both platforms: background compilation,
  ready IDE takeover and recycling, hidden IDE compilation, fresh reload
  generation, Stop disconnect, background fallback and eight-second recycling.
- macOS native clicks verified the side menu, Engine/IDE switching, Stop and
  automatic menu collapse. The user confirmed clipboard and switching.
  Direct input, save, select-all and undo passed automated native checks.
- Windows' missing handle was fixed by embedding the compatibility manifest
  required for layered child controls. The actual executable manifest was
  verified; the handle remains reachable with an oversized saved window.
  The user confirmed the handle, menu and Engine/IDE switching.
- Windows reuses the installed stable Runtime and existing SDK/static loader;
  no browser kernel, Runtime installer or loader DLL was added.

## Earlier native IDE baseline

- Both platforms passed native file import/export with matching bytes,
  UTF-8 save/build, editing shortcuts, hide/reopen and reload checks.
- The user confirmed Simplified Pinyin on macOS and Microsoft Pinyin on
  Windows: candidates, committing Chinese text and saving worked; Windows
  close-tab also passed.
- Windows browser-process failure removed readiness; native Reload recreated
  the browser and restored the compiler session.
- Frontend production build and transpile-protocol regression passed.

## CI

Commit `04a31942fe621d43b4de541b490478bc85a035c8` passed all nine workflows.
The Studio Lua extractor fix passed eight local regressions and the Studio
suite (293 tests). Relevant final runs:

- [macOS](https://github.com/IppClub/Dora-SSR/actions/runs/38332440263)
- [Windows](https://github.com/IppClub/Dora-SSR/actions/runs/38332440152)
- [UI CI](https://github.com/IppClub/Dora-SSR/actions/runs/38332440245)

## Limits and reproduction

- Manual OS IME acceptance predates the single-window input routing revision;
  it was not repeated for that revision. Cross-monitor DPI was not exercised.
- Windows Ctrl-Shift-L was not physically verified; native/API reload passed.
  Automated VM clicks and macOS clipboard injection were unreliable; manual
  acceptance above is recorded separately.
- Full frontend type checking had a pre-existing `ignoreDeprecations` version
  incompatibility; production build success does not establish type-check success.
- With usable external IDEs disconnected, launch Dora and run
  `node Tools/dora-dora/scripts/verify-native-ide.mjs`. This retained source
  creates and removes its own fixture. Verify file dialogs, shortcuts, OS IME
  and side-menu clicks through the native UI.

Temporary validation files and test builds are disposable; this document and
source verification scripts retain the reproducible conclusions.
Cleanup removed macOS/repository artifacts (about 1.15 GiB), the Windows QA
application, fixture and build configuration (about 143 MiB), and stale QA
editor entries. Source, verification scripts, toolchains and user data remain.
