# Godot / Dora integration completion gates

Objective: 完成 Godot 和 Dora 引擎的整合并完成多平台的验证和测试。

Current status, product decisions and prioritized work are maintained in
[`TRACKING.md`](TRACKING.md). This file remains the append-only implementation
and evidence log.

This is the active implementation record. A prototype, a passing compile, or a
single-platform GPU test does not complete the objective.

## Required integration

- [x] Versioned C ABI, pinned Godot source, isolated native-library symbols (macOS / Linux / Windows runtimes).
- [x] GodotNode loads real projects/scenes, retains SceneTree/autoload semantics (macOS / Linux ARM64 / Windows WGL tested).
- [x] GPU transport with explicit ownership, bounded buffers and synchronization (Metal, Linux EGL and Windows WGL; other backends pending).
- [ ] Node create/remove/recreate, scene restart, pause/resume, resize and errors.
- [ ] Pointer/touch/keyboard/text/controller focus and coordinate conversion.
- [ ] Content/resource paths and packaged/imported Godot project resources.
- [ ] Audio mixing through the Dora host, without competing audio device ownership (macOS/Linux ARM64/Windows WGL PCM-to-SoLoud callbacks passed with audio ABI2; mobile/Web and broader project coverage pending).
- [ ] Lua/Yue/Teal/TypeScript bindings and documentation; other supported native bindings.
- [ ] Optional dependency packaging/build integration, licensing and reproducibility.
- [ ] Clean shutdown and GPU/resource accounting, invalid-input regressions.

## Platform acceptance matrix

All Dora target families remain in scope. Record compile and actual runtime
validation separately; unavailable execution environments are not a pass.

| Target | Build | Runtime/GPU output | Input/lifecycle | Evidence |
| --- | --- | --- | --- | --- |
| macOS Metal | full standard runtime and ordinary host builds passed | Metal shared GPU textures; 2/3/4-buffer lifecycle/resize regressions; shader TIME, actual GPU particles, source-owned Window stretch/resize/input convergence and Rust/Wa resize execution passed | animation, pause, pointer/key/text/focus, standard controller button/axis and held-state focus release, restart/remove/recreate, host audio, resize/cancel and retained aliases passed; recovery/full IME/physical-controller hotplug pending | build/godot-runtime/node-controller-focus-macos-2/verification.json; gl-targets-desktop.json; timing-desktop.json; bindings-resize-desktop.json; output-desktop.json |
| Windows | full standard Godot4.6 WGL x64 DLL and MSVC host passed; current controller-extension DLL passed exact-hash runtime execution; x64 C# native DLL and public .NET execution passed | source-owned Window stretch/resize/input convergence, actual GPU particles, timing/lifecycle/resize and 2/3/4-buffer GPU regressions passed | resize/cancel/aliases/audio/input lifecycle, standard controller button/axis and held-state focus release, automatic Control IME attach/remove/recreate plus OS-originated Unicode commit passed; C#/Rust/Wa each passed1000 controller frames/15 GPU captures with resize; recovery/native composition-candidate UI/physical-controller hotplug pending | build/godot-runtime/windows-controller-focus/verification.json; build/godot-windows/windows-ime-acceptance-results/verification.json; gl-targets-desktop.json; timing-desktop.json; output-desktop.json; Parallels Windows11 ARM64 running x64 binaries, OpenGL3.3; not a physical Windows x64 GPU test |
| Linux | full standard Godot and ordinary Dora ARM64 builds passed; current controller-extension runtime and host passed exact-source execution; current x86_64 LibGodot and Dora host cross-builds passed | EGL/virgl shared GPU textures; 2/3/4-buffer resize, shader TIME, actual GPU particles, source-owned Window stretch/resize/input convergence and Rust/Wa resize execution passed; x86_64 independent ANGLE/SwiftShader sharing passed 360 frames under Rosetta, but full x64 Dora-node execution is blocked by translation/runtime startup constraints | animation, pause, input/focus, restart/remove/recreate, resize/cancel/aliases, host audio, standard controller button/axis and held-state focus release passed on ARM64; recovery/full IME/physical-controller hotplug and native x86_64 hardware pending | build/godot-runtime/linux-controller-focus/verification.json; build/godot-runtime/linux-x64-rosetta-report.json; gl-targets-desktop.json; timing-desktop.json; bindings-resize-desktop.json; Ubuntu ARM64 VM / isolated Weston / Mesa virgl; x64 evidence is Rosetta translation, not native hardware |
| Android | full standard ARM64 runtime, upstream Java services and isolated Dora APK built | actual node shared EGL GPU output passed 2/3/4 buffers, resize/cancel/retained aliases, shader TIME, GPU particles and eight source-driven size/stretch modes | injected input/focus, SDL-touch to GUI, standard controller button/axis and held-state focus release, restart/recreate, host PCM audio/stalls and same-process Home/resume with surface recreation passed; physical input/forced context loss pending | build/godot-runtime/android-controller-focus/verification.json; android-node.json; android-advanced.json; API35 ARM64 emulator / Apple M1 Pro GLES translation; ordinary APK ARM64 build/inspection passed; physical devices and ordinary-app execution pending |
| iOS | standard simulator Metal framework, isolated and ordinary Dora hosts built; device archive/framework linked (no physical execution) | simulator GPU output unsupported: real Apple2 profile rejects cube arrays, Godot requires Apple4; no GPU-sharing pass | Apple4 capability rejection/cleanup verified; real runtime lifecycle/input pending | build/godot-runtime/ios-metal-capabilities/capabilities.json; ios-final-apple4-rejection/unsupported-gpu.json; build/godot-ios/ordinary-compilation.json; user prioritizes simulator testing |
| Web | real Godot4.6 WASM and opt-in Dora core Debug built; current controller/teardown runtime and host rebuilt; ordinary no-Godot core startup/teardown passed | actual Dora GodotNode GPU composition passed directory2/3/4 + PCK3; current controller matrix passed 1,860 frames /36 PNGs; rebuilt context-loss boundary passed a fresh normal 2/3/4-buffer matrix with 1,860 frames/36 PNGs | pause/resume/restart/resize/retained aliases/recreate/manual pointer-key, standard controller button/axis and held-state focus release, host PCM, explicit host suspend/resume, post-stop platform-service teardown and two-lifetime IDBFS persistence passed; real WEBGL_lose_context fail-safe cleanup passed after animation on 2/3/4 buffers with pending0/GPU errors0; in-place context restoration, OS IME composition/real background-tab policy/latency/physical-controller pending | build/godot-web/node-controller-teardown/verification.json; context-loss-matrix.json; node-suspend-results/verification.json; persistence-teardown-results/verification.json; ordinary-teardown-results/execution.json; Chrome156 / ANGLE Metal Apple M1 Pro; not broad-browser/release acceptance |

## Current sequence

1. Extract the versioned bridge and real-project GodotNode from the Metal probe.
2. Verify macOS native node creation, project scene, animation, input and cleanup.
3. Add backend-independent lifecycle/ownership tests on macOS, Linux and Windows.
4. Implement native GPU bridges on the remaining targets and run real output tests.
5. Complete bindings, audio/resources, distribution and platform regression gates.

## Evidence policy

Keep original Metal stress tests as regression evidence. Record the actual
renderer, device, frame identifiers, GPU completion/error accounting and final
Dora output for each new backend. Do not use CPU pixel readback/upload as the
production shared-texture transport. Screenshot readback for verification is fine.

Progress classification: the previous thread turn was progress (implemented
continuous animation and synchronized multi-buffer transport, with actual Metal
GPU results). This goal starts with all full-integration gates still unproven.

## Latest continuation evidence (2026-10-28)

- macOS Metal: current-source 2/3/4-buffer stress passed 3,600 consumer frames,
  with Metal API Validation enabled. The overloaded 2-buffer case deferred 799
  productions instead of blocking. All producer/consumer completions and event
  tickets drained; GPU errors were zero.
- Formal GodotNode macOS and Linux ARM64 tests each passed 720 frames / 8 captures,
  including animation, pause before asynchronous boot, native Always-process
  behavior while paused, input/global InputMap state, focus release, scene reload
  and node remove/recreate. Folder and imported-resource PCK variants passed.
- Imported PCK fixtures omit the source PNG and load the imported compressed
  texture three times across lifecycle changes. Final Dora pixels validate
  premultiplied alpha, node opacity and additive Godot drawing on both platforms.
  PCK was produced by the installed Godot 4.4.1 editor and consumed by the pinned
  4.6 runtime; this is a PCK v2 test, not evidence for all export formats.
- Linux actual GPU: Mesa 25.2.8 virgl (Apple M1 Pro Compat), OpenGL ES Compatibility,
  Ubuntu ARM64 VM. Tests use an isolated GL-rendered headless Weston. Independent
  real-LibGodot EGL test also passed 360 frames / 361 completed productions;
  screenshot encoding was corrected to retain the logical top row.
- Fixed startup/import ordering: defer native runtime boot until bgfx has created
  the allocated textures, including after handle reuse on node recreation.
- Fixed Wayland startup: show/pump the SDL surface before startup submissions so
  eglSwapBuffers does not wait indefinitely for a hidden surface frame callback.
- Fixed input routing through Godot Input and explicit release of bridge-owned
  held keys/buttons. Fixed pause to use native SceneTree semantics while still
  advancing the engine iteration. Fixed default Sprite shader/blending to retain
  Godot premultiplied RGBA including additive pixels and node opacity.
- Optional runtime packages include source provenance/hash, upstream MIT license,
  third-party notices and checked binary hashes. EN/ZH API pages document the
  implemented behavior and remaining boundaries.

## Evidence and remaining work

Authoritative reports (all paths relative to repository root):

- `build/godot-metal-probe/current-matrix/verification.json`
- `build/godot-runtime/node-results/verification.json`
- `build/godot-runtime/node-imported-pck-results/verification.json`
- `build/godot-runtime/node-linux-arm64/verification.json`
- `build/godot-runtime/node-imported-pck-linux-arm64/verification.json`
- `build/godot-runtime/gl-runtime-linux-arm64/verification.json`
- `build/godot-runtime/gl-transport-linux-arm64.json`
- `build/godot-runtime/protocol/verification.json`

All GPU tests behind these reports are terminal. The first Linux
build's rejected --path flag, hidden-Wayland-surface hang, stale texture after
node recreation and incorrect alpha pixels were failures, reproduced and fixed;
only subsequent passing reports count. The shared-EGL transport test and C ABI
header checks alone do not prove full platform integration.

The complete goal remains active. Windows, Android, iOS and Web native runtime/GPU
integration and execution are pending. Linux x86_64 has no GPU output validation.
Also pending: dynamic viewport resizing, controller/full IME, host audio mixing,
multiple projects, device-loss recovery, remaining native bindings and production
packaging/distribution. Keep compile-only results distinct from real runtime/GPU
results. Resume these gates without relaunching any already-completed build.

## Language binding continuation (2026-10-28)

Previous turn classification: progress. This turn also made progress:

- Added generated GodotNode C ABI imports/exports and language units for Rust,
  Wa and C#. Registered native object conversions in Rust/C# and optional Wasm3
  imports. Only the Godot units were copied from an isolated generator staging
  tree, preserving unrelated generated Cache edits.
- Added GodotNode sources to the legacy C# native Visual Studio project. XML
  structure checked; Windows native compilation/execution is still pending.
- Rust and Wa each passed real Wasm3 -> GodotNode -> final Dora GPU output tests
  on macOS Metal and Linux ARM64 EGL: 720 frames and 8 captures per language /
  platform, with all generated lifecycle/input control methods exercised.
- C# complete binding assembly compiled against .NET 8 with warnings treated
  as errors: zero warnings/errors. This is compilation evidence only; no .NET
  host GPU execution is claimed.
- Reproduced invalid-project startup failure on Linux. A cross-host fixture had
  incorrectly embedded macOS's /private/tmp alias for a Linux /tmp path. Fixed
  target-path handling in the fixture builder. The failure also exposed native
  teardown after a Wasm initializer panic: Sprite's default GPU effect renderer
  could be introduced by a constructor destined to fail. Added factory preflight
  before Sprite allocation. Invalid-project Wasm startup now exits with code 2,
  no GPU handle leaks, no late C++ objects and no crash on both macOS and Linux.
- Added build/run/failure fixture tools and documented reproducible commands.
  Compilation reports and actual runtime/GPU reports remain separate.

Evidence:

- `build/godot-bindings/compilation.json`
- `build/godot-bindings/node-rust/verification.json`
- `build/godot-bindings/node-wa/verification.json`
- `build/godot-bindings/linux-node-rust/verification.json`
- `build/godot-bindings/linux-node-wa/verification.json`
- `build/godot-bindings/invalid-macos/verification.json`
- `build/godot-bindings/invalid-linux/verification.json`

The earlier Linux ordinary build finished successfully (352 seconds); its old
session 77771 is terminal. The source-transfer HTTP server and ad hoc Weston
remain stopped. Test compositor wrappers clean up their own process groups.

The full goal remains active: Windows / Android / iOS / Web GPU runtime support,
Linux x86_64 GPU output, dynamic resize, device recovery, host audio, complete
controller/IME support, .NET runtime execution and production distribution remain
unproven or unfinished. None of the language tests changes that platform scope.

Final checks for this continuation: macOS and Linux normal Dora builds, without
native test entry, both passed after the constructor preflight change. All four
language/GPU tests and both expected-startup-failure tests are terminal and pass.
Collected matrix: `build/godot-bindings/verification.json` (2,880 consumer frames).
There are no live build/test sessions to resume from this continuation. Next work
should address the remaining platform backends and integration gates above;
do not reclassify C# compilation or existing desktop results as their completion.

## Windows WGL continuation (2026-10-28)

Previous goal turn: progress. This turn: progress (new platform backend source,
real Windows runtime/binaries compiled and packaged, desktop GPU regressions).

Implemented:

- WGL producer context with the host pixel format/share group, independent hidden
  drawable, pinned upstream private GLAD dispatch, shared GL textures and syncs.
  EGL and WGL now share the same GPU copy/fence algorithm in texture_ring.inc.
- Windows native DLL loader / GLSession integration, UTF-8 DLL paths, early
  renderer validation, optional Windows OpenGL host mode and bgfx GL build flags.
  The ordinary Windows renderer selection stays unchanged unless
  DORA_GODOT_WINDOWS_GL=1 is requested before startup.
- Godot Windows LibGodot entry registers the virtual display. Full standard
  runtime built for x86_64 via MinGW, without Vulkan/D3D12/AccessKit. The first
  cross-build linked a Windows PE image with an inherited .so filename and the
  wrapper's DLL glob failed. Fixed the Windows SharedLibrary suffix; incremental
  relink/package completed in 25 seconds, reusing the 34m44s build's objects.
- Real Windows transport.exe and LibGodot runtime.exe, Windows-only execution
  launchers, PE architecture matching and GPU-output verifiers. Windows runtime
  GPU reports cannot be created by a Linux/macOS compile-only run.
- Expected missing-library startup failure now has a regression case; actual
  macOS and Linux processes exit with code 2, no Godot boot and no leaked GPU
  handles or late C++ objects. This supplements invalid-project startup tests.

Evidence and actual validation scope:

- `build/godot-windows/compilation.json`: full Godot 4.6 x86_64 runtime DLL compiled;
  gpu_tested=false. Package: `build/godot-windows/package/dora_godot.dll` (122,370,048
  bytes), manifest source/binary hashes and upstream licenses included.
- `build/godot-windows/pe-inspection.log`: actual DLL imports only Windows system
  libraries, no libstdc++/libgcc/winpthread runtime DLL dependencies. Both bridge
  entry points exported; upstream LibGodot C entry points / Windows GPU hints
  are also present, without an exported C++ SDK surface.
- `build/godot-windows/transport/compilation.json`: two Windows x64 PE EXEs and real
  GodotNode / GodotRuntimeGL / Application C++ objects compiled. No Windows GPU
  execution is claimed.
- `build/godot-runtime/wgl-shared-egl-transport/verification.json`: extracted
  production EGL/shared ring code passed 3,600 consumer frames / 99 sampled
  images on actual Mesa virgl (Apple M1 Pro Compat), buffers 2/3/4.
- `build/godot-runtime/wgl-linux-pck-arm64/verification.json`: updated runtime and
  node passed 720 frames / 8 captures, imported texture without source PNG,
  alpha/node opacity/additive pixels, input, pause and lifecycle. GPU errors 0.
- `build/godot-runtime/wgl-macos-results/verification.json`: current-source Metal
  node regression passed 720 frames / 8 captures, GPU errors 0.
- `build/godot-runtime/wgl-missing-library/verification.json` (macOS) and
  `wgl-missing-library-linux/verification.json`: expected missing-runtime failure
  exits without crash/leaks. CPU ABI/frame ownership protocol also passed.

Live external state / next continuation:

- Full Windows runtime build sessions 77577 and 18391 are terminal. Do not restart
  them: the completed DLL package and EXEs are already copied back to the host.
- Windows 11 is running. Resume session 82978 is terminal (exit 0); do not
  resume/restart it. Current-user CLI runs in interactive session 1 and allows
  GPU execution without unlocking the Mac. No UI automation is necessary.
- Actual Windows OpenGL 3.3 on Parallels / Apple M1 Pro passed 2/3/4-slot WGL
  transport stress: 3,600 consumers / 99 sampled images, GPU errors 0. Actual
  LibGodot passed 360 frames, 361 produced/completed, pause/resume and a Chinese
  project directory. Reports: build/godot-windows/transport-windows-verification.json
  and runtime-windows-results/verification.json. Host OS ARM64; tested binaries
  x86_64 under emulation. These are independent consumers, not Dora-node output.
- Windows Dora source archive expanded completely (8,843 files) into owned
  C:\DoraGodotNative-01a17dc1\repo. Host session 65116 is terminal; configure
  exited -1 because C:\App\Bin\xmake.exe cannot import core.language.menu.
  No source compilation started. Logs/exit file retained in its parent folder.
  Isolated official xmake 3.0.7 win64 archive downloaded (hash recorded in
  build/godot-windows/xmake-package.json). Tool extraction/configure/build chain
  is live in host exec session 94074, under the same owned root/tools. New logs
  configure-isolated.log / configure-isolated.exit; build.log / build.exit.
  Global installation unchanged; do not restart the completed source expansion.
- Windows test launcher configuration now receives the same opt-in test/GL
  environment as compilation and execution; Python syntax validation passed.
- Windows native runtime dependencies now select Rust/Go architectures for both
  existing x86 and new x64; full x64 host validation remains pending.
- Linux/macOS ordinary builds passed earlier in this continuation. The final
  missing-library check rebuilt the opt-in test hosts; rebuild ordinary targets
  once at the next appropriate check if required. Do not relaunch passed GPU
  tests without a relevant new change or unresolved concern.
- Current remaining platform gates are actual Windows Dora/WGL output and input,
  Android/iOS/Web runtime/GPU support and tests, Linux x86_64 GPU, plus the audio,
  resize, device recovery, controller/IME, .NET runtime and distribution gates.
- iOS source inspection found OS_IOS has a no-argument constructor inherited from
  OS_AppleEmbedded and the platform currently builds a static library, without a
  LibGodot entry. This may support a dedicated embedded framework/entry reusing
  Metal, but no iOS bridge implementation or compile/GPU pass exists yet.
- Further ownership audit should test inherited Sprite.texture aliases outside
  the owning GodotNode; current per-node consumption tests do not prove that use.

The full objective remains active and is not complete.

## Native Windows Dora build continuation (2026-10-28)

Previous turn classification: progress (x64 native-runtime mapping, real Windows
GPU evidence, isolated source staging, verified broken global xmake). This turn
continues the full objective without narrowing platform acceptance.

- Isolated xmake 3.0.7 win64 fixed missing scripts but selected a non-host x64
  Rust toolchain on the ARM64 guest; configuration failed before source build.
- Downloaded the complete official xmake 3.1.2 ARM64 distribution, retained archive
  hash in build/godot-windows/xmake-arm64-package.json. No global tools changed.
  ARM64 host configuration passed; target remains Windows x64. Native MSVC
  compilation now active, last observed at 25% (SDL2/openmpt), host session 38710.
  Guest owned root C:\DoraGodotNative-01a17dc1; configure-arm64.log/.exit and
  build.log/.exit are authoritative. Earlier session 94074 is terminal failure.
- test_windows.py now supports --xmake and --skip-runtime-build so the same
  reviewed host build can be repeated with a prebuilt matching DLL; the default
  full build and --skip-build paths remain available. README now distinguishes
  actual independent Windows GPU passes from the still-pending Dora node pass.
- iOS source gate: Godot 4.6 platform/ios/detect.py disables Metal for simulator;
  it does not advertise library support. A dedicated embedded entry/build path
  and device validation are still required. simctl query triggered Xcode's own
  first-launch setup (PID 87688, host session 44503); last observed live, no
  simulator availability result yet. Do not relaunch it on an observation timeout.
- Audio investigation found AudioDriverDummy exposes set_use_threads(false) and
  mix_audio(), and Dora has PCMQueueFile/SoLoud. These owning sources support a
  future explicit pull-audio bridge, but no audio implementation/pass is claimed.

Launcher --help execution and git diff --check passed after the new options.

Final verified wait: Windows native xmake PID 7028 and cl PIDs 2460/11236 live;
configure-arm64.exit=0, build at 25%. Host session 38710 remains live. Copied
configure proof and a build-log snapshot to build/godot-windows/native-*.log.
No Windows Dora GPU pass yet; next action is poll this same build and then run
Tools/Godot/test_windows.py --skip-build with the existing x64 runtime DLL.

## Windows native dependency correction (2026-10-28)

Previous turn: progress and verified wait at 25%. This turn inspected the same
build until it terminated at ~32% with a real xmake sandbox error: assert was
called from a project-scope architecture helper rather than an on_build script.
Moved architecture validation into each on_build callback and removed all helper
references (including the Wa dependency-cache values expression). The first
incremental retry exposed that missed cache expression and is terminal too;
raw logs retained as build-assert-failure.log and build-helper-reference-failure.log
under the owned Windows root. Current retry is host session 52020; no earlier build should be restarted.
Ubuntu ARM64 was confirmed idle (no build/test processes) and gracefully suspended
to free host memory; its /tmp source/build state is preserved for later resume.

The corrected retry passed both native-runtime build callbacks: Rust installed
x86_64-pc-windows-msvc target under the native ARM64 host toolchain and actual
cargo compilation started; Go c-shared compilation started too. Last observed
xmake PID 6060, cargo 6592/8404 and Go 3220 live. No native host binary or GPU
node result exists yet. Keep this retry live; do not restart on a poll timeout.

Further native build evidence: Rust x64 staticlib completed (308,981,546 bytes,
59.41s dev build). Session 52020 terminated when Wa DLL generation failed. A
separate exact Go invocation (session 75607, now terminal) revealed missing
WSAData / Servent / JOBOBJECT_BASIC_LIMIT_INFORMATION, not a compiler/toolchain
failure. The vendored x/sys Windows tree only retained types_windows_386.go.
Restored types_windows_amd64.go byte-for-byte from golang.org/x/sys v0.33.0;
`go mod download -json` reports the module hash already pinned in go.sum:
h1:q3i8TbbEz+JRD9ywIRlyRAQbM0qF7hu24q3teo2hbuw=.
Added windows/amd64 to Projects/xmake/tools/wa/collect_vendor.py so future sync
preserves this platform. No dependency version changed. Full incremental retry
is host session 52378. One subsequent read-only guest poll returned transient
PrlJob_GetResult Invalid argument; this is not a terminal build observation.
Do not restart the retry solely because that poll failed.

Final verified state for this continuation: session 52378 remains live, native
xmake PID 9932 and cl PIDs 5428/11220 confirmed running. Build snapshot now at
44%. Rust x64 staticlib and Wa x64 DLL both built; Wa PE machine is 0x8664 and
actual objdump imports are KERNEL32.dll / msvcrt.dll only. Evidence recorded in
build/godot-windows/native-dependencies.json; raw build snapshot plus a UTF-8
mirror and the original Wa failure log copied to the host. These prove native
dependency builds only, not full Dora linking or GPU behavior. Next continuation
must poll 52378 / current build.exit before any retry. Session 75607 is terminal
failure; 52020 and 38710 are terminal too. Xcode first-launch session 44503 was
last observed live and remains an independent pending environment operation.

## Windows GL compiler / entry-point correction (2026-10-28)

Previous turn: progress (sandbox architecture selection and pinned Wa amd64
vendor restoration; Rust/Wa actual x64 builds), ending in a verified native
build wait. Re-polled the same session 52378: it reached shaderc/bgfx and then
terminated with MSVC C3861 for glIsEnabled/glGetBooleanv in existing Love GL
trace code. These had no bgfx dynamic-dispatch declarations when enabling the
previously disabled Windows OpenGL renderer.

Added the two core GL entry points/types to bgfx glimports.h. Source inspection
also found Windows shaderc still compiled GLSL=0 with only HLSL enabled. The
actual GodotNode constructor always compiles its premultiplied-alpha resolve
shader through SharedShaderCompiler, so Windows WGL cannot boot correctly with
that configuration. Enabled GLSL alongside HLSL and the matching glsl_optimizer
dependency. The existing node/GPU/alpha tests cover this real shader path; no
replacement or simpler rendering path was substituted.

Native retry host session 32029 is now live with both corrections copied to the
owned guest source. Preserve and poll it; session 52378 is terminal. Original
error log retained as build-gl-dispatch-failure.log under the guest owned root.
The new dependency graph has additional compiler objects, so build percentages
from the previous graph are not a completion/ETA measure. No full Windows Dora
build or GPU pass is claimed yet. Linux GL must receive a focused regression
after the common glimports change; its VM is currently suspended.

