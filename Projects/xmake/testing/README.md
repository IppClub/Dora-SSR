# Test entrypoints and CI ownership

Test implementations and fixtures live in **Dora-Example**, under `Test/`.
Dora-SSR keeps the xmake launcher, build/release validators, and package-local
Go tests. Do not add a second copy of an external regression test here.

```sh
xmake dora-test --suite=contract
xmake dora-test --suite=engine
xmake dora-test --suite=ui
xmake dora-test --suite=studio
xmake dora-test --case=test_shutdown_watchdog -- --engine /absolute/path/Dora
```

The default launcher clones/fetches Dora-Example's latest default-branch HEAD,
then runs an immutable revision checkout. It records both repository revisions
and dirty states in `build/test-results/`. Local test development uses
`--repo=/absolute/path/Dora-Example` or `DORA_TEST_REPO`; it never resets that checkout.
CI resolves once per job with `xmake dora-test-deps --env-file="$GITHUB_ENV"`.
Every later test command in the job uses that same test revision.

| Workflow | Responsibility | Dependencies |
| --- | --- | --- |
| UI CI | Frontend/proxy tests, lint, typecheck, Vite build, Web export validation | Node/pnpm, xmake for the external runner and bundled Web runtime; IDE and linked Studio packages |
| Engine Tests | Contract tests, native HTTP/shutdown, Lua services; separate native Git backend job | Node, xmake, Python/C/C++, Lua; Go only in the Git job |
| Studio CI | Studio source tests, frontend and Go backend acceptance with a real built Agent host | Node/pnpm, Lua, Go, managed xmake compiler SDK |
| macOS / Web / Windows / Pages | Platform builds and artifact-specific validation | Existing platform toolchains |

UI generates shared contract declarations explicitly; it does not depend on
Studio tests having run. `Source/**` remains a UI trigger because the exported
Player runtime is built from current engine sources. Studio shared packages
trigger UI as well as Studio; these are shared inputs, not duplicate test cases.

`Test/ci-coverage.json` and `check_ci_test_coverage.test.mjs` in Dora-Example audit
previous coverage, single ownership, migrated test discovery, and representative
push/PR trigger paths. Source-only checks run in Engine Tests on branches/PRs;
Web tag publication retains its own source gate. Artifact checks with different
outputs/platforms are intentionally separate.

Publish the Dora-Example test migration **before** the corresponding engine CI
changes. An external test-only change does not generate an engine repository
push event: use the workflows' manual dispatch to validate it immediately, or
let the next matching engine push/PR resolve the latest tests.

## Network resource acceptance

`xmake dora-test --case=test_http_resource_limits` runs native HTTP/WebSocket
wire tests under ASan/UBSan. To also exercise a freshly built desktop engine and
its real IDE upload/read/save routes (requires unused ports 8866 and 8868):

```sh
xmake dora-test --case=test_http_resource_limits -- --engine /absolute/path/Dora
```

The server admits 64 HTTP and 16 WebSocket connections. Ordinary request bodies
are capped at 8 MiB with a shared 32 MiB ingress buffer budget (higher-level
request copies are bounded by those same leases). Known Content-Length bodies
reserve their actual size; chunked bodies reserve the full 8 MiB cap. Upload
routes retain the 512 MiB total multipart-body limit, with two concurrent uploads
spooled into anonymous files in the app's writable directory. Multipart parsing
and file copying use fixed windows and run off the shared network worker.
Oversized bodies receive 413, exhausted body/upload slots receive 503, and a
spool-file creation/write failure receives 507. Excess TCP connections close at
admission; there is no HTTP request to return a 429 to at that point.

Incomplete/idle HTTP requests and unfinished WS handshakes expire after 15
seconds of inactivity (WS uses a fixed handshake deadline). Partial ordinary
requests also have a 30-second total deadline; uploads have a ten-minute total
receive deadline. Established WebSockets are not closed merely for being idle.
Disconnects, rejection and shutdown release body leases and anonymous files.

## Agent storage maintenance

