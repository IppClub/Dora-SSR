import {build} from 'esbuild';
import {mkdir,readFile,writeFile} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {fileURLToPath} from 'node:url';
import {compileAgentCommand} from './compile-agent.mjs';

// A separate trusted-host support artifact, deliberately outside the public
// Studio web app/Player output. Agent libraries are compiled from their original
// TypeScript sources; the dedicated engine is supplied separately.
const target=new URL('../dist/agent-host/',import.meta.url);
const source=new URL('../apps/web/src/',import.meta.url);
const bundled=await build({stdin:{contents:`export {prepareAgentBootstrap} from './agent-bootstrap';
export {decodeAgentHostConfig} from './agent-host-config';
export {prepareAgentHostRuntime} from './agent-host-runtime';
export {agentStorageId,acquireAgentStorage} from './agent-storage';`,resolveDir:fileURLToPath(source),loader:'ts'},
  bundle:true,write:false,format:'esm',platform:'browser',target:'es2022',metafile:true});
for(const path of Object.keys(bundled.metafile.inputs)) {
  if(path.includes('App.tsx') || path.includes('runtime-host.ts'))throw new Error('Game/workbench code entered trusted host bundle');
}
const files=[{path:'host.js',bytes:bundled.outputFiles[0].contents}];
const page=await build({entryPoints:[fileURLToPath(new URL('agent-host-page.ts',source))],bundle:true,write:false,format:'esm',platform:'browser',target:'es2022'});
files.push({path:'page.js',bytes:page.outputFiles[0].contents},{path:'index.html',bytes:await readFile(new URL('../packages/runtime-web/agent-host.html',import.meta.url))});
for(const name of ['worker.js','typescript.js','compile-worker.js'])files.push({path:'compiler/'+name,bytes:await readFile(new URL(`../packages/compiler-web/dist/browser/${name}`,import.meta.url))});
for(const name of ['Dora.d.ts','es6-subset.d.ts','lua.d.ts','jsx.d.ts'])files.push({path:'declarations/'+name,bytes:await readFile(new URL(`../../Assets/Script/Lib/Dora/en/${name}`,import.meta.url))});
files.push({path:'declarations/lualib_bundle.lua',bytes:await readFile(new URL('../../Assets/Script/Lib/lualib_bundle.lua',import.meta.url))});
// The original Lua/Teal checker is built from Dora's tl.lua and WebServer
// checking source, then copied into this separate, integrity-pinned host.
for(const name of ['api.js','worker.mjs','compiler.mjs','declarations.json'])files.push({path:'teal/'+name,
  bytes:await readFile(new URL(`../apps/web/.generated/teal/${name}`,import.meta.url))});
for(const name of ['worker.mjs','compiler.mjs'])files.push({path:'yarn/'+name,
  bytes:await readFile(new URL(`../apps/web/.generated/yarn/${name}`,import.meta.url))});
// The original Agent searches Dora API/tutorial files through Content at their
// engine-relative locations. Keep the generated, integrity-indexed bundles in
// trusted support; snapshot assembly expands them into those original paths.
for(const language of ['en','zh'])files.push({path:`docs/${language}.json`,
  bytes:await readFile(new URL(`../packages/agent-contracts/dist/docs/${language}.json`,import.meta.url))});
// Built-in skills and their typed helper declarations must live in the trusted
// engine asset tree. They are read-only support files, never project content.
files.push({path:'types/Agent/Gen/Music.d.ts',bytes:await readFile(new URL('../../Assets/Script/Lib/Agent/Gen/Music.d.ts',import.meta.url))});
for(const name of ['SKILL.md','GeneralUserGS-Presets.md'])files.push({path:`skills/music-generation/${name}`,
  bytes:await readFile(new URL(`../../Assets/Doc/skills/music-generation/${name}`,import.meta.url))});
for(const path of ['AgentHostSession.lua','AgentSessionBridge.lua','StudioAgentEntry.lua','StudioAgentYueBuild.lua','StudioAgentXmlBuild.lua'])files.push({path,bytes:await readFile(new URL(`../packages/runtime-web/${path}`,import.meta.url))});
// Use the exact global lint/TIC80 helpers used by the original WebServer Yue
// build path. This module is integrity-pinned in the trusted host snapshot.
files.push({path:'lua/Utils.lua',bytes:await readFile(new URL('../../Assets/Script/Lib/Utils.lua',import.meta.url))});
for(const file of await compileAgentCommand({fullAgent:true,lineComments:true})){
  if(file.path.startsWith('/') || file.path.split('/').some(part=>part==='..' || !part))throw new Error('Invalid compiled Agent path');
  files.push({path:'lua/'+file.path,bytes:Buffer.from(file.text)});
}
await mkdir(target,{recursive:true});
for(const file of files){const path=new URL(file.path,target);await mkdir(new URL('./',path),{recursive:true});await writeFile(path,file.bytes);}
await writeFile(new URL('manifest.json',target),JSON.stringify({version:1,kind:'dora-studio-agent-host-support',
  requires:{studioAgentHost:true,separateOrigin:true},originalAgentLibraries:'included',
  files:files.map(file=>({path:file.path,size:file.bytes.length,sha256:createHash('sha256').update(file.bytes).digest('hex')}))},null,2));
console.log('Built trusted Agent host support (not a standalone runtime): '+fileURLToPath(target));
