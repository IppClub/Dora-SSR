# Native IDE validation — 2026-10-13

## Single-window revision

The IDE now shares the engine window, with an Android-style translucent side
handle and a menu for IDE/Engine, Stop and Reload. The earlier independent
window results below are retained as baseline evidence, not as acceptance of
the revised input routing.

- macOS arm64 build passed in 13.07 seconds; Windows x86 build passed in
  133.406 seconds. Current binaries were launched on macOS 26.6.2 and Windows 11.
- Both actual native IDE/TSTL lifecycle harnesses passed: background compilation,
  ready IDE takeover and recycling, hidden IDE compilation, fresh reload
  generation, Stop disconnect, background fallback and eight-second recycling.
  Logs: `/tmp/dora-integrated-lifecycle-mac-final.log` and
  `/tmp/dora-integrated-lifecycle-win.log`.
- Native macOS side-menu clicks showed IDE and returned to the engine in the
  same Dora SSR window, retaining the ready compiler connection. Clicking Stop
  returned to the engine and disconnected the IDE. The menu automatically hid
  after 3.5 seconds. Empty overlay areas use Cocoa hit-test passthrough.
- macOS direct Latin keyboard input appeared once. Command-S wrote the test
  source to disk; Command-A selected its actual contents and Command-Z undid
  an edit. Automatic paste produced no visible text in either Monaco or a
  normal HTML input. The user manually confirmed Command-C/V copy/paste and
  MENU -> Engine -> IDE switching work normally. The automatic clipboard
  result is a tooling limitation.
- Windows rendered both IDE and engine in the same original Dora SSR window.
  The user's saved engine size extends beyond the VM screen, and automated
  title-bar resize/input did not respond. Manual maximize and side-menu
  acceptance found no visible switching handle. Inspection found the executable
  lacked the Windows compatibility manifest required for layered child controls;
  the repair embeds that manifest and reports native control creation failures.
  The repaired build passed in 39.859 seconds, and the actual executable's
  embedded XML was checked for Windows 8/8.1/10 compatibility and asInvoker.
  A native screenshot confirms the repaired handle appears at the right edge
  of the visible screen while the saved engine window extends beyond it. The
  user manually confirmed entering IDE through the handle and switching back
  through MENU -> Engine work normally. Automated VM clicks do not reliably
  reach the guest. The full real compiler lifecycle rerun passed again in
  `/tmp/dora-integrated-lifecycle-win-overlay.log`.
- SDL browser/native-control events are excluded from game input. On macOS,
  SDL's text-input responder also leaves the embedded WebKit responder intact.
  Manual OS IME acceptance below predates this revised routing and was not
  repeated for the single-window build.

## Earlier independent-window baseline

Both earlier native builds passed real compiler lifecycle checks and native
file import/export verification. The user completed manual OS IME acceptance
on both platforms, separately from automated UTF-8 editing checks.

## Passed on macOS

Environment: macOS 26.6.2, arm64 debug native Dora, system WKWebView, Chinese UI.

- `xmake build Dora` passed, including the download-cancellation and IDE window-level changes.
  The final window-level build passed in 11.15 seconds; its actual lifecycle
  rerun is `/tmp/dora-nativeide-lifecycle-mac-topmost.log`.
- Frontend production build, JavaScript minification, asset versioning and
  synchronization passed. Resources were explicitly copied into the test app.
- `verify-native-ide.mjs` passed with the actual native IDE page and TSTL:
  background compilation, ready IDE takeover and background view recycling;
  hidden IDE compilation without a new background view; reload with a fresh
  compiler generation; stop disconnecting the session; background fallback and
  eight-second idle recycling. Output Lua was checked for the fixture value.
- `xmake dora-test --suite=web-ide --case=test-transpile-protocol` passed:
  one case, zero failures.
- Native window close and Command-Shift-H hide retained the compiler session.
  Command-Shift-L reloaded the page. Command-W closed an editor tab.
- Command-S saved actual UTF-8 Chinese source; Command-B generated Lua.
  Select all, paste, undo and redo worked in the native editor.
