# Dora Dora Web IDE

This project uses [Vite](https://vitejs.dev/) for development and builds. YarnEditor is integrated as a Vite multi-page entry under this project.

## Available Scripts

In the project directory, you can run:

### `pnpm dev` / `pnpm start`

Runs the app in development mode.\
Open [http://localhost:3000](http://localhost:3000) to view it in the browser.

The page will reload if you make edits.\
You will also see any lint errors in the console.

### `pnpm build`

Full production build pipeline for Dora Dora Web IDE. It will:

1. Run `vite build`, including the YarnEditor page and assets
2. Minify generated JavaScript helper outputs
3. Copy the final `build` output to `../../Assets/www`

The final `../../Assets/www` output is refreshed automatically.

### `pnpm preview`

Serves the production build locally for verification.

### `pnpm lint`

Runs ESLint for `src`.

## Learn More

You can learn more in the [Vite documentation](https://vitejs.dev/).

## Web game export

Open a project file, then choose a format from **Package** in the development toolbar. Both formats save open files, compile the project, and include the Dora SSR loading screen and engine license notices. Compilation errors stop the export.

- **Web (HTML)** downloads `<project>-web-html.zip`. Extract the entire ZIP and double-click its root `index.html`; no server is needed. Keep the accompanying files. WASM and game resources are encoded as classic JavaScript files, verified, and passed to the player's in-memory snapshot interface. Audio uses local Blob and data URLs. This format also works on static hosting, but encoding increases package size and all resources are loaded into memory at startup.
- **Web (HTTP Server)** downloads `<project>-web-http.zip`. Deploy the extracted directory to a static host using HTTPS (or localhost). It contains the player, binary game assets, and SHA-256 manifest; opening it through `file://` is unsupported.

Use a modern browser with WebAssembly and Web Crypto support. HTML export isolates saved data by package directory, so moving the extracted directory changes its save location.

`PlayerShell.ts` owns the exported page, loading logo, progress callbacks, and format-specific entry script. Export does not consume gallery or compiler HTML, so minification and external markup changes do not affect it. `HtmlArchive.ts` only converts package resources; `HtmlPlayer.ts` loads them in the browser. `RuntimeAdapter.ts` applies the legacy audio URL patch only when both expected runtime expressions occur exactly once; incompatible generated JavaScript is rejected instead of being partially rewritten.

The current export uses the single-threaded `dora-preset` Web Player and requires a compiled `init.lua`. It includes browser-compatible Dora gameplay features, including LoveNode, Model3D, Jolt 3D physics, and the Rust bridge. Yue, Teal, and XML compiler support is intentionally omitted because Web IDE exports package their generated Lua. APIs that require native host capabilities, such as the embedded HTTP server, native video playback, and dynamic Wasm loading, also remain unavailable in a standalone browser export. Test the resulting game in a browser because browser security and graphics-driver differences can still affect individual games.

`pnpm build` prepares the export runtime before building the IDE. For `pnpm dev`, first run `pnpm prepare:web-runtime`. If the runtime is missing, fails its size/SHA-256 checks, or lacks the 3D export features, preparation invokes `xmake dora-web` and builds the single-threaded `dora-preset` player from the current local source tree. Later builds reuse the verified local cache. Rust must meet the minimum version in `Projects/Web/toolchain.env`; newer Rust releases are accepted. Drift in other locally installed build tools is reported as a warning so the local IDE build can proceed. It does not depend on a deployed gallery. The generated runtime is excluded from Git and distributed in the IDE's static files; packaging a user's project does not upload game files or contact the gallery.

After preparing the runtime, run `pnpm test:web-package` to verify both ZIP formats, independent page generation, the adapter against the actual runtime JS, local resource loading, resource hashes, excluded private files, and invalid/oversized input rejection. Browser smoke tests are still required to verify the real WASM/snapshot and audio lifecycle; the loader unit tests use a simulated DOM.

Run `pnpm test:web-runtime-preparation` to check the automatic local build, cache reuse, corruption repair, ignored compiler shells, and explicit override checksum handling in an isolated temporary directory.

For a reproducible runtime override, set `DORA_WEB_RUNTIME_LOCK` to an absolute path to a separate JSON lock containing `engineVersion`, `baseUrl`, and a `files` map of `{size, sha256}` entries. Its `baseUrl` may be a `file:///` directory or an HTTP(S) URL containing the player files. This is the only mode that reads a runtime from a URL. Size and SHA-256 checks still apply; an `index.html` entry in an older lock is ignored. Use that environment variable for every prepare/build invocation. Overrides do not bypass the HTML runtime structure checks.

### Web IDE origin protection and local development

The engine validates Host and parses Origin before dispatch. Authentication is
fixed by the request source; there is no `authRequired` setting or script property.

| Client | Protected HTTP APIs and WebSocket |
| --- | --- |
| Loopback peer, loopback Host and matching HTTP page Origin | No authentication |
| HTTP page on 8866 connecting to WS on 8868 | Same policy as the page |
| LAN device or configured domain, including same-origin pages | Authentication required |
| Direct cross-origin HTTP(S) page, including another localhost port | Authentication required |
| CLI/server-side client without Origin | Authentication required |

Browser requests without Origin can use the local exemption only with
`Sec-Fetch-Site: same-origin` and a real loopback peer and Host. Public static
GET/HEAD navigation remains available without Origin. Cross-site and same-site
subresource requests identified by Fetch Metadata still require authentication,
even when the browser omits Origin. `/auth` and `/auth/confirm`
remain public bootstrap endpoints; PIN/session approval still controls issuing a
session. Opaque (`null`), malformed or duplicate origins and untrusted Hosts are
rejected even with authentication. No forwarded header grants local access.

For a valid concrete cross-origin request, CORS echoes that Origin, allows the
session-signature headers and handles OPTIONS without authentication. The actual
request, including cross-origin static GET/HEAD, must authenticate. Responses vary
by Origin, and authenticated cross-origin responses use `Cache-Control: no-store`.
WS upgrades require the existing session signature too. Local access remains
available after remote sessions expire; cross-origin access does not bypass expiry
or nonce replay protection.

Allowed Hosts are localhost, loopback and interface addresses at startup.
For an explicit DNS name, set `DORA_WEB_IDE_HOSTS=dora.local` (comma-separated exact
names, no scheme or port) and restart. This allows the Host; it never exempts the
client from authentication. The policy is identical on desktop and mobile.

Run the frontend with `pnpm dev`. HTTP uses `/__dora/api/…`, and WebSocket uses
`/__dora/ws`. Vite validates the original Host and concrete Origin before proxying to fixed
loopback engine ports. Only local loopback clients get their validated Origin
rewritten to the engine page Origin. LAN clients keep their original Origin and
must authenticate; clients without Origin retain authenticated CLI semantics.
Signatures cover the engine path without the development prefix. HMR is separate.

A TLS reverse proxy must preserve the external browser Origin when forwarding to
the engine, overwrite `Sec-Fetch-Site` with `cross-site` for remote clients, and
must not turn remote traffic into local same-origin traffic by
rewriting Origin to the loopback engine origin. The engine ignores client-supplied
forwarded headers for authentication exemptions.

Regression checks (from this directory):

```sh
python3 ../../Tools/tests/test_http_origin.py
python3 ../../Tools/tests/test_http_origin_wire.py
node --test scripts/ide-dev-{proxy,proxy-wire,client}.test.mjs
pnpm test:auth-reconnect
pnpm test:websocket-lifecycle
```

Native acceptance (graphical desktop, ports 8866/8868 free), from the repository root:

```sh
xmake build Dora
python3 Tools/tests/test_http_access_native.py --engine build/macosx/arm64/debug/Dora.app/Contents/MacOS/Dora
```

This uses isolated assets and exercises real session signatures, preflights,
static access, HTTP/WS replay rejection, loopback and LAN source checks, and
asynchronous handlers. Add `--hold` to keep the fixture running for the browser
page at `http://127.0.0.1:8866/browser.html`. Serve `Tools/tests/fixtures` with the
Vite proxy on 18736 and open `/http-access.html` for browser CORS/WS verification.
The fixture's known token is test data only and never enters the normal runtime.
