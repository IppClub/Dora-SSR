import {createHash} from 'node:crypto';
import {readFileSync} from 'node:fs';
import {join} from 'node:path';
import {fileURLToPath} from 'node:url';

const supportDirectory=fileURLToPath(new URL('../../dist/agent-host/',import.meta.url));
const engineNames=['dora-player-runtime.js','dora-player-runtime.wasm','dora-player-runtime.data',
  'dora-web-features.json','audio-worklet.js','dora-audio-mixer.wasm'];
const mime={
  'index.html':'text/html; charset=utf-8','page.js':'text/javascript; charset=utf-8',
  'dora-player-runtime.js':'text/javascript; charset=utf-8',
  'dora-player-runtime.wasm':'application/wasm','dora-player-runtime.data':'application/octet-stream',
  'dora-web-features.json':'application/json; charset=utf-8',
  'audio-worklet.js':'text/javascript; charset=utf-8','dora-audio-mixer.wasm':'application/wasm',
  'compiler/worker.js':'text/javascript; charset=utf-8','compiler/typescript.js':'text/javascript; charset=utf-8',
  'compiler/compile-worker.js':'text/javascript; charset=utf-8',
  'teal/api.js':'text/javascript; charset=utf-8','teal/worker.mjs':'text/javascript; charset=utf-8',
  'teal/compiler.mjs':'text/javascript; charset=utf-8','teal/declarations.json':'application/json; charset=utf-8',
  'yarn/worker.mjs':'text/javascript; charset=utf-8','yarn/compiler.mjs':'text/javascript; charset=utf-8',
};

/** Load only build-owned files. A public game Player is rejected at startup. */
export function loadAgentHostAssets(engineDirectory){
  if(typeof engineDirectory!=='string'||!engineDirectory)throw new Error('Missing dedicated Agent engine directory');
  const support=JSON.parse(readFileSync(join(supportDirectory,'manifest.json'),'utf8'));
  if(support.kind!=='dora-studio-agent-host-support'||support.requires?.studioAgentHost!==true||support.requires?.separateOrigin!==true)throw new Error('Invalid Agent support build');
  const assets=new Map();
  for(const name of ['index.html','page.js','compiler/worker.js','compiler/typescript.js','compiler/compile-worker.js',
    'declarations/Dora.d.ts','declarations/es6-subset.d.ts','declarations/lua.d.ts','declarations/jsx.d.ts','declarations/lualib_bundle.lua',
    'teal/api.js','teal/worker.mjs','teal/compiler.mjs','teal/declarations.json',
    'yarn/worker.mjs','yarn/compiler.mjs']){
    const entry=support.files.find(file=>file.path===name),bytes=readFileSync(join(supportDirectory,name));
    if(!entry||bytes.length!==entry.size||createHash('sha256').update(bytes).digest('hex')!==entry.sha256)throw new Error(`Agent support integrity failed: ${name}`);
    assets.set(name,bytes);
  }
  for(const name of engineNames){
    const bytes=readFileSync(join(engineDirectory,name));
    if(!bytes.length)throw new Error(`Empty Agent engine asset: ${name}`);
    assets.set(name,bytes);
  }
  const features=JSON.parse(assets.get('dora-web-features.json').toString('utf8'));
  if(features.studioAgentHost!==true||features.activeProfile!=='dora-preset')throw new Error('Game Player is not a dedicated Studio Agent engine');
  const manifest=JSON.parse(readFileSync(join(engineDirectory,'dora-web-manifest.json'),'utf8'));
  if(manifest.format!=='dora-web-game'||manifest.profile!=='dora-preset'||typeof manifest.engineVersion!=='string'||!manifest.engineVersion||manifest.engineVersion.length>128)throw new Error('Invalid dedicated Agent engine manifest');
  return {assets,engineVersion:manifest.engineVersion};
}

/** Static host/engine resources remain bound to a live launch and account. */
export function createAgentHostAssetsRoute({authorize,getLaunch,assets}){
  if(typeof authorize!=='function'||typeof getLaunch!=='function'||!(assets instanceof Map))throw new TypeError('Invalid Agent host asset route');
  return async(req,res)=>{
    const match=/^\/agent-host\/([A-Za-z0-9_-]{1,128})\/([A-Za-z0-9_.-]+(?:\/[A-Za-z0-9_.-]+)?)$/.exec(req.url??'');
    if(!match||!assets.has(match[2]))return false;
    res.setHeader('Cache-Control','private, no-store');res.setHeader('X-Content-Type-Options','nosniff');
    res.setHeader('Cross-Origin-Opener-Policy','same-origin');res.setHeader('Cross-Origin-Embedder-Policy','require-corp');
    // The isolated Studio parent may embed this authenticated HTML document;
    // its scripts, engine bytes and private launch data remain host-origin only.
    res.setHeader('Cross-Origin-Resource-Policy',match[2]==='index.html'?'cross-origin':'same-origin');
    const finish=code=>{res.statusCode=code;res.end();return true;};
    if(req.method!=='GET'&&req.method!=='HEAD'){res.setHeader('Allow','GET, HEAD');return finish(405);}
    try{
      const grant=await authorize(req,match[1]),launch=await getLaunch(match[1]);
      if(!grant||!launch||grant.accountId!==launch.config.accountId||grant.projectId!==launch.config.projectId||grant.generation!==launch.config.generation)return finish(403);
      const bytes=assets.get(match[2]);res.statusCode=200;
      res.setHeader('Content-Type',mime[match[2]]??(match[2].startsWith('declarations/')?'text/plain; charset=utf-8':'application/octet-stream'));res.setHeader('Content-Length',bytes.length);
      res.end(req.method==='HEAD'?undefined:bytes);return true;
    }catch{return finish(500);}
  };
}
