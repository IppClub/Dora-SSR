import {prepareAgentHostRuntime} from './agent-host-runtime';
import {decodeAgentHostConfig, type AgentHostConfig} from './agent-host-config';
import type {AgentHostModule} from './agent-wasm-source';

const status=document.getElementById('status')!;
let configuration:Readonly<AgentHostConfig>|undefined;
let runtime:ReturnType<typeof prepareAgentHostRuntime>|undefined;
let failed=false;
function fail() {
  if(failed)return;failed=true;
  runtime?.close();
  status.textContent='Agent 宿主启动失败，请返回工作台重试。';
  if(configuration)parent.postMessage({type:'studio-agent-failed',version:1,projectId:configuration.projectId,
    generation:configuration.generation,code:'initialization-failed'},configuration.parentOrigin);
}
async function readConfig(path:string) {
  const response=await fetch(new URL(path,location.href),{credentials:'same-origin',cache:'no-store',redirect:'error',signal:AbortSignal.timeout(15000)});
  if(!response.ok || !response.body)throw new Error('Host configuration unavailable');
  const reader=response.body.getReader();let total=0;const chunks:Uint8Array[]=[];
  try {
    for(;;){const {done,value}=await reader.read();if(done)break;total+=value.length;if(total>16384)throw new Error('Host configuration too large');chunks.push(value);}
  }finally{await reader.cancel();reader.releaseLock();}
  const bytes=new Uint8Array(total);let offset=0;for(const chunk of chunks){bytes.set(chunk,offset);offset+=chunk.length;}
  return JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(bytes));
}
async function start() {
  if(window.parent===window)throw new Error('Open this host from Dora Studio');
  const config=decodeAgentHostConfig(await readConfig('./host-config.json'));
  configuration=config;
  const features=await readConfig('./dora-web-features.json');
  if(features?.studioAgentHost!==true)throw new Error('Dedicated Agent engine required');
  // All URLs are deployment-owned, never taken from query strings or projects.
  const module={canvas:document.getElementById('canvas'),
    print:(...args:unknown[])=>console.log(...args),printErr:(...args:unknown[])=>console.error(...args),
    onAbort:fail,
    doraManifestUrl:new URL('./host-manifest.json',location.href).href,
  } as unknown as AgentHostModule & {doraStorageId:Promise<string>};
  runtime=prepareAgentHostRuntime(module,parent,config);
  module.doraStorageId=runtime.storageId;
  (window as unknown as {Module:unknown}).Module=module;
  runtime.ready.then(()=>{if(!failed)status.textContent='Agent 已就绪';},fail);
  const script=document.createElement('script');script.src=new URL('./dora-player-runtime.js',location.href).href;
  script.onerror=fail;
  document.body.append(script);
}
void start().catch(fail);
