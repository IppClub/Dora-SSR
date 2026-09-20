import { readFile, writeFile, mkdir, copyFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { createHash } from 'node:crypto';
import { build } from 'esbuild';
import {validateGameRuntimeProfile} from './runtime-profile.mjs';

// Explicit build input: never silently serve a stale or single-thread Player.
const runtime = process.env.STUDIO_RUNTIME_DIR;
if (!runtime) throw new Error('Set STUDIO_RUNTIME_DIR to a built pthread Player directory');
const source = resolve(runtime);
const output = new URL('../../../../build/studio-runtime/', import.meta.url);
const features = JSON.parse(await readFile(resolve(source, 'dora-web-features.json')));
validateGameRuntimeProfile(features);
const names = ['dora-player-runtime.html', 'dora-player-runtime.js', 'dora-player-runtime.wasm',
  'dora-player-runtime.data', 'dora-web-features.json', 'audio-worklet.js', 'dora-audio-mixer.wasm'];
const contents = new Map(await Promise.all(names.map(async name => [name, await readFile(resolve(source, name))])));
const engineSource = contents.get('dora-player-runtime.js').toString();
const builtinFont = engineSource.match(/\/builtin\/Font\/sarasa-mono-sc-regular\.ttf.{0,64}?start:(\d+),end:(\d+)/s);
if (!builtinFont || Number(builtinFont[2]) - Number(builtinFont[1]) < 1_000_000) {
  throw new Error('Studio Player requires the full Chinese font; rebuild with '
    + '-DDORA_WEB_BUILTIN_FONT="$PWD/Assets/Font/sarasa-mono-sc-regular.ttf"');
}
const engineVersion = engineSource.match(/input\.engineVersion\s*!==\s*["'](\d+\.\d+\.\d+)["']/)?.[1];
if (!engineVersion) throw new Error('Cannot identify the Player engine version; refusing an unbound Studio runtime');
const hash = createHash('sha256');
for (const [name, bytes] of contents) hash.update(name).update('\0').update(bytes);
const engineBuild = hash.digest('hex');
const html = contents.get('dora-player-runtime.html').toString();
const engineScript = /<script\s+async\s+src=["']?dora-player-runtime\.js["']?\s*>/;
if (!engineScript.test(html)) throw new Error('Unknown Player shell structure; refusing unsafe injection');
await mkdir(output, { recursive: true });
for (const name of names.filter(name => !name.endsWith('.html'))) await copyFile(resolve(source, name), new URL(name, output));
await build({ entryPoints: [new URL('../src/runtime-entry.ts', import.meta.url).pathname],
  outfile: new URL('studio-runtime.js', output).pathname, bundle: true, platform: 'browser', format: 'iife',
  target: 'es2022', define: {
    __STUDIO_ENGINE_BUILD__: JSON.stringify(engineBuild),
    __STUDIO_ENGINE_VERSION__: JSON.stringify(engineVersion),
  } });
await writeFile(new URL('index.html', output), html.replace(engineScript, match => `<script src="studio-runtime.js"></script>${match}`));
await writeFile(new URL('studio-runtime.json', output), JSON.stringify({ engineBuild, engineVersion, profile: 'dora-preset', entry: 'index.html' }, null, 2));
console.log(`Studio runtime prepared: ${output.pathname} (${engineBuild})`);
