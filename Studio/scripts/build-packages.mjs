import {spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';

const studio = fileURLToPath(new URL('..', import.meta.url));
for (const args of [['-r', 'build'], ['build:agent-host'], ['build:server']]) {
  const result = spawnSync('pnpm', args, {cwd: studio, stdio: 'inherit', shell: process.platform === 'win32'});
  if (result.error) throw result.error;
  if (result.status !== 0) process.exit(result.status || 1);
}
