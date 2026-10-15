# Go game packages

Go exposes **Share game / 分享作品** on local game cards and completed Remix sessions. The **+ New / + 新建** menu contains **New game / 新建作品** and **Import package / 导入作品包**. Sharing packages code and assets into a ZIP snapshot, then offers the native share sheet or export picker. No hosted links or account are required.

Android accepts ZIP `ACTION_VIEW` and `ACTION_SEND` deliveries, including cold starts, and copies content URIs while their temporary grant is valid. iOS declares `public.zip-archive`; a Dora subclass of the SDL app delegate copies incoming document URLs into the native inbox before queuing them, including deliveries before SDL's event queue starts. An external file waits until the local launcher is idle; it does not interrupt gameplay, Remix, or a Web IDE session. The preview does not execute code. **Import & play / 导入并试玩** installs and starts the game; **Import / 仅导入** focuses its local card. Conflicting names receive a numeric suffix without overwriting the existing project.

## Package contract

- A runnable `init.lua`, `init.yue`, `init.tl`, `init.xml`, or `init.wasm` at the project root is required. Build TypeScript projects before sharing. Legacy ZIPs containing a single enclosing project folder are also accepted.
- Export preserves source, assets, licenses, and the allowed `.dora/repo.json` and banner files. Hidden state, `node_modules`, `__MACOSX`, `credentials.json`, `config.db`, and log files are excluded. This filename filter is not a secret scanner for source code.
- `dora-package.json` contains `format: "dora-game"`, `version: 1`, `title`, `engineVersion`, and `entry: "init"`. Existing manifest fields, including optional author and provenance, are retained. Packages from a newer engine are rejected with an update prompt.
- ZIP size is capped at 256 MiB; total uncompressed size at 512 MiB and file count at 10,000. Path traversal, absolute paths, drive prefixes, and backslash archive paths are rejected before extraction. These size/count limits are optional parameters of `Content.unzipAsync`; existing callers remain unlimited.
- Extraction uses a fresh `.share` staging directory. Metadata and entry validation happen before a local project is created. Cancel/failure removes the staging directory. Successful installation moves the validated root into a unique destination.
- Export snapshots and native picker copies remain available for system consumers; entries older than seven days are pruned when that cache is next used. Original selected files are never deleted.

## Platform boundaries

`App.shareFile` and `App.saveFileDialog` report dispatch, not delivery or save completion. Android displays save/failure feedback from the native operation. iOS uses the system sheets. Desktop fallback opens the directory containing the exported package; it does not present a mobile share sheet. `App.openFileDialog(false, ...)` selects ZIP files on mobile; folder selection remains desktop-only. `App.takeReceivedFile()` drains externally opened paths and callers must validate them.

## Regression checks

In Dora-Example, generate disposable fixtures with `python3 Test/Mobile/mobile_package_fixtures.py <Dora appPath>`, compile `Test/Mobile/PackageTest.ts`, then run its generated Lua in Dora with Dora-Example on the search path. Read `<appPath>/mobile-package-test.result`. The test covers source/asset retention, private-state exclusion, Unicode naming, immutable snapshots, runnable installed entries, collision copies, cancellation, malformed/oversized/unsafe archives, and legacy ZIP layouts. Test projects are removed in `finally`.

Build Android and iOS with the repository platform wrappers. Device acceptance additionally requires native picker cancel/retry, saving and reopening a ZIP, incoming cold/warm starts, import-and-play followed by exit to the card, rotation/safe-area layout, and repeating the cycle with another recipient. A successful build alone does not establish cross-app delivery on a physical device.

## Verified on 2026-09-05

- macOS Debug, Android Debug (three ABIs), and iOS Simulator builds passed. Generated Lua syntax and package round-trip regression passed.
- On iPhone 17 Pro / iOS 26.5 Simulator: local share sheet, native Save to Files, picker cancellation and retry, reopening the saved ZIP, import-and-play, exit back to the imported card, and same-name source preservation passed.
- Selecting Dora from the iOS system share menu delivered a ZIP to the running app. Go displayed its receive preview after the existing sheet closed; import-only returned to the new local card.
- Follow-up with an OPPO A3x 5G / PKD130 running Android 15: iOS-exported ZIP transferred via the host into Downloads, selected in the Android system picker, imported, played, and exited back to its local card. Android native share and Save document dialogs passed; sharing from the system Files app to a stopped Dora also cold-started into the preview and imported/played successfully. Warm ACTION_SEND delivery was checked as well.
- Android re-exported the imported game through Save package. That ZIP was transferred back through the host to iOS Files, shared to stopped Dora, imported, played, and exited back to a new collision-safe card. Both runtime/source files matched byte-for-byte across the round trip. Transfer hashes matched at each hop.
- This exposed and fixed iOS cold-start delivery loss: UIKit opened the document before SDL initialized its event queue. The app delegate now copies and queues the document independently of SDL startup. The iOS Debug build and real Files-to-Dora cold-start sequence passed after the fix; warm Files-to-Dora delivery and cancellation were then rechecked successfully.
- Android used an isolated `org.ippclub.dorassr.sharetest` debug install because the existing app had a different signing certificate; the original app/data were preserved. Two-device transport here used the computer to relay ZIPs. Direct chat/AirDrop/nearby transport and physical iOS hardware remain unverified.

- Compact UI follow-up: the local-card share button is 84 x 36; package sheets measure their text instead of reserving 370 points. On the Android device, the smaller share button, restored + New label, compact add/share sheets, and transition into the new-project form were visually checked.

- Opening stability: share sheets retain their surface and controls while exporting; completion updates only the detail label. `PackagePanelTest.ts` checks sheet identity and height across async export and waits for the final size label; the in-engine check passed. The updated Android test app was installed and its share sheet was reopened three times with stable geometry.

- Measurement lifecycle regression: temporary Labels used to measure sheet text are cleaned up immediately. Otherwise Dora adopts them into the main scene, producing overlapping text in later screens. The extended panel test failed on the previous Lua and passed after the fix, checking scene child counts during export and after closing. On Android, opening add/share sheets, closing them, and entering the AI template configuration screen no longer left overlapping text in the center.
