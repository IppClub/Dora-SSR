# Desktop application Web IDE

macOS and Windows mount the local Web IDE inside the existing engine window.
On macOS, Windows and Android, the translucent left-edge IDE handle always
opens the editor directly. Inside the IDE, MENU offers Engine, Reload and Close.
The desktop engine address link opens the external browser through `App.openURL`.
The engine continues running behind the IDE.
Native IDE and background compiler views have separate lifetimes.

## Runtime opt-in

`App.webIDEEnabled` defaults to `false` on each engine launch. A packaged game
that supplies its own startup script gets no switching handle or host toggle
shortcut. It does not inherit the development launcher's saved preference.
The normal Dora development entry enables this feature by default and exposes
the **Embedded Web IDE / 内嵌 Web IDE** checkbox in its settings.

Custom startup scripts can opt in explicitly:

```ts
import { App } from "Dora";
App.webIDEEnabled = true;
```

```lua
Dora.App.webIDEEnabled = true
```

Set the property to `false` to cancel composition, restore engine input focus,
disconnect and release the IDE, remove the switching controls and unregister
the host shortcut. Re-enabling recreates the controls and lazily creates a new
IDE session. Save editor changes before disabling. The local Web IDE server
and frontend assets must be available for a custom application to open the IDE.
This switch does not stop or disable the independent background TS compiler.
`/status.nativeIDE.enabled` reports the runtime setting, and `/ide` rejects
actions when it is disabled.

## Window and session behavior

- Show lazily opens the IDE and focuses the browser's native text input view.
- Engine in the IDE menu hides the
  browser, retaining the page, editor buffers and WebSocket compiler connection.
  The handle reads IDE over the engine and MENU over the IDE. The menu closes
  automatically after 3.5 seconds. Closing the main window exits Dora.
- A successful Run / Run This from the embedded IDE hides it and returns focus
  to the engine, retaining the page and compiler session. Compile/startup errors
  leave the IDE visible. Remote browser runs do not switch the embedded view.
  Switching, stopping or reloading while a run is pending cancels its automatic
  return; later runtime errors retain the existing handling.
- Close returns to the engine and disconnects its IDE session without disabling
  the IDE entry. macOS explicitly closes the page's WebSocket lifecycle, then
  releases the WKWebView and its message handlers, rather than retaining a page
  navigated to `about:blank`; Windows and Android navigate
  to `about:blank`. Clicking IDE opens a new session.
  The next TS build can start the background compiler.
  Page unload cancels reconnect timers and pending transpiler warmup, so an old
  document cannot reconnect after Close. A restored browser-cache page starts
  a fresh connection lifecycle.
- Reload loads the local IDE again. Persistent browser storage retains IDE
  preferences and authentication state; unsaved buffers should be saved first.
- A ready IDE takes new build requests. Existing background jobs finish before
  their last user releases the compiler. Idle background views close after
  eight seconds, or earlier when an IDE becomes ready.
- The engine handle never opens a menu. The IDE menu lists Engine, Reload and
  Close in that order and has no additional actions. Host shortcuts are
  Command/Ctrl+Shift+H toggles Engine/IDE in either direction;
  Command/Ctrl+Shift+L reloads the visible IDE. Editor save, run, build, close
  tab, undo/redo and clipboard commands retain their existing bindings.
- Window size, fullscreen, DPI and always-on-top settings apply to both views
  because they share the engine window.
- `POST /ide` accepts `show`, `hide`, `stop`, `reload`, `toggle`; `/status.nativeIDE`
  reports support, state and error text. Compiler connection generation is
  reported to distinguish a fresh reload handshake from a prior connection.

## Platform implementation

macOS uses system WKWebView as a subview of SDL's existing NSWindow, persistent
website storage,
NSOpenPanel for files/folders and multiple selection, and WKDownload with an
NSSavePanel for HTTP and Blob exports. JavaScript alert/confirm and external
links are delegated to native interfaces. The Edit menu uses Cocoa's responder
chain. SDL's Cocoa translator excludes embedded native controls and browser views,
leaving their keyboard, mouse and IME events to Cocoa. SDL text input cannot
replace the native browser responder. Empty overlay areas pass clicks through
to the engine.
Command-W from Cocoa's Window menu is forwarded to the IDE's close-tab handler.