- Native upload chooser imported a Chinese-named file. Blob export opened the
  native Save panel. Imported and exported bytes matched the 47-byte source;
  SHA-256: `3bbd4500651fb4c1af025630f05c1deb09616bd6f313221aebc3422ca657a31d`.
- Direct keyboard input produced each Latin character once after fixing SDL's
  event routing for independent Cocoa windows. Before the fix it was doubled.
- The user manually confirmed Simplified Pinyin candidates appeared normally,
  committed `你好` in the test editor and saved with Command-S. This is
  user-observed acceptance, not a synthetic-key or clipboard result.
- `git diff --check` passed.

Runtime logs and a UI screenshot are retained locally under
`/tmp/dora-nativeide-*` and `/tmp/dora-native-ide-macos.png`.

## Passed on Windows

After the user restored Windows 11 to its desktop, the current x86 debug native
build passed (`xmake build Dora`, 152.515 seconds). Current Assets were staged
locally in `C:\DoraBuild\NativeIDEQA\Assets`; the test process ran from that
directory. `/status.platform` confirmed Windows.

The same real-compilation assertions as `verify-native-ide.mjs` were executed
through a PowerShell harness because Node was not installed on the guest:
ready native IDE takeover and background recycling, hidden IDE compilation,
reload generation and compilation, stop disconnect, background fallback and
idle recycling all passed. Fixture Lua contained the expected value, 42.
The Windows lifecycle log is `/tmp/dora-nativeide-lifecycle-windows.log`.

Native UI testing found that the user's existing always-on-top preview setting
obscured the IDE. Both desktop show adapters now inherit that setting without
changing the preference. The final Windows build passed in 30.094 seconds;
native UI retesting confirmed the IDE could be brought above the preview.
The final lifecycle rerun passed in
`/tmp/dora-nativeide-lifecycle-windows-final.log`.

- Ctrl-S saved Chinese UTF-8 source; Ctrl-B generated actual Lua. Chinese
  codepoints were verified independently in both files. Select all, paste,
  undo and redo worked.
- The system upload chooser imported `import.txt` into the test folder.
  Export opened the native Save As dialog and wrote `export.txt`. Source,
  imported and exported SHA-256 all matched:
  `aac6113f38b33e3cd18e403f6f12ea193d1c69576b812c7bbcf219e6a1d159b4`.
- The user manually confirmed Microsoft Pinyin candidate selection and
  committing `你好`, Ctrl-S saving, and Ctrl-W closing the test editor tab
  while using the native IDE. This is user-observed acceptance.
- Ctrl-Shift-H hid the window while retaining a ready compiler connection.
- Maximizing and restoring the native window resized the browser and toolbar.
  Moving between monitors with different DPI was not exercised.
- Terminating only the IDE's own WebView2 browser process reported a failed
  IDE and removed compiler readiness. Clicking the native Reload button
  recreated the browser and restored readiness with generation 2 -> 3.
  Logs: `/tmp/dora-nativeide-win-crash.log` and
  `/tmp/dora-nativeide-win-recover.log`.
- Installed stable WebView2 Runtime ran both IDE and background compiler.
  The existing SDK/static loader is reused; no browser kernel, Runtime
  installer or loader DLL was added to the package.

## Validation limits

- Windows Ctrl-Shift-L was not separately verified with a physical guest
  keyboard: Parallels consumes or remaps some host key combinations. Native
  Reload and API reload passed, including recovery after browser process failure;
  the host reload accelerator is implemented.
- Full frontend type checking remains affected by the pre-existing unsupported
  `ignoreDeprecations` setting with the installed TypeScript version; production
  build success above is not a claim that the full type check passes.

## Reproduce

Build Dora with the existing Windows xmake environment, synchronize current
Assets into the test application's local asset directory, launch it, disconnect
usable external IDEs, and run `verify-native-ide.mjs` from Node on Windows.
Then exercise native file import/export, Ctrl-S/B/W, clipboard and undo/redo,
Chinese IME composition, close/hide/reopen, DPI resizing and reload after browser
process failure. Check `/status` for the Windows platform and fresh compiler
generation. An older background-compiler build is not evidence for this change.
