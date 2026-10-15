import { build } from 'esbuild';
import { createRequire } from 'node:module';
import { copyFile, mkdir } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
const require = createRequire(import.meta.url);
const target = new URL('./dist/browser/', import.meta.url);
await mkdir(target, { recursive: true });
await copyFile(require.resolve('typescript'), new URL('typescript.js', target));
await copyFile(resolve(dirname(require.resolve('typescript')), '../LICENSE.txt'), new URL('LICENSE.typescript.txt', target));
await copyFile(resolve(dirname(require.resolve('@dora-studio/tstl')), 'LICENSE'), new URL('LICENSE.tstl.txt', target));
await copyFile(new URL('./src/worker-loader.js', import.meta.url), new URL('worker.js', target));
await build({
  entryPoints: [new URL('./src/worker.mjs', import.meta.url).pathname],
  outfile: new URL('compile-worker.js', target).pathname,
  bundle: true, format: 'iife', platform: 'browser', target: 'es2022',
  alias: {
    path: require.resolve('@dora-studio/tstl/path'),
    typescript: require.resolve('@dora-studio/tstl/browser-typescript'),
    url: require.resolve('@dora-studio/tstl/browser-url'),
  },
});
await build({ entryPoints: [new URL('./src/client.ts', import.meta.url).pathname],
  outfile: new URL('client.js', target).pathname, bundle: true, format: 'esm', platform: 'browser', target: 'es2022' });
