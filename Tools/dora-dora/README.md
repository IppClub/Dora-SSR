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

Use a modern browser with WebAssembly and Web Crypto support. HTML export isolates saved data by package directory, so moving the extracted directory changes its save location. The runtime lock also pins the snapshot interface and two audio resource URL expressions used by HTML export; update and test both formats when upgrading it.

The current export uses the single-threaded `dora-preset` Web Player and requires a compiled `init.lua`. Native-only APIs such as LoveNode, 3D physics, video, and the Wasm runtime are outside this profile. Export does not validate every game's API compatibility; test the resulting game in a browser.

`pnpm build` prepares the export runtime before building the IDE. For `pnpm dev`, first run `pnpm prepare:web-runtime`. The first preparation downloads the runtime pinned in `scripts/web-runtime-lock.json` from the official Dora gallery and verifies every file's SHA-256 and size. Later builds reuse the verified local cache. The generated runtime is excluded from Git and distributed in the IDE's static files; packaging a user's project does not upload game files or contact the gallery.

Run `pnpm test:web-package` to verify both ZIP formats, local resource loading, resource hashes, loader compatibility, excluded private files, and invalid/oversized input rejection.
