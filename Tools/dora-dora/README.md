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

`PlayerShell.ts` owns the exported page, loading logo, progress callbacks, and format-specific entry script. Export does not consume gallery or compiler HTML, so minification and external markup changes do not affect it. `HtmlArchive.ts` only converts package resources; `HtmlPlayer.ts` loads them in the browser. `RuntimeAdapter.ts` contains compatibility with the verified gallery player: its complete JS fingerprint identifies the snapshot/audio interface, and only that verified artifact receives the legacy audio URL patch. An unknown JS build is rejected for HTML export even if it contains similar source snippets; HTTP export remains available. When upgrading the runtime, verify its snapshot/audio behavior and update the adapter with the lock. A matching engine version or checksum alone does not establish HTML compatibility.

The current export uses the single-threaded `dora-preset` Web Player and requires a compiled `init.lua`. Native-only APIs such as LoveNode, 3D physics, video, and the Wasm runtime are outside this profile. Export does not validate every game's API compatibility; test the resulting game in a browser.

`pnpm build` prepares the export runtime before building the IDE. For `pnpm dev`, first run `pnpm prepare:web-runtime`. The first preparation downloads the runtime pinned in `scripts/web-runtime-lock.json` from the official Dora gallery and verifies every file's SHA-256 and size. Later builds reuse the verified local cache. The generated runtime is excluded from Git and distributed in the IDE's static files; packaging a user's project does not upload game files or contact the gallery.

After preparing the runtime, run `pnpm test:web-package` to verify both ZIP formats, independent page generation, the adapter against the actual runtime JS, local resource loading, resource hashes, excluded private files, and invalid/oversized input rejection. Browser smoke tests are still required to verify the real WASM/snapshot and audio lifecycle; the loader unit tests use a simulated DOM.

Run `pnpm test:web-runtime-preparation` to check local runtime preparation, cache reuse, ignored compiler shells, and checksum failure handling in an isolated temporary directory.

To test a rebuilt engine before publishing a runtime release, set `DORA_WEB_RUNTIME_LOCK` to an absolute path to a separate lock file with the same schema. Its `baseUrl` may be a `file:///` directory containing the rebuilt player files. Size and SHA-256 checks still apply; an `index.html` entry in an older lock is ignored. Use that environment variable for every prepare/build invocation; without it, preparation restores the official pinned runtime. Local overrides do not bypass the HTML compatibility adapter. A rebuild without the snapshot interface can only use HTTP export.
