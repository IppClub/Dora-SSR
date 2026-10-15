# Native WebView TypeScript compiler

Dora Agent and `/ts/build` can compile TS/TSX without Web IDE on Android,
macOS and Windows. The desktop adapters reuse the existing compiler page,
virtual project snapshot, request queue and reference-counted lifecycle.

## Backend selection and lifecycle

- A WebSocket connection alone does not establish compiler readiness. Each
  `TranspileTSProbe` awaits TypeScript/TSTL warmup and reports `success`.
  A positive response from any connected IDE establishes readiness; negative
  responses from all IDEs, disconnects or the 5-second probe deadline cause
  desktop/mobile requests to use the embedded compiler.
- Web IDE build transport/runtime failures, missing Lua output or a 30-second
  build timeout also fall back. TypeScript diagnostics remain diagnostics;
  cancellation returns immediately without retrying another compiler.
- Embedded startup is lazy, with a 15-second readiness deadline. Concurrent
  requests share one WebView and use distinct job IDs. Successful output must
  contain Lua and must be saved successfully.
- A ready IDE takes over new requests. An existing embedded job is allowed to
  finish before its last user releases the WebView. Idle views close after
  8 seconds; an IDE becoming ready closes an unused view sooner. A close
  generation prevents an older idle task from closing a reused compiler.
- `/status` exposes `typescriptCompiler` readiness, users, queued jobs and
  native startup errors. `/compiler/poll` uses bounded long polling so hidden
  browser timer throttling does not delay dispatch.

## Platform integration

macOS uses system WebKit/WKWebView, a nonpersistent data store and a transparent
1-pixel view attached to the SDL window. Creation and disposal run on the
window thread. Navigation/load/process errors are returned to the logic thread.
On macOS 14 and later the inactive scheduling policy is explicitly disabled.

Windows uses WebView2 COM on the window STA thread. The SDK package installs
headers and the matching architecture's `WebView2LoaderStatic.lib` only. It does
not install or distribute a browser executable, fixed runtime, loader DLL or
runtime installer. Environment creation selects the installed stable Evergreen
Runtime; absence produces an actionable error directing users to install the
Runtime or connect Web IDE. User data lives under the local application profile,
not the potentially network-mounted workspace. Generation guards discard stale
asynchronous creation and failure callbacks.

Adding adapter and static loader code has a small executable cost; this is not
a promise of literally zero bytes added. No browser core is added to the package.

## HTTP prerequisite

XRT is built with coroutines disabled. A synchronous scheduled HTTP callback
waiting for compilation blocked the same network worker that had to serve
compiler assets, poll requests and results. Scheduled POST handlers now return
XRT asynchronous futures backed by bounded worker threads (maximum 32 active
requests). Request headers/body are copied for their asynchronous lifetime.
Shutdown cancels pending logic waits and waits for active handlers before
releasing the server wrapper. Ordinary short routes remain synchronous.

## Reproduction

Build and launch the native Dora target, close Web IDE tabs, then run:

```sh
node Tools/dora-dora/scripts/verify-native-compiler.mjs
```

The script creates and removes its own temporary project. It checks cross-file
Lua output, TSX, diagnostics, concurrency, unavailable IDE fallback, empty Lua
fallback, idle recycling and compiler restart. It requires Node with built-in
WebSocket support. Real Web IDE handover and native window background behavior
are additionally checked interactively.

Detailed results and platform coverage are recorded in [VALIDATION.md](VALIDATION.md).

The standalone compiler initializes the shared path implementation from the
engine's `/status` platform before warming up TSTL. It does not depend on the
IDE bootstrap or the browser host's operating system. The static resource
refresh fingerprint includes `compiler.html` so compiler-only bundle changes
also invalidate the cached `.www` copy.