Follow-up verification in this turn: native MSVC passed the GodotNode,
GodotRuntimeGL and GodotNodeTest source units and progressed to other engine
objects (last observed 60%, xmake PID 2880). Full link/GPU result still pending.
Pillow 12.0.0 installed into owned C:\DoraGodotNative-01a17dc1\venv, without
changing global Python packages. Imported PCK/manifest staged under the owned
root/imported-fixture; guest SHA256 matches the prior macOS/Linux fixture.

Audit correction: Tools/Godot/tests/protocol.sh previously marked
texture_boot_frame_gate=true without actually invoking existing render_boot.cpp.
Added compilation/execution of that test and removed the stale report before
running checks. Actual macOS run now passes ABI, frame-ring schedules (100k per
buffer count) and render boot queue. Prior Linux boot-gate field is not proof;
rerun the corrected script when resuming Linux for the common GL regression.
This does not invalidate the separate actual Metal/GPU tests.

Final verified wait: host session 32029 still running; Windows xmake PID 2880,
cl PIDs 5788/5980 live, latest native build at 63%. Test Python venv/Pillow is
installed and the matching imported PCK is staged. Next action is poll this same
build; no Windows Dora node pass exists yet. Source files for the loader and
test entry compiled; GodotNode.cpp was observed in the latest compile queue.
Raw native GL failure and updated build snapshots are copied to the host, with
UTF-8 build mirror at build/godot-windows/native-build-progress.utf8.log.
When build.exit is 0, run owned venv Python + Tools/Godot/test_windows.py
--skip-build --library C:\Users\Jin\AppData\Local\Temp\DoraGodotWGL\dora_godot.dll,
then repeat with --project owned-root/imported-fixture/project.pck and
DORA_GODOT_FIXTURE_MANIFEST=owned-root/imported-fixture/fixture.json. Preserve
separate results directories and copy actual reports/screenshots to the host.
Linux VM remains suspended; common GL dispatch and corrected boot-queue CPU test
still need the Linux regression after the Windows build/test frees resources.

## Native runtime ABI guard coverage (2026-10-28)

Previous turn classification: progress (GL dispatch and GLSL support fixes,
corrected CPU boot-queue test) plus verified wait. This turn re-polled session
32029, with native xmake 2880 and cl processes live, and continued waiting for
full Windows linking; it was last observed at 83% before the next poll.

Added Tools/Godot/tests/runtime_abi.py, executing against actual optional native
libraries in separate processes without a GPU context or Godot instance. Checks
wrong ABI versions, null/small/extended output tables and canaries, malformed
configs and diagnostics, invalid handles, repeated shutdown and rejection after
shutdown. Actual Metal library passed 59 checks; actual Windows WGL DLL passed
82 checks including GL extension table/functions. Reports retain library hashes
and gpu_tested=false: build/godot-runtime/abi-native-macos/verification.json and
build/godot-windows/abi-preboot-wgl/verification.json. These are preboot ABI
results only, not additional engine/GPU/lifecycle execution passes.

The macOS/Linux/Windows test launchers now run this child-process preflight before
starting the Dora GPU host. Shell syntax and Windows launcher help checks passed.
Sync updated test_windows.py and runtime_abi.py to the owned Windows checkout
before executing the node tests. The Linux ABI/GPU regression remains pending
while its VM is suspended; do not label that platform's new checks passed yet.

## Windows link and first actual node execution (2026-10-28)

Session 32029 is terminal: all source compilation passed, but native link failed
with nine glcpp_preprocess / Mesa symbol-table references. The previously-unused
Windows glsl_optimizer target forced its C sources to C++, mangling these entry
points. Removed that override, retained C++ for actual .cpp sources and selected
MSVC C11 for C files. Native incremental retry 38302 passed fully in 11.485s;
Dora.exe SHA256 ecfbd653e1db0da24241fcfa718f270bce7e9684724f580d59be57cc9b20bc79.
Build logs retained in owned guest build-glsl-linkage-failure.log and
build-before-gl-readback-fix.log. Native dependency report remains valid.

PowerShell .ps1 dispatch is disallowed by the guest execution policy. No policy
was changed. Read-only process/file checks confirmed earlier guest-session
errors had not started the test. Use native Python directly via prlctl exec
--current-user; do not use build/godot-windows/run-native-node.ps1. The public
Windows test runner now accepts --fixture explicitly, so no script wrapper is
needed. Updated test_windows.py/runtime_abi.py are synced to the owned checkout.

Direct actual source node test session 47133 is terminal failure (0x80000003).
Preboot ABI checks passed (82). Real Godot booted inside Dora, OpenGL 3.3
Parallels using Metal (Apple M1 Pro), first scene/autoload and preboot pause
checks executed. No GPU pass report was emitted. Raw result directory copied to
build/godot-windows/node-source-results (no verification.json).

Diagnostic GDB session 47180 is terminal and its own debuggee is gone. Raw log
build/godot-windows/node-gdb.log captured the exact breakpoint: bgfx_p.h readTexture
asserted because the screenshot render target lacked READ_BACK. Existing bgfx
validation only permitted direct GL RT readback on Android/Linux, whereas native
GL readTexture already supports glGetTexImage/FBO readback. Corrected that
exception to select OpenGL/OpenGLES by actual renderer; other backends still
require the readback flag. Production shared-texture transport is unchanged.

Current native incremental rebuild is session 59355 (after the readback guard
fix); do not restart earlier sessions. Prior compiled-host report archived as
native-host-before-readback-fix.compilation.json; refresh final compilation proof
and run source then PCK cases after this build completes. PCK fixture flag:
--fixture C:\DoraGodotNative-01a17dc1\imported-fixture\fixture.json.
Linux/common bgfx regression is still pending and its VM remains suspended.

## Windows native node GPU acceptance (2026-10-28)

The readback-guard rebuild (59355) passed in 20.625s; corrected test executable
SHA256 485903afdaa7dfee5ef23edfb68ec8a35ae1912460d1326d3938a18ca4e0c75b.
Direct native Python source test 93032 passed, followed by imported-PCK test
54897. Both are terminal: 720 frames and 8 final Dora captures each, animation,
preboot pause/Always processing, pause/resume, pointer/key/text and global Input,
focus release, scene reload and node remove/recreate all passed, GPU errors 0.
Source counts: first close 395/395, final cumulative 590/590. PCK counts:
364/364 and final cumulative 554/554. These are cumulative within each process;
do not sum the first and final counters as separate production totals.

PCK additionally passed source-PNG omission/imported .ctex loading, node opacity,
premultiplied-alpha and additive-pixel checks. All images/reports copied back to
build/godot-windows/node-source-after-readback and node-pck-results. Viewed the
actual PCK animated image; upright cube, native UI and marker controls are present.
Summary: build/godot-windows/node-windows-verification.json (1,440 consumers,
16 captures); build/godot-windows/native-host-compilation.json is separate
compile evidence. Actual environment: Windows 11 ARM64, x64 binaries under
Windows emulation, Parallels OpenGL 3.3 / Metal on Apple M1 Pro.

Normal Windows x64 Dora build, with both test-entry/forced-GL env vars removed,
also passed (session 12811, 18.438s), rebuilding normal Application.cpp and linking
its separate ordinary executable. Logs/exit code copied to the host. This is an
ordinary build check, not an additional Direct3D runtime/GPU test. Runtime DLL
remains ef36af51b520a6402755af84de32298492842b31c0426312ffeebf9b61c04361.
README and English/Chinese API docs now reflect the verified Windows scope.

All Windows build/test/debug sessions from this continuation are terminal.
Remaining immediate work is the common GL regression and corrected protocol /
new native ABI test on Linux, then remaining platform/feature gates. Unicode
Windows DLL/project environment paths still need a node-level test: Windows
CRT getenv uses the local code page, while the bridge expects UTF-8. The
independent WGL runtime's Chinese project test does not prove this host path.
The full objective remains active; Android/iOS/Web, Linux x64 GPU and other
feature/distribution gates are still unfinished.

VM handoff after Windows acceptance: no Dora/xmake processes remained, verified
normal and test executable paths are distinct and test SHA stayed 485903af... .
Windows 11 gracefully suspended (43853 terminal success) to preserve its owned
checkout and release host memory. Ubuntu ARM64 resume/start dispatched next;
check its live handle/status before launching any duplicate start operation.
Xcode first-launch process 87688 / session 44503 was last observed live, with no
simulator result; it remains independent from these VM tests.

Next continuation handoff: Windows VM is suspended and Ubuntu ARM64 is currently
resuming (confirmed via prlctl list); live start session 18508 must be polled,
not restarted. A guest path inventory failed because the agent is not ready;
no Linux build/test was started. Prepared and shell-syntax-checked owned host
script build/godot-runtime/post-windows-linux.sh. Once guest execution works,
first verify /tmp/dora-godot-gl/build/xmake/bin/xmake, existing Linux runtime
package, and /media/psf/Home/Workspace/Dora-SSR shared source. Then execute it via
prlctl exec Ubuntu ARM64 /bin/bash /media/psf/Home/Workspace/Dora-SSR/build/godot-runtime/post-windows-linux.sh.
It updates only task-owned common bgfx/test files, builds the test host, runs
corrected CPU protocol and native ABI / imported-PCK GPU checks with isolated
Weston, builds ordinary Dora, then copies actual reports to host
build/godot-runtime/post-windows-linux. Preserve its live handle if yielded.
No Linux pass should be inferred from script preparation alone.

## macOS regression and Windows Unicode implementation (2026-10-28)

Previous turn: progress (Windows native source/PCK GPU acceptance and ordinary
build), ending in verified Ubuntu resume wait. This turn re-polled the same
18508 handle; Ubuntu remains resuming. prlctl process 89859 and VM process 89860
are live. No restart/reset was issued. Read-only sampling captured the VM state
machine waiting and a dev.sata.0 thread blocked in open(), with resident 6GB.
Virtual CD is already disconnected; no media/hardware change was made. The
sample does not establish a permission/lock cause. Evidence:
build/godot-runtime/ubuntu-resume.sample.txt. No Linux regression has started.

Independent macOS current-source test 56331 passed: runtime build + native node,
59 preboot ABI checks, 720 frames / 8 captures, animation/pause/input/lifecycle,
GPU completions 444/444 and 208/208, errors 0. Actual artifacts:
build/godot-runtime/post-windows-macos/verification.json and its abi-preboot
report. Normal macOS build 29850 passed afterward. These cover the common bgfx
readback guard and portable test-harness changes, not the Windows-only branch.

Implemented Windows Unicode environment-path handling in GodotRuntimeGL.cpp:
read DORA_GODOT_LIBRARY directly with GetEnvironmentVariableW, then LoadLibraryW;
only the asset-root fallback converts the engine's UTF-8 path. Empty/unreadable
or concurrently resized environment values fail with a diagnostic. The test
harness reads project/output/Wasm paths from the native Unicode environment and
uses filesystem::u8path for output creation. No CRT locale or system policy was
changed. Microsoft owning API docs distinguish the CRT multibyte environment
from the OS Unicode API; links recorded in README. This is source implementation
only: no Windows compilation/GPU pass exists for the new path handling yet.

Added tests/unicode_windows.py: actual opt-in Windows node driver for Unicode
DLL, project + capture, and optional imported-PCK + capture paths (Chinese and
non-ACP emoji). Each case runs test_windows.py's 720-frame/image/GPU checks in a
new process. Metadata records whether the PCK case ran; no pass is written on
failure. CLI --help, AST parsing and diff checks passed; these are not Windows
execution. Run all three with the staged fixture after restoring Windows and
rebuilding loader/test units. Baseline reports and binaries retain their SHA
and remain separate evidence.

Updated build/godot-runtime/post-windows-linux.sh to sync the changed loader and
portable harness too. Once Ubuntu resume 18508 completes, verify owned paths and
run that script. It will do the new EGL ABI checks, corrected CPU boot queue,
imported-PCK GPU regression and normal build. Do not count its preparation as a
Linux pass. Windows VM is still suspended. Xcode first-launch session 44503 /
PID 87688 was last observed live; no simulator result was obtained.

Audio driver/host mixer and texture-alias ownership were investigated, but no
implementation or pass is claimed for either. Remaining original platform and
feature gates remain active; full integration is not complete.

## Report failure handling and extended Metal run (2026-10-28)

Previous goal turn: verified wait (original Ubuntu resume processes 89859/89860
confirmed live), plus inspection of existing GPU reports; it did not add a new
GPU pass. This continuation changes test failure handling and starts a longer
actual run, while keeping the full platform objective active.

Standalone node/probe screenshot verifiers now remove an old verification.json
before inspecting evidence. The probe launcher removes it before dependency
preparation/build too, so build failures cannot retain an earlier PASS. Added
tests/verifier_failures.py; all four missing/error-log cases passed on macOS.
These test report failure handling only. Existing macOS node 720-frame evidence
and the 1200-frame double-buffer pressure evidence were rechecked successfully
with the changed verifiers; this recheck is not a new GPU execution.

Removed duplicate render-boot compile/execution in protocol.sh. Corrected CPU
suite passed again on macOS: C ABI, boot ordering and 100000-frame schedules for
each of 2/3/4 buffers. No GPU claim is made for that suite.

Extended Metal run dispatched: exec session 85468, three buffers, 36000 requested
consumer frames, Metal API Validation, normal CPU frame limiter. Output:
build/godot-metal-probe/soak-36000; launcher log is its sibling
soak-36000-launcher.log. Native Dora PID 91321 and launcher Python PID 91320
confirmed live; animation capture at frame 1200 succeeded. This run is pending,
not a pass. Poll the existing handle; after terminal success run
python3 Tools/LibGodotMetalProbe/verify_outputs.py build/godot-metal-probe/soak-36000.
The probe build changed the optional host build selection; restore ordinary
Dora build only after this run is finished, not while it is running.

Ubuntu original start session 18508 remains live/resuming, not restarted. Disk
metadata was readable and showed the normal hdd container/files; that does not
establish the reason the resume is slow. Windows resume dispatched once as
session 79384, prlctl PID 91098 and VM PID 91102; currently resuming too.
Both VM logs reached loading application data. Do not duplicate either start.

Prepared syntax-checked build/godot-windows/run-unicode-regression.py (scratch,
not run): copies only listed changed task files into the owned guest checkout,
uses native ARM64 xmake to rebuild the x64 opt-in host, records host/source SHA,
runs all three Unicode native GPU cases, then copies results to the host.
After Windows is ready, run its owned venv Python directly with the script at
\\Mac\Home\Workspace\Dora-SSR\build\godot-windows\run-unicode-regression.py via
prlctl exec --current-user. It does not execute a PowerShell script or alter
execution policy. Unicode compilation/runtime acceptance remains pending.

## Extended Metal acceptance and initial host audio integration (2026-10-28)

Previous goal turn: progress (report failure handling, CPU protocol correction,
extended native run dispatched). This turn is progress: the extended run
completed, and an actual Godot -> host audio callback path was implemented/tested.

Metal soak session 85468 / Dora PID 91321 completed successfully. Actual report:
build/godot-metal-probe/soak-36000/verification.json. Three buffers, 36000 consumer
frames, 35875 produced/completed, all waits/signals/consumers completed, GPU
errors 0, tickets 0, 122 exact screenshot frame stamps. Metal API Validation was
enabled. About ten minutes of native execution; this is finite local evidence,
not proof of device-loss recovery or other-platform execution.

Added optional versioned GodotBridgeAudio.h table; graphics ABI stays unchanged.
New runtime builds select a threadless 48000-Hz stereo Dummy audio driver before
Main::setup. PCM pulls are owner/render-thread calls, bounded to 4096 frames,
without opening another audio device. Both native module backends implement it;
only the macOS implementation has been compiled and executed so far.

Added GodotAudioStream using the existing Dora SoLoud mixer and an 8192-frame
SPSC queue. Render-thread pulls maintain a 4096-frame prebuffer; the host audio
callback only reads/zero-fills bounded preallocated memory and never calls Godot.
It remains alive on underrun. Logic-thread stop destroys the SoLoud source while
the mixer is alive; a retained active session lets final render-thread shutdown
report audio accounting even if the normal close callback is no longer serviced.
Older optional DLLs without the extension keep their existing silent behavior.
Legacy C# host project also registers the new C++ unit; its build is pending.

Actual failures were retained/fixed, not accepted:
- Overlapping GUI launch was rejected by Dora single-instance handling while the
  soak was still running. Log: audio-single-instance-rejection.log. Tests are now
  serial; no single-instance bypass was added.
- First real audio run delivered PCM but had underruns and a Godot ObjectDB exit
  leak. Evidence: node-audio-macos-before-fixes. Increased prebuffer, corrected
  test capture handling, retained final session accounting, and patched prepared
  Godot Main::cleanup to mix final fade-outs / service AudioServer deferred frees
  after SceneTree deletion, while audio/server/script state still exists.
- Registered the source voice with Dora Audio's ownership map to remove unknown
  voice-end cleanup warnings and preserve host stopAll behavior.

Final actual native acceptance: session 27545 terminal pass, report
build/godot-runtime/node-audio-macos-final/verification.json. 720 frames / 8 PNG,
animation/pause/input/restart/remove/recreate passed; GPU 443/443 + 208/208,
errors 0. Both node lifetimes captured a full 48000-frame stereo second from the
actual SoLoud source callback: positive crossings 440/660 in each. Audio consumed
359424 and 167424 frames, underruns 0 for both; produced 363520 and 169472.
No Godot ObjectDB leak warning. This proves Godot PCM delivery to the host mixer
callback, not physical speaker audibility or final-device loopback measurement.
The report explicitly records audio_device_audibility_tested=false.

The verifier now rejects any source underrun for this reference test. Rechecked
the final real evidence with that stricter rule. A temporary copy of the actual
evidence with underrunFrames changed to 1 was rejected and its stale PASS report
removed. No synthetic fixture was published as GPU/audio acceptance.

Other current validation:
- Native macOS shared runtime compiled; 103 actual preboot ABI checks passed,
  including the audio extension and canaries. No engine/GPU boot in that child.
- SPSC tests passed 300000 stereo frames, bounded-full behavior, planar strides,
  silence and repeated ring reuse; ThreadSanitizer run passed with no report.
- C audio/graphics ABI headers compiled for Windows/Linux/Android/iOS/Web targets;
  header compilation alone does not prove those platform runtimes.
- Normal macOS build session 34850 passed (audio-normal-build.log), with no
  optional node/probe entry enabled. All macOS jobs this turn are terminal.

Ubuntu resume 18508 (PIDs 89859/89860) and Windows resume 79384 (91098/91102)
were still live/resuming at the final check. No reset or duplicate start was
issued. Xcode first-launch PID 87688 remains independent/pending. Poll the same
handles before guest work; a timeout is not a terminal VM result.

Updated the prepared Linux regression script to sync the new audio source/header,
module/prepare files, rebuild the runtime, then run imported-PCK graphics and
source-folder audio cases serially under separate isolated Weston runs, followed
by a normal build. The Windows Unicode scratch driver now syncs the audio host
unit/manifest too (it may still use the old silent DLL for Unicode-only checks).
These scripts are prepared, not executed. Native GL audio compilation/runtime,
Windows Unicode acceptance, original mobile/Web targets, resize, recovery,
controller/IME, .NET host execution and distribution remain open. Goal is active.

## Retained texture aliases, GL ABI 2 and resumed desktop validation (2026-10-28)

Previous goal turn: progress (extended Metal acceptance and initial host audio).
This turn adds actual GPU alias ownership protection and multi-platform evidence.
The full objective is still active, not complete.

GodotNode.texture could previously be retained by another Sprite while the
producer only tracked the source node's current slot. Added render-owned
GodotGpuReads: each actual bgfx frame waits on all published slot sequences and
signals last consumption for every slot, independently of node update tickets.
Both native backends use this ledger. A slot reference is mutable ring storage,
not an immutable screenshot. Metal imports retain textures after client removal;
the GL transport keeps its shared objects across same-project client recreation.

Actual failures drove fixes:
- Initial all-slot checks waited on the newest consumer fence before it had
  been submitted; production nearly stopped. Logs retained in
  node-readers-before-submit-fix and node-readers-before-ready-gate.
- Added render-thread bgfx::submitNativeFrame(), calling Context::flip through
  its existing m_flipped bookkeeping, outside native callbacks. It does not
  double-present. Metal queries previous producer readiness before advancing;
  its new blit waits for the target's last submitted consumer on the GPU.
- GL's strict latest-consumer CPU query still starved on WGL (17/24 cumulative
  productions). Early presentation recovered Linux but not WGL. Added GL ABI 2:
  can_advance queries previous producer completion and validates the target's
  submitted reader; advance_async queues glWaitSync for that reader. The old
  synchronous functions and ABI-1 prefix getter remain available. Primary
  graphics ABI and audio ABI stay at 1. Current host requires GL extension 2.
- Adding a test buffer-count global initially hit Dora's strict Lua globals.
  Corrected the harness to rawset its private global, as for the project path.
  This was a test-harness failure; no production Lua restriction was bypassed.

macOS native acceptance:
- 2/3/4 buffer cases each passed 720 controller frames, 9 captures, distinct
  retained slot aliases, animation/pause and an orphan-alias capture after source
  removal. 81 top/bottom barcode comparisons agree. Total 2160 controller frames
  and 1992 active host GPU frames, all completed; GPU errors/pending readers 0.
- Source callbacks also passed 440/660-Hz stereo audio with zero underruns.
- Aggregate: build/godot-runtime/alias-matrix-macos.json; individual reports in
  node-aliases-{two-,four-}macos and node-aliases-macos. Orphan PNG was viewed:
  three retained cubes remain at the left and the original center is blank.
- CPU ledger suite passed 100000 schedules per 2/3/4 slots. ABI headers compiled
  for Windows/Linux/Android/iOS/Web. These CPU/header tests are not GPU evidence.
- Ordinary macOS builds passed, including latest common Metal/GL presentation
  helper (gl-present-macos-normal-build.log). All macOS jobs are terminal.

Both original VM resumes finally completed without resets/restarts. Ubuntu and
Windows are now running. The old start PIDs disappeared; existing guest paths
and the Windows task-owner marker were checked before mutation. Do not treat
them as still resuming. The independent Xcode first-launch PID 87688 remains
unresolved; do not dispatch another first-launch merely because it is slow.

Linux ARM64 / virgl:
- Full new runtime and native host compiled; 147 real preboot ABI checks passed,
  including GL ABI 2, legacy ABI-1 prefix/canaries, and audio extension guards.
- Imported PCK GPU test passed 720/8: cumulative productions 225 then 332, all
  completed, errors 0, imported texture/premultiplied alpha/additive checks pass.
  Host copy: build/godot-runtime/post-windows-linux/node-pck/verification.json.
- Source-folder run completed 720/9 with three aliases and 27 matching barcode
  samples. Its GPU-only verifier passed; explicit separate report:
  build/godot-runtime/linux-gl2-alias-graphics-only/verification.json.
  audio_acceptance_passed=false is recorded, not hidden.
- Audio gate failed with 1024 first-client underrun frames (earlier GL-1 run had
  3584/512). Rendering/scene work can starve the render-thread PCM pump. Keep the
  zero-underrun requirement; decouple safe Godot-side audio production from
  render scheduling rather than weakening the verifier. No thread/ABI redesign
  has been implemented for that yet. The native Dummy mixing thread is an owning
  source to investigate. Host callbacks must remain free of Godot VM calls, and
  be quiesced before native audio teardown.
- Full-script sessions 37989, 84262 and 47547 are terminal failures due to their
  stated gates. Last run's actual files were copied to the host even on failure.
  Historical guest directories post-windows-linux-before-flip and
  post-windows-linux-gl1-present retain earlier failures. Linux ordinary build
  after GL2 passed via session 1810; log copied to post-windows-linux/normal-build.log.

Windows 11 ARM64 / x64 emulated binaries / Parallels OpenGL 3.3:
- Original DLL-path case loaded the Unicode DLL but failed graphics freshness
  with GL ABI 1. Evidence: unicode-before-gl-flip and launcher logs; not a pass.
- Built new full WGL runtime in existing Ubuntu MinGW cache (session 75077,
  terminal success). Preserved the legacy bin/godot.dll under legacy-bin before
  rebuilding the canonical output. New host package gl2-package/dora_godot.dll
  SHA256 cf712dd580dfc0dc891e87833115905f910bd46b3cbb318a99de85598090bfd4.
  Cross-build compilation.json still says gpu_tested=false; real native evidence
  is separate below. Old baseline package/DLL remains intact on the host.
- Native MSVC x64 host rebuilt; session 21833 passed all three Unicode cases
  (Chinese + emoji DLL, project/capture, PCK/capture): 2160 frames, 24 PNG, GPU 0.
  Each child passed 147 native preboot checks against the actual new DLL. Native
  cumulative GPU counts: DLL 291/448, project 291/434, PCK 272/383; do not sum
  snapshots within a process. Report: build/godot-windows/unicode-results/verification.json.
- Session 96732 passed actual WGL aliases: 720/9, three distinct slot references,
  27 agreeing barcode samples, source removal, GPU readers fully completed;
  cumulative productions 239 then 344, errors 0. Host report/captures copied to
  build/godot-windows/alias-gl2-results. This case did not request audio acceptance.
- The Unicode scratch driver now requires explicit --library, e.g. the shared
  gl2-package DLL; do not silently reuse the old Temp DLL for current GL ABI 2.
- Final ordinary Windows build session 46840 completed successfully; its logs
  normal-gl2-launcher.log and normal-gl2-build.log are on the host. All current
  desktop builds/tests are terminal. Both VMs are running for continued work.

Next: address Linux audio scheduling,
then remaining mobile/Web backends, resize/recovery/input/.NET/distribution gates.
No full-goal completion is claimed by the desktop GPU progress.