Windows uses the existing SDL engine HWND, an installed stable Evergreen WebView2
Runtime and the existing SDK/static loader. No browser executable, fixed Runtime,
loader DLL or installer is added to Dora's package. The browser child HWND owns
keyboard/IME focus; only host shortcuts are intercepted. Native file inputs use
WebView2's file chooser. DownloadStarting obtains a deferral and then opens the
system Save As dialog after the callback returns, supporting ordinary and Blob
exports without entering a modal loop inside a WebView2 callback. The native side handle, menu and
browser bounds follow window size and DPI changes. The IDE profile is stored
under the local application directory, separately from the compiler profile.
The executable embeds a Windows 8/8.1/10 compatibility manifest required by
Win32 layered child windows (see [Microsoft's documentation](https://learn.microsoft.com/en-us/windows/win32/winmsg/using-windows)).
Creation failures are reported through native IDE status. The side controls
follow the visible client area when a saved window extends beyond its monitor,
without changing saved window settings.

Both adapters keep web navigation on the local service, and send HTTP/HTTPS
external links to the system browser. Existing HTTP/WebSocket authentication
rules are retained. Application shutdown releases both native views and overlay controls before
SDL destroys the engine window.
The frontend ignores shortcut dispatch during IME composition, including the
legacy keyCode 229 case, before preventing browser defaults.

## Toggle shortcut and input ownership

Command+Shift+H on macOS and Ctrl+Shift+H on Windows/Android switch directly
between Engine and IDE. Android supports hardware keyboards; the floating
button remains available for touch input. Only the Dora window handles the
shortcut. Repeated key-down events and the corresponding key-up are consumed.
The shortcut and side-menu switch use the same show/hide paths, preserving the
page, unsaved buffers and compiler session. Close and Reload remain separate.

Switching cancels unconfirmed IME text before transferring focus, retaining
confirmed text and ordinary selections. macOS clears the marked range and
ends the Cocoa conversion session. Windows cancels IMM candidates and awaits
Chromium composition cancellation before hiding the browser. Android uses the
active input connection on its designated handler thread, waits for cancellation
before changing focus, protects ordinary selections, intercepts
hardware shortcuts before the IME, and hides the soft keyboard. Focus returns
to the native browser or engine surface. The logic thread cancels engine input
consumers before releasing pressed keys, and clears queued ImGui key state.

Android also supports the same `/ide` actions and native IDE status reports.
For guest/device compilation verification, set `DORA_REMOTE_FIXTURE=1` and
`DORA_COMPILER_URL` when invoking the retained verifier; it creates and removes
its project through the existing file APIs. When access verification is enabled,
set `DORA_IDE_AUTH_FILE` to a local JSON file containing an approved session's
`sessionId` and `sessionSecret`; the verifier signs requests using the existing
Web IDE protocol. Never commit that session file.

Windows declares Per-Monitor V2 DPI awareness in its embedded application
manifest, with PerMonitor and legacy true/pm fallbacks. WebView2 retains its
normal automatic monitor scaling and uses raw pixel bounds from the parent
client area; no page zoom is used to simulate high-DPI rendering.

## Desktop responsiveness

While the IDE is visible, the render thread uses a 1 ms timeout when waiting
for a submitted bgfx frame before polling native events. macOS also services the Cocoa RunLoop;
Windows yields through the native message queue. macOS also dispatches ready
RunLoop sources while the IDE is hidden or closed, without waiting, so WebKit
can complete socket teardown and background work. This bounds the frame semaphore
wait, not GPU submission or presentation time. Visibility is atomic because the
main and logic threads both read it.

The engine skips scene drawing while the opaque IDE covers it. Simulation,
services and bgfx resource processing continue; explicit game captures request
fresh drawing. Presentation temporarily omits VSync without changing the
requested View.vsync setting. Returning to Engine restores normal presentation
and drawing. While the IDE is visible, the engine sleeps to its target FPS even
when the requested unlimited mode is enabled, avoiding empty-frame flooding.
Hidden/stopped IDEs restore the usual engine scheduling and requested settings.

The editor keeps one pending validation timer per file and checks the latest
snapshot after 500 ms of inactivity. Stable Monaco options and callbacks avoid
repeated option updates during typing. Workspace editors apply their editable
policy explicitly on mount; definition/peek protection remains in place.
Deferred saves remember the requested file across tab changes and wait for an
in-flight save. A successful write does not clear edits made after its snapshot.

## Validation

With external usable IDEs disconnected, launch the native engine and run:

```sh
node Tools/dora-dora/scripts/verify-native-ide.mjs
```

This script creates/removes its own project, uses the real IDE compiler and
checks show, hidden compilation, reload generation, stop, background fallback
and recycling. File dialogs, editor shortcuts and OS input-method composition
require native UI verification. Verified results and outstanding checks are
recorded in VALIDATION.md.
