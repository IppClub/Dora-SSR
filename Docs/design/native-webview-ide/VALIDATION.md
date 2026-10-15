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

## Responsiveness optimization (local validation)

- macOS arm64 and Windows x86 debug builds passed. Windows ran locally in the
  Windows 11 VM with the installed WebView2 Runtime; package dependencies did
  not change. Both repeated real TSTL takeover, hidden compilation, reload,
  Stop fallback and idle recycling successfully.
- A 2,000-line TS file passed native macOS typing, save and scrolling. The
  source file contained the saved marker; scrolling visibly advanced the view.
- Warmed, visible IDEs were measured for 20 seconds, with a 300 ms logic-thread
  busy loop requested every two seconds. These are `requestAnimationFrame`
  interval measurements, not physical input latency or a hardware benchmark.

| Platform/build | Frame p50 / p95 | Maximum interval | Intervals over 100 ms |
| --- | --- | --- | --- |
| macOS baseline | 20 / 22 ms | 335 ms | 9 |
| macOS optimized | 17 / 18 ms | 33 ms | 0 |
| Windows optimized VM | 8.3 / 12.1 ms | 48.6 ms | 0 |

- Windows completed all ten stress requests without command errors. There is
  no Windows baseline measurement; different refresh rates prevent direct
  cross-platform comparison. A run overlapping hide/show was discarded because
  hidden browsers suspend animation frames. Cold-start samples were excluded.
- Two-second native counters (logic ticks / scene draws): macOS visible 97/26,
  hidden 102/101; Windows visible 98/25, hidden 97/96. Covered drawing stays
  below 15 FPS and ordinary drawing resumes when the IDE is hidden. macOS also
  passed with App.idled=false (103 ticks / 26 draws), exercising IDE sleep pacing.
  Fresh game capture callbacks succeeded on both platforms with the IDE visible.
- macOS main-thread sampling moved from predominantly bgfx semaphore waiting
  to servicing the Cocoa RunLoop. The short timeout bounds only frame waiting;
  GPU submission, presentation and page-side synchronous work can still stall.
- The user confirmed noticeably smoother macOS editing and scrolling. Windows
  native input/scrolling was not independently confirmed in this round. These
  changes have local build/runtime validation, not a new remote CI result.
- The retained `Tools/dora-dora/scripts/native-ide-responsiveness-probe.js`
  reproduces the warm-up and stress measurement in a disposable native QA page.
  Define `window.DORA_NATIVE_IDE_PROBE.outputPath` before loading it; keep the
  IDE visible throughout and restore the normal served page afterward.
- Disposable QA builds, probe pages and fixtures were removed; prior editor
  entries were restored. The ordinary local debug build remains available.

## Second responsiveness pass (local validation)

- macOS arm64 and Windows x86 debug builds passed. The frontend production
  build and four per-file debounce regressions passed. No new CI was run.
- Covered scene draws now stop; explicit capture still draws fresh frames.
  Requested VSync and FPS settings survive the temporary presentation/pacing
  changes. With IDE visible and fpsLimited=false, macOS measured 104 logic
  ticks in 2.011 seconds (51.7 Hz at target 60); original settings were restored.
- macOS final native lifecycle passed: real TSTL handover, hidden compilation,
  bidirectional toggle, reload, Stop fallback and eight-second idle recycling.
  Two IDE-visible captures showed the moving fixture at different positions.
- Native macOS checks saved edits to two files while switching tabs immediately
  after the save shortcut. Read-only files remained unchanged. Monaco mount
  explicitly restores each workspace editor's policy; deferred saves retain
  the requested file and preserve newer edits while a write is in flight.
- Matched 120-second runs with a 2,000-line TS file on the same native build
  recorded 28 input events each: input-to-next-frame p50/p95 was 11/14 ms
  before and 8/13 ms after the frontend changes. This is page event timing,
  not hardware input latency. rAF p95 was 18/19 ms; wheel event counts differed
  greatly (379/4), so these samples do not establish a scrolling improvement.
  Concurrent build/copy work can confound the observed long stalls. Final
  deferred-save and unlimited-pacing fixes were functional checks, not a new
  controlled performance comparison.
- Windows final build and the subsequent DPI manifest build passed. SHA-256
  confirmed the running QA executable matched the native build. After the user
  launched it on the desktop and bypassed access verification, both builds
  passed real TSTL handover, hidden compilation, toggle preserving generation,
  reload, Stop fallback and idle recycling. The validation did not change the
  user's access-verification preference.
