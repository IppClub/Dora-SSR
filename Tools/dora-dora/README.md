# Dora Dora Web IDE

This project uses [Vite](https://vitejs.dev/) for development and builds, and integrates the external `Tools/YarnEditor` build output into the Web IDE.

## Available Scripts

In the project directory, you can run:

### `pnpm dev` / `pnpm start`

Runs the app in development mode.\
Open [http://localhost:3000](http://localhost:3000) to view it in the browser.

The page will reload if you make edits.\
You will also see any lint errors in the console.

### `pnpm build-yarn-editor`

Builds `Tools/YarnEditor` (platform-aware: macOS/Linux/Windows) and copies its `dist` output into `public/yarn-editor`.\
The target folder is refreshed automatically and `.gitkeep` is restored after copying.

Use this before `pnpm start` when you need the latest YarnEditor assets during local development.

### `pnpm build`

Full production build pipeline for Dora Dora Web IDE. It will:

1. Build and copy YarnEditor into `public/yarn-editor`
2. Run `vite build`
3. Minify generated JavaScript helper outputs
4. Copy the final `build` output to `../../Assets/www`

Both `public/yarn-editor` and `../../Assets/www` are refreshed automatically, and `.gitkeep` is restored after copying.

### `pnpm preview`

Serves the production build locally for verification.

### `pnpm lint`

Runs ESLint for `src`.

## Learn More

You can learn more in the [Vite documentation](https://vitejs.dev/).