## Dedicated PCM worker, audio ABI 2 (2026-10-28)

- Audio now uses a Godot-registered Thread producing into the bounded SPSC ring,
  demand-paced to Dora's single mixer consumer. No device is opened by Godot.
  The mixer callback only calls the ABI ring-copy routine, never the Godot VM or
  mixer. Partial reads are zero-filled by the host. Both endpoints stop before
  runtime close, which joins the worker before scene/audio teardown.
- Audio ABI 2 adds start_capture/get_stats; deploy a matching runtime and host.
  Base graphics ABI remains 1 and queued GL extension remains 2.
- Removed rendering-frame PCM pumping. Owner primes 4096 frames after the
  requested preboot pause, then the registered worker maintains that target.
- Added opt-in 250 ms render stalls at controller frames 320 and 610, with
  verifier --audio-stall requiring both markers and zero host-source underruns.
- Actual desktop regressions passed: macOS 2/3/4 slots, each720 frames/9 PNG;
  Linux ARM64 EGL 720/9; Windows11 ARM64 emulated x64 WGL720/9. All GPU
  readers completed with zero errors; audio tones440/660 and zero underruns.
  Reports: node-audio2-{two-,four-}macos (default node-audio2-macos),
  audio2-linux/node-audio, and build/godot-windows/audio2-results.
  Linux source images were reverified on the host with --audio-stall after
  observing both actual stall markers (the original guest test wrapper omitted
  this verifier flag); host-verifier.log preserves that output.
- Linux imported PCK720/8 and ordinary build also passed with the new ABI2
  runtime. This fixes the measured render-pump starvation in that regression;
  physical audio-device output, arbitrary workloads and other platforms remain
  outside this evidence.
- Audio queue concurrent test exercises both planar/interleaved reads across
  300000 stereo frames, untouched partial-read guards and quiescent reset;
  macOS ThreadSanitizer run passed. CPU protocol/verifier negative tests passed.
- Added optional soak frames (0..36000 in multiples of300), sampling every300;
  formal macOS12000-frame soak passed:12720 controller frames,12603 GPU
  produced/completed,40 soak PNG,147 agreeing alias stamp pairs, all GPU
  readers drained and zero errors/underruns. Report node-audio2-soak-macos.
  Mobile/Web and the remaining full-goal gates are pending. No commits or
  publication made.

- Post-cleanup ordinary Linux build initially found a missing explicit <atomic>
  include after the queue header was removed from the host PCM source. Added
  <atomic>/<algorithm>; ordinary Linux and Windows builds passed afterward.
  Desktop result index: build/godot-runtime/audio2-desktop.json. Ordinary macOS
  build also passed after the soak (normal-audio2-macos-build.log). All jobs
  from this iteration are terminal; no runtime/simulator reset was issued.


## Metal viewport generation replacement (2026-10-28)

The previous goal turn was progress: audio ABI2 worker, native desktop tests
and a12720-frame formal Metal node soak yielded authoritative new evidence.
This turn adds an optional viewport ABI1 without changing base ABI1, audio2,
or GL2. The Metal library exports owner-thread resize; unsupported/old runtimes
retain fixed-size operation. GL resizing is not implemented in this iteration.

- C++/Lua resizeViewport(width,height) accepts one asynchronous request while
  ready; invalid/busy requests returnfalse. viewportSize commits with the new
  texture. Same-size requests succeed without allocation. Lua/Teal/TS types
  and English/Chinese class docs updated. Other native bindings still pending.
- Host stops node publication and invalidates queued generation callbacks,
  allocates wrappers, waits for their actual bgfx resource commands, then
  dispatches the resize between host frames. Flush/drain consumer GPU work,
  drain producer work, replace native textures/events, query slots, import,
  produce first frame, publish new dimensions and restart the logic frame ring.
- The render-reader ledger preserves aggregate counters and monotonic sequence
  and host-frame checks across replacement. New events begin with no consumed
  host frame. Production/simulation counters and SceneTree/autoload/pause/audio
  worker continue. Existing alias textures are immutable after replacement and
  retained by bgfx's Metal wrapper; no unbounded retired-generation list.
- Native ABI preboot138 guards and shared protocol tests pass. Concurrent
  production/publication cancellation uses an atomic generation plus closing
  flag; test removes a node immediately after an accepted resize request.
- Actual Metal Lua tests passed at2/3 buffers, each1000 frames/15 PNG:
  800x450 ->320x180 while paused ->640x360,30 corner/bounds samples per case,
  unchanged paused capture, changed resumed scene, retained aliases, cancellation
  and subsequent recreation. Scene boots remain3. All GPU work complete, no
  GPU errors or PCM underruns. Three-buffer case also injects two250ms stalls.
  Reports node-resize-two-macos and node-resize-three-macos.
- Earlier scratch tests node-resize-macos / node-resize-lua-macos failed their
  fixture gates: corner was obscured by a barcode, then a proposed higher z
  exceeded Godot's canvas maximum. Fixed fixture by using probe4096/stamp4095.
  Failed outputs preserved; no pass is claimed for those directories.
- Ordinary Linux and Windows builds passed with new C++/Lua API and unsupported
  default GL resize. Logs: audio2-linux/normal-viewport-build.log and
  build/godot-windows/normal-viewport-build.log. These are compilation evidence,
  not proof of GL dynamic resize. Four-buffer Metal test also passed1000/15,
  including cancellation and injected render stalls. Matrix result is
  build/godot-runtime/viewport-macos-matrix.json (3000 controller frames,
  45PNG,135 agreeing alias stamp pairs,90 corner/bounds samples,2743 GPU
  images all completed, zero errors/underruns). Ordinary macOS build passed
  (normal-viewport-macos-build.log). All jobs in this iteration are terminal.
  Full goal stays active.

- Follow-up gates: GL viewport texture ownership/release handshake (Metal relies
  on bgfx retaining immutable old textures; GL currently borrows texture names),
  remaining native-language resize bindings, scene-driven size changes,
  device recovery and mobile/Web runtime integration. Audit active-node
  reservation ownership on failed creation too: close() currently clears the
  global reservation even for a session whose start() never acquired it.
  This finding is not yet a verified/fixed duplicate-node regression.


## Failed node initialization / runtime reservation (2026-10-28)

Previous goal turn was progress (Metal viewport API and actual2/3/4 GPU tests).
This turn checked the previously noted reservation concern against native state.
A probe-only baseline passed: node-reservation-before-fix-macos. That baseline
was insufficient: Node construction registers a retained unmanaged node with
Director, so init failure can return nullptr without destroying the node.
A stronger native test counted the scene tree and failed before the fix:
node-reservation-tree-before-fix-macos shows4 nodes at stage115 and6 at575,
where only the single original node should exist. Its process exited2; no PASS
report was published. Preserve both baselines; do not treat probe-only PASS as
proof of failed-node cleanup.

- Added GodotNode init scope cleanup for every false return: setAsManaged() to
  stop automatic adoption, then cleanup its partial session and weak references.
  Do not modify Director/Object or the user's unrelated Model3D work.
- Metal/GL sessions record whether start actually acquired clientReserved.
  Nonowners close without posting native teardown or releasing another client.
  This is essential once failed nodes are promptly cleaned up.
- Five competing creates at stages0/100/110/560/570 must all returnnullptr.
  Tree traversals at115/575 must find only the original GodotNode, independent
  of UI/entry root overlap. Original scene boots remain3; active node continues,
  then real removal releases ownership and permits normal recreation.
- Native macOS Metal1000/15 passed including resize, cancellation, aliases,
  two250ms render stalls and audio. Linux ARM64 EGL720/9 and Windows11 ARM64
  emulated x64 WGL720/9 also passed with five probes, scene absence, zero GPU
  errors and zero PCM underruns. Three actual reports indexed in
  build/godot-runtime/reservation-desktop.json. Windows host-build.json includes
  hashes of the actual staged Node.cpp and host binary; Node.cpp hash matches
  the current host source. Linux/Windows GPU counters are cumulative snapshots.
- reservation_verifier_failures.py used each real passing dataset in turn:
  accepted competitor, adopted failed node, missing probe, missing tree check
  all fail verification and delete a seeded stale PASS (12 negative checks
  total across3 datasets). These checks launch no GPU work themselves.
- Ordinary macOS, Linux and Windows builds passed. All jobs from this
  iteration are terminal. No commits/publication. No VM
  reset/restart was issued for transient prlctl observation errors.
- Next gates remain GL viewport ownership/release, other resize bindings,
  scene-driven size changes, device recovery and mobile/Web integration.
  Full goal remains active; desktop lifecycle evidence does not prove them.


## Host-owned GL targets / viewport resizing (2026-10-28, desktop verified)

The previous goal turn was progress (failed-node cleanup and native desktop
reservation regressions). This turn implements GL resizing with a different
resource ownership contract from the Metal bridge:
- New optional GL targets ABI1 binds host-owned shared RGBA8 texture names.
  bgfx getNativeTexture() is a read-only render-thread query; no internal
  ownership flag is changed. Dora holds raw handles before publication and
  Texture2D refs afterwards. Godot borrows targets and never deletes them.
- Initial boot uses host textures too. Legacy libraries without this extension
  retain the old imported fixed-size path; base ABI1/GL2/audio2 remain unchanged.
  Existing legacy native clients can still use library-owned initial slots.
- EGL/WGL share bind/clear logic. Validate count, nonzero/distinct names,
  glIsTexture and renderable normalized8-bit RGBA attachments without requiring
  GLES3.1 texture-level queries. Exact dimensions are the trusted host contract.
  Drain first, detach FBOs/delete old fences, delete only native-owned textures,
  replace borrowed targets, preserve production/completion counters.
- Real Godot Window resize redraws and refreshes the source handle, preserving
  scene/autoload/pause/audio. Host cancels stale publications by generation,
  waits for bgfx resource creation, submits/drains between actual frames,
  rebinds targets, seeds the first image and publishes new dimensions.
- Native client close clears borrowed targets; old Sprite aliases retain their
  owned textures independently of the Godot transport. Reopen can change pixel
  dimensions on the same project/buffer count after host-owned target mode.
- Shared EGL ownership test passed on actual virgl / OpenGL ES3.0:2/3/4 slots,
  64->96->32 sizes,54 exact pixel samples; old targets survive replacement,
  clear and transport destruction. Invalid null/count/duplicate/zero targets
  rejected. Report build/godot-runtime/gl-host-targets/verification.json.
- Legacy EGL path passed3600 consumer frames/99 samples on the changed native
  code, no GPU errors. Report gl-legacy-after-targets/verification.json.
- macOS Metal regression passed1000/15 with resize/cancel/reservation/aliases/
  audio/stalls, all GPU work completed and zero errors/underruns; report
  node-targets-metal-regression. This tests the new common bgfx API declaration
  did not disturb the existing Metal path; it does not prove GL resizing.
- Linux ARM64 actual GodotNode3-buffer GL resizing passed1000/15,30 corner/bounds
  samples,45 alias stamp pairs, two render stalls, five rejected competitors,
  zero GPU errors/underruns. Native preboot182 guards include GL targets ABI.
  Host results targets-linux/node-audio; native source RuntimeGL also includes
  explicit glFlush before producer bind. Linux ordinary build passed.
- Linux2/4 actual node cases running (session69386); Windows full runtime DLL
  compiled in existing MinGW cache, staged targets-package, actual native host
  still rebuilding on Windows (session77286; xmakePID6524, compiler processes
  observed live). Public header change causes a broad rebuild. No dispatch
  restarted because of transient prlctl observer failures. Mac ordinary build
  running (session as returned by exec). No Windows GPU pass is claimed yet.
- User confirmed Mac unlocked; the earlier unlock question is resolved.
  No reset/restart was issued. Full goal remains active; remaining bindings,
  source-driven size changes/stretch handling, recovery and mobile/Web remain.


### GL targets final acceptance

- Actual Linux ARM64 EGL and Windows11 ARM64/emulated x64 WGL each passed
  2/3/4 buffers,1000 frames/15PNG per case. Three-buffer initial WGL report is
  targets-results; the final stronger native matrix is targets-stamps-results.
  Linux final cases are targets-stamps-linux/node-{2,3,4}.
- Full matrix also includes a Metal4 regression on the new common bgfx query.
  In total7 cases:7000 controller frames,105 PNG,330 retained-alias barcode
  pairs,42 active resized-texture barcode pairs and210 corner/bounds samples.
  All GPU producer/read work completed; no GPU errors or host audio underruns.
  Each case retains scene/pause/audio, cancels a resize on node removal,
  recreates the node, rejects five competitors and injects two250ms stalls.
- AliasStamp now redraws on viewport size_changed, even during pause, and places
  both rows relative to current dimensions. This checks the active small image,
  in addition to immutable prior-generation aliases. Four-buffer resize tiles
  use scale0.20/margin70 to avoid large-viewport corner occlusion in1280px
  windows; other cases keep0.25/120. Verifier parses actual scale and retains
  original color/torn-frame thresholds. Preserved failed occluded capture under
  targets-linux/node-4-occluded; no pass is claimed for that directory.
- Final host verification reuses the actual native captures and also compares
  central3D crops excluding the barcode rows. All7 cases show real cube motion
  after resize/resume (small changed pixels1206..3543). host-final-verifier.log
  records these stronger checks; no runtime rerun was needed for an oracle-only
  change. The original Windows native-source provenance matches current GL
  runtime/bgfx/fixture sources; final Python verifier has the later crop check.
- Final index: build/godot-runtime/gl-targets-desktop.json. Ordinary macOS,
  Linux and Windows builds all passed; their logs are linked in that index.
  All iteration jobs are terminal. Xcode first-launchPID87688 was checked live
  at3h20m elapsed; no restart was issued. It is not simulator acceptance.
- Updated API docs/type comments: fixed-size legacy libraries remain usable;
  resizing needs Metal viewport ABI1 or GL host-targets ABI1. No ABI version
  change to base1, GL2 or audio2. Native language resize bindings, source-driven
  resize/stretch/input transitions, device recovery and mobile/Web integration
  remain completion gates. Full goal remains active.

- Timing follow-up to audit before completion: both native draw() helpers still
  pass a fixed1/60 render step after each manually driven Godot iteration.
  Check shader TIME/particle progression against Main/Engine timing when the
  GPU producer runs slower than the host; cube rotation tests alone do not
  prove material-time parity. No timing bug/fix is claimed until measured.


## Render-time handoff and actual shader clock parity (2026-10-28)

Previous goal turn was progress (GL targets/resize and native desktop matrices).
Audited pinned Main.cpp: scaled_step is computed using effective_time_scale
before the physics catch-up cap. Both RD and GLES rasterizers accumulate this
render step into shader time. The bridge previously passed fixed1/60 to each
manual draw and did not increment Engine.frames_drawn. Main could also draw
pending RD resources automatically despite the disabled render loop.

- Before-fix native Metal test really failed: normal sampled interval GPU29/64
  seconds versus script136/64 seconds; frames_drawn stayed1. Raw13 PNG/logs
  preserved in timing-before-fix-macos; no PASS report published.
- prepare.py now adds an idempotent Main timing hook for dora-metal/dora-gl
  only: enqueue the original scaled render step and suppress the automatic
  pending-resource draw for these manually rendered displays. Other Godot
  displays retain upstream behavior. Module draw consumes the accumulated step
  once, uses0 for redraws without iteration, and increments frames_drawn.
  Client close resets any leftover step. Base/GL/audio/viewport ABIs unchanged.
- runtime_timing.h is owner-thread-only; no Godot mixer/GPU thread touches its
  pending scalar. CPU protocol tests cover consumption/reset/zero redraw, but
  actual acceptance uses GPU pixels, not these counters.
- New timing_project encodes shader TIME and an independent GDScript delta sum
  into two16-bit barcode rows at64Hz; _process deliberately sleeps60ms. Its
  process mode is Always and max_physics_steps_per_frame64 isolates catch-up
  clipping. Controller samples scales1/.25/2/0, SceneTree pause, frozen resize
  to800x450 and back640x360, and resume;1000 frames/13PNG per process.
- Actual Metal, Linux ARM64 EGL/virgl and Windows11 ARM64/emulated x64 WGL each
  passed. Every sampled code stayed aligned (max relative drift0 ticks at64Hz),
  including scale transitions; shader time froze through resize at scale0,
  advanced during SceneTree pause as Godot specifies, and frames_drawn advanced.
  timing-desktop.json indexes39 actual PNG over3000 controller frames.
- Current host verifier rechecked all3 datasets including scale/pause metadata
  and cross-transition relative drift. Host-verifier.log preserves output when
  the native guest used the earlier verifier revision. This is oracle-only
  strengthening on actual captures, not synthetic GPU output.
- timing_verifier_failures.py rejects the actual pre-fix dataset and two mutated
  metadata cases, deleting seeded stale PASS files; generic verifier_failures
  also includes the timing verifier (6 missing/error cases). No GPU launched by
  these negative checks. Source prepare.py compiles twice idempotently in builds.
- Full1000/15 node regressions with resize/cancel/aliases/reservation/input/audio
  and render stalls passed on all3 desktops using new runtime libraries. All
  GPU work completed with zero errors/underruns. Ordinary macOS/Linux builds
  passed; ordinary Windows build also passed. All iteration jobs are terminal.
  These regressions are separate
  from the shader clock test and do not claim particle/mobile/recovery coverage.
- Remaining full-goal gates still include other language resize bindings,
  source-driven resize/stretch/input transitions, particle-specific acceptance,
  device recovery and mobile/Web. No completion, commit or publication claimed.

- Exact artifact audit: Linux/Windows timing and full regressions already share
  identical library hashes. macOS two builds differed, so preserved a byte-for-
  byte copy of the full-regression dylib (timing-verified-full-macos.dylib),
  rebuilt only the host, and ran another actual1000/13 clock test against it.
  timing-same-library-macos passed with0 relative ticks drift. The final index
  uses this case; all3 timing/lifecycle library hash pairs now match. Original
  timing-fixed-macos remains supplementary evidence. No cause for the differing
  prior build hash is inferred. Ordinary macOS host rebuild after this extra
  test passed; no runtime recompilation was needed for the exact-copy test.
  All jobs from this iteration are terminal.

## Rust/Wa viewport binding runtime validation (2026-10-28)

- Added committed viewportSize and asynchronous resizeViewport to both owning
  binding IDLs. The generators emitted C ABI/Wasm3, Rust, Wa and C# APIs.
  bindings/generate.py runs the generators in an isolated build directory,
  removes old target outputs first, and publishes only four GodotNode files;
  unrelated generated bindings and Model3D work remain untouched.
- All Rust/Wa fixtures and the entire C# binding assembly compiled; C# had
  zero warnings/errors. Compilation does not count as C# native runtime coverage.
- The actual Rust/Wa modules call the generated size getter and resize method
  through Wasm3. Both macOS Metal and Linux ARM64 EGL/virgl passed: four cases,
  4000 controller frames, 60 real GPU screenshots, fixed three-buffer transport.
  Covered 800x450, paused 320x180, resumed 640x360, busy/invalid rejection,
  same-size no-op, and accepted resize canceled by node removal. Existing
  animation/input/restart/recreation, five reservation probes, retained texture
  aliases, audio and two 250ms render stalls were enabled in every case.
- GPU producer/completion totals matched, all readers drained, zero GPU errors
  and zero audio underruns. Actual device audibility was not tested. Ordinary
  macOS and Linux host builds passed after the opt-in test builds.
- bindings-resize-desktop.json indexes final reports. The original Rust Metal
  run exposed a verifier substring-count collision between verify and
  verify_large. Exact complete-command counting fixed the oracle; its original
  real captures were reverified successfully. A copied actual dataset with
  verify_large removed is rejected and its seeded stale PASS report deleted.
  No synthetic pixels or new GPU execution were used by this negative check.
- README documents generation and resize runner flags; --verify-only now avoids
  modifying the bundle/assets and rechecks both pixels and exact commands.
- Remaining gates include C# native runtime, Windows language resize execution,
  particles, mobile/Web, device recovery, source-driven resize/stretch and full
  input/IME/controller behavior. Overall goal remains active; no commit/PR.
  All jobs from this iteration are terminal.

## C# native host follow-up (2026-10-28, in progress)

- Added Windows opt-in DORA_BUILD_CSHARP_NATIVE=1 shared-library output to xmake,
  preserving the default GUI build. DORA_AS_LIB is scoped to its owning
  Application/WasmRuntime units and test exports, rather than changing unrelated
  engine/vendor compilation. This addresses the old Win32 project versus x64
  Godot runtime mismatch without treating compilation as runtime acceptance.
- Added a test-only reverse P/Invoke factory in the existing native harness and
  a real C# fixture using public App.Run, generated GodotNode APIs, global events
  and a DLL resolver pointing at the exact built library. Managed failures exit
  nonzero rather than unwinding across native callbacks. C# fixture/all binding
  units compile with zero warnings/errors on the host.
- run_csharp.py stages assets, requires real 1000-frame/15-capture Windows WGL
  acceptance with resize/cancel/aliases/reservation/input/audio/stalls, checks
  complete command counts, records DLL/fixture hashes and removes stale PASS
  reports on any failure. README includes reproducible Windows commands.
- Latest macOS Rust/Wasm3 regression using the modified harness passed1000/15
  with all the above flags; ordinary macOS rebuild passed afterwards. Reports:
  build/godot-bindings-csharp/macos-wasm-regression/node-rust/verification.json.
- Windows has .NET8 SDKs but its x64 host only had runtime6. Downloaded official
  .NET8 x64 runtime ZIP, checked its release-metadata SHA512, extracted only to
  this task's C:\DoraGodotNative-01a17dc1\dotnet-x64-8; --list-runtimes confirms8.
  No machine-wide runtime installation. Windows native DLL build remains live;
  no C# runtime/GPU PASS exists yet. Continue the existing job; do not start a
  duplicate or infer failure from an observation timeout. Runtime and ordinary
  build scripts are prepared under build/godot-windows/.
- Old Xcode first-launch PID87688 is now absent. Fresh xcodebuild
  -checkFirstLaunchStatus and simctl list devices available both returned0.
  Simulator inventory is available; this is toolchain readiness, not iOS Godot
  runtime or GPU acceptance. Broad goal remains active; no commit/publication.


## C# and Windows language runtime acceptance (2026-10-28)

Previous turn classified as progress: added Windows Rust/Wa runner and cross-host
module-path handling, with the existing native build still live. Interruption
recovery checked actual processes/logs: the DLL build had finished; the old
functions cell was absent and a Parallels execution error meant the runtime had
not started. Only then was the runtime started, without duplicating a live job.

- Actual .NET execution first rejected the DLL's missing str_new export. The
  portable string/object C ABI lives in RustRuntimeBridge.cpp; added that owner
  to the file-scoped DORA_AS_LIB build configuration. Original failed log and
  artifact hashes are preserved under windows-entrypoint-failure.
- A new independent PE export-table check found seven more import mismatches:
  five legacy optional-object _null helpers and Director SystemUI/clearSystemUI
  spellings. The owning C# generator now passes zero to canonical setters and
  the IDL supplies canonical system_ui/clear_system_ui aliases. Public C# names
  stay unchanged. Isolated generation publishes only GodotNode plus these five
  C# units, preserving other generated/user changes. Repeated owning generation
  reproduces the fixes; unchanged outputs retain timestamps. Failed static
  audit is preserved under windows-export-audit-failure; it is not GPU evidence.
- Actual C# GPU run then exposed overlapping asynchronous capture requests:
  paused-b was rejected and the run recorded14/15,result2. The controller now
  holds scene/pause/size state until the previous readback/PNG callback finishes,
  including the timing harness. No expected image, count or pixel check relaxed.
  Original failed14-capture dataset retained under windows-capture-busy-failure.
- Final DLL shutdown accounting was lost because dedicated logger workers had
  already been canceled while Logger was still resident in DORA_AS_LIB mode.
  Debug.cpp emits logs synchronously once the logic loop has stopped. The
  repeated real C# run now contains complete PCM, producer/completion and reader
  shutdown accounting, rather than inferring success from process exit0.
