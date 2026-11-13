# Repository importer

The built-in `Tools.RepositoryImporter` program uses the normal Entry run/stop
lifecycle. A desktop or Android link starts it with a repository URL; running the tool directly
shows a URL input with clipboard paste and Enter submission.

```js
const link = `dora-ssr://open?repo=${encodeURIComponent(repositoryUrl)}`;
```

Public HTTPS repositories on GitHub, AtomGit, Gitee and GitCode are supported. The
encoded link is limited to 2048 bytes for desktop activation transport. Both `open`
and the Windows Shell-normalized `open/` form are accepted. No website metadata
API is used. The protocol registration belongs to the macOS app, Windows MSI (or
`RegisterDoraLinks.cmd` beside a portable Dora.exe), and Linux desktop entry. Android registers a BROWSABLE `dora-ssr://open` Intent
filter and forwards the original encoded URI through JNI on cold start and
`onNewIntent`. The consumed Intent is cleared to prevent recreation from replaying
an import, and SDL never receives the URI as a dropped file. Android also hides
and restores the embedded IDE around the importer using the same program flow.

Each activation stops/unloads the current program and re-enters the importer,
including repeated clicks. It does not stop the long-lived Agent service: Agent
work has the same lifetime and execution rules as with other project switches.

Git clones into a unique hidden workspace directory, without fetching repository
LFS endpoints, then verifies resources and locates the shallowest Dora init entry.
Only a verified checkout is moved into its final workspace directory. Unload marks
the operation canceled; its async continuation waits for Git's terminal status
before removing the temporary directory. Completed imports have a marker inside
`.git` and are reused without checkout, pull, reset, or modification of local files.

The success screen does not run the imported code. It lists live IDE sessions,
distinguishing embedded and browser IDEs and ordering them by recent activity.
A targeted WebSocket message opens the workspace in only the chosen session; an
acknowledgement is required before reporting success. An embedded IDE is revealed
on success; an external IDE leaves a “switch to your browser” result in the tool.
Without an IDE, View project returns to the engine launcher and reveals the entry.
Done exits without changing the edited project and restores a previously visible
embedded IDE. Source-only TS/TSX entries are listed but require an IDE build.

Shared `lualib_bundle` identity is kept across scene unloads because persistent
services and temporary project modules exchange TSTL Promises.

Validation:

- `python3 Tools/Tests/test_project_links.py`: production parser and repeated IPC
  activation, including the maximum accepted payload size.
- `go test ./internal/gitjobs` from `Source/3rdParty/Wa/Source`: LFS opt-out and
  ordinary Git behavior.
- Compile Import.ts, View.tsx, Controls.tsx, Dev/ImportIDE.ts and Dev/Entry.yue with
  the running engine; compile RepositoryImporter.yue with the same Yue pipeline.
- Web IDE: `pnpm lint`, `pnpm exec tsc --noEmit`, `pnpm build:frontend`.
- Native macOS: `xmake build Dora`, then URL activation, cancellation/re-entry,
  preservation of tracked/untracked changes, and both IDE handoff paths.

Android validation:

- Compile the Java activity and merged manifest with Gradle (the Java-only check
  can use `-Pdora.godot=false -Pdora.android.abis=arm64-v8a`).
- Compile-check Application.cpp using the Android NDK arm64 compile command.
- On a test device/emulator with a freshly built APK, send the following command
  once with Dora stopped, then again while a game/import is running. Verify
  re-entry, cancellation cleanup and embedded IDE restoration; rotate/recreate
  the activity and verify the consumed link is not replayed.

```sh
adb shell am start -W -a android.intent.action.VIEW \
  -d 'dora-ssr://open?repo=https%3A%2F%2Fgithub.com%2FIppClub%2FDora-Example' \
  org.ippclub.dorassr
```
