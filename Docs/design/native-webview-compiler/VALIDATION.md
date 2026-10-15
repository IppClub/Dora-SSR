# Validation

Validation date: 2026-10-12 (checks continued after midnight). Source and generated Lua are both updated.

## macOS

Host: macOS 26.6.2, Apple Silicon. Native debug target built successfully with
xmake. Updated `Assets/` were explicitly staged into the application's
`Contents/Resources/` before final runtime checks; incremental native builds
alone do not update this existing resource copy.

The final `verify-native-compiler.mjs` run passed in 17.4 seconds, using the real
WKWebView compiler with Web IDE disconnected. It verified cross-file TS output,
TSX output, TS2322 diagnostics without an invalid Lua file, three simultaneous
build requests, a connected but unavailable IDE, a deliberately empty IDE Lua
response, 8-second idle recycling, startup failure propagation and subsequent
compiler recovery. Temporary projects were removed by the test.

Additional actual checks passed:

- `Agent.Tool.Build.build` from the isolated Agent command environment produced
  a successful one-file build. A cancelled TS build returned `interrupted=true`.
- A real Web IDE loaded in the browser reported compiler readiness, recycled
  the idle embedded view early, and successfully handled a subsequent build.
- After minimizing the native window, final cold-start compilation succeeded
  in 1.92 seconds. Before long polling, hidden timer throttling had delayed a
  request to about 19 seconds.
- A state request during cold compilation returned in about 20 ms. Before
  asynchronous scheduled HTTP handling, compiler assets could not load until
  the 15-second readiness wait timed out.
- Quitting while a compile request was pending disconnected that request and
  shut down cleanly without a hanging server or disposed-object error.

## Windows

Runtime verification is performed in the existing Windows 11 ARM64 VM, building
Dora's Windows x86 debug target. It uses the VM's installed WebView2 Runtime;
no browser runtime is installed or copied by this change.

The x86 debug native build passed. Actual requests against the running binary
passed cold-start TS (6.92 seconds), cross-file `math` imports, TSX, TS2322
without invalid Lua output, readiness reporting, idle recycling, restart and
`Agent.Tool.Build.build` (1/1 passed). Three concurrent build requests passed.
An injected startup failure was returned to the waiting request, and the next
request successfully restarted the compiler.

Connected fault peers verified fallback when the IDE reported unavailable and
when it reported success with empty Lua. A ready protocol peer then produced
Lua through the IDE route and verified that the embedded view was recycled
early. This Windows handover check used a protocol peer; the real browser IDE
handover was verified on macOS.

Installed Runtime process paths were
observed under `C:\Program Files (x86)\Microsoft\EdgeWebView\Application\154.0.4258.48`;
no private browser core was used. The controller remained invisible throughout.

The first actual Windows compile exposed a missing platform bootstrap in the
standalone compiler. Initializing shared paths from engine `/status` fixed it.
Verification also exposed that a compiler-only frontend rebuild did not
invalidate `.www`; the refresh fingerprint now includes `compiler.html`.
Final runtime checks used assets staged after both fixes.

## Shared validation and coverage limits

- Web IDE production build passed with Vite, minification, asset versioning and
  asset synchronization.
- `xmake dora-test --suite=web-ide --case=test-transpile-protocol` passed.
- `xmake dora-test --suite=web-ide --case=test-xrt-network-wrapper` passed.
- `git diff --check` passed.
- Full frontend `tsc --noEmit` is not clean in the current repository. The
  checked-in `ignoreDeprecations` value is rejected by the installed TS 5.9.3;
  overriding it to 5.0 exposes existing errors in other frontend/compiler
  modules. The output contains no errors in the modified Service/compiler page.
- This does not claim validation on macOS 12/13, separate Windows x64/ARM64
  binaries, or a newly built Android APK. Android's native adapter is unchanged;
  it uses the improved shared queue, readiness checks and compiler page.