- Windows high-DPI diagnosis measured PROCESS_DPI_UNAWARE (0). The embedded
  application manifest now requests PerMonitorV2 with PerMonitor fallback and
  legacy true/pm. Runtime measured Per-Monitor awareness (2) and WebView
  devicePixelRatio=2 (3024 buffer pixels / 1512 visual units); the user
  confirmed the display became clear. No browser
  kernel, Runtime installer or loader DLL was added. Cross-monitor DPI changes
  have not been physically exercised.
- Windows optimized high-DPI VM: warmed 20-second measurement accepted all ten
  300 ms engine busy-loop requests. rAF p50/p95/max was 8.3/10.1/26.3 ms,
  with zero intervals over 100 ms; 20 ms timer p50/p95/max was 20/22/52.1 ms.
  No keyboard/wheel events were recorded, so this proves neither physical
  interaction latency nor a scrolling improvement. There is no controlled
  Windows baseline for this round. Two fresh IDE-visible game captures showed
  the moving green fixture at different positions.

## Bidirectional shortcut (local validation)

- macOS uses Command-Shift-H; Windows and Android use Ctrl-Shift-H.
  Native input routing reserves both down/up, consumes repeats, restores the
  destination focus and clears SDL/engine/ImGui pressed input state.
- macOS arm64, Windows x86 and Android arm64-v8a debug builds passed.
  macOS and Android repeated the real TSTL lifecycle verifier; Windows passed
  its guest-local equivalent. Toggle preserved compiler generation; hidden
  compilation, reload, Stop fallback and idle recycling passed.
- macOS native automation verified both directions and a 1.5-second hold.
  The user confirmed Simplified Pinyin cancellation: candidate UI closed,
  pending text disappeared and previously confirmed Chinese text survived.
- The user confirmed Windows Ctrl-Shift-H in both directions, Microsoft
  Pinyin cancellation, saved confirmed Chinese text and editing after return.
  The saved fixture was read back successfully. VM automation input remains
  unreliable; this IME acceptance is manual.
- Android API 34 emulator ADB input is explicitly user-authorized. A real
  Gboard composing-input test exposed Chromium's input-thread assertion;
  cancellation now runs on InputConnection.getHandler(), with a completion
  fence before focus loss and a FIFO for rapid switching/reload/Stop.
  Final Android lifecycle verifier passed after the fixes.
  Gboard Simplified Pinyin retest passed: unconfirmed ni hao and
  candidate UI disappeared, the soft keyboard was hidden in Engine, and
  confirmed Chinese text survived save/readback. Ctrl-A selection survived
  toggle; continued typing and save after return passed without another
  editor click. DOM composition tracking prevents stale Java input state
  from deleting ordinary selections, and the remembered editor element is
  refocused on return.
- A later Windows restart restored required authentication; the user later
  bypassed access verification for local testing. The second responsiveness
  pass above records the completed Windows lifecycle reruns separately from
  the earlier manual shortcut/IME acceptance.
- These changes have local validation; no new CI was run. Android physical
  hardware and older Android API levels have not been exercised.

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

- Cross-monitor DPI was not exercised. Shortcut IME acceptance for the current
  single-window working tree is recorded above.
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

2026-10-14 follow-up: Windows switching controls now fit the measured IDE/MENU
text with equal vertical padding; Windows debug build passed and the user
confirmed the button display. Shared Web IDE authentication rechecks the server
before prompting and while a PIN dialog is open; a confirmed unauthenticated
response removes the dialog and stale session. Five production-bootstrap
regressions, TypeScript checking, lint (one existing Archive.ts warning), and
Vite production build passed. A headless Chrome run of the built frontend with
controlled HTTP/WebSocket responses passed PIN login, disconnect, offline/500
retaining the dialog, disabled mode dismissing it, unsigned requests and reload
with stale credentials. The automated browser run uses controlled responses.
Windows follow-up found an automation-started session-0 test process still
serving the old page with authentication enabled. After terminating that owned
process, the user launched the updated application from the desktop with
authentication disabled and confirmed the embedded IDE no longer prompted for
PIN. The live unsigned /info request returned 200, and the served main script
matched the updated build. Other platforms were not exercised for this fix.