- Windows x64 public App.Run/generated PInvoke passed actual1000 controller
  frames/15 PNG, three buffers, animation/input/focus/restart/remove/recreate,
  reservation probes, resize/cancel/aliases/audio and render stalls. All1728
  C# imports match2046 actual DLL exported names, zero missing; helper aliases
  and Audio.Listener=null were also called through real PInvoke. Both GPU
  sessions drained, producer totals matched completions, zero errors/underruns.
  Source remains standard Godot (no Mono/Godot C# scripting runtime enabled).
- Rust/Wa Windows Wasm3 executions each also passed1000/15 with the same flags.
  Cross-building modules on macOS now preserves absolute Windows project paths
  lexically. Three Windows language cases used the same Godot DLL hash.
- macOS and Linux Rust/Wasm3 each passed fresh1000/15 regressions for capture
  gating and shutdown logging. Ordinary macOS, Linux and Windows builds all
  passed after test hosts. Build/GPU pipelines from this iteration are terminal.
- Final primary index bindings-resize-desktop.json contains seven recorded
  desktop language cases (7000 controller frames/105 PNG), including earlier
  macOS/Linux Wa cases. It separately points to the two fresh capture/logging
  regressions and each case's artifact manifest where recorded. Previous
  four-case index retained as bindings-resize-desktop-before-csharp.json.
- A copied actual C# dataset with verify_large removed fails exact command
  verification and deletes a seeded stale PASS. No GPU launched for this
  negative check; result under windows-negative-missing-command.
- Remaining full-goal gates include mobile/Web runtime/GPU integration, particle
  acceptance, device recovery, source-driven viewport/stretch/input transitions,
  full IME/controller, Linux x64 GPU and distribution/broader project coverage.
  Native C# host support remains Windows-only. Overall goal is active; no
  completion, commit or publication claimed.


## Actual GPUParticles2D desktop acceptance (2026-10-28)

- Added a real two-emitter scene: custom DELTA particle shader (Always) and
  standard ParticleProcessMaterial (Pausable), each compared with an independent
  CPU-integrated red marker in the final Dora composite. Three 16-bit clock rows
  also check shader TIME, script delta and pausable script delta. Each final
  desktop case ran1000 controller frames/13 PNG with scales1/.25/2/0, pause,
  frozen resize800x450/back640x360, resume and complete GPU drain.
- Found a real stock Godot material-key bug on Metal. Shader-cache lookup failed
  during standard particle material destruction: copied bitfields had different
  padding bytes despite identical logical fields/RID, leaking a shader resource.
  prepare.py now generates a semantic packed key for hash/equality/order. The
  pinned stock source and exact baseline dylib reproduced the failure; the fixed
  noninstrumented library passed. CPU particle_key.py independently rejects the
  stock key and accepts the prepared key, including after repeated preparation.
  Package manifests record prepare.py and prepared key-header SHA256.
- Found a real EGL surfaceless issue: Mesa reported an undefined default FBO
  (0x8219) and GL_INVALID_FRAMEBUFFER_OPERATION in particle transform feedback.
  Pbuffer-only creation failed on the Wayland host config. The final bridge uses
  a private1x1 pbuffer where supported, otherwise a private complete1x1 auxiliary
  FBO registered as Godot GLES system_fbo. It owns/deletes this FBO and renderbuffer;
  no visible guest window or CPU image transport was added. Transport failures
  now retain the actual GL error code and reject pre-existing errors.
- Kept failing evidence instead of widening clock/position tolerances. GLES
  floating exp2/division barcode extraction produced wrong low bits compared to
  logged CPU clocks; highp integer shifts fixed the clock oracle. A subsequent
  particle position failure exposed first-use shader stalls exceeding the
  fixture's64-step physics catch-up limit. Particle fixture now uses512 steps
  to isolate render/particle integration from upstream catch-up time clipping.
  Catch-up-limit game-time behavior is outside this acceptance scope. Final
  three environments measured0 relative clock ticks and0.0px CPU-reference error.
- Primary index particles-desktop.json links final Metal, ARM64 EGL/virgl and
  Windows11 ARM64/emulated x64 WGL datasets, artifacts and same-library full
  regressions. Final library lifecycle runs each passed1000 frames/15 PNG with
  resize/cancel, aliases, reservation, input, restart/recreate, host PCM and stalls.
  Linux new transport additionally passed2/3/4 buffers (3600 consumer frames,
  99 pixel samples) and immutable host-target generations (54 samples).
- Actual old leak, old EGL failure and instrumented datasets are rejected by the
  current verifier, deleting seeded stale PASS reports. Instrumentation that
  once masked the key-padding bug is not acceptance evidence; its old report
  was removed. Temporary native diagnostics are absent from production bridge
  sources and the final macOS cached Godot source.
- Ordinary macOS, Linux and Windows builds passed after the optional test
  hosts; all build/GPU jobs from this iteration are terminal.
- Particle acceptance is complete only for these desktop environments. Remaining
  full-goal gates include mobile/Web, source-driven viewport/stretch/input
  transitions, device recovery, full IME/controller, Linux x64 GPU and broader
  project/distribution coverage. No completion, commit or publication claimed.


## Project-owned output dimensions and Window stretch (2026-10-28)

- Added optional output ABI1 (GodotBridgeOutput.h), preserving base/GL/audio/
  viewport ABI tables. A zero advance is recoverable only when the output
  snapshot explicitly reports resize_pending and different bounded dimensions.
  Skipped publications do not consume producer sequence/completion counters.
- Fresh display servers use the constructor resolution before SceneTree startup.
  The bridge no longer overrides project _ready Window.size changes after start.
  Startup without a first matching frame negotiates resources before publishing
  running=true; the audio stream starts once after the first usable output.
- Window content stretching is resolved with an internal Godot RS viewport/canvas
  only when outer scaling or letterbox offsets are needed. It uses native Window
  transforms and a premultiplied-alpha material, preserving SceneTree/input and
  3D source rendering. Output dimensions are physical Window pixels; pointer
  events enter Godot's native inverse content transform. Transparent margins
  expose Dora's background. Production transport remains a GPU blit/fence ring.
- Source-owned retries requery the latest dimensions before rebinding, and also
  recover when project _process changes dimensions in the first replacement
  advance. They discard only unpublished wrappers and preserve old aliases.
  An actual continuous-resize test failed with invalid Godot consumer frame
  when an intermediate size equaled the last published size: the ring had been
  closed but same-size fast-path skipped reinitialization. Retrying now forces
  a fresh generation; native Metal viewport resize always replaces its slots,
  including same-size native handshakes, as required by its requery contract.
- New output/output_startup scenes and GodotOutputTest.inc execute1260 controller
  frames/16 final Dora PNG, _ready resize, Disabled/Canvas Items/Viewport modes,
  Keep/Ignore/Expand, integer scaling, restore and four consecutive scripted
  resize requests. Real SDL events flow through Dora Touch and hit a Godot Button
  once in each of8 configurations. The test matches Dora's platform input source:
  mouse on macOS, SDL mouse-converted touch events on Linux/Windows. Raw pushed
  mouse events intentionally bypass SDL's native prequeue conversion and were
  correctly rejected on touch-source platforms; tests now use the correct class.
- First prototype rejected repeated viewport_set_active calls; final resolver
  tracks activation transitions. Linux's first module also lacked the new
  export in its version script; export fixed. Fractional Retina target injection
  now rounds to the nearest SDL pixel rather than truncating. Tolerances remain
  <=2 logical input pixels and strict GUI/pixel/accounting checks.
- macOS Metal and Ubuntu ARM64 EGL/virgl final8-configuration cases passed,
  including startup and continuous-resize convergence, premultiplied colors,
  transparent margins, moving pixels, real GUI signals and complete GPU drain.
  Their fresh same-library lifecycle1000/15 and particle1000/13 regressions and
  ordinary builds passed. Windows11 ARM64/emulated x64 WGL also passed the same
  final8-configuration, lifecycle, particle, preboot ABI and ordinary-build gates.
  output-desktop.json indexes3780 output controller frames/48 PNG plus3000/45
  lifecycle and3000/39 particle regressions. Each platform uses the same library
  hash across output/lifecycle/particle/ABI checks. All build/GPU jobs are terminal.
- Output verifier negative checks use copied actual GPU data: missing bounce
  record, GUI signal, image and injected runtime error each reject and delete
  stale PASS. This negative check launches no GPU. The actual pre-fix resize,
  duplicate activation and missing-export datasets remain failure evidence.
- Remaining full-goal gates include mobile/Web, device recovery, full IME/
  controller/multitouch, input while output generations are transitioning,
  Linux x64 GPU and broader project/distribution coverage. Post-transition
  pointer correctness does not prove those gates. Overall goal stays active.


## Android native runtime continuation (2026-10-28)

- Built pinned standard Godot 4.6 ARM64 runtime with NDK 28.1, actual upstream
  Android Java/JNI services, host-owned EGL and no Godot render view. Java AAR
  contains no native libraries; APK runtime hash must match the source package.
- Isolated prototype application ID and test assets protect the ordinary Dora
  Android installation. Driver records native PID/output ownership and leaves
  unfinished tests available for inspection on observation timeout.
- Native Android EGL transport passed 2/3/4 buffers, 3,600 consumer frames,
  99 transport pixel checks and 54 host-target samples on API35 ARM64 emulator,
  Apple M1 Pro translated GLES3. This alone is not GodotNode acceptance.
- Actual APK runs exposed UI Looper ownership, resource-factory timing and a
  duplicate upstream GLES3 canvas VAO/buffer release. UI service construction
  now runs on Android UI; Godot Main stays on Dora owner/render thread. Host
  filesystem selection occurs before Main reads project.godot. Android-only
  source preparation removes the duplicate canvas release.
- First complete node run produced 720 controller frames / 8 PNGs, restart and
  node recreation; producer/consumer counters drained with zero GPU errors.
  Strict verification rejected the teardown diagnostic, so that dataset is
  intentionally not a pass: android-node-filesystem/run.log. Re-run corrected
  library before claiming Android node acceptance.
- Test-only Android exit uses SDL_QUIT and writes an atomic native finish marker.
  Ordinary mobile application shutdown behavior is unchanged.

- Corrected 3-buffer lifecycle dataset android-node-clean-3 passed strict GPU
  pixels/accounting: 720 frames / 8 captures, 5,759 changing animation pixels,
  zero pause changes, 693 produced/completed, zero GPU errors. Capture verifier
  now enforces Dora's actual longer-edge 1280 limit for portrait Android rather
  than a desktop-only minimum width.
- Extended 2-buffer test deliberately remains failed: Android Window::set_size
  ignored offscreen size requests. Android source preparation now exempts only
  dora-gl from native root-window size/min/max restrictions. Rebuild and strict
  resize/alias/audio retry required; do not reuse failed dataset as evidence.

- Four-buffer retry exposed test-only overlap in portrait output: the desktop
  side alias column intersected the large active viewport. Portrait aliases now
  occupy the free space above the main node; strict stamp checks remain intact.
  Final APK regression suite runs buffers 4/3/2 serially without changing APK or
  runtime. Keep android-final-node-{4,3,2} and their driver logs as owned outputs.

- Final APK suite passed all 2/3/4 buffer cases: 3,000 controller frames / 45 PNGs,
  native animation/pause, injected input/focus, restart/remove/recreate, three
  viewport sizes, resize cancellation, retained alias stamps, five reservation
  rejections, host stereo PCM and two 250 ms render stalls per case. Every GPU
  producer/consumer ledger drained; GPU errors and audio underruns were zero.
  Identical APK, native host and runtime hashes checked by android-node.json.
- All Android build/test jobs from this continuation are terminal. Original AVD
  state and ordinary Dora Android package remain preserved. Emulator is owned,
  read-only and still running. Overall goal remains active: Android physical
  devices/background recovery/native input, shader/particles/source-driven output
  and ordinary APK regression, iOS/Web and other previously listed gates remain.

## Android timing, particles and output continuation (2026-10-28)

Previous turn classification: progress (actual Android 2/3/4-buffer node suite,
3,000 controller frames / 45 captures, matching APK/runtime/host hashes).

- First Android timing run completed its 1,000-frame controller, 13 captures and
  zero-error GPU drain, but strict clock verification correctly rejected the
  resumed phase: 2,024 shader ticks versus 977 script ticks at 64 Hz. Concurrent
  unrestricted Ninja compilation drove emulator frame times above 1–3 seconds,
  exceeding the fixture's 64-step/60 Hz physics catch-up capacity. Godot render
  timing intentionally retains the original pre-cap step; script delta caps.
  Failed raw evidence is retained in android-timing, with failure.json.
- Observed resource contention justified interrupting the exact owned ordinary
  Ninja build (PID30072); Gradle session15474 is terminal failure. This was not
  an observation-timeout restart. Added optional dora.android.jobs (1–32), mapped
  to CMake's native Ninja compile/link job pool. Existing default is unchanged.
- Ordinary APK retry session60652 uses dora.android.jobs=2. Actual generated
  CMakeFiles/rules.ninja has dora_compile depth2. Timing retry session80342 uses
  the same previously accepted APK/runtime; no timing tolerance was relaxed.
- At this point retries are live; no timing/ordinary build pass is claimed yet.

- Bounded-load timing retry passed 1,000 frames / 13 PNGs with zero relative
  clock drift at 64 Hz, all time-scale/pause/zero-time resize phases. Actual
  custom/standard GPU particles passed another 1,000/13, zero sampled error
  versus independent CPU reference markers.
- Source-driven output passed 1,260 frames / 16 PNGs: eight size/stretch modes,
  premultiplied resolve, continuous animation, startup size and real
  SDL-touch->Dora->Godot GUI clicks in every phase.
- Home/resume driver now observes actual Android onPause/onResume, resumes only
  the same owned native PID, and refuses automatic restart after termination.
  Actual 720-frame/8-PNG run passed with stereo PCM: same PID, surfaceDestroyed
  followed by surfaceCreated, GPU drain zero errors and audio zero underruns.
  Forced EGL context loss, orientation/native multitouch/IME and real devices
  are not proven by this surface-recreation test.
- Advanced evidence index: build/godot-runtime/android-advanced.json (3,980
  controller frames / 50 PNGs), same APK/runtime as accepted 2/3/4 suite.
  Sessions80342,18476,76652,63347 terminal success. Ordinary build60652 remains
  live; original failed/unbounded build15474 remains terminal and is not reused.

- Ordinary ARM64 Debug APK completed (60652 terminal success, 6m59s). Inspected
  final package: original org.ippclub.dorassr ID and Assets/Script/init.lua,
  NDK26.1, no test entry/harness, no libgodot_android.so. No existing device app
  was installed over. Evidence: build/godot-runtime/android-ordinary.json.
- All jobs in this continuation are terminal. Android advanced index and EN/ZH
  API docs/README updated. Remaining: physical Android devices, forced context
  loss, full OS touch/IME/controller, orientation, PCK/broader projects; iOS/Web,
  desktop recovery and other previously listed gates. Overall goal active.

## iOS Metal embedded runtime continuation (2026-10-28)

Previous turn classification: progress (Android advanced timing/particles/output,
real Home/resume surface recreation, ordinary APK build/package inspection).

- Added iOS LibGodot creation/destruction with real OS_IOS services and Dora's
  windowless Metal display. Native UIKit app/renderer ownership stays in Dora.
  Embedded iOS cleanup avoids finalizing the SceneTree twice after instance stop.
- Pinned source copies are isolated under build/godot-ios/<simulator|device>;
  standard modules stay enabled. The iOS simulator SDK27.1 has Metal but lacks
  MetalFX and timed presentDrawable:afterMinimumDuration:. Source preparation
  reports MetalFX unsupported only on simulator and preserves real Metal; native
  device branches stay enabled. Raw compile failures are retained in the owned
  simulator directory, not accepted as runtime results.
- Wired iOS GodotNode to the existing Metal texture/event backend; runtime loads
  from the app's Frameworks/DoraGodot.framework. Test host uses independent app
  ID, output/cache trees and staged Script/init.lua, not ordinary iOS resources.
- Added framework linking/export/signature inspection and simulator test driver.
  Driver checks framework hashes, explicit simulator, same owned PID/finish
  ownership, saves stdout/stderr and uses existing strict GPU pixel verifiers.
  Compile/AST checks are not app/GPU acceptance.
- Created owned iPhone17e / iOS26.5 simulator E0A11091-3091-4295-8D7E-0E278DB9DACC;
  metadata build/godot-ios/simulator-device.json. It is not booted yet. Closed
  only the owned read-only Android emulator after its native finish marker.
- Current live jobs: runtime SCons session56396 (after SDK fixes), native Dora
  xmake session91420 / PID35880. Earlier runtime sessions70599,71005,61312,38743
  are terminal failures with raw diagnostics. No iOS framework/app/GPU pass yet.

- iOS archive compiled and framework linked with only the versioned ABI exports;
  ad-hoc signature and IOSSIMULATOR Mach-O metadata passed. Added the empty native
  iOS export-plugin registry normally generated by Godot's exporter (no optional
  native iOS export plugins in this package; all standard modules remain enabled).
- Actual first app installed/launched, loaded the matching framework and created
  the BGFX Metal host. Controller exited with native result2 / zero captures:
  upstream iOS default disable_path_overrides rejected the required --path.
  Raw run/failure.json retained in ios-node-first. Full runtime retry1605 enables
  the real upstream disable_path_overrides=no build option; no check bypass.
- Host build91420 completed; isolated resources initially remained stale after
  correcting an asset-branch edit. Rebuilt only the owned Dora.app rule cache
  (58948 terminal success); final app Script/init.lua is exactly return true.
  Build/inspection evidence: build/godot-ios/host-compilation.json.
- Ordinary macOS host build55777 completed successfully after iOS conditional
  wiring. First iOS run also exposed SDL's indirect-mouse opt-in diagnostic;
  iOS Info.plist now enables UIApplicationSupportsIndirectInputEvents, which
  SDL requires to register its native GCMouse handlers. This is not OS-input
  acceptance until actual events are exercised.

- Added repeatable build_ios_host.py with an explicit job limit and owned bundle
  cache invalidation, asset-entry/hash/harness/signature checks. Simulator host
  rebuild79871 terminal success; iOS indirect-mouse declaration present.
- Runtime1605 remains live with disable_path_overrides=no. First actual app
  native finish marker is result2/captures0 and original UIKit PID45644 remains
  idle; the simulator driver will terminate only this finished owned prototype
  before installing a corrected framework. Do not infer success from that PID.

- Corrected simulator runtime1605 and framework32082 completed; actual retry
  ios-node-host-path got through project loading but native RenderingDeviceMetal
  initialization failed. Independent native simulator probe confirms Apple2 maximum,
  no Apple4 family, and Metal itself aborts cube-array allocation as unsupported.
  Capability report: ios-metal-capabilities/capabilities.json. Apple documentation
  also specifies a simulator profile similar to Apple2. No override/fake family
  or relaxed GPU verification is used; simulator GPU sharing remains unverified.
- User steering: prioritize simulator tests; allow Dora's hardware requirement
  to rise to Apple4. Implemented exact iOS physical-device supportsFamily Apple4
  check, reject Noop renderer fallback, preserve simulator host compatibility,
  and fail GodotNode before library initialization on unsupported GPU profiles.
- Final simulator rejection test78720 passed its negative contract: native result2,
  zero captures, explicit Apple4 reason, no Godot runtime startup and clean host
  drain. It writes unsupported-gpu.json, never a renderer verification pass.
- Physical-target compile66565 verified the four affected C++/ObjC++ units.
  Ordinary simulator host5323 rebuilt successfully. Device full host32605 was
  interrupted after the user's simulator-first instruction to release its owned
  build lock/cache; compiled objects retained. Device runtime73098 remains live.
- Device inventory contains three simulated devices, no physical device, and zero
  valid signing identities. User chose simulator testing first; no further hardware
  preparation is requested now. Ordinary macOS regression is the current final
  check. Overall objective remains active, with iOS GPU, Web and other gates open.

- Current acceptance index: build/godot-runtime/ios-status.json explicitly sets
  simulator_godot_shared_gpu_output_verified=false. Simulator host build60132,
  final rejection78720, physical-target affected-unit compile66565, ordinary iOS
  build5323 and ordinary macOS78148 are terminal success. Negative rendering
  rejection is not counted as a positive renderer pass. Noop fallback is now
  rejected on iOS, and physical Dora requires exact supportsFamily Apple4.
- Device runtime73098 / SCons PID53034 was confirmed live compiling core files;
  do not restart it because an observation ends. Full device host32605 is
  terminal interrupted after simulator-first steering, with source caches kept.
  Active goal and original missing-platform/GPU gates remain unchanged.

- Device runtime73098 completed successfully (16m18s); framework50444 linked,
  export/signature inspection passed. Actual Mach-O platform IOS, minimum14,
  MetalFX weak-linked for availability. This is cross-compilation, not device
  GPU execution. Device host caches remain interrupted; changed units compiled.
- All jobs from this continuation are now terminal. Current index ios-status.json
  separates both framework builds, host builds, simulator capability rejection
  and the still-false iOS shared-GPU-output gate. User's Apple4/simulator-first
  steering is retained. No iOS GPU output or overall completion is claimed.


- Web transport continuation: implemented SharedGLBoundary and a reproducible
  two-independent-WASM probe on one real WebGL2 context. Chrome156 / ANGLE Metal
  / Apple M1 Pro passed 2/3/4 buffers, 720 frames, 1,815 pixel samples and 720
  state-boundary comparisons. Of these, 357 frames do not read pixels; 130 actual
  fence polls deferred via requestAnimationFrame. Browser errors/warnings zero.
  Final reports include source/binary hashes and Emscripten5.0.5-git command.
- Reproduced then fixed JS shadow-state pollution: Emscripten stores currentProgram
  and pack/unpack bindings on the shared context. Restoring raw GL alone failed
  failure-shadow-state.json. Probe now deliberately reuses the restored shader
  without glUseProgram; producer changes its own shader and pixel-buffer bindings.
  Also retain earlier deleted-texture snapshot failure; forgetTexture purges
  saved references only after reader fences drain, before actual owner deletion.
- Permanent reproduction: Tools/Godot/tests/web/run_transport.py (requires
  Playwright + Chrome). Owned browser/server exit at test completion. Native
  pixel readback is an oracle only; transport shares WebGLTexture objects.
  This is concrete transport progress, not a Godot library, GodotNode or Web
  lifecycle/audio/input/resources acceptance. Existing all-platform gates stay open.


- Web real-runtime continuation: added isolated pinned-source preparation,
  standard Web-module LibGodot lifecycle, scalar exports across separate heaps,
  same-context GL transport and host-owned target imports. First full link passed
  (9m04s, Emscripten5.0.5-git); directory startup correctly failed because the
  upstream template defaults disable_path_overrides=yes. Failed report retained.
  Official disable_path_overrides=no full rebuild is live (session88916/SCons70367);
  never restart it merely because an observation times out.
- Concurrent old-binary PCK diagnostic executed actual Godot4.6 GDScript drawing:
  180 frames / 900 pixels, produced=completed=180 and GPU errors0. Overall report
  remains false: missing fixture global-class metadata and an unused Worklet's
  unconditional thread join were diagnosed. Also reproduced deleted program/
  texture rebinds during teardown; SharedGLBoundary now prunes invalid saved
  objects (including deletion-pending programs). The repeated old-binary run
  has zero GL warnings but still fails the native errors; it is not acceptance.
- Queued incremental repair after session88916 is terminal: prepare_web.py joins
  AudioDriverWorklet only if its thread actually started. New fixture includes
  the legitimate empty global-class cache; directory/PCK reproduction supports
  --buffers2/3/4. Do not confuse this queued source fix with a repaired binary.
  Same-context Web async copies use command order rather than native-context
  waitSync/poll cycles; tests add 179 consecutive frames without pixel readback.
- Browser harness preserves Emscripten's exact main-thread blocking diagnostic
  in browser_errors and browser_diagnostics. The graphics-only oracle classifies
  that SDK warning separately; all actual Godot errors and GL validation errors
  still fail. No main-thread latency/performance acceptance is claimed.


- Final Web runtime build and repaired incremental link are terminal success.
  Native template now supports directory paths. Unused Web AudioWorklet cleanup
  joins only an actually started thread. Web async transport uses the verified
  single queue's ordering; reader submission ledger and real fences remain.
- Real Godot4.6 browser matrix passed: directory2/3/4 buffers and PCK3 buffers,
  each360 frames/905 sampled pixels, including30 paused-image checks, resume,
  restart,179 non-readback submissions, correct lifetime/cleanup and host objects
  surviving shutdown. Totals1440 frames/3620 pixels/716 non-readback frames;
  each produced=completed=360, GPU errors0, GL warnings0. All use the same JS/WASM
  binaries; tested HTML/bridge JS and artifact hashes were checked against the
  current source/package. Summary: build/godot-web/runtime-matrix.json.
- The latest raw transport-current probe also passed720 frames after deletion
  snapshot pruning. Package includes upstream notices and build/source hashes.
  Browser keeps the exact SDK main-thread blocking diagnostic; it is explicitly
  separate from Godot/GL errors. No latency or performance pass is claimed.
- All owned Web build/browser/server processes in this continuation are terminal.
  Current web-status.json replaces the earlier live/queued-build snapshots:
  real-runtime shared GPU output=true, actual Dora GodotNode output=false.
  Actual node/host bootstrap, filesystem coordination, input/audio/resize/alias
  accounting, browser coverage/distribution and positive iOS GPU gates remain.
  This continuation is concrete integration progress, not overall completion.


- Actual Web node integration is now implemented: local C ABI thunks in
  Source/Godot/GodotWebAPI.cpp marshal integers/strings/metadata/PCM across two
  WASM heaps; function tables and C++ objects never cross. Native GLSession
  keeps its existing frame-ring/read ledger and bgfx callbacks. Resource startup
  preloads verified manifest Godot directories/PCK, then copies a resource
  snapshot. Canvas creation captures a clean baseline and isolates Godot VAO0.
  Opt-in root xmake mode DORA_WEB_GODOT stages the independently built runtime;
  ordinary mode excludes its Lua binding/backend and remains standalone.
- Fixed real integration failures instead of accepting their runs: WebGL bgfx
  internal-format queries must use valid sized renderbuffer formats and cannot
  probe TEXTURE_2D_MULTISAMPLE; Emscripten6 print's unexported getter hid the Lua
  traceback (safe data-property callback lookup now preserves it). Godot Web's
  default Sample playback bypassed Dummy; embedded default uses Stream/PCM.
  Initial fixture omitted beginGameCapture; failed raw runs remain retained.
- Actual diagnostics found PCM underruns4096 then512 with the4096-frame Web
  target. Callback records show512-frame requests batched after main-thread
  work. The same fixed8192-capacity queue now primes/targets8192 on Web only;
  native platforms retain4096. This trades buffer latency (~171ms at48kHz) for
  burst margin; do not call it low latency or main-thread independence. Raw
  failures are retained, and the verifier still requires exactly zero underruns.
- Final actual Dora matrix: directory2/3/4 buffers + PCK3,620 controller frames /
  12 PNGs each; totals2480/48. Independent CPU image oracle checks orientation,
  transparent premultiplied composite, colour440 samples plus16-bit top/bottom
  stamps, pause equality, resize640x360->480x270 and retained aliases frozen after
  removal and across recreate. Pointer100,70 and Space pressed/released state
  reach real GDScript; initial/restart/recreate each boot exactly once.
