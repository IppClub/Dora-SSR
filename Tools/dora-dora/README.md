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

Open a project file, then choose **Package → Web** in the development toolbar. The IDE saves open files, compiles the project, and downloads `<project>-web.zip`. Compilation errors stop the export. The ZIP includes the player, game assets, SHA-256 manifest, runtime capability manifest, and engine license notices. Deploy the extracted directory to a static host using HTTPS (or localhost); `file://` is unsupported.

The current export uses the single-threaded `dora-preset` Web Player and requires a compiled `init.lua`. Native-only APIs such as LoveNode, 3D physics, video, and the Wasm runtime are outside this profile. Export does not validate every game's API compatibility; test the resulting game in a browser.

`pnpm build` prepares the export runtime before building the IDE. For `pnpm dev`, first run `pnpm prepare:web-runtime`. The first preparation downloads the runtime pinned in `scripts/web-runtime-lock.json` from the official Dora gallery and verifies every file's SHA-256 and size. Later builds reuse the verified local cache. The generated runtime is excluded from Git and distributed in the IDE's static files; packaging a user's project does not upload game files or contact the gallery.

Run `pnpm test:web-package` to verify ZIP contents, resource hashes, loader compatibility, excluded private files, and invalid/oversized input rejection.