`xmake dora-test --case=test_agent_storage` runs the production storage Lua
against real SQLite through a small Dora boundary adapter. The engine suite
owns this regression; implementations and fixtures remain in Dora-Example.
For native codec, manual cleanup, HTTP and actual file rollback acceptance:

```sh
xmake dora-test --case=test_agent_storage --repo=/path/to/Dora-Example -- --engine /absolute/path/Dora
```

The native test requires free ports 8866/8868 and uses a disposable profile.
Add `--hold` to leave that window open for actual settings-panel button acceptance.
Storage maintenance is manual: open Status / Settings > Misc > Agent storage,
then click Clean orphan data. There is no startup or periodic cleanup job. A
user-triggered operation processes at most four tasks per frame and stops when
its initial attempt budget is exhausted. Usage is cached while the section is
open; Refresh usage reads it again. The cleaner protects every session's
current task, all RUNNING/WAITING_USER tasks, and the transitive closure of
their task references. Cycles terminate; failed transactions can be retried
manually, and failed reachability queries prevent deletion. It retains all chat messages and
current/referenced task checkpoints; it does not trim history or vacuum files.

The authenticated `POST /agent/storage/usage` endpoint is read-only. It reports
agent.db page allocation, used/free pages, row counts, UTF-8 payload byte counts,
raw/stored checkpoint bytes, and orphan candidates. These are database-only
statistics: project `.agent` files and transient journal files are excluded.
Free pages remain available for SQLite reuse, so reclaimed payload does not
imply an immediate reduction in database file size.

## Desktop GUI single instance

Standalone desktop GUI launches share one instance per user (per Windows login
session on Windows). CLI launches branch before this check and can run concurrently,
including alongside the GUI. Mobile, Web, and `DORA_AS_LIB` retain their existing
lifecycle. A duplicate exits with status 0; lock/notification failures exit with
status 1.

Windows and macOS queue activation, restore a minimized window, and print
`Dora GUI is already running. Activation requested for the existing window.`
Windows uses a named mutex, activation event, and PID mapping. If the launcher
cannot transfer foreground permission, the owner briefly shares the foreground
input queue. Native window state handles requests arriving before SDL pumps
minimization events. macOS uses `flock` and a Unix datagram socket, and queries
Cocoa's native window state during activation.

Linux uses `flock` only and prints
`Dora GUI is already running. Please use the existing window.`
It deliberately performs no automatic window activation or restoration in either
X11 or Wayland. Wayland compositors may reject activation without a valid token;
the same explicit policy is used for both backends. No X11-specific activation
code or vendored SDL activation patch is needed.

Ownership lasts through engine teardown. OS locks are released automatically
on crashes, and stale macOS IPC endpoints are replaced by the next owner.

Tests live in Dora-Example. During development, pass its local checkout:

```sh
xmake dora-test --case=test_gui_single_instance --repo=/path/to/Dora-Example
# Desktop integration: duplicate GUI processes and overlapping CLI executions.
xmake dora-test --case=test_gui_single_instance --repo=/path/to/Dora-Example -- --engine /absolute/path/Dora
# Native macOS/Windows activation test; use SDL2.lib and a VS developer prompt on Windows.
xmake dora-test --case=test_gui_single_instance --repo=/path/to/Dora-Example -- --sdl-library /absolute/path/libSDL2.a
# Run Linux GUI/CLI acceptance under both SDL backends.
SDL_VIDEODRIVER=x11 xmake dora-test --case=test_gui_single_instance --repo=/path/to/Dora-Example -- --engine /absolute/path/Dora
SDL_VIDEODRIVER=wayland xmake dora-test --case=test_gui_single_instance --repo=/path/to/Dora-Example -- --engine /absolute/path/Dora
```

The default test compiles the production instance module and exercises startup
races, concurrent launches, clean/crash recovery, and the platform activation
policy without a desktop. Optional macOS/Windows window tests require an unlocked
desktop. Engine integration requires unused ports 8866 and 8868. On Windows it
checks five minimize/relaunch cycles with foreground focus; on Linux X11 it
checks that a duplicate leaves a minimized window unchanged. Both Linux backends
check duplicate-launch messages and four overlapping CLI processes beside a GUI.
