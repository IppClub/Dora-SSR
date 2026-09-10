// Local browser behavior tests; intentionally not part of CI.
import fs from 'node:fs';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const build = path.resolve(process.argv[2] || path.join(root, 'build/web'));
const source = path.join(root, 'build/web-api-contract-source');
const output = path.join(root, 'build/web-api-contract');
const run = (script, args = [], env = {}) => execFileSync(process.execPath, [path.join(root, 'Tools/build-scripts', script), ...args], {cwd:root, stdio:'inherit', env:{...process.env, ...env}});
fs.mkdirSync(source, {recursive:true});
fs.copyFileSync(path.join(root, 'Projects/Web/api-contract/init.lua'), path.join(source, 'init.lua'));
run('check_web_api_parity.mjs', ['--emit', path.join(source, 'expected.lua')]);
run('package_web_game.mjs', [source, output], {DORA_WEB_GAME_PROFILE:'dora-preset', DORA_WEB_EAGER_GAME_ASSETS:'1'});
for (const name of ['dora-player-runtime.js', 'dora-player-runtime.wasm', 'dora-player-runtime.data', 'dora-web-features.json']) fs.copyFileSync(path.join(build, name), path.join(output, name));
fs.copyFileSync(path.join(build, 'dora-player-runtime.html'), path.join(output, 'index.html'));
run('check_web_game_smoke.mjs', [output], {DORA_WEB_SMOKE_LOG:'1'});
