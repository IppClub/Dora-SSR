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
