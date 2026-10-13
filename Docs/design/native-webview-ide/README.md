# Desktop application Web IDE

macOS and Windows mount the local Web IDE inside the existing engine window.
A translucent handle at the right edge opens a small switching menu, following
Android. Opening `http://localhost:8866/` shows this embedded IDE; other URLs
retain their normal behavior. The engine continues running behind the IDE.
Native IDE and background compiler views have separate lifetimes.

## Window and session behavior

- Show lazily opens the IDE and focuses the browser's native text input view.
- The menu switches between IDE and Engine. Switching to Engine hides the
  browser, retaining the page, editor buffers and WebSocket compiler connection.
  The handle reads IDE over the engine and MENU over the IDE. The menu closes
  automatically after 3.5 seconds. Closing the main window exits Dora.
- Stop IDE navigates to `about:blank`, returns to the engine and disconnects its
  session. The next TS build can start the background compiler.
- Reload loads the local IDE again. Persistent browser storage retains IDE
  preferences and authentication state; unsaved buffers should be saved first.
- A ready IDE takes new build requests. Existing background jobs finish before
  their last user releases the compiler. Idle background views close after
  eight seconds, or earlier when an IDE becomes ready.
- Stop appears over the engine once the IDE has been loaded; Reload appears
  over the IDE. Host shortcuts are
  Command/Ctrl+Shift+H and Command/Ctrl+Shift+L. Editor save, run, build, close
  tab, undo/redo and clipboard commands retain their existing bindings.
- Window size, fullscreen, DPI and always-on-top settings apply to both views
  because they share the engine window.
- `POST /ide` accepts `show`, `hide`, `stop`, `reload`; `/status.nativeIDE`
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
