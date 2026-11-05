import {spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';

const studio = fileURLToPath(new URL('..', import.meta.url));
const root = fileURLToPath(new URL('../..', import.meta.url));
function run(command, args, cwd) {
  const result = spawnSync(command, args, {cwd, stdio: 'inherit', shell: process.platform === 'win32'});
  if (result.error) throw result.error;
  if (result.status !== 0) process.exit(result.status || 1);
}
run(process.env.DORA_XMAKE || 'xmake', ['dora-studio'], root);
run('pnpm', ['-r', 'build'], studio);
run('pnpm', ['build:agent-host'], studio);
run('pnpm', ['build:server'], studio);