- All four use the same host/Godot WASM hashes. Actual C ABI close stats show
  cumulative sequence598 completed per case (2392 total), errors0. Logical
  reader ledgers drain with signals=frames*buffers, waits only for published
  slots (therefore waits<=signals), pending0. Reader 'completed' is a logical
  encoding-frame count, not separate hardware-fence evidence; hardware drain
  comes from actual transport close/fences and strict GL validation evidence.
- Host SoLoud PCM: both client lifetimes in each case produced/consumed nonzero
  samples, underruns0, captured48000 frames with440/660 positive crossings.
  Actual Node report: build/godot-web/node-desktop-browser-matrix.json.
  run_node.cjs writes execution.json; verify_node.py alone writes the full
  verification.json after image, GPU and PCM checks (stale passes removed).
- Ordinary core Debug rebuild and actual browser startup/stop passed without a
  Godot directory or enabled feature. Root outputs remain isolated under build/.
  Known SDK main-thread blocking and ScriptProcessor deprecation diagnostics are
  retained. All owned build/test/server handles from this continuation are now
  terminal. At that checkpoint web-status.json set actual node GPU output=true;
  later bullets close trusted DOM input and userfs persistence. Performance/latency,
  Web OS async service teardown, imported/broader projects/browser/release scope
  and positive iOS GPU stay open.
  This was concrete progress; the complete multi-platform goal remains active.


### Trusted browser input continuation

- Actual visible Chrome / macOS OS-focus input passed 13 assertions in
  `build/godot-web/dom-input-acceptance/verification.json`, including transformed
  touch, right mouse, keyboard modifiers, ASCII and held-input release on blur.
- Fixed normalized Dora mouse numbering, modifier propagation and aggregation,
  and pre-main blur entering an uninitialized native runtime. Earlier failing
  reports remain as evidence; Playwright focus emulation is explicitly disabled
  after cross-origin navigation so this test observes real OS focus.
- Updated three-buffer node regression passed 620 frames / 12 PNG / 110 color
  samples, actual fence drain and zero GPU errors/PCM underruns:
  `build/godot-web/node-platform-regression-3/verification.json`.
- Input-only focus test records 12,288 silent-stream underrun frames. Pausing
  the host voice still left 8,192 frames missing when Chrome delivered a burst
  on resume, so that experiment was reverted rather than doubling baseline
  latency with a 16,384-frame queue. Background audio continuity, real OS IME
  composition UI and wider browser coverage remain open.
- Changed common input code passed the actual macOS Metal three-buffer node
  regression: 720 frames, 9 PNGs, 27 alias stamp samples, two 440/660 Hz audio
  lifetimes, 739 completed GPU producer frames, zero GPU errors and zero PCM
  underruns. Report:
  `build/godot-runtime/node-common-input-macos/verification.json`. It has not
  been rerun on every native platform. Positive iOS GPU rendering remains pending.
- A clean ordinary core Debug build after the pre-main blur guard passed actual
  Chrome startup/stop with no browser errors and no Godot runtime in its file
  tree or feature manifest. Evidence:
  `build/godot-web/ordinary-final-results/execution.json`.
- Godot `user://` now mounts `/userfs` before Main::setup. The embedded loop
  bypasses upstream web_main's dirty-file polling, so the isolated Web runtime
  enables IDBFS auto-persistence at write time. Two complete page/runtime
  lifetimes on one real Chrome origin restored counter 1 then wrote 2:
  `build/godot-web/persistence-autopersist-results/verification.json`.
  The first no-sync 1→1 failure is retained separately. A subsequent actual
  three-buffer node regression passed 620 frames / 12 PNG / 110 samples,
  440/660 Hz and zero GPU errors/PCM underruns:
  `build/godot-web/node-persistence-regression-3/verification.json`.
- Web text input now uses a focusable hidden textarea while Dora IME is
  attached, forwards committed UTF-8 without splitting code points, and sends
  composition-update events into Dora's existing TextEditing path. Actual
  trusted browser input committed Chinese “中文”; Godot received code points
  20013/25991 while all prior pointer/modifier/focus checks remained green.
  Report: `build/godot-web/dom-input-unicode/verification.json` (15 assertions).
  Godot's custom display servers now expose IME and virtual-keyboard features
  through a versioned state extension. A real `LineEdit` automatically enabled
  Dora's textarea, projected its caret to `(404, 290)`, accepted Chinese text,
  and released IME when the node closed. All 19 DOM assertions passed:
  `build/godot-web/dom-input-auto-ime-headless-2/verification.json`. This proves
  automatic committed-text routing, not a real OS IME candidate/composition UI.
  Subsequent Web and macOS Metal node regressions passed:
  `build/godot-web/node-auto-ime-regression/verification.json` and
  `build/godot-runtime/node-auto-ime-macos/verification.json`.
- Latest IME bridge sources were rebuilt into the iOS simulator runtime,
  framework and host. The dedicated iOS 26.5 simulator again rejected its
  Apple2 profile before Godot initialization, produced zero captures and shut
  bgfx down cleanly. Framework SHA-256 is
  `61911bd313a740ba2d641bd124f450d9f145b05392d60851939b86dc010ad31a`;
  report: `build/godot-runtime/ios-auto-ime-apple4-rejection/unsupported-gpu.json`.
  This is negative capability evidence, not iOS shared-output acceptance.
- Windows 11 was resumed after the Mac unlock. Current Dora host sources rebuilt
  with MSVC and passed a real 720-frame WGL / three-buffer / retained-alias / PCM
  regression with zero GPU errors and zero PCM underruns:
  `build/godot-windows/node-auto-ime-host-results/verification.json`. It used the
  previously validated ABI-2 runtime DLL because this macOS host has no MinGW;
  therefore it proves host backward compatibility, not the new Windows runtime
  IME extension. The failed macOS cross-build was a missing-toolchain detection,
  not a source compiler failure.

### Android rebuild after automatic IME bridge

- Rebuilt the source-owned standard Godot 4.6 Android ARM64 runtime after the
  versioned IME extension, then rebuilt the isolated Dora test APK. Runtime
  SHA-256: `4a3899eb4d19772239b5f6d5ebcd5eb54ab045ce20ff9f063abd2c4c218eaf92`;
  APK SHA-256: `a4da6709b93bd86c24821a40f5684ac9a4df7e93c6517fc2560922aacb519542`.
- Actual Pixel 7 / API35 ARM64 emulator runs passed the 2/3/4-buffer matrix,
  720 controller frames per case and two complete node lifetimes. Retained
  aliases matched the configured buffer count; every reader drained with
  pending0 and GPU errors0. Reports:
  `build/godot-runtime/android-auto-ime-node-buffers2/verification.json`,
  `build/godot-runtime/android-auto-ime-node/verification.json`, and
  `build/godot-runtime/android-auto-ime-node-buffers4/verification.json`.
- The three-buffer run also passed two nonzero 48 kHz stereo PCM lifetimes with
  zero underrun frames. These runs prove the new ABI compiles/links and preserves
  Android animation, shared EGL textures and multi-buffer synchronization. They
  do not prove a real Android soft keyboard or OS composition/candidate UI;
  that remains an explicit input acceptance gate, as do physical devices and
  forced EGL context loss.
- Added a dedicated Android `--ime` acceptance path. A real Godot `LineEdit`
  automatically requested IME focus through the versioned runtime state;
  Android `InputMethodManager` reported the soft keyboard shown with SDL
  `DummyEdit` as its served view, and system-injected committed text `IME42`
  reached the LineEdit. The same process passed 720 frames, three-buffer shared
  EGL animation, retained aliases and zero GPU errors:
  `build/godot-runtime/android-auto-ime-soft-keyboard/verification.json`.
  This closes Android automatic soft-keyboard lifecycle and committed-Latin
  routing, but not real composition/candidate UI or CJK IME acceptance.

### Windows runtime rebuild with the IME extension

- Installed the x86_64 MinGW POSIX toolchain in the isolated Ubuntu ARM64 VM
  and compiled the full standard Godot 4.6 Windows runtime from current bridge
  sources. The first final link was killed by the VM's 2 GiB memory limit;
  after a clean shutdown and reversible increase to 6 GiB, the retained object
  tree linked successfully in 16.7 seconds.
- The resulting stripped PE32+ x86_64 DLL exports all six required entry points,
  including `dora_godot_get_ime_api`. SHA-256:
  `b594469d73d48577cad433f99086b9748bfdb7a32e0192e76390cbf7771aff1d`;
  local artifact: `build/godot-windows/ime-package/dora_godot.dll`.
- The exact DLL then passed 228 native ABI checks and an actual 720-frame WGL
  GodotNode regression in the logged-in Windows console session. Both node
  lifetimes drained their three-buffer readers with pending0/GPU errors0;
  animation, pause/resume, input, scene restart/recreate, retained aliases and
  48 kHz stereo host PCM passed with zero underruns. Report:
  `build/godot-windows/node-new-ime-runtime-results/verification.json`.
- A first launch from `prlctl exec` returned255 because that process ran as
  NT AUTHORITY\\SYSTEM. Its full dump shows the fault inside Parallels
  `prl_gldd.dll` during WGL setup, before `dora_godot.dll` was loaded. Running
  the same binary and exact DLL as the logged-in interactive user passed; future
  Parallels GPU tests must preserve that session boundary. Native Windows IME
  candidate/composition UI remains a separate acceptance gate.
- Added `test_windows.py --ime` and host-side lifecycle assertions. The current
  host/exact runtime DLL passed another 720-frame run: real Godot `LineEdit`
  focus automatically attached Dora/SDL text input, node removal detached it,
  and recreation attached it again. Win32 `SendInput` delivered `WinIME中`
  through the foreground `SDL_app` window into the LineEdit. Three-buffer GPU
  readers drained with pending0/errors0 and both PCM lifetimes had zero
  underruns. Report:
  `build/godot-windows/windows-ime-acceptance-results/verification.json`.
- The Windows ARM VM exposed no legacy IMM32 context for that SDL window, so
  this is OS-originated committed-Unicode and automatic lifecycle evidence,
  not composition/candidate UI evidence. The verifier records this limitation
  explicitly rather than inferring a full native IME pass.

### Simulator-first iOS confirmation after the Apple4 decision

- Re-ran the current simulator host/framework on the owned booted iPhone17e /
  iOS26.5 simulator after the user selected simulator-first validation. Dora's
  host remains simulator-compatible, while GodotNode rejects the real Apple2
  simulator profile before runtime initialization because the embedded Godot
  renderer requires Apple4 cube-array capability.
- The negative contract completed normally with result2, zero captures, the
  explicit Apple4 diagnostic and clean bgfx shutdown. Exact current framework
  SHA-256 remains
  `61911bd313a740ba2d641bd124f450d9f145b05392d60851939b86dc010ad31a`;
  report:
  `build/godot-runtime/ios-user-request-simulator-apple4-rejection/unsupported-gpu.json`.
  This confirms the guard and cleanup path, not shared GPU rendering.
- Dora's physical-iOS initialization now requires
  `supportsFamily:MTLGPUFamilyApple4`; the simulator exception is intentional so
  Dora-only host regressions still run. Positive iOS Godot GPU sharing still
  requires Apple4-or-newer physical hardware and valid device signing.

### Standard controller bridge

- Added controller button and axis input kinds without changing the versioned
  C-struct layout or ABI number. Existing fields carry Dora controller id, SDL
  standard control name and normalized axis value; invalid names and values
  outside -1..1 are rejected by the runtime.
- GodotNode now subscribes to Dora `ButtonDown`, `ButtonUp` and `Axis` events.
  The runtime creates real `InputEventJoypadButton` and
  `InputEventJoypadMotion` objects with the original controller id. Focus loss
  emits releases for every held bridge-owned button and nonzero axis before
  Godot receives focus-out.
- Current macOS Metal runtime and host passed 720 frames with `a`,
  `leftx=0.75`, neutralization and a second held button/axis pair released by
  focus loss. Three-buffer readers drained with pending0/GPU errors0; both host
  PCM lifetimes had zero underruns and retained texture aliases remained valid.
  Report: `build/godot-runtime/node-controller-focus-macos-2/verification.json`.
- Rebuilt the current Android ARM64 GL runtime and isolated APK. The Pixel 7 /
  API35 emulator passed the same button/axis/focus-release contract together
  with 720 frames, three-buffer GPU drain, retained aliases and two zero-underrun
  PCM lifetimes. Runtime SHA-256:
  `20af7feb71feee0c2c1f943cc71deec70f1017f5aa7fb214d64b69bc53d9f389`;
  report: `build/godot-runtime/android-controller-focus/verification.json`.
- Rebuilt the current Windows x64 WGL runtime and MSVC Dora host. The interactive
  Windows 11 ARM64 VM passed the same contract with 720 frames, two complete
  node lifetimes, three-buffer readers pending0/GPU errors0, retained aliases
  and zero PCM underruns. Runtime SHA-256:
  `c13761f608e82fcf08fc3c94bda4cac9b67fa074916dff20eb3c450ce5ce08f7`;
  report: `build/godot-runtime/windows-controller-focus/verification.json`.
- Rebuilt the current Linux ARM64 EGL runtime and Dora host. The isolated
  Weston/Mesa virgl run passed the same contract with 720 frames, two complete
  node lifetimes, three-buffer readers pending0/GPU errors0, retained aliases
  and zero PCM underruns. Runtime SHA-256:
  `6997eb3c3a65c0178c7ab41bffce662764422ecd02292ed7c4774cfc76d82fa2`;
  report: `build/godot-runtime/linux-controller-focus/verification.json`.
- Rebuilt the current Web LibGodot and Dora Player. Chrome 156 passed the same
  contract in the 2/3/4-buffer matrix: 1,860 controller frames, 36 Dora-composed
  PNGs, two node lifetimes per case, readers pending0/GPU errors0 and zero PCM
  underruns. Runtime WASM SHA-256:
  `f946c218adb3fefb866fdf91cb6fb000787c4a21165b5d5360ed4259fc1ae54c`;
  report: `build/godot-web/node-controller-teardown/verification.json`.
- These are synthetic Dora controller-event acceptance runs, not physical
  controller, hotplug or rumble tests. iOS still requires supported physical
  Apple4-or-newer hardware and signing for a positive GPU/controller run.

### Linux x86_64 Rosetta boundary

- Built the current full Godot 4.6 x86_64 shared runtime and x86_64 Dora host
  from the shared source tree. Their SHA-256 values are
  `e63c84910eecdd781cd2734d1607dc9345e1f55ad8ae31f51d9ce0705d73fb4c`
  and `c416b34b825604fb57fc37862293b1c4b33c43d90f0d3903dfc0cb91b4ed7c93`.
- An independent x86_64 consumer running through Parallels Rosetta used
  ANGLE/Vulkan SwiftShader to share the real LibGodot EGL texture for 360
  frames. Produced/completed were 361/361, GPU errors were zero, animation
  changed before and after a pause while the paused captures were identical,
  and no CPU pixel transport was used.
- The full Dora host reached bgfx EGL initialization with system Mesa, then
  Rosetta rejected Mesa's x86_64 LLVM library AOT image. Preloading Electron
  ANGLE instead terminated during translated startup before Dora main. These
  are environment/translation limits, not LibGodot scene crashes; native
  x86_64 hardware output remains open. Reports:
  `build/godot-runtime/linux-x64-rosetta-report.json` and
  `build/godot-runtime/linux-x64-rosetta-angle-independent/verification.json`.

### Web normal-stop service teardown

- Normal `stopped` state now uses the same idempotent platform-service disposal
  path as `faulted`, without re-entering a closed engine. It removes DOM input
  and visibility listeners, releases the hidden IME control, cancels host audio
  callbacks and closes the audio context.
- The current 2/3/4-buffer browser matrix asserts inactive platform state,
  zero held keys/pointers, closed audio, absent IME DOM, a false second-dispose
  result, and no error from late blur/visibility events. All 1,860 frames and 36
  screenshots still pass with GPU errors/PCM underruns zero.
- A current-binary two-page persistence regression restored `user://` from
  IndexedDB as values 1 then 2 after two full Dora/Godot lifetimes. Reports:
  `build/godot-web/node-controller-teardown/verification.json` and
  `build/godot-web/persistence-teardown-results/verification.json`.
- A live three-buffer node suspended at engine frame70 with both legacy and
  Worklet audio contexts suspended, remained at frame70 for400ms, then resumed
  both contexts and completed620 frames/12 captures/two node lifetimes with GPU
  errors and PCM underruns zero. This is explicit host lifecycle acceptance,
  not a claim about every browser's real background-tab throttling policy.
  Report: `build/godot-web/node-suspend-results/verification.json`.
- A fresh ordinary core build used `DORA_WEB_NO_GODOT`, contained no Godot
  package files, and passed startup/stop/late-event teardown independently:
  `build/godot-web/ordinary-teardown-results/execution.json`.

### WebGL context-loss fail-safe

- Added an owned Chrome DevTools acceptance test that starts the current Dora
  Web player and embedded Godot runtime, obtains the live WebGL2
  `WEBGL_lose_context` extension and confirms `gl.isContextLost()` after the
  forced loss. This is a real browser context loss, not a synthetic DOM event.
- Shared GL state capture/restore now treats a lost context as non-restorable;
  the bridge rejects graphics operations racing the host's fault transition,
  while retaining close/shutdown for page-lifetime cleanup. This removed the
  previous null-VIEWPORT TypeError and spurious transport GPU errors.
- The page entered its explicit restart-required fault state, closed host audio,
  removed input/IME services, made repeated disposal a no-op and drained both
  Godot readers and client accounting with pending0/GPU errors0. Current Godot
  WASM SHA-256 is
  `a634615be01338ba038a87b785fb16d8c3ec882cd1db8edd47e6515ffec3ab33`.
- All 2/3/4-buffer cases forced the loss after real animation output and drained
  72/74/72 reader frames with pending0/GPU errors0. The same rebuilt WASM then
  passed a fresh normal 2/3/4-buffer matrix: 1,860 controller frames, 36 verified
  Dora-composed images, 330 pixel checks, two node lifetimes per case,
  resize/pause/restart/controller checks and zero PCM underruns/GPU errors.
  Aggregate report: `build/godot-web/context-loss-matrix.json`. Automatic in-place
  WebGL resource restoration is still not implemented. The documented page
  reload recovery was also executed: a fresh embedded Godot lifetime restarted,
  completed all 620 frames after the loss, then stopped with platform/audio
  services closed. Report:
  `build/godot-web/context-loss-reload-recovery/verification.json`.

## 2026-10-29 tracking checkpoint archive

2026-10-29 Web清理修复推送：从d60c48b独立临时索引只加入12路径（Source仅Application.cpp、WebTaskQueue.cpp/.h），tree3ebfee0c4436878258d75fff575240e7144e3359，补丁29846字节/SHA fd840e664b803581cfcd8f3b51106907497cde8ef23dd6688a73b558f1fcbcee；commit6c4b7fdc963dce85421e23349fd13a150e00638d，非强制推送并ls-remote核实。主HEAD仍6a05611e，工作区和真实索引保留；PR159正文按最终代码重写，保持draft/未合并。因为实际源代码修复触发新12轮CI，旧Godot40772555311被并发策略取消，不是观察超时后重启、不计为验收失败或通过；旧提交9个工作流success保留，Web/AppImage未终态。旧/新run列表分别冻结，当前以6c4b7fd为准。

新Godot run40776123749：Ubuntu协议job123125908681 success，含新Web队列CPU测试；macOS协议123125908395 queued，LinuxEGL123125908694准备工具中，GPU未执行通过。新Web run40776123603含Chromium真实启动失败清理步骤，待终态。GitHub插件下载返回云端文件引用，需本机字节校验，使用已授权本机GitHub客户端下载artifact12854148925；未回显/保存签名下载URL。ZIP SHA8c09ac975002380b841bbff725c02727bc3d0de5c31a9357977624913d349bbb与服务digest一致，解包检查路径，协议/四格式shader/Web队列JSON均passed，队列源码SHA匹配提交blob。结果build/godot-remote-ci/6c4b7fd/protocol-ubuntu/download-verification.json。仅远程CPU契约，不是原生GPU证据。源CPP/测试/矩阵冻结在task-stop-evidence/，严格浏览器故障三项为final-strict-fault，普通生命周期三项与Godot矩阵5580帧/108图/990像素报告都复核哈希通过。

2026-10-29 Web故障清理实修：先复查现有失败包并获取完整wasm符号堆栈，确认drainOneTask在主入口返回/Life销毁后仍调用PoolManager::push导致越界。首次临时浏览器probe错误地只从console.error匹配Lua报错（实际记录为console.log中的[error]），保留failure.json后改为检查全部日志；旧包真实越界仍明确可见。独立plain-error旧包对照无排队任务时通过，加入print排队后的最小107字节fixture旧5881fded WASM稳定失败。不是原始浏览器只读赋值崩溃复现。

增加WebTaskQueue.stopTaskQueue，启动失败时先在活动池/GPU存活期间清队列，普通退出/主入口返回幂等终止；晚到回调/新任务无操作。最终普通host4f1dfd0d...在三浏览器故障/普通生命周期通过，最终严格driver再验证无JS/Wasm/GL错误，输入/IME释放、音频context关闭；实际C++队列的外部/内部停止、捕获释放、后到回调CPU测试通过并接入protocol.sh。Web CI加入受控Lua print+error fixture及固定Playwright1.62.1 Chromium（npm元数据核实Node>=20），故障报告上传；actionlint与语法通过。

Godot-enabled core Debug host重建为fda4fcc1c4144eb64122ac57cc912ec9e9677b46b2aa43ecc7eff9a5c29c4911，复用封存LibGodot WASM，三浏览器2/3/4矩阵5580帧/108PNG/990像素检查通过，GPU/PCM/pending=0、正常平台清理。第一轮自编驱动误给verify_node位置参数加--results，CLI退出2，实际case-2浏览器执行/图像未失败；三个旧failure.json与旧驱动保留，修正后校验既有case-2并继续新3/4用例，最终全部通过。没有重跑二缓冲掩盖失败、没有修改严格GPU校验器。task-stop-evidence/冻结源码、报告哈希、实际宿主/运行库哈希和图像哈希均核对。该构建来自主工作区（含无关Cache改动），不称纯候选构建。

远程d60c48b现已观察Engine Tests/Windows/Linux完整工作流success，Godot协议Ubuntu/macOS成功，LinuxEGL主步骤仍在构建/测试；其他工作流继续跟踪。上述修复需要一个代码提交触发新CI，不把旧提交结果当作新修复通过；不因状态文档轮询单独推送。主工作区和真实索引仍保留无关改动。

2026-10-29 远程推进：v5候选289文件、1334858字节，tree d9062744eead2c0065b5e430bcfdb773428f2e6c / patchSHA e45ae128f7f4c59b9800b93ea0a2eed9972cc4775379e153124829fa312032e9，Source相对v4无差异。临时索引应用/树检查通过，凭据形状字面量预检无命中（不等于完整安全审查），真实索引未变。远程main仍6a05611e，目标dev分支不存在；从候选tree用commit-tree生成d60c48b4e547e79ac67de02e4da75df3c8849622，仅创建dev/godot-runtime-integration分支并非强制推送，ls-remote核对一致；未切换主工作区HEAD，原文件/索引保留。publication.json保留提交与推送回执。

GitHub连接确认IppClub/Dora-SSR写入权限后，通过连接工具创建draft PR159并立即attach_artifact，PR可合并但保持draft/未合并。触发12工作流，run列表保留godot-remote-ci-snapshot.json。Godot run40772555311：Ubuntu协议/包检查job123113307518 success；LinuxEGL job123113307056安装依赖中；macOS协议job123113307423 queued。其他工作流未终态，不能计为通过。first-jobs.json保留实际子job；不因工作流总体queued覆盖已运行子job。进展状态后续仅本地同步，避免每次文档状态推送导致取消并重启既有CI。初次保存快照脚本的btoa在编排环境不存在，尚未写文件即失败，改用结构化apply_patch成功保存，未重发创建PR或推送。

2026-10-29 v4 Linux整套CI结束：bootstrap72659/worker72666及宿主session89158正常退出0，聚合769.982秒、build_skipped=false且复用编译缓存。测试宿主重建53.309秒、普通宿主17.647秒；实际测试宿主51ff851eff3d8f487746736493b4e876b04863d04d5570a728bf86e8ee1d5d1b、普通宿主541089e0a32bfdce494647ab37ab0f4122714d96e974844ef988c25a1b795110、LibGodot6997eb3c...。包括失败退出/恢复、2/3/4矩阵3000帧、100循环及普通宿主项目边界/随包/缺库。环境仍UbuntuARM64 VM/Mesa llvmpipe，不是物理GPU或远程CI。

导出归档98294cc99868c28c45961660f70a8caf0ae6aaecea692778875731c1e55cfa87，117606985字节，606文件逐项SHA通过，实际三个原生产物映射匹配。369独立原生PNG；冻结严格校验器在宿主离线复验矩阵2/3/4、恢复阶段及100轮通过，普通用例保留原生报告和完整性证据，无额外原生运行。目录build/godot-linux-ci-local/ci-candidate-v4-export/。本轮过滤明确排除test-assets/assets/Assets及重复DLL/宿主，避免前轮metadata描述过宽；源HTTPsession16954与客体导出PID76537均停止。源码archive按.gitattributes生成，123项行尾转换已独立证明，无代码差异。

随后准备v5候选：只更新三语言fixture、build/run脚本、共享constructor_rejections.py及README/TRACKING/PLAN；Source与v4保持一致。将使用独立临时索引应用/树检查、排除15无关路径、保留5共享接口，并针对候选文本执行不输出值的凭据字面量预检；该预检不是完整安全审查。下一步独立草稿PR与远程CI，不能以本地报告代替远程结果。