2026-10-14 runtime opt-in: macOS debug, Windows x86 debug and Android debug
(arm64-v8a, armeabi-v7a, x86_64) builds passed. Lua syntax checks, frontend type
checking and the eight Teal source checks passed. A macOS application with its
own startup script asserted the default flag was false; native UI inspection
confirmed no handle initially, creation on opt-in and removal on disable.
The disabled macOS shortcut did not reopen the IDE. The retained native verifier
passed on macOS and the Android API 35 emulator, including real TS compilation,
hide/toggle/reload, game run/stop, disabling a visible IDE, rejected IDE actions,
background compilation and idle recycling while disabled, and recreation on
re-enable. Android UI inspection found no buttons or visible WebViews after
disable; injected Ctrl-Shift-H kept the disabled/stopped state. The verifier
restored the initial runtime flag and removed its fixtures. The user confirmed
on Windows that disabling the development setting removes the handle and blocks
Ctrl-Shift-H, and re-enabling restores switching. Windows initially crashed in
EmbeddedBrowserWebView.dll (0xc0000005) while
disabling a visible IDE. Controller teardown was moved out of the IME completion
callback to a queued render action; the Windows x86 rebuild passed. After a
desktop restart, the full retained verifier passed, including real TS builds,
hide/toggle/reload, compiler takeover, stop/idle recycling, game run/stop, visible
IDE disable, rejected disabled actions, background compilation while disabled
and recreation on re-enable. The service remained responsive with zero compiler
users, jobs and connections, and both compilers recycled. Three additional visible
IDE disable/recreate cycles passed; the initial enabled flag was restored and
the earlier crash fixture removed. No session-0 engine process was launched for
this check. Temporary macOS test bundles were removed.

Shortcut QA fixtures and temporary screenshots on macOS/Android were removed;
prior editor entries were restored. The second responsiveness pass restored
the macOS editor entries (also preserving a newly opened user tab) and Windows
editor entries; its probe copies and capture fixtures were removed. The current
Windows QA application remains available for the user.
Cleanup removed macOS/repository artifacts (about 1.15 GiB), the Windows QA
application, fixture and build configuration (about 143 MiB), and stale QA
editor entries. Source, verification scripts, toolchains and user data remain.

2026-10-15 embedded Run and switching interactions:
- macOS debug, Windows x86 debug and Android three-ABI debug builds passed;
  frontend production build and TypeScript checking passed. Six native-run,
  five WebSocket lifecycle and five authentication regressions passed.
- Actual embedded Run This actions on macOS, Windows and Android started a
  successfully compiled TS fixture and returned to Engine. Compilation/startup
  failures stayed in IDE. On macOS and Windows, manual hide/show during a delayed
  run cancelled the automatic return. Ordinary browser and external HTTP runs did not switch views.
- All platforms place the handle at the left edge. IDE opens the editor directly
  from Engine, including an already-loaded session. Inside IDE, MENU lists Engine,
  Reload and Close. Engine retains the page/session; Close ends it while keeping
  the IDE entry available. macOS and Android native menu/reopen checks passed.
  Windows screenshots confirmed placement, but VM mouse delivery was unreliable;
  native Windows menu click acceptance remains unverified.
- The desktop address callback uses restored App.openURL behavior; invoking it
  opened external Edge on macOS and Windows with embedded IDE support enabled.

2026-10-15 compiler and session regression:
The retained native verifier passed on macOS, Windows and Android: real TS
compilation, ready-IDE takeover, hidden compilation, bidirectional toggle, reload,
Close/stop fallback, idle recycling, game run/stop, runtime disable/re-enable and
background compilation while IDE controls are disabled. The final macOS run also
passed three immediate reload/Close cycles followed by idle waits without
reconnection. Windows launch/test keys used temporary interactive desktop tasks.
Original editor entries were restored after Run QA; all fixtures, temporary tasks
and Android UI captures were removed. No editor files changed for menu checks.

2026-10-15 macOS Close/disconnect repair:
A stopped IDE could retain a live WebKit connection. Close now stops navigation,
marks the document closed, disposes its WebSocket/reconnect lifecycle and clears
the document before releasing WKWebView. Late initialization/warmup cannot connect;
pagehide cancels retries, and cached browser pages resume a fresh lifecycle on
pageshow. The engine continues polling ready RunLoop sources after hiding/closing
so asynchronous teardown can finish. Final macOS build, frontend build, typecheck
and the full native verifier passed. Actual MENU -> Close returned to Engine;
after an idle wait, nativeIDE.state=stopped, wsConnectionCount=0,
webIDEConnected=false and webIDEReady=false. No TCP client remained on port 8868,
compiler users/jobs were zero and both compiler views were recycled. The repaired
macOS application remains running.
