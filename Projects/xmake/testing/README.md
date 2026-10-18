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