2026-10-29 C#错误面续验：新增opt-in constructor-rejections覆盖公开TryCreate六类参数/项目拒绝，run_csharp.py设置显式模式并用公共constructor_rejections.py校验12条预期错误；Rust/Wa runner也共享该函数。helper要求全部error/critical/warning精确匹配，非预期诊断不能被宽泛删除。基于Rust/Wa既有截图/原日志的8项离线正反例通过，见godot-bindings-constructor-filter-audit/。旧frozen-fixtures和原生报告不覆盖。

Windows当前用户Jin/CLI可用，严格检查既有owned标记和native/runtime SHA后，只复制测试/校验器并重编C# fixture，未重编原生DLL，未复制主工作区无关Cache修改。真实x64 .NET/PInvoke/WGL两轮共12次TryCreate null拒绝，随后1000帧/15截图及全部高级标志通过，pipeline46.343秒，GPU/PCM/pending=0。宿主7d1c6edc52779e075e50e5cb8f4e9902d9781eb5eb5cbf1e03ddf77049305cc7、运行库c13761f608e82fcf08fc3c94bda4cac9b67fa074916dff20eb3c450ce5ce08f7复用。实际fixture DLL已导出，与native/runtime三份哈希映射核对；冻结verifier在宿主离线复核恢复阶段通过，原始错误日志SHA匹配。首次审计在离线校验通过后遍历__pycache__目录出错，改为仅普通文件后生成export-verification.json，未启动额外原生运行。结果build/godot-bindings-constructor-rejections-csharp-windows/，来源helper build/godot-windows/run-constructor-rejections-csharp.py。此轮是Windows VM和既有DLL证据，不是v4 Windows全源码构建；这些新fixture/helper尚未刷新进v4候选。Linuxv4现有bootstrap72659/worker72666仍实际在跑，未重启。

2026-10-29 v4原生续验：Mac隔离源码10728个blob同步前发现131差异（123仅行尾），同步后构建前/后完整哈希一致。首次主cwd+-P错误输出路径构建主动终止143，恢复主project缓存；从隔离cwd+-P构建1.747秒，复用缓存及Release LibGodot。新2/3/4矩阵3000帧/45PNG，所有高级标志启用，GPU/PCM/pending=0、退出0。普通宿主6.716秒缓存构建，SHA94e0af...，无测试入口/故障hook；随包11.153秒与缺库6.380秒、各2PNG通过。见candidate-v4-native-matrix.json、ordinary-macos/和macos-source-audit.json。

同轮启动Linux v4：完整git archive 109477568字节/SHA9a014676389ea8b279f65a1c0291e71bd3c37be39e6509f71c5d5670267385e0。首次脚本不接受两处Android符号链接，源staging失败，不是运行失败，PID72590退出1；修正链接检查后复用已校验归档并核对10728项，再启动bootstrap72659/worker72666，宿主session89158。归档与raw Git有123处.gitattributes行尾转换差异，逐项确认无其他差异；保留source-sync/transfer-audit。测试宿主缓存重建53.309秒，后续完整CI仍在进行，需查实际进程与exit，不能把progress状态当通过。源HTTP session65937已停止。此CI冻结v4，后续绑定测试不在其中。

并行补BIND-01：Rust/Wa fixture增加显式constructor-rejections模式，每生命周期6项非法构造须返回None/nil，然后正常节点继续。build.py与run.py支持独立opt-in；两种实际Wasm3模块各1000帧/15PNG通过，包含12次拒绝、双生命周期与原完整resize/cancel/alias/audio/stall/reservation校验，GPU/PCM排空通过。原始错误日志未改写；恢复输入只删除精确计数10+2预期错误，其他错误继续拒绝，原strict verifier未放宽。离线额外错误反向控制确实拒绝，成功报告删除。目录godot-bindings-constructor-rejections/与-negative-control/；没有称为C#、缺库/异步错误验证，未纳入v4候选。使用同一2aa0231e测试宿主和2e3f2ea6 Release库，没有新运行库构建。

2026-10-29 v4候选刷新：288文件，补丁1314875字节/SHA256 9b8ed66b9ab7c1714c4cddcf6074ccc98565b6bb95bf068f4f02ea37bf6bc76f，tree dc1b8a5c9102d12eb85236d2a494f1aeb61b8305。六个路径从工作区更新（封装、测试、默认Web入口、三份文档）；其余候选继承v3，包括5个拆分共享接口与3个仅行尾差异的C#文件，15个无关路径继续排除。第二临时索引应用到基线后tree一致，真实索引SHA不变。候选导出独立目录candidate-v4-protocol-source/，实际运行protocol.sh及四格式CPU检查通过，结果candidate-v4-protocol-results/；40个Source路径与既有隔离macOS源码逐字节相同。此轮未新建分支/提交/推送，未称为v4完整原生或远程CI通过；下一步审查及最新源码完整回归。

2026-10-29 完成新版Linux整套CI证据导出：归档70e86f3b201b123d4aadd53b351ba0a3dbdc678533e48d101bc65b5eeade91e3，171951618字节，3134文件逐项哈希匹配，测试宿主/普通宿主/LibGodot与聚合报告匹配。冻结严格verifier离线复核case-2/3/4、恢复阶段1000帧及100轮均通过；369张独立原生截图，不重复计恢复阶段副本。普通宿主保留原生结果与完整性证据，未再次执行。导出器实际保留小写assets树（元数据excluded文字过宽，在本地export-verification.json纠正），排除test-assets/Assets、重复Dora/.so；这不是新增GPU运行。证据目录build/godot-linux-ci-local/ci-lifetime-integrated-export/；源文件传输服务session12214与客体导出服务PID71713均已停止。首次prl内联Python被拒绝、curl的星号被客体展开导致传输失败，改用明确IP的noproxy和文件脚本成功，未重启CI或VM。

2026-10-29 本地跟踪文档同步：再次核对 Application.mm 的 Apple2 和 GodotRuntimeMetal.mm 的 Apple4 检查，保持用户确认的能力边界。新版 Linux 本地聚合 CI 正常退出0，用时740.07秒，build_skipped=false但使用编译缓存；包含初始化失败退出/恢复、2/3/4缓冲、100轮及普通宿主边界用例。聚合报告/日志/退出码捕获到 build/godot-linux-ci-local/ci-linux-lifetime-integrated/；子报告和图像仍在任务VM，完整导出复核待做，无远程run ID。该轮冻结v3阶段源码，未覆盖随后string_view修改。

后续修正的证据独立记录：显式追加零方案遇Web末尾逗号生成格式编译失败，改为std::string_view携带长度；四种零/逗号组合CPU测试通过，macOS隔离宿主重建后恢复1000帧/15截图通过，见embedded-length-view-four-formats/和embedded-view-native-recover/。Web默认入口改为返回既有Director.entry；新普通core host Chrome启动/停止与三个浏览器根节点身份断言探针通过，无Godot/GPU截图验收。旧Web普通脚本也能启动（TOLUA_RELEASE不安装只读错误setter）；旧探针失败仅证明新增返回值断言不满足，不能宣传为浏览器原始只读崩溃复现。新源码尚未刷新进v3补丁，独立执行标记、候选回归和远程CI继续待办。具体报告索引与交接顺序同步TRACKING.md。

2026-10-29 负例严格诊断最终收口：初版Linux GPU通过后审查发现来自Projects/Web/runtime-assets/init:3的readonly Director错误，旧验证报告与恢复子报告已保留verification-before-strict-audit.json并明确passed=false。旧导出字节/截图校验仍是历史材料，不再作为整体验收。driver现在独立复制资产并用--asset和中性入口，保留asset-inputs.json且全日志仅允许编译器和Lua两条预期error；未修改或宣称修复Web产品脚本，该问题列PKG-01。

最终冻结runner40d7376de2d2dc517a308f58dc9a937614c09c92516a6a930612c65dfeef96b9的macOS init-lifetime-final-macos-{exit,recover}通过，1.002/19.957秒、0/15截图、恢复1000帧；源/产物/fixture与资产清单哈希复核。Linux复用相同ace538...宿主/6997eb...库，final两项0.437/32.641秒，退出0、1000帧15截图、GPU/PCM/pending零；冻结runner/verifier及资产清单与日志归档12ee9a8f1c4aefe0e0e9e25f5b9ac8f5e4ca50e3d231d72f770210b7d323a076，导出到init-lifetime-final，排除复制资产树并保留清单，逐项SHA核对。native runner65622正常结束，临时服务器66033确认关闭；init-lifetime-final-audit.json复核四份最终报告，不是额外运行。前面带-v3名称的Mac报告和旧Linux报告是过程记录，最终以-final目录为准。

候选v3基于v2临时索引刷新11路径，287文件/1305534字节，tree4efbad2551a90b73661421e63a97581c682dd227，patch39bd8a37eb8190718d0551c4af6d9ba80ab0f77e98e4860b0a2315212ba3f0a2。独立apply与write-tree一致，真实索引保持；Source仅新增GodotNode.cpp/Sprite.cpp差异，与隔离构建对应文件字节一致，5共享接口保持候选基线，15无关文件继续排除。新版完整CI/远程CI尚未运行，源码快照晚于部分已存过程记录，以清单与最终报告限定范围；未提交/推送。

2026-10-29 初始化失败与首帧前退出崩溃闭环：新增仅测试宿主编译的缺入口着色器注入。最初宏只给Application.cpp，GodotNode.cpp未启用，导致正常构造后立即退出也以SIGSEGV结束（rejected=0，记录init-shader-failure-before，不计注入成功）；补xmake按文件宏后，真正编译拒绝rejected=1也复现，init-shader-invalid-before保存f72c774c...宿主、原始日志与crash.ips。崩溃栈pthread_mutex_lock→bgfx::Context::destroyUniform访问已关闭context，日志SpriteRenderer在BGFXDora/PoolManager/Application之后销毁。SpriteRenderer有GPU effect，但RendererManager只在首次draw实例化，依赖链未闭合；构造中显式初始化manager，不改全局LifeCycler。修复后Mac首轮exit/recover通过，随后以冻结runner重验，core/fixture字节与隔离候选目录核对一致。LLDB启动60秒未推进，wrapper及子进程已结束、残余debugserver5637已终止；依据真实系统crash和原生前后对比，不计调试器成功。

构建材料另有两次启动路径错误：从主仓库带-P启动写了主仓库输出；只改cwd但省-P又被xmake父Git项目发现规则重定向到主源码，均因实际编译输入/输出不符主动终止（3274/4123退出143），不是观察超时重启。最终使用非登录Shell、候选cwd和显式-P，检查编译器include/output及进程cwd后通过51.758秒；启用注入宏6.171秒、生命周期修复6.699秒、标记更新6.402秒均完成。主仓库项目缓存误指向候选的关联已备份并恢复为主仓库，模式仍为此前记录的release；未改真实索引或无关工作区源码。

Linux任务目录传入9文件da26d9a7369ed5b78ee8944fde6247162663466973a7f2926f4b236d48028c2a，宿主重建40.661秒，最初两项GPU/清理通过；进一步严格审查发现启动多出readonly Director错误。run_init_failure首次以仓库根为资产根，递归发现Web默认init的非法Director.entry赋值。旧宿主导出793566...与旧日志完整保留；宿主端旧exit/recover和恢复子报告明确passed=false，原成功快照留verification-before-strict-audit.json。增设独立测试资产、副本中性init、显式--asset；严格全日志只准编译器和Lua断言两条预期error，产品Web脚本自身列PKG-01待修复，没有通过改测试称其已修复。

最终同一runner40d7376de2d2dc517a308f58dc9a937614c09c92516a6a930612c65dfeef96b9在Mac/Linux实际通过exit/recover，原始日志不改写，恢复阶段仅移除有边界的预期故障区间再用原严格校验器。Mac init-lifetime-final-macos-{exit,recover}为1.002/19.957秒、0/15原生截图、恢复1000帧；宿主44229adcbbbd6fbe6fd59b34a72f610e3334c4f9c944ad0fed7d7532e5fa15a7，Release LibGodot2e3f2e...不重编。Linux final为0.437/32.641秒、0/15截图、恢复1000帧，GPU错误/PCM欠载/pending=0；复用ace5380025101da0e0312ebfae7847918a3268afbffa8757b466fb2cc2d69fdd及既有6997eb...库。归档12ee9a8f1c4aefe0e0e9e25f5b9ac8f5e4ca50e3d231d72f770210b7d323a076包含宿主、冻结脚本、日志/截图/资产清单，排除复制资产树；宿主端逐项SHA复核export-verification.json。公共CPU协议含fresh embedded shader在Linux也通过。服务64039/66033均已关闭，worker62907/65622均正常结束，无新增原生任务在跑。

普通Mac Release构建9.253秒，源宿主6aabc32ac68f46a75fceacd65a6160d6953cd745ce60855fa93c6accd199d269无测试入口/注入字符串；随包与缺库12.857/6.481秒各2PNG通过，报告init-lifetime-ordinary-macos。两项新负例加入Linux CI init_failure_reports，额外GPU依赖源文件纳入源码哈希，workflow/README同步；新版全聚合CI与远程CI未执行，其他平台负例和Web默认入口仍未完成。

2026-10-29 Windows C# v3严格通过与候选v2归档：Mac矩阵完成后，Windows以Python312/Pillow11.1执行，原生Debug DLL重建25.453秒，session1774真实退出0。node-csharp/verification.json确认1000帧15PNG、两次能力查询、完整resize/cancel/别名/竞争节点/输入/两个250ms停顿及清理，GPU错误/PCM欠载/pending=0；本C#入口不注入控制器，仍使用既有原生控制器报告。宿主7d1c6edc52779e075e50e5cb8f4e9902d9781eb5eb5cbf1e03ddf77049305cc7，运行库c13761f608e82fcf08fc3c94bda4cac9b67fa074916dff20eb3c450ce5ce08f7，fixture511f8c5d6e0db9a07a3de696dd032bbf672f5f4fb6f1e71721d339424afebbb4；三份执行产物导出/映射后SHA复核，export-verification.json保留。Mac四缓冲动画图、Windows缩小后运动图已人工抽查。首次512帧欠载原因未确认，留AUDIO-01；不据v3通过称已修复。helper复制结果时清除本轮不存在的旧标记，宿主已移除旧failure标记（两份失败目录完整保留）。

v2候选在临时索引从原tree刷新8个源/测试/文档/工作流路径，285文件/1281957字节，tree ebd6da88eba7b8298d3af0a7f0b9c73e5db51984、补丁SHA95e2fc5c617b9bba2e802031e5b1e7e3eca0847b7321ce52600054839f6e768d。独立再应用到基线得到相同tree，真实索引不变，15无关文件继续排除；Source唯一差异wrapper与已测试候选字节一致，5共享接口与旧候选一致。Windows主工作区同步运行不计为候选Windows独立构建。全部本轮构建/测试进程已结束，仍无远程提交/CI。最新tracking日志更新晚于v2源码快照，快照身份以清单为准；后续审查推进远程CI。

2026-10-29 候选原生构建与干净生成缺陷：session99258正常退出0，候选目录原生Release首次完整宿主构建605.578秒，ccache=false，LuaBinding独立生成并保留getLoadError基线及Godot能力查询。原样首轮二缓冲在Godot启动前着色器编译失败，源码混入std::function类型名，随后退出SIGSEGV；旧宿主6a50e4...和candidate-native-node-2、matrix-failure记录保留。确认xmake bin2c nozeroend=true生成的bgfx_shader/compute字节列表无终止零，主工作区旧头有零，从而掩盖BgfxEmbeddedShaders.hpp的C字符串越界。直接静态数组ASan未诊断，长度却43554/17417而原数组26137/17363；将精确数组复制到ASan受保护分配后复现heap-buffer-overflow，不冒称静态global探针捕获。封装显式补零，修复后ASan长度与上游源码一致。新增embedded_shader.py生成带零/不带零两种列表，编译实际封装并以有界memchr及原文件字节比较检查；接入protocol.sh及CI归档，主工作区和候选隔离源码CPU报告均通过，actionlint/语法通过。

同一候选目录仅加上述封装修复后重建5.851秒，session48550退出0；实际矩阵session42885退出0，candidate-native-shader-fixed-matrix.json通过，2/3/4各1000帧15PNG，共3000帧45PNG，总驱动50.036秒。全部动画、输入/控制器、resize、别名、双生命周期及退出排空，GPU错误/PCM欠载/pending=0。新宿主2ee58dd5f3d2293e10283f6c493c09159488b0b0267632dee15863e8e2c7fb48，既有Godot Release库2e3f2ea69d9e7272b4aa8c5e0944b2fc0906a6f735ce0e0d52d1ec9422a1746d不重编且哈希保持。证据是原候选tree加wrapper修复，非原tree原样通过；candidate-native-progress.json已记录终态，后续刷新候选补丁与远程CI。

2026-10-29 Windows恢复与C#新查询续验：prlctl系统命令、--current-user Jin和共享目录均恢复可用，未再重启。helper新增精确task-owner内容检查、显式--package及Pillow预检；同步着色器wrapper。首轮构建/C#编译通过，但固定旧package目录不是v1清单，被校验拒绝，归档godot-bindings-capability-csharp-windows-stale-package-failure。改用package-integrity-current后，真实x64.NET执行1000帧15PNG、两次unsupported_reason_empty=1，原生导出1729导入全部存在，GPU排空无错；Python314缺PIL导致后校验未运行，且日志已记录第二次生命周期512帧音频欠载。宿主离线严格verifier明确拒绝该欠载，不计整体验收；完整保留py314-underrun-failure与offline-verifier.log。该轮同时有Mac编译，相关性未证明因果，未更改队列/阈值。现有Python312已确认Pillow11.1；Mac矩阵结束后v3使用该解释器单独复测，明确记录实际子进程退出码，不沿用PowerShell写exit文件后返回0的假象。

2026-10-29 候选独立原生构建：从候选tree 3c2323da4bb26bfe70e45e739d78368ce6e7b30b执行git archive，完整导出candidate-native-source，归档255774720字节/SHA256 bd6191fdc8aa028d4ba93c6f66209a37633f1e78b9c330ac74039b7bac57cf4c；不复制主工作区对象/生成绑定。缓存API与8个源码文件一致性检查通过；git archive遵循C# CRLF属性，首个字节断言未考虑换行，明确按属性规范化后通过，不是源码缺失。首轮exec的登录zsh回到主仓库，lsof确认PID95556实际cwd错误；主动SIGTERM，session54926退出143，日志另存candidate-native-wrong-directory-*，不计独立构建。主仓库默认xmake配置已被误设为macosx/arm64/release/ccache=false（专用release-host-config保持），该边界明确记录。改用login=false和显式-P候选绝对路径，新configure正常完成；实际PID96772 cwd、候选.xmake配置、独立build目录均核实，session99258继续编译。candidate-native-progress.json记录进程身份和续查句柄。复用Godot Release库2e3f2e...的包完整性复核通过；候选原生构建与GPU测试尚未完成，不替代运行库重编或远程CI。

2026-10-29 Linux 普通宿主整合入 CI：ci_linux.py 增加普通宿主独立构建及项目恢复/随包/缺库用例，聚合报告 ordinary_reports 收录两份报告与5/4截图；普通构建前后核对测试宿主和运行库哈希，再分别锁定三个产物。预构建复验要求显式 --skip-build --ordinary-binary，默认流程依次切换原生测试/普通宿主构建。工作流步骤名和README同步，actionlint及语法检查通过。实际默认分支在Ubuntu VM运行 ci-linux-ordinary-integrated，父53472正常退出0，聚合699.630秒、build_skipped=false，但复用编译缓存（测试宿主19.957秒），不能称为全量重新编译。3000帧45截图矩阵、100轮300截图（最小变化20554）、普通项目恢复5截图（12.219秒、变化12818/12960像素）及普通随包/缺库4截图（4.835/4.475秒）全部通过，354张原生截图；资产中另有12张PNG，不计为截图。09b997...测试宿主、8f99f8...普通宿主、6997eb...运行库三份SHA与前轮相同。归档824c36ab9ffce2a0ae4c21e4814ab547d69b11e48a542c97ae7a713293d422b5核对后导出宿主，映射ci-integrated-export-verification.json与截图清单post-export-check.json保留，导出服务56699已关闭。只删除了虚拟机export目录内三份已在宿主按SHA验证的二进制副本，保留真实构建产物和全部宿主证据，释放约0.5GiB。

2026-10-29 CI 分支候选隔离准备：list_artifacts确认本任务无已有PR/工作树，当前main工作区有66个已跟踪改动和232个新文件。只读作用域盘点后，将缓存诊断/3D文档15文件排除，对5个共享接口文件去除诊断片段，其他Godot与依赖修复保留，生成godot-candidate.patch（283文件/1262175字节）。通过专用GIT_INDEX_FILE应用到HEAD并write-tree，真实索引SHA未变，未改动工作区文件；候选tree=3c2323da4bb26bfe70e45e739d78368ce6e7b30b，清单godot-candidate-manifest.json。仅编译候选树导出的全部C#绑定与fixture，candidate-csharp-compilation/compilation.json通过，artifact79eb06294dd1304ca83ebf4d84cb3a4d49378250993b70f50154e07f2b9ecee7、runtime_tested=false；未代替Windows原生运行。候选协议首轮材料漏导module/runtime_timing.h导致编译前失败（保留candidate-protocol-staging-failure.log），从同一tree补齐module后candidate-protocol-v2/verification.json通过C ABI、2/3/4环、时序、PCM队列与reader账本CPU测试，GPU未测。候选仍需完整依赖审查及独立原生构建；未创建提交/分支或发布远程，GitHub CI未执行。

2026-10-29 Linux 修正采样的 100 轮最终通过：父47324、原生48135、采样48526均正常结束，fixed-cycles-exit=0；完整 ci-linux-fixed-cycles/verification.json 已导出宿主 build/godot-linux-ci-local。聚合复用新宿主（build_skipped=true）耗时624.616秒，含协议/包检查、3000帧45PNG矩阵与100轮300PNG。循环全部100场景启动、读者/GPU/PCM排空，最小动画变化20559，预热后纹理1/程序13/着色器16/帧缓冲0/估计纹理49152字节稳定，Metal未测。新宿主09b997b88360d627b4e0034504da850bbdd86f5870b907d67577a35eb16e4390已保存Dora-fixed-test-host；原运行库6997eb3c3a65c0178c7ab41bffce662764422ecd02292ed7c4774cfc76d82fa2不变。资源采样387.390秒/193条，RSS479055872..601014272字节，观察进程退出；中途附加、不证明启动基线/显存/泄漏。resources.json与jsonl逐项匹配。

后续48884在先决成功后构建无原生测试入口的普通Linux Debug宿主，23.018秒；其后ordinary-linux-project-boundary实际12.276秒、5PNG通过，动画12920/12880像素，GPU客户端64/64与125/125，读者两次107/107、pending/errors=0。普通宿主8f99f87db93ae14f6f6ed58d90490aef02ba6ac0a28871a42b035bab3d1bffa5已导出Dora-ordinary-host，原测试宿主哈希保持一致。所有普通边界图像用公共校验器在导出后复核，非新增原生执行。

新增ordinary_native.lua与run_ordinary_linux.py，分别构造有库/缺库两份独立资产树，GodotProject相对查找且断言public projectPath等于期望绝对路径，使用默认资产目录库路径、不设DORA_GODOT_LIBRARY。首轮在启动前因把Assets/LICENSES文件当目录而失败，NotADirectoryError保留ordinary-fallback-staging-failure.json；未进行原生运行。改为独立GodotNotices目录后重新执行ordinary-linux-fallback-v2，随包/缺库两项分别4.969/4.486秒，各2PNG，绿色Dora图形中心均419.5→859.5，正向Godot客户端63/63、错误0，缺库无Godot启动/客户端，普通图形继续且正常退出。每项两份Godot许可哈希与源包一致；导出时比对原源码传输快照中Assets/LICENSES，现有Dora许可文件完整保留。缺库第二帧已人工抽查。两个用例和边界验收仅说明本地Ubuntu VM / llvmpipe、普通Debug宿主，非正式分发/物理GPU。

导出固定CI/普通边界/普通缺库目录、二进制与采样，核对访客SHA后本地重验；export-final-verification.json保存执行路径到本地字节映射，post-export-audit.json保存离线复核记录。归档去除重复.so后，普通资产中的库用与封装包字节匹配的硬链接补齐，缺库树保持实际缺库。临时文件服务均已关闭，新增原生/采样任务均结束。远程CI尚未执行；下一步将普通宿主用例接入CI及继续其余平台/外部环境门槛。

2026-10-29 Linux CI 首轮完整运行与采样死锁修正：初版 full-build/2/3/4 矩阵成功退出，报告导出 build/godot-linux-ci-local/ci-linux/verification.json（1422.40 秒包含构建，3000 帧/45 PNG，Mesa llvmpipe / ES3.2，GPU/PCM/pending 全零）；保留匹配 SHA 的 173MiB 宿主 Dora-test-host（913fcbcb...141fa1e）和运行库 package（6997eb3c...d82fa2），export-verification.json 核对访客执行位置和本地导出字节。缩小尺寸/四别名截图已人工抽查。

