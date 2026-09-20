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

The current export uses the single-threaded `dora-preset` Web Player and requires a compiled `init.lua`. It includes Model3D, Jolt 3D physics, and the Rust bridge; native-only APIs such as LoveNode, video, and the dynamic Wasm runtime remain outside this profile. Export does not validate every game's API compatibility; test the resulting game in a browser.

`pnpm build` prepares the export runtime before building the IDE. For `pnpm dev`, first run `pnpm prepare:web-runtime`. If the runtime is missing, fails its size/SHA-256 checks, or lacks the 3D export features, preparation invokes `Tools/build-scripts/build_web.sh` and builds the single-threaded `dora-preset` player from the current local source tree. Later builds reuse the verified local cache. Rust must meet the minimum version in `Projects/Web/toolchain.env`; newer Rust releases are accepted. Drift in other locally installed build tools is reported as a warning so the local IDE build can proceed. It does not depend on a deployed gallery. The generated runtime is excluded from Git and distributed in the IDE's static files; packaging a user's project does not upload game files or contact the gallery.

After preparing the runtime, run `pnpm test:web-package` to verify both ZIP formats, independent page generation, the adapter against the actual runtime JS, local resource loading, resource hashes, excluded private files, and invalid/oversized input rejection. Browser smoke tests are still required to verify the real WASM/snapshot and audio lifecycle; the loader unit tests use a simulated DOM.

Run `pnpm test:web-runtime-preparation` to check the automatic local build, cache reuse, corruption repair, ignored compiler shells, and explicit override checksum handling in an isolated temporary directory.

For a reproducible runtime override, set `DORA_WEB_RUNTIME_LOCK` to an absolute path to a separate JSON lock containing `engineVersion`, `baseUrl`, and a `files` map of `{size, sha256}` entries. Its `baseUrl` may be a `file:///` directory or an HTTP(S) URL containing the player files. This is the only mode that reads a runtime from a URL. Size and SHA-256 checks still apply; an `index.html` entry in an older lock is ignored. Use that environment variable for every prepare/build invocation. Overrides do not bypass the HTML runtime structure checks.
