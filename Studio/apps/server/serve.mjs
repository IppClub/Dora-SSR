import {createServer} from 'node:https';
import {readFileSync} from 'node:fs';
import {openSessionStore} from './session-store.mjs';
import {openAccountStore} from './account-store.mjs';
import {openLoginStore} from './login-store.mjs';
import {openProjectStore} from './project-store.mjs';
import {openModelStores} from './model-stores.mjs';
import {createAccountModelHandler} from './account-model-handler.mjs';
import {createAgentServiceHandler} from './agent-service-handler.mjs';
import {loadAgentHostAssets} from './agent-host-assets.mjs';
import {createAgentHostSnapshot} from '../../scripts/agent-host-snapshot.mjs';
import {loadTrustedProviderDefinitions} from './trusted-provider-definitions.mjs';
import {agentProviderCatalog,createAgentProviderIds} from './agent-provider-profiles.mjs';

const required=name=>{const value=process.env[name];if(!value)throw new Error(`Missing ${name}`);return value;};
const path=required('STUDIO_DB_PATH'),studioOrigin=required('STUDIO_PUBLIC_ORIGIN');
if(new URL(studioOrigin).origin!==studioOrigin||!studioOrigin.startsWith('https://'))throw new Error('STUDIO_PUBLIC_ORIGIN must be an HTTPS origin');
const key=Buffer.from(required('STUDIO_SECRET_KEY'),'base64');if(key.length!==32)throw new Error('STUDIO_SECRET_KEY must be 32 bytes in base64');
const providerIds=createAgentProviderIds();
const providers=loadTrustedProviderDefinitions(process.env.STUDIO_PROVIDER_ENDPOINTS,providerIds);
const stores=openModelStores({path,providerIds,activeKeyId:'studio',keys:new Map([['studio',key]])});
const sessions=openSessionStore(path),accounts=openAccountStore(path),login=openLoginStore(path),projects=openProjectStore(path);
const handler=createAccountModelHandler({studioOrigin,sessions,accounts,login,projects,...stores,gatewayProviders:providers,providers:agentProviderCatalog});
const tls={key:readFileSync(required('STUDIO_TLS_KEY')),cert:readFileSync(required('STUDIO_TLS_CERT'))};
let agent,hostServer;
if(process.env.STUDIO_AGENT_HOST_ORIGIN){
  const hostOrigin=required('STUDIO_AGENT_HOST_ORIGIN');
  if(new URL(hostOrigin).origin!==hostOrigin||!hostOrigin.startsWith('https://')||hostOrigin===studioOrigin)throw new Error('STUDIO_AGENT_HOST_ORIGIN must be a distinct HTTPS origin');
  const {assets,engineVersion}=loadAgentHostAssets(required('STUDIO_AGENT_ENGINE_DIR'));
  agent=createAgentServiceHandler({studioOrigin,hostOrigin,sessions,accounts,projects,engineVersion,assets,createSnapshot:createAgentHostSnapshot,
    modelGateway:{catalog:stores.catalog,vault:stores.vault,ledger:stores.ledger,providers}});
  hostServer=createServer(tls,async(req,res)=>{
    try{if(!await agent.host(req,res)){res.statusCode=404;res.end();}}
    catch{if(!res.headersSent){res.statusCode=500;res.end();}else res.destroy();}
  });
}
const server=createServer(tls,async(req,res)=>{
  try{if(!await agent?.api(req,res)&&!await handler(req,res)){res.statusCode=404;res.end();}}
  catch{if(!res.headersSent){res.statusCode=500;res.end();}else res.destroy();}
});
const host=process.env.STUDIO_API_HOST??'127.0.0.1',port=Number(process.env.STUDIO_API_PORT??8899);
if(!Number.isSafeInteger(port)||port<1||port>65535)throw new Error('Invalid API port');
if(hostServer){
  const hostPort=Number(required('STUDIO_AGENT_HOST_PORT'));
  if(!Number.isSafeInteger(hostPort)||hostPort<1||hostPort>65535||hostPort===port)throw new Error('Invalid Agent host port');
  hostServer.listen(hostPort,host,()=>process.stdout.write(`Studio Agent host listening on https://${host}:${hostPort}\n`));
}
server.listen(port,host,()=>process.stdout.write(`Studio API listening on https://${host}:${port}, frontend origin ${studioOrigin}\n`));
for(const signal of ['SIGINT','SIGTERM'])process.once(signal,()=>{
  const listeners=[server,...(hostServer?[hostServer]:[])];
  let remaining=listeners.length;
  for(const listener of listeners)listener.close(()=>{if(--remaining===0){projects.close();login.close();accounts.close();sessions.close();stores.close();process.exit(0);}});
});