100 轮扩展在第 3 轮移除后停滞，原 PID 46513 存活；线程等待/日志多次检查后 GDB attach+detach 保存全线程栈，主渲染线程 bgfx::getStats→getPerfStats→m_resourceApiLock，逻辑线程 Context::frame 持 resourceApiScope 等待 renderSemWait，结合源码确认测试统计死锁。诊断完成后 SIGTERM，watchdog 143 退出；父 followup 24887 以失败 1 结束，保留原三缓冲数矩阵通过与循环失败，不算 100 轮通过。失败 archive、backtrace 与原 GodotCycleTest.inc 已带匹配哈希导出。统计改为逻辑/API 线程复制 6 项标量，渲染线程只做 Metal 查询与 release 发布；不改生产协议，不放宽检查。Weston 比原生循环超时多 120 秒、CI 循环外层改 1500 秒，检查各循环/soak 组合边界顺序，避免同刻抢先结束外层。修正测试源码归档 e6816522d9ff7492a198e05655cddf7f0e3eec49b7d2694f4d2e08b3a602bdec 在访客核对后仅重编译宿主，23.98 秒，父47324启动新矩阵+循环到独立ci-linux-fixed-cycles，未重编译运行库或覆盖失败目录。

macOS 同修正已独立重建 cycle-api-thread-host（9.211 秒），实际 run_cycles_macos.py 完成100轮，186.694秒/300PNG、最小动画变化3447，场景/读者/PCM全排空，bgfx计数稳定、Metal149520384字节/峰值增长0，报告cycles-api-thread-macos-100/verification.json；session13624终止0。Linux新矩阵已通过，循环PID48135仍存活并越过原卡点。sample_native_process.py 扩展 Linux /proc exe+start_ticks 身份校验，独立复制到任务目录避免修改活跃CI源码快照；采样PID48526已实际记录RSS/CPU，非启动基线/显存测量。后续普通Linux宿主边界 worker48884确认活跃，等待47324，只有成功退出+aggregate passed+产物哈希一致后才构建/运行普通宿主，失败不继续。临时文件服务均在各次传输后关闭。尚无修正后Linux100轮最终报告或远程CI成功记录。

2026-10-29 公共项目边界验收推进：提取 verify_project_boundary.py，原 macOS v2 报告离线重验关键结果一致；初次比较因 Python tuple 与 JSON list 表示不同而拒绝，规范化 JSON 后匹配，不修改原报告。重构后的普通 macOS 入口实际重跑通过：project-boundary-common-macos/verification.json，验收耗时 14.19 秒、5 PNG、动画差异 3200/3078 像素，两个有效客户端 100/100 和 101/101，失败客户端 readers=0，pending/errors=0。新增 Linux 普通宿主入口，自己的资产/项目目录与默认随包 .so、包校验、输入/产物哈希、真实渲染器记录；仅语法检查通过，尚未运行。按源码确认 GL 只在有有效句柄时报告 readers，而 Metal 失败节点也输出零值账本，公共校验分别约束 2/3 份记录，保持各后端完成/错误检查。新 Lua 模板由驱动传入后端预期错误文本。另 Playwright WebKit 公共初始化三缓冲回归实际 620 步/12 PNG/110 像素检查通过，webkit-shared-init-3/verification.json；Chrome/Firefox 既有公共初始化回归也通过。Windows CLI 复查仍报 Invalid argument；不重启 VM。Linux 原构建与后续等待任务仍存活，宿主编译继续，未启动额外 GPU 工作。

2026-10-29 Linux 原生 CI 构建阶段更新：同一 SCons 3689 已正常结束，build.log 明确 done building targets、耗时 00:12:30.33；父任务 3571 仍存活并进入 Dora 宿主编译，等待后续的 24887 仍存活。新包 libdora_godot.so SHA256 6997eb3c3a65c0178c7ab41bffce662764422ecd02292ed7c4774cfc76d82fa2。通过任务专用、仅服务该包目录的访客临时 HTTP 服务导出到宿主 build/godot-linux-ci-local/package，清单逐文件完整性通过，报告 package-integrity.json：3 文件/131289867 字节。临时导出服务 PID 40369 已关闭，不改变 VM 共享权限。当前仅完成 Godot 原生构建与包检查，Dora/EGL/循环仍未通过，不升级为 GPU 验收。

2026-10-29 后续验收：Linux 原 CI PID 3571、SCons 3689 及等待后续的 24887 均再次确认存活，编译已推进到 Godot core，不重启。Windows UI 实际仍为启动标志与转圈，CLI 会话仍不可用，未进行新的强制重启。真实 Safari 26.6.2 的 SafariDriver 会话预检返回必须开启 Allow remote automation；未修改设置，已请求此控制权限确认，预检服务随后关闭。新增原生 run_safari.py，公共 acceptance_init.js 由原 Playwright 初始化逻辑提取并补浏览器内错误/日志采集，Chrome/Firefox 三缓冲各实际 620 步/12 PNG/110 像素检查、GPU/PCM 排空通过（chrome-shared-init-3、firefox-shared-init-3）。Safari 原生端到端仍待权限和实际执行，不能以其他浏览器通过代替。

2026-10-29 普通 macOS 项目边界回归：新增 project_boundary.lua 与 run_project_boundary_macos.py，使用无测试入口的普通 Release host 和既有 Release runtime，在独立重签名副本执行 A 动画 → 关闭 → 不同路径 B 拒绝 → A 恢复动画。最终 project-boundary-macos-v2/verification.json 通过，验收耗时 13.768 秒，5 PNG，动画变化 3142/3084 像素；成功客户端 produced/completed 为 98/98 与 101/101，两个有效 readers 为 102/102 与 103/103，失败客户端 readers 为 0，所有 pending/errors=0。检查仅两次真实场景启动；保存宿主/运行库/启动脚本及 PNG 哈希。首轮同样通过且证据保留，恢复截图已人工抽查。此项证明 macOS 上拒绝请求后同项目可恢复，不提供多项目或动态卸载。README 修正旧平台状态并明确 GL 重建限制，当前结果同步 TRACKING.md。

2026-10-29 CI 执行推进：Ubuntu ARM64 已启动，现有 Guest Tools 命令通道可用，但当前内核缺少 prl_fs，共享目录不可用；为避免改动既有工作区，使用独立 `/tmp/dora-godot-ci-20261029` 目录、只传源码快照及哈希校验的 Godot 归档。传输完成后临时文件服务已关闭。xmake 3.1.1 官方发布源包与 GitHub release digest 匹配，在任务目录内构建安装；宿主配置预检通过。完整 CI 首轮 PID 3571、SCons PID 3689 正在执行；不因观察超时重启。新增公共 verify_cycles.py，macOS 驱动复用；原 100 轮证据离线复核与关键结果比对通过。Linux 测试入口支持循环模式，CI 增加 100 轮，测试/Weston 超时按循环数计算。后续 PID 24887 等待首轮成功后应用仅测试脚本更新，复用前轮原生产物执行新矩阵及循环；首轮失败则停止。尚无 Linux 新入口完整成功或远程 GitHub CI 运行证据。

2026-10-29 本地跟踪文档整理：按用户决定固定 Dora iOS Apple2 / 可选 GodotNode Apple4。重新核对 Application.mm 的 Apple2 检查、GodotRuntimeMetal.mm 的 Apple4 加载前检查，以及模拟器兼容边界、macOS 38.36 分钟、100 轮节点循环、Android Release 矩阵和普通 macOS 应用报告。TRACKING.md 增加进展速览，保留失败证据并明确后续通过的范围；README 链接统一跟踪入口并修正 Web 矩阵的旧状态。CI 工作流和 Linux 聚合入口已准备，但尚无远程执行或 Linux 新入口端到端成功记录；本地 macOS 协议报告通过，包完整性 11 项正反例复查通过。当前仅整理文档，未新增真机或发布验收结论。

Added native GodotCycleTest mode and test-only ARC Metal resource probe;
new cycle-host built in12.027s from Release config with actual optimized code,
including current common audio diagnostics. Original long-run host untouched.
Cycle runner37732 completed100 clients in190.245s,300 PNGs: animation changed
at least3456 center pixels per pair, every removed view returned to clear color,
all100 client/readers/PCM drains accepted with zero errors/pending/underruns.
Warmup5; every idle snapshot textures4/programs15/shaders18/framebuffers0,
textureBytes4514816/rtBytes0, Metal currentAllocatedSize149520384 throughout;
peak growth0 against explicit0-byte limit. Report cycles-release-100/verification.json.
Independent scene-boot-audit.json checks exact actual boots1..100/root_path_ok
and original log hash. Runner now enforces that check on future runs and uses
the current Pillow flattened-data API when available. Original passing run used
getdata (only deprecation warnings); no GPU execution was repeated for that API
cleanup. Reader wait bounds independently checked against the retained log.

RSS sampler48578 attached partway through, observed72.646s/36samples and native
exit, RSS280395776..281100288bytes; not full-run CPU-heap acceptance. Metal metric
is same-device resource allocation including Dora/Godot, not all driver/CPU
memory. CI-01 and PERF-01 retain their broader outstanding scope. Windows guest
session still unavailable after its completed normal restart; no reset/restart
loop or alternative-runtime success claim was introduced.

Strict macOS long-run completion:44686 exited0 and full verifier passed; runtime
2301.853426s (38.36min) versus required1800s. 216720 total frames,720 soak PNG
samples,2187 alias stamp pairs, both producer/reader drains matched, GPU errors0,
pending0 and both PCM underruns0. Host/runtime before/after hashes matched.
Report release-optimized-soak-216000/verification.json. Resource35085 exited0
after observing PID75528 exit;2305.604s/230 samples, RSS67993600..259293184bytes,
first-window median181706752 vs last80969728. This observes RSS/CPU, not GPU
allocation or a formal leak verdict. Manually inspected final soak-216600.png
and audited actual duration, reader drains and audio counters from the report.
CI-01 remains open for creation/destruction loops, GPU-memory growth, other
platform long runs and actual CI automation. No overall goal completion claim.

Android callback diagnostics added to opt-in audio capture: fixed64-entry
underrun records, request/received frames, callback timestamps/gaps and producer
snapshot; no callback allocation/logging and no queue/latency/threshold change.
Initial compile lacked SDL_timer.h; failure log preserved as
apk-audio-diagnostics-before-include-build.log, header fixed and43716 built19s.
Diagnostics94836 passed1000-frame full combined test under SwiftShader, with
512-frame maximum callback request and zero underruns. This does not prove the
earlier3072/512 underrun cause or a fix.

Observed emulator71193 using722% hostCPU and SwiftShader; AVD configuration
hw.gpu.enabled=no. After94836 terminal completion, stopped only the task's
emulator and launched81310 with explicit -gpu host, no snapshot load/save,
without editing AVD configuration. Boot/SurfaceFlinger/Godot renderer confirm
Apple M1 Pro / Metal host translation. Hardware-GPU3 case56181 passed; subsequent
2 passed but4 hit driver IME race: injected IME42 crossed deliberate focus-loss
step285 and final text was DoraE42. Native run4347 was inspected as finished0,
its remaining output recovered to recovered-after-ime-failure without a false
success report. Original APK was already replaced when preservation was attempted;
the old exact hash/log/native outputs remain, not a copy of that APK.

Added Android-only test window at295, after focus restoration: scene/render/audio
continue, control steps wait for driver's successful actual system-text evidence
and private-app acknowledgement file. A bounded30s native timeout prevents stuck
tests. Driver waits for keyboard/DummyEdit and still requires full DoraIME42;
does not bypass system input. New APK38985 built24s. Matrix16837 passed2/3/4
with identical APK c9b54f7b68e802a02e4ad1807c1e06bc7be5e085397a36fd5840a9b491d8646b
and runtime eb53c136ba402d4f6bc54642520e32ee09bff14ecd77fe199a21ec90dac2d40c:
3000frames/45PNGs, audio/stalls/resize/cancel/aliases/reservation/controller/IME/
same-process Home/resume/cleanup, GPU errors/PCM underruns/pending all0. Report
android-release-ime-window-matrix/verification.json. Physical Android and
production distribution remain unverified. Visual inspection confirmed the
actual Android node/cube/aliases image. macOS75528 remains live approaching its
216000-frame target; actual duration already exceeds30min but final proof pending.

Web drain fix verified: runtime99249 exit0 (13.46s incremental build), package
integrity passes7files/110077172bytes. WASM8098208471698e3b4e995fc7fd4e13853edbde57efc22a400985f46f8ac820e5.
Firefox long-output55942 exit0 and strict verify_node passed; full 60-second
output plus both node drains now agree on produced/completed and GPU errors0.
Three matrices completed: chromium43727, Firefox61211, WebKit69308, each2/3/4,
aggregate5580frames/108PNGs/990pixelchecks, zero GPU errors/PCM underruns/pending.
Reports chromium-drain-matrix-v2, firefox-drain-matrix, webkit-drain-matrix-v2.

First concurrent Chrome/WebKit matrices failed before launching the browser:
shared source staging directory was rewritten during packaging, fixture guard
correctly rejected hash/marker drift. prepare_node_game now derives staging
from target-package hash, removing that race. Failed first directories retained.
An attempted run_node --context-loss was an unsupported option and was terminated;
CLI now rejects unknown options instead of silently running an ordinary case.
Actual dedicated web_context_loss.mjs session97385 passed real loss, safe fault,
service/audio teardown and page-reload recovery with all620 steps completed:
drain-context-loss-reload-3/verification.json. This is not in-place restoration.

Android remains incomplete after successful JNI keep fix: retry22034 finished
native lifecycle/background/IME but failed strict audio verification at3072/512
underrun frames. No relaxed threshold, rerun-only success claim, queue-size or
latency increase was introduced. Next work is callback/request/producer timing
diagnostics and a verified fix. Windows restart is terminal-success, but still
boot-loading in CUA and no guest session available. Original macOS216000 soak
continues, latest captured soak-118800.png, no completion report yet.

Release Android compilation completed: runtime session24433 exit0 (19m25s),
native host72758 exit0 (17m47s), APK20088 exit0 (46s). Runtime package7files /
134939768bytes verifies; SHA256 eb53c136ba402d4f6bc54642520e32ee09bff14ecd77fe199a21ec90dac2d40c.
Actual initial APK crashed with JNI NoSuchMethodError Godot.restart(): R8 had
removed a private JNI-resolved method. Original APK/mapping/log retained in
android-release-controller-3. Added optional Godot package keep rules, retaining
R8 for the rest of Dora. Rebuild71514 exit0 (29s), mapping explicitly retains
restart. Retry22034 completed native test with background/IME records but strict
verifier rejected PCM underrunFrames3072 and512; no verification.json and no
overall Release runtime pass. Retry evidence android-release-controller-3-jni-keep.

Extended browser audio probe duration plus live-animation fixture hold. Chrome
69910 and WebKit27354 completed full controller tests, verify_node passed both.
Firefox65893 completed browser execution, but strict verify_node rejected the
second client produced2276/completed2275. All three separate 60-second rendered
audio windows passed2880000 samples; max silent Chrome128 (2.67ms), Firefox1,
WebKit1. Reports chrome-audio-output-60s, firefox/webkit-audio-output-60s-v2.
Initial Firefox/WebKit launch attempts used Playwright1.63 with missing browser
revisions; preserved failed startup reports, then used installed matching1.62.1
runtime from Codex dependencies. No product runtime incompatibility inferred.

WebGL2 specification confirms newly created sync status cannot become signaled
until returning to browser main loop, even with synchronous GL APIs. Drain
already calls glFinish; Web-only ledger now records sequence completion after
successful finish/no GL error, preserving error checks and strict verification.
Source: https://registry.khronos.org/webgl/specs/latest/2.0/#3.7.14 . Build session
99249 is live; logs build/godot-web/{drain-build-driver,build}.log. Must re-run
Firefox long case plus three-browser matrices before claiming current-source pass.

Windows normal restart80659 returned success after Tools update. CUA currently
shows boot logo/loading; guest exec still reports boot/session unavailable.
No second restart or reset was attempted. macOS strict216000-frame soak75528
continues and must remain untouched until its actual-duration and drain checks.

Tools update reached installed version27.0.3-58680; guest installer visibly
reports success and requires Windows restart, with an automatic restart timer.
Clicked its Restart control; completion must still be observed, not inferred.
Attempted shared-path windows_capability.py launch returned2 without pipeline
results; later guest Test-Path returned False while task-owner text remained
readable. Intermittent prlctl Invalid argument also persists. Recheck commands
and shared folders after the required restart before retrying the pipeline;
there is no C# native acceptance report from this attempt.

Windows guest recovery observation: VM eventually reached desktop. One
--current-user command successfully returned Windows build 26200.9711 and a
second listed Python314 plus the existing task-owner marker/owned repo/shared
path as present. Later guest exec calls still failed with Parallels Invalid
argument. Existing Tools were 26.4.1-57516 while host prlctl is27.0.3. Used the
existing Update Parallels Tools menu; CLI now confirms state=installing. No
Windows reset/disk recovery or new security access was performed. New
tests/bindings/windows_capability.py stages the current new-query sources in
the owned checkout and runs native/Dotnet acceptance, retaining hashes/results;
syntax checked only, not executed while Tools are updating.

Android release test packaging now explicitly enables debuggable and the local
debug signing config only for dora.godot.test's dedicated prototype package ID.
Ordinary releases retain their original settings. This is necessary for the
driver's existing run-as report export; it is optimized-code acceptance rather
than production-package signing acceptance. Driver validates debuggable status
before installation and records package provenance. Existing native build and
Godot template_release compile sessions remain live and were not restarted.

Completed macOS continuation evidence: original session 32188 exited 0. Its
release-optimized-soak-108000/verification.json passes 108720 total frames,
360 soak samples, 1107 alias stamp pairs and both GPU reader drains with
pending/errors/PCM underruns all zero. Measured process runtime is 1179.849642s,
so this is a 19.7-minute pass, not the required 30-minute gate. Resource session
39459 exited 0 after observing original PID exit, recording 882.725s/88 samples
and RSS 66732032..173015040 bytes. This partial RSS window is not a leak verdict.

Ordinary application session 30064 exited 0. Both bundled-runtime and physically
missing-library cases passed their real Lua/public-API startup and pixel tests;
four PNGs total, native test entry absent, default runtime lookup with no env
override, valid case GPU producer/consumer close accounted with zero errors,
missing case no Godot engine startup and ordinary Dora content still animating.
Report: build/godot-runtime/ordinary-macos-release-acceptance-v2/verification.json.
Actual staged signed binaries/startup hashes are separate from source artifacts.
Visual inspection of the valid case confirmed cyan Godot cube plus green Dora
shape. Installer/update/distribution signing remain unverified.

Started strict follow-up: session 44686, PID75528, 216000 extra frames and
--min-runtime-seconds 1800, same unchanged optimized host/runtime. Resource
session35085 attaches near startup with 10-second sampling. Results directory
release-optimized-soak-216000 has no completion report yet. Android release
runtime and native-host sessions remain live; generated Android host compile
commands independently confirm -O2/-DNDEBUG in host-configuration.json.

Android Release work: build_android_runtime.py now accepts template_release,
uses optimize=speed and target-specific upstream JNI/STL output paths, and seals
a separate release/arm64/package with the real build target. Non-default debug
architectures also receive distinct outputs. Gradle accepts explicit
dora.godot.runtimePackage and dora.godot.buildDir without changing defaults.
run_node.py accepts --runtime-package, verifies the sealed inventory and then
compares the APK runtime hash. Python syntax checks passed; native runtime
build session 24433 and externalNativeBuildRelease session 72758 are live.
Logs: build/godot-android/release/arm64/{build,host-build}.log. API35 Pixel7 AVD
was started and adb reports emulator-5554 device. No Release compile/GPU pass
has been claimed yet. Existing Debug package and active macOS soak were retained.

Ordinary macOS Release host built successfully without
DORA_BUILD_GODOT_NODE_TEST, using a separate configuration and existing reusable
object cache. Output: build/godot-runtime/release-host-build/macosx/arm64/release/Dora.app;
log ordinary-macos-build.log confirms Application.cpp -O3 and the ordinary entry.
The executable lacks dora_godot_node_test_main and passes codesign verification.
No active soak binary/runtime was overwritten.

Added ordinary_macos.lua and run_ordinary_macos.py: stage an isolated bundle,
execute its actual Lua startup, load a runtime from the default resource path,
verify Godot cube pixels/animation and ordinary Dora drawing, then physically
remove the runtime and verify startup error plus continued ordinary rendering.
Both cases use public APIs, captures and normal app shutdown. Source and signed
executed artifacts are recorded separately; no installer or global Release
shutdown claim is implied. Python syntax check passed. Initial queued runner was
terminated before staging when its already-loaded implementation was superseded;
new runner session 30064 waits for live soak PID 69060, output
build/godot-runtime/ordinary-macos-release-acceptance-v2. No GPU result yet.

Continuation after tracking consolidation: observed original soak PID 69060
still alive and advancing through soak-32400.png; no completion report yet.
Attached sample_native_process.py with binary/start-time identity checks and
10-second RSS/CPU JSONL sampling (session 39459). This is a partial observation
window, not a startup baseline, GPU-memory measurement or leak pass. Added an
explicit --min-runtime-seconds acceptance gate for subsequent macOS runs;
insufficient duration fails instead of padding with idle time. The active run
was already launched and is not retroactively covered by the new argument.

Windows VM is running but visibly remains at the Windows boot logo/loading
screen; repeated prlctl guest exec cannot establish a session. No disk recovery,
reset or forced restart was performed. C# fixture now logs actual successful
GetUnsupportedReason calls; the runner requires this in both lifetimes, records
artifact hashes and rechecks them after execution, and records failure.json on
failure. Updated C# compilation passed in
build/godot-bindings-capability-csharp-query/compilation.json; runtime remains
unverified for the new query. Python syntax checks passed for all three changed
test tools. Original soak host/runtime binaries were not changed.

以下为整理 TRACKING.md 时迁移的逐轮记录，含已被后续结果取代的状态；当前结论以 TRACKING.md 为准。

## 推荐执行顺序

2026-10-29 macOS 优化组合短回归全部通过：`release-optimized-node-2/3/4` 各1000帧/15截图；`release-optimized-particles/verification.json` 为1000帧/13截图，真实 custom/standard GPUParticles2D 对 CPU参考、shader TIME 对独立脚本时钟、倍率/暂停/冻结resize均通过，最大相对时钟漂移0；`release-optimized-output/verification.json` 为1260帧/16截图，八种源码主动尺寸/拉伸模式、启动尺寸、SDL→Dora→Godot GUI输入、预乘合成与动画均通过。所有报告位于 `build/godot-runtime/`，GPU错误/未完成读者为0，正常退出。已启动同一优化host/runtime的108000额外帧耐久（目标约30分钟，实际以runtime_seconds为准），目录 `build/godot-runtime/release-optimized-soak-108000`。该长运行尚无完成报告，继续观察原进程，不能按已启动判通过。

2026-10-29 修正后 Release 运行闭环：`release-optimized-node-3` 原生用例与 `godot-bindings-capability/node-rust`、`node-wa` 三项均已生成严格通过报告；均实际正常退出并有 Logger/Godot/GPU 排空日志，新查询真正经 Wasm3 调用。旧 Rust 超时不能替代新报告，仍保留 before-quit-fix。host SHA256 `4b06f7c7db529dcffcfb584c28686d5bd8a3131d0bf3beb2dbe89f1ed05e4888`，runtime SHA256 `2e3f2ea69d9e7272b4aa8c5e0944b2fc0906a6f735ce0e0d52d1ec9422a1746d`。下一步执行优化组合2/4缓冲、GPU粒子、source-owned输出和30～60分钟耐久，不重启已经完成的构建。

2026-10-29 优化 Release+Release 正向验收：macOS host 实际 `-O3 -DNDEBUG`，在 `release-quit-fixed-build.log` 增量编入 SDL_QUIT/测试清理修正，并在 `release-test-exports-build.log` 显式保留 Apple 测试入口符号（否则 Release 隐藏符号使入口检查拒绝）。`build/godot-runtime/release-optimized-node-3/verification.json` 已通过 184 项 ABI 和 1,000 帧/15 截图的三缓冲、动画、暂停、输入、控制器、PCM、resize、aliases、双生命周期及完整退出/GPU 排空；GPU 错误/PCM 欠载为 0。报告带双端哈希和实际 runtime_seconds。Rust/Wa 新查询正在修正后的同一宿主+库上重跑（`build/godot-bindings-capability/node-rust`、`node-wa`）；首轮失败日志仍保留在 before-quit-fix 目录，不覆盖失败证据。尚待2/4缓冲、粒子/source-owned输出和耐久测试，不能标记整体 Release 验收完成。

2026-10-29 CI-01 耐久入口准备：测试宿主额外动画帧上限由 36000 提高至 216000（必须为 300 的倍数），`run_macos_node.py --soak-frames` 同步支持，禁止与 resize 混用，按额外帧数设置有界进程超时，并记录实际 runtime_seconds。此项仅完成入口/语法检查，未执行 30～60 分钟耐久；不能用帧数推断实际持续时间。优化宿主原会话仍存活、持续编译；结束后先增量编入测试退出/Release 清理修正，再进行原生和绑定回归，之后启动耐久。

2026-10-29 退出路径修复续验：首轮 Rust 运行在 180 秒后由 runner 判超时，原进程已终止；未生成成功报告，日志/截图/双端哈希已保留到 `build/godot-bindings-capability/node-rust-before-quit-fix/`。除 devMode 只通知问题外，又核对到 NDEBUG 的普通应用 SDL_QUIT 路径会 `_Exit`，Godot 测试入口现独立排除此快速退出，保证能验证运行库/GPU 清理。普通应用退出行为不变。新测试 runner 也会写独立 failure.json，保留明确错误类型。优化 host 仍在编译（原会话存活）；本轮结束后需增量重编译 Application.cpp 和 GodotNodeTest.cpp，再重跑 Rust/Wa 和原生节点，当前不算通过。

