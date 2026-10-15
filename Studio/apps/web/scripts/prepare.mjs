import { cp, mkdir, readFile, readdir, writeFile } from 'node:fs/promises';
import { build } from 'esbuild';
const target = new URL('../.generated/', import.meta.url);
await mkdir(target, { recursive: true });
await cp(new URL('../../../../Projects/Web/web-package.js', import.meta.url), new URL('web-package.js', target));
await cp(new URL('../../../packages/compiler-web/dist/browser/', import.meta.url), new URL('compiler/', target), { recursive: true });
await cp(new URL('../../../../Assets/Script/Lib/Dora/en/', import.meta.url), new URL('declarations/', target), { recursive: true });
await cp(new URL('../../../../Assets/Script/Lib/lualib_bundle.lua', import.meta.url), new URL('declarations/lualib_bundle.lua', target));
await cp(new URL('../../../../Docs/static/img/site/logo.svg', import.meta.url), new URL('dora-symbol.svg', target));
const tealTarget = new URL('teal/', target);
await mkdir(tealTarget, {recursive:true});
for (const name of ['worker.mjs', 'compiler.mjs', 'Lua-LICENSE']) await cp(new URL(`../../../packages/agent-contracts/dist/teal/${name}`, import.meta.url), new URL(name, tealTarget));
await build({stdin:{contents:`export {createTealWorkerBuild} from './teal-worker-client.js'; export {compileTealProject} from './teal-project.js';`,
  resolveDir:new URL('../../../packages/agent-contracts/dist/', import.meta.url).pathname},bundle:true,format:'esm',platform:'browser',outfile:new URL('api.js',tealTarget).pathname});
const tealDeclarations = [];
async function collectTeal(directory, prefix = '') {
  for (const entry of await readdir(directory, {withFileTypes:true})) {
    if (entry.isDirectory()) await collectTeal(new URL(entry.name + '/', directory), prefix + entry.name + '/');
    else if (entry.name.endsWith('.d.tl')) tealDeclarations.push({path:prefix + entry.name,kind:'text',text:await readFile(new URL(entry.name,directory),'utf8')});
  }
}
await collectTeal(new URL('../../../../Assets/Script/Lib/Dora/en/', import.meta.url));
await writeFile(new URL('declarations.json',tealTarget), JSON.stringify(tealDeclarations));
const yarnTarget=new URL('yarn/',target);
await mkdir(yarnTarget,{recursive:true});
for(const name of ['worker.mjs','compiler.mjs','YarnFlow-LICENSE','YueParser-LICENSE','UTF8-LICENSE'])await cp(new URL(`../../../packages/agent-contracts/dist/yarn/${name}`,import.meta.url),new URL(name,yarnTarget));
