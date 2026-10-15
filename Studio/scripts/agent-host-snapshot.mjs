import {readFile,realpath} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {resolve,sep} from 'node:path';
import {fileURLToPath} from 'node:url';
import {decodeAgentHostConfig} from '../dist/agent-host/host.js';
import {verifyDocumentBundle} from '../packages/agent-contracts/dist/documents.js';

function documentRuntimePath(language,path){
  const match=/^@dora-doc\/(dora-api|love-api|tic80-api|dora-tutorial)\/(.+)$/.exec(path);
  if(!match)throw new Error('Invalid Agent document path');
  const directory=language==='zh'?'zh-Hans':'en';
  return match[1]==='dora-tutorial'?`Doc/${directory}/Tutorial/${match[2]}`:`Script/Lib/Dora/${directory}/${match[2]}`;
}

/** Server-side assembly from a trusted build, after account/project authorization.
 * Never merge imported game files into this privileged startup snapshot.
 */
export async function createAgentHostSnapshot(value,{engineVersion,supportDirectory=fileURLToPath(new URL('../dist/agent-host/',import.meta.url))}) {
  const config=decodeAgentHostConfig(value);
  if(config.projectRoot!=='/user/studio-project')throw new Error('Agent project must be separate from the trusted library mounted at /game');
  if(typeof engineVersion!=='string' || !engineVersion || engineVersion.length>128)throw new Error('Invalid engine version');
  const root=await realpath(supportDirectory);
  const support=JSON.parse(await readFile(resolve(root,'manifest.json'),'utf8'));
  if(support.kind!=='dora-studio-agent-host-support' || support.version!==1 || support.originalAgentLibraries!=='included'
    || !Array.isArray(support.files) || support.files.length>1024)throw new Error('Invalid Agent support manifest');
  const files=[],seen=new Set(),documentBundles=new Map();
  for(const file of support.files){
    if(['host.js','page.js','index.html','compiler/worker.js','compiler/typescript.js','compiler/compile-worker.js',
      'declarations/Dora.d.ts','declarations/es6-subset.d.ts','declarations/lua.d.ts','declarations/jsx.d.ts','declarations/lualib_bundle.lua',
      'teal/api.js','teal/worker.mjs','teal/compiler.mjs','teal/declarations.json',
      'yarn/worker.mjs','yarn/compiler.mjs'].includes(file.path))continue;
    if(typeof file.path!=='string' || !(file.path==='AgentHostSession.lua' || file.path==='AgentSessionBridge.lua' || file.path==='StudioAgentEntry.lua'
      || file.path==='StudioAgentYueBuild.lua' || file.path==='StudioAgentXmlBuild.lua' || file.path==='lua/Utils.lua'
      || /^lua\/(?:Agent\/[A-Za-z0-9_/-]+|DoraX|lualib_bundle)\.lua$/.test(file.path)
      || /^docs\/(en|zh)\.json$/.test(file.path)
      || file.path==='types/Agent/Gen/Music.d.ts'
      || /^skills\/music-generation\/(?:SKILL|GeneralUserGS-Presets)\.md$/.test(file.path)))throw new Error('Unexpected Agent support file');
    const absolute=await realpath(resolve(root,file.path));
    if(!absolute.startsWith(root+sep))throw new Error('Agent support file escaped build directory');
    const bytes=await readFile(absolute);
    if(bytes.length!==file.size || createHash('sha256').update(bytes).digest('hex')!==file.sha256)throw new Error('Agent support integrity mismatch');
    const documentMatch=/^docs\/(en|zh)\.json$/.exec(file.path);
    if(documentMatch){
      if(documentBundles.has(documentMatch[1]))throw new Error('Duplicate Agent document bundle');
      documentBundles.set(documentMatch[1],bytes);continue;
    }
    const path=file.path.startsWith('lua/')?file.path.slice(4)
      :file.path.startsWith('types/')?file.path.slice(6)
      :file.path.startsWith('skills/')?'Doc/'+file.path
      :file.path;
    if(seen.has(path))throw new Error('Duplicate Agent support file');seen.add(path);
    files.push({path,bytes});
  }
  for(const required of ['Agent/Session.lua','AgentHostSession.lua','AgentSessionBridge.lua','StudioAgentEntry.lua','StudioAgentYueBuild.lua','StudioAgentXmlBuild.lua','Utils.lua','lualib_bundle.lua'])if(!seen.has(required))throw new Error('Missing Agent support file');
  for(const language of ['en','zh']){
    const bytes=documentBundles.get(language);if(!bytes)throw new Error('Missing Agent document bundle');
    let bundle;try{bundle=JSON.parse(bytes.toString('utf8'));}catch{throw new Error('Invalid Agent document bundle');}
    const documents=await verifyDocumentBundle(bundle,language);
    for(const document of documents){
      const path=documentRuntimePath(language,document.path);
      if(seen.has(path))throw new Error('Duplicate Agent document file');seen.add(path);
      files.push({path,bytes:Buffer.from(document.text)});
    }
  }
  if(files.length>1024)throw new Error('Agent host file limit exceeded');
  files.push({path:'init.lua',bytes:Buffer.from("require('AgentHostSession').startConfigured(require('Dora').Content:load('/game/studio-host.json'))")},
    {path:'studio-host.json',bytes:Buffer.from(JSON.stringify({version:1,projectRoot:config.projectRoot,title:config.title}))});
  const manifest={format:'dora-web-game',version:1,engineVersion,profile:'dora-preset',entry:'init.lua',
    files:files.map(file=>({path:file.path,url:'host-files/'+file.path,size:file.bytes.length,sha256:createHash('sha256').update(file.bytes).digest('hex'),startup:true}))};
  return {config,manifest,files};
}