2026-10-29 Release host 配置发现：首轮 `-m release` host 已编译，但实际 clang 命令无优化参数；macOS 分支缺少 iOS 已使用的 mode.debug/mode.release 规则。已补规则，并另行输出 `release-optimized-host`，日志 `release-optimized-host-build.log` 已确认实际 `-O3 -DNDEBUG`，该轮编译仍在运行。首轮 host 保留供新增 Rust/Wa 能力查询回归：Rust 完成 1000 帧/15 截图、result=0 后未退出，因此尚无成功报告。采样显示仍在 SDL/bgfx 循环，Application.shutdown 在 devMode 下仅发通知；测试 stopGodotTest 已改为所有平台显式 SDL_QUIT（此前仅移动端如此）。需要当前运行自然超时并保留失败证据，再在修正后的宿主上重跑，不能把节点完成标记当作进程退出/排空通过。

2026-10-29 Release 库正向运行：`build/godot-runtime/release/abi-preboot/verification.json` 通过 184 项 ABI；`build/godot-runtime/release-library-debug-host-3/verification.json` 通过指定 Debug host + Release LibGodot 的 1,000 帧 GPU/音频/控制器/resize/aliases 回归，GPU 错误、PCM 欠载为 0，生产/消费排空。此结果证明优化后的运行库可以工作，不代表尚在构建的 Release Dora host 已通过。Release host 仍存活，日志进入 78% 的 imgui 编译阶段；完成后须继续执行 Release+Release 及 Rust/Wa 能力查询。

2026-10-29 macOS Release 库已编译：完整标准模块 template_release / optimize=speed 构建成功（日志 build-release.log，耗时约 8m25s）；包校验 `build/godot-runtime/release/package-integrity.json` 通过，3 文件/57745347 字节。库 SHA256 `2e3f2ea69d9e7272b4aa8c5e0944b2fc0906a6f735ce0e0d52d1ec9422a1746d`，manifest 记录 build_target。Release Dora host 仍在原构建会话运行；先用既有 Debug host 验证 Release 库，结果目录 `build/godot-runtime/release-library-debug-host-3`，不等同于 Release+Release 组合验收。粒子/source-owned 输出 runner 也已补显式 `--app`，避免后续误用默认 Debug host；语法检查通过。

2026-10-29 BIND-01 验收准备：`tests/bindings/run.py` 已支持显式 `--app` 和 `--library`，指定 macOS app 时只验证签名而不修改包；运行前后核对 host/module/runtime 哈希，最终报告附带哈希。新增能力查询已同步到中英文类对象 API 文档，并修正实例文档中过时的 171ms Web PCM 预填充说明，写明三浏览器矩阵与短音调探针范围。Python 语法检查通过；Rust/Wa 新能力查询仍待新宿主执行。两项 Release 构建仍在原会话推进，未判定编译通过。

2026-10-29 回归入口验收：`build/godot-runtime/explicit-pair-runner-debug/verification.json` 证明 `run_macos_node.py` 已在指定既有 Debug host/library 上实际执行通过；184 项 ABI、1,000 帧、音频/控制器/resize/aliases、双生命周期 GPU 排空通过，GPU 错误和 PCM 欠载为 0，报告包含前后核对的双端 SHA-256。这不是 Release 或最新宿主源码的验收。两项 Release 编译会话仍存活且持续产生编译日志；Godot 正在 modules/thirdparty 阶段，Dora 已进入 shader/spirv 优化依赖阶段。包校验另补两项负例：封存拒绝已有来源/版本不一致的身份，校验拒绝缺少 native/Web runtime 载荷；总计 11 项通过，现有 Web/iOS 实包仍通过强化后的检查。

2026-10-29 Release 续建：已给 macOS Godot 测试宿主增加独立 `DORA_GODOT_TEST_TARGETDIR`，使用单独 XMAKE_CONFIGDIR、`-p macosx -a arm64 -m release` 配置和 release-host-build 对象目录，正在构建 Release Dora 到 `build/godot-runtime/release-host`（日志 `release-host-build.log`）；不会覆盖默认 Debug host。Godot template_release 仍在原会话编译，日志 `build-release.log`。新增 `tests/run_macos_node.py`，显式指定 app/library/results，校验测试入口和签名，执行 ABI 与 GPU 回归并记录/前后核对双端哈希；host-mode 为声明，须由独立构建配置佐证。当前仅语法检查通过，尚未宣称 Release 运行通过。两项构建完成后执行该入口，要求音频/控制器/resize/aliases；再执行 GPU 粒子与 source-owned 输出回归。

2026-10-29 PKG-01 Release：macOS 构建/测试入口新增 `DORA_GODOT_TARGET=template_release`，开启 `optimize=speed`、关闭调试符号/LTO；独立输出 `build/godot-runtime/release/package`，保留默认 Debug 包。运行库包清单记录真实 build_target。已启动首轮完整标准模块 Release 编译，日志 `build/godot-runtime/build-release.log`；尚无编译成功或运行结果，不能标记通过。待完成后执行包校验、ABI、实际节点 GPU/音频回归，并独立构建/验收 Release Dora 宿主。

2026-10-29 PKG-01 追加：macOS 重封装库实际加载并通过 184 项启动前 ABI 边界检查，报告 `build/godot-runtime/package-integrity-abi/verification.json`（仅 ABI，不新增 GPU 证据）。Android 随包 `libc++_shared.so` 的 NDK 许可已补充：NDK28.1.13356709 的 NOTICE 和 NOTICE.toolchain 包含 LLVM/libc++/libc++abi 声明，Android 构建打包入口现在自动带入并加入许可证哈希清单。含 notice 实包验证报告 `build/godot-android/package-integrity-notices.json`，7 文件/255695640 字节；这补齐已识别的 STL 声明缺口，不代表全部第三方许可审计完成。

2026-10-29 PKG-01 多平台实包：Linux ARM64、Windows x64、Android ARM64 现有运行库已使用当前工具重新封装并完整校验（未重新编译其运行库）。报告分别为 `build/godot-linux/package-integrity.json`、`build/godot-windows/package-integrity.json`、`build/godot-android/package-integrity.json`。Android 清单包含 JNI/STL 依赖树，5 文件/254379563 字节（包含根目录与 JNI 中的同一运行库副本）。iOS simulator/device 两份 Framework 从哈希已核对的既有 archive 重新链接，本地 ad-hoc 签名、签名校验、导出符号与 Mach-O 平台检查通过，完整包校验报告分别为 `build/godot-ios/simulator/package-integrity.json` 和 `build/godot-ios/device/package-integrity.json`。这些是开发包完整性，未证明真机执行、分发签名或跨机器可复现；ABI 动态调用和最终宿主部署仍需分别验收。许可证清单哈希通过不等同于第三方许可完整性审计，尤其要补核对 Android 随包 STL 的许可。

2026-10-29 PKG-01 证据：当前 Web 构建已生成统一清单，实际 7 文件/110077059 字节包的校验通过，报告 `build/godot-web/package-integrity.json`；macOS 重新封装实际库的报告为 `build/godot-runtime/package-integrity.json`。打包入口在清单写入后自动调用只读校验；可用 `--output` 将独立报告写在包外，失败前会清除旧报告。签名验证、运行时 ABI 调用、其他平台新清单实际打包、Release 和最终应用分发仍未完成。

2026-10-29 当前跨浏览器结论：按需 PCM 新运行库的 Chrome 156、Firefox 153、Playwright WebKit 26.5 均通过 2/3/4 缓冲矩阵，合计 5,580 帧、108 张截图、990 项像素检查；三者均通过音调、节点两次生命周期、GPU 排空和平台服务清理，PCM 欠载/GPU 错误为 0。WebKit 新报告 `build/godot-web/webkit-demand-matrix/verification.json`。WEB-01 的已复现队列欠载已修复，但保持进行中，等待浏览器实际输出连续性/端到端延迟和复杂混音压力验证；不能把 PCM 队列不欠载等同于音频设备没有掉音。WEB-02 的真实 Safari/移动浏览器验收仍未完成。

2026-10-29 WEB-01 追加验收：新版按需 PCM 的 Firefox 2/3/4 与 Chrome 2/3/4 均严格通过，各浏览器 1,860 帧/36 张截图/330 项像素检查，欠载/GPU 错误为 0。Firefox 报告为 `build/godot-web/firefox-demand-pcm-3/verification.json` 和 `build/godot-web/firefox-demand-matrix-24/verification.json`；Chrome 为 `build/godot-web/chrome-demand-matrix/verification.json`。已计时用例 Firefox PCM 调用平均 0.436～0.462ms、最大 1.48ms，Chrome 平均 0.074～0.078ms、最大 2.24ms；这些是当前简单场景的 JS→WASM PCM 调用耗时，不是音频端到端延迟，也不证明实际音频设备无输出掉音。WebKit 新运行库 2/3/4 矩阵正在执行，目录 `build/godot-web/webkit-demand-matrix`。待完成后，推进浏览器输出延迟/实际播放连续性和复杂混音负载测量。

1. 完成 IOS-01，确保普通 Dora 与可选 GodotNode 的硬件要求解耦。
2. 在等待 iOS 真机期间并行完成 WEB-01、WEB-02。
3. 完成 PKG-01，把实验运行库变成可复现的可选产物。
4. 获取设备后执行 IOS-02、HW-01，并把结果写回平台矩阵。
5. 依次推进 REC-01、INPUT-01、AUDIO-01 和 CI-01，再评估正式发布门槛。


## 2026-10-29 用户确认硬件边界与本地跟踪整理

用户确认继续采用 Dora Apple2 / Godot Apple4，并要求将进展和待办整理到本地文档。TRACKING.md 为当前交接入口；本节保留整理依据。

本次只读核对 Application.mm 的 Apple2 与 GodotRuntimeMetal.mm 的 Apple4 检查，未修改硬件策略代码。TRACKING 顶部补充能力边界、进展/缺口摘要和最新活动节点停止测试证据，并修正 CI-01 的旧“远程 CI 未执行”表述：PR #159 已推送且远程流程已启动，最终状态仍需按同一提交刷新，不能用旧检查点冒充实时结果。本次未查询远程、未提交或推送。

读取并确认 Web active-stop-strict-audit/verification.json：9 个实际浏览器用例、18 张原生截图、不同别名槽/动画/48000帧音调与排空检查通过，两个反例均被拒绝；这是既有运行的离线严格复核，不增加实际运行次数。当前工作区 Debug 宿主的范围已注明。读取 macOS active-stop-macos-3/execution.json：普通 Release 宿主保留活动节点及三个别名，frame142 时请求停止，8.4134秒、退出0、产物哈希记录通过；尚无独立严格图像/GPU汇总验收，不将其提升为完整通过。未启动新测试或重跑已有用例。

后续顺序保持：远程 CI/产物与错误面 → 真浏览器/音频 → Apple4+ iOS 和其他真实硬件 → 恢复/输入/控制器 → 普通 Release 分发、复杂项目和统一性能基线。模拟器 Apple2 普通 Dora 与 Godot 安全拒绝已验证，Apple4+ 真机正向共享仍待开发者模式设备及有效签名。


## 2026-10-29 普通 Release 活动节点退出缺口与修复

上一轮整理跟踪文档属于进展。本轮按 CI-01/RUNTIME-01 刷新同一远程提交6c4b7fd的实际状态：10工作流success，iOS/Godot仍in_progress；Linux EGL job123125908694仍在同一构建/测试步骤，未因观察超时重启。macOS CPU协议、Web Ubuntu Chromium故障清理均success，下载产物12855288710/12855464163并比对GitHub digest、检查内容；源码队列SHA匹配提交。Web关闭音频/释放输入/IME且无pageerror，不作为GodotGPU验收。产物证据见TRACKING当前远程节。

读取已结束的active-stop-macos-3原生用例：exit0而无最终GPU/PCM记录。公共严格verifier拒绝；图像离线条码检查通过并单独记录，execution.json保留其仅执行范围。实际代码定位普通NDEBUG SDL_QUIT分支std::_Exit，跳过引擎显式清理。修复在GodotNode会话start被接受后设置进程内atomic标记，Application仅对使用过Godot的进程执行正常清理。标记不因节点移除重置；普通Dora无Godot使用保留快速退出。未改Apple2/Apple4策略。

为保护已审计v4源码/二进制，以APFS复制创建active-stop-native-source，只叠加上述三文件修改。首次准备脚本把工作目录误当根目录，嵌套路径失败而后续依赖构建仍启动，确认任务PID22971后SIGINT主动结束130；未运行任何原生用例。改为绝对根路径、先准备成功再独立构建；最终session37093退出0，155.703秒、使用缓存，源文件前后SHA与active-stop-source-delta.json一致。不是当前远程PR tree原样构建，也没有重编封存LibGodot。

新增run_active_stop_macos.py/verify_active_stop_macos.py；与Web共用精确的条码图像校验模块active_stop_images.py。复用原Web原生case做单次离线校验通过，未重跑浏览器。三个新的macOS原生用例（session44025、27844均退出0）分别保留2/3/4槽别名和活动节点至公开App.shutdown，最终严格报告全部通过：produced/completed149/149、153/153、152/152；读者pending0/错误0、PCM欠载0、48000帧双声道音调439/659、Metal验证无错误、6截图动画与槽差异通过。完整清理日志出现Director/BGFX、Godot shutdown与Logger释放。

随后run_ordinary_macos.py（session52557退出0）对新普通Release宿主执行随包与缺库两项，共4截图通过；节点先移除后仍走正常清理，缺库时普通Dora继续动画。Python/Pillow getdata弃用提示不属于运行时错误，未据此重跑或改产品。

active-stop-fixed-evidence/verification.json完成产物、日志、报告和10截图证据审计，封存测试源文件；旧Release缺排空和篡改pending1均被拒绝且无残留成功报告。初版审计误将active-a图像键当作完整文件名，生成报告前失败；补.png后离线完成，没有重跑原生测试。原始失败/日志均保留。

修复和本轮测试尚未提交或推送。当前远程CI仍属于6c4b7fd，不继承其绿色结果。下一步补GL/移动普通Release的活动退出与启动中退出覆盖，收口候选后再推送必要代码修复并跟踪新CI；现有运行中的Linux job继续观察。跨平台、真机、恢复和正式分发总目标保持未完成。


## 2026-10-29 Linux NDEBUG Release 构建启动与 macOS 启动中退出

上一轮实际Release修复/回归属于进展。本轮从TRACKING继续RUNTIME-01/CI-01/DIST-01：当前PR6c4b7fd远程iOS现success，合计11个工作流success，仅Godot Integration未终态；同一Linux EGL job123125908694仍在构建/测试主步骤，未重启。记录godot-remote-ci-6c4b7fd-linux-release-checkpoint.json。

Linux VM e241815e仍running，task-owner.txt精确Dora-Godot-CI-20261029，旧本地测试/编译均已结束。发现Dora Linux target未启用mode.release规则，模式名不构成优化/NDEBUG证明；在Projects/xmake/engine.lua的Linux分支补mode.debug/mode.release。源码直接导出6c4b7fd归档SHA89c745457c601175906f80f1424caf900962892b6bc3667bd90b76ee686db790，独立新目录active-stop-release/repo叠加8文件overlay，未改旧v4目录源码。新run_active_stop_linux.py/verify_active_stop_linux.py保留相同条码/别名/排空校验，记录实际OpenGL渲染器；使用SDL dummy音频，不能计真实音频输出。

磁盘实测仅991166464空闲，无法直接克隆旧6.6GiB构建树。确认无旧checkout活动进程、核对四个保护SHA后，只删除本任务可重建的build/.objs、build/runtime/cargo及Godot bin/obj；清理后空闲3687526400，旧运行库6997eb3c、测试宿主51ff851e、普通宿主541089e0、源归档9a014676均哈希不变。没有删源码、运行库包、可执行文件或失败/成功报告。清单active-stop-linux-cache-cleanup.json。探测ccache时工具不存在、直接prlctl传Python-c参数被其拼接机制拒绝均仅发生在只读预检；后续改脚本文件调用，无测试重跑。

新bootstrap/session19119已完成准备并启动runuser86996、真实worker87000，xmake87070，/proc启动标记分别1489051/1489388且命令身份真实存活。编译命令已观察-O3/-DNDEBUG；尚未完整构建或运行矩阵。worker随后自动执行三缓冲优先，再二/四缓冲和普通应用随包/缺库两项，全部通过后才写聚合报告。progress中的child_exit_code0在build时是此前configure结果，不能当作完成证据。watch-export脚本/session34046仅观察原PID和启动计数，终态0后才调用完整源文件/包/产物/图像导出审计；不自动重启、终止原任务。回执active-stop-linux-handoff.json记录同一句柄和下一步。

等待期间实际执行macOS普通Release启动中退出：run_early_stop_macos.py复制旧已通过退出修复的普通Release应用，创建节点后立即断言running=false、调用公开App.shutdown。session40074退出0；Godot在退出事件处理前随后启动，produced/completed2/2、readers4/4、pending/错误0、PCM4096/0/欠载0，完整Director/BGFX/Logger清理，无Metal验证错误。报告early-stop-fixed-macos/verification.json。这不是持续图像/设备丢失验收。

新增可复用verify_early_stop.py对同一原日志做独立严格GPU/PCM复核和pending1反例，early-stop-macos-strict-audit/verification.json通过；属于离线复核、无额外原生运行。旧普通Release同fixture/session72612实际被新runner拒绝，failure.json为Engine cleanup must actually run；旧程序即使exit0也没有清理记录。失败原目录保留，无成功报告。README补充Linux活动退出与macOS启动中退出命令，脚本语法和所改文件diff空白检查通过。

本轮修复/构建规则/测试尚未提交或推送。下一步收集同一Linux本地/远程终态；本地通过后核验自动导出内容，再补GL启动中退出与NDEBUG CI，Windows普通EXE模式也需独立核实。整体多平台、真实硬件、恢复和发布条件仍未完成。


## 2026-10-29 Linux Release 原生与新CI入口通过、Safari授权后的认证门槛

上一轮真实修复/构建启动及macOS测试属于进展。本轮持续观察相同worker87000/xmake87070；完成后session19119退出0，导出观察34046退出0，没有重启。Linux优化NDEBUG普通宿主实际构建871.017秒，5进程/10截图连构建共906.887秒。2/3/4矩阵生产/完成93/93、78/78、80/80，读者/GPU/PCM排空且错误/欠载/pending0；随包/缺库各2截图也通过。复用6997eb3c运行库，不称为重编Release LibGodot。VM/llvmpipe、SDL dummy边界保留。

自动导出全源10734项、两符号链接、产物/包/日志/报告/10截图；84件文件50734528字节归档SHA805c46d42022d3dfa8b5c9df974dfa0b7122a19798c3941da946fa76c738b4cd。宿主完整核对，三个冻结verifier离线逐字节复现报告，active-stop-release-export/host-verification.json通过。此审计不增加原生执行次数。

新增ci_linux_release.py、run_early_stop_linux.py，复用verify_early_stop.py；Godot工作流在Debug整套后增加优化Release回归和产物上传。默认构建/检查-O3与NDEBUG，另支持必须有完整源码/编译命令/二进制回执的显式prebuilt复现。actionlint/脚本语法通过。为避免改变第一轮冻结产物，使用后一模式在相同已建宿主上实际执行新入口。

首轮CI入口/session24826在源审计报告读取时PermissionError（root导出文件归属），尚未开始任何场景；保留ci-release-entry/failure.json。仅调整该任务报告归属给parallels，修正导出器后续归属处理，在新目录v2运行/session84443退出0。新入口6进程/10截图、34.052秒全部通过，GL创建后立即退出也通过生产/完成1/1、readers3/3、pending/错误0、PCM4096/0/欠载0。原生头less GTK键盘seat Gdk-CRITICAL六条保留，不称为完整输入系统无诊断。

新CI入口68件文件43816字节归档SHA90c76c68b514e4609927bf582a45518a420c2160318d62abec25d936fbdf7529，宿主完整核对、映射第一归档的封存二进制、冻结verifier重现通过。首次离线比较tuple与JSON数组直接比较失败，改规范化结构后通过，无原生重跑；说明记录在host-verification.json。Linux早退出公开报告的范围文字随后仅澄清Dora/GPU检查与GTK诊断边界，校验逻辑不变。本地新入口使用prebuilt模式，不称为其默认构建分支或远程CI已完成。

期间用户明确授权Safari开启远程自动化并测试。CUA在开发者设置观察开关0，点击后系统提示密码认证，用户回复已完成；实际UI仍为认证窗口，SafariDriver新会话明确拒绝未启用。该次执行safari-native-current-3在页面加载前失败，非Godot/GPU兼容结论。已置前同一窗口并请求用户完成本机认证、确认勾选，不再次要求授权。未读取或输入密码，未修改跨源/本地文件限制等其他安全设置。认证未实际生效前不重复启动测试；后台Linux工作继续。

当前代码/新CI尚未推送；需要收口候选、取得旧远程Linux终态后按真实代码变更推进新CI。Windows普通EXE、移动退出、真实Safari/硬件/恢复/分发等仍未完成。


## 2026-10-29 远程6c4b7fd全绿与退出修复候选准备

远程Godot job123125908694现success，提交6c4b7fd全12工作流success。下载Linux artifact12858080284（167015071字节），zip SHA46765cfd5f590bcab7c341a737d487632121685df7d55753bc50d78a03ae2251匹配GitHub digest；16通过报告、203源文件SHA匹配提交，4674导出文件已哈希记录。实际原生x86_64 Azure / Mesa llvmpipe构建与测试2599.825秒、build_skipped=false，3000矩阵帧/100轮、失败退出恢复、普通宿主检查通过。按报告指定目录计369验收截图，另外35张为恢复副本/测试资产，总glob404不能都称原生独立采集。两份运行库字节SHA匹配；旧workflow没有上传宿主可执行文件，仅记录执行SHA，明确保留这个审计边界。

PR元数据证明head6c4b7fd、base6a05611e、synthetic merge7790c152。仓库git commit API证明merge tree3ebfee0c与head tree完全相同，GITHUB_SHA是合并提交而非headSHA。连接器commit数据包含过大的diff，实际树字段另用GitHub git对象接口只读获取，没有改变任何分支。远程平台状态更新为原生Linuxx64完整Dora节点执行通过（仍是软件GL而非物理GPU）。后续workflow补上传测试/普通Debug/Release宿主和完整Godot包，ci_linux源清单补Application.cpp/Debug.cpp/构建manifest三项；均属证据保留改进，不据此重跑旧CI或称新工作流已验收。

退出修复初版候选由私有索引基于6c4b7fd生成，显式21路径，tree16497bda38d41dd884dccc79b8bd8de96154388c，补丁99982字节/SHA dbc1c71a4eeced7f422fc8b3547d1235f177fb8e545a38871e2a5b60d6673924。另一私有索引应用后tree相同，真实索引和主HEAD不变，未纳入15个无关文件/共享接口缓存诊断。候选四个生产/构建文件与新LinuxRelease实际源SHA一致。

初版CPU协议按部分tree导出时漏了bgfx_shader.sh和bgfx_compute.sh，前半协议完成但聚合未生成；保留release-stop-protocol-driver.log。补同一tree原始两blob并在新输出release-stop-protocol-results-complete全套通过，没有修改源代码或GPU重跑。此后再补远程成功记录和CI证据保留改进，最终提交需按最终树/发布回执标注，初版tree不能冒充最终树。Safari第二次本机认证确认仍等待实际开关勾选，原生驱动预检失败不作兼容结论；授权本身已获得。


## 2026-10-29 原生Safari授权生效、DPR布局与端口预检修正

用户第二次确认完成认证并看到勾选后，CUA确实观察Safari开发者设置Allow remote automation=1，其他安全项保持0；关闭设置后由已授权原生WebDriver测试。此前safari-native-current-3失败为认证未生效的会话创建拒绝，未进入页面。

授权生效后的首个真实三缓冲safari-authorized-native-3实际620步/12图、GPU/PCM排空、输入API和平台清理完成，但严格像素校验在332,192处期望红色却读到背景，整轮passed=false保留。图像确认节点仅320×180，DPR2实际View2560×1440而截图1280×720。验收Lua原假定世界坐标等于截图像素；新增layout()按View.width/1280缩放节点与别名，只改GPU几何布局，不改像素采样要求或运行库。新日志确认factor2，红角标边长12→24；未放宽verify_node。

safari-dpi-native-3/session12918实际通过。矩阵94746保留该三缓冲并实际完成二缓冲；四缓冲在固定18748端口bind时失败，尚无页面/Godot执行，旧目录/失败日志保留。当前端口监听检查未发现活动listener，不能据此断言失败时的具体TCP状态。run_safari默认改0由OS选空闲端口，保留显式指定及启动前拒绝机制；保存旧helper用于溯源。仅四缓冲以新目录safari-dpi-native-4-auto-port/session72194继续，实际通过，未重跑2/3。

Safari矩阵1860步/36图/330检查，capabilities明确browser26.6.2/platformmacOS26.6.2/useSimulator=false/acceptInsecureCerts=false，Apple GPU，DPR2；6次客户端GPU/PCM排空、错误/欠载/pending0，48kHz音调440/660。DPR1 Chrome新布局另实际620步/12图/110检查通过/session84268，View1280×720 factor1；预期Emscripten主线程阻塞提示保留，不当成GPU错误或隐藏。

safari-dpi-evidence/verification.json封存新旧helper、Lua、公共采集/strictverifier与48图/运行库SHA；旧DPI数据复制到专用负例，仅把harness旗标设true以到达像素oracle，原始文件不改，严格像素仍被正确拒绝。这个离线反例/哈希检查不增加原生运行次数。继续用封存GodotWASM80982084和工作区coreDebug宿主fda4fcc1，不是新候选/Release构建；原生DOM/IME、移动Safari/Chrome、长音频与设备恢复仍待做。

授权已完成，后续不重复询问Safari自动化许可。当前新增node_game布局和Safari驱动端口修正须与退出修复/新CI一同收口最终候选。此前21路径tree为初版快照，不能当最终提交；真实主索引/HEAD和无关缓存/3D改动继续保留。
