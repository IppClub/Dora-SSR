import {spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
import {join} from 'node:path';

const root = fileURLToPath(new URL('../..', import.meta.url));
function run(command, args, env = process.env) {
  const result = spawnSync(command, args, {cwd: root, env, stdio: 'inherit', shell: process.platform === 'win32'});
  if (result.error) throw result.error;
  if (result.status !== 0) process.exit(result.status || 1);
}
const xmake = process.env.DORA_XMAKE || 'xmake';
run(xmake, ['studio']);
// The engine task installs Emscripten inside xmake's package environment.
// Load the completed Player configuration so subsequent pnpm builds inherit
// that same SDK instead of requiring an unrelated system emcc installation.
run(xmake, ['lua', 'Projects/xmake/tools/studio.lua', process.execPath,
  'Studio/scripts/build-packages.mjs'], {
  ...process.env,
  XMAKE_CONFIGDIR: join(root, 'build/studio-runtime-engine/.xmake-config'),
});
