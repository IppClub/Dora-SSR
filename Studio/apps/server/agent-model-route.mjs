import {createHash} from 'node:crypto';
import {executeModelRequest} from './model-request-executor.mjs';
import {sendCompatibleCompletion} from './model-provider-transport.mjs';
import {tokenCharge} from './model-amount.mjs';
import {getAgentProviderProfile} from './agent-provider-profiles.mjs';

const pathPattern=/^\/agent-host\/([A-Za-z0-9_-]{1,128})\/(model|vision|model-config)\/([A-Za-z0-9_-]{1,128})$/;
const requestIdentity=value=>typeof value==='string'&&/^[A-Za-z0-9_-]{1,128}$/.test(value);
const modelBodyBytes=1024*1024,visionBodyBytes=20*1024*1024;
async function readBody(req,maxBodyBytes){
  if((req.headers['content-type']??'').split(';')[0].trim().toLowerCase()!=='application/json')throw new Error('Unsupported content type');
  if(Number(req.headers['content-length'])>maxBodyBytes){req.resume();throw new Error('Request too large');}
  const chunks=[];let size=0;
  try{
    for await(const chunk of req){size+=chunk.length;if(size>maxBodyBytes){req.resume();throw new Error('Request too large');}chunks.push(Buffer.from(chunk));}
    const bytes=Buffer.concat(chunks);
    try{
      const raw=new TextDecoder('utf-8',{fatal:true}).decode(bytes),body=JSON.parse(raw);
      if(!body||typeof body!=='object'||Array.isArray(body)||typeof body.model!=='string'||!body.model||!Array.isArray(body.messages)||!body.messages.length||typeof body.stream!=='boolean')throw new Error('Invalid completion request');
      return {body,bytes:size};
    }catch{throw new Error('Invalid completion request');}
    finally{bytes.fill(0);}
  }finally{for(const chunk of chunks)chunk.fill(0);}
}

function validateVisionRequest(body){
  if(body.stream!==false||body.tools!==undefined||body.tool_choice!==undefined||body.messages.length!==2)return false;
  const [system,user]=body.messages;
  if(!system||system.role!=='system'||typeof system.content!=='string'||!user||user.role!=='user'||!Array.isArray(user.content))return false;
  let images=0;
  for(const item of user.content){
    if(!item||typeof item!=='object'||Array.isArray(item))return false;
    if(item.type==='text'){if(typeof item.text!=='string')return false;continue;}
    if(item.type!=='image_url'||!item.image_url||typeof item.image_url!=='object'||Array.isArray(item.image_url))return false;
    const url=item.image_url.url;
    if(typeof url!=='string'||!/^data:image\/(?:png|jpeg);base64,[A-Za-z0-9+/]+={0,2}$/.test(url))return false;
    images++;
  }
  return images>=1&&images<=3;
}

function maximumOutputTokens(body){
  const supplied=[body.max_tokens,body.max_completion_tokens].filter(value=>value!==undefined);
  if(supplied.some(value=>!Number.isSafeInteger(value)||value<1||value>65536))throw new Error('Invalid completion output limit');
  return BigInt(supplied.length?Math.max(...supplied):8192);
}

function gatewayFailure(res,body,code,message){
  const payload={error:{message,type:'studio_gateway_error',code}};
  if(body.stream){
    res.statusCode=200;res.setHeader('Content-Type','text/event-stream; charset=utf-8');
    res.end(`data: ${JSON.stringify(payload)}\n\ndata: [DONE]\n\n`);return true;
  }
  res.statusCode=200;res.setHeader('Content-Type','application/json; charset=utf-8');res.end(JSON.stringify(payload));return true;
}

function admissionFailure(decision){
  if(decision?.reason==='insufficient-amount')return ['model-amount-insufficient','当前账号的模型额度不足，请补充额度后重试。'];
  if(decision?.reason==='zero-capacity')return ['model-capacity-disabled','当前模型并发额度未开放，请联系管理员。'];
  if(decision?.reason==='unavailable'||decision?.reason==='configuration-unavailable')return ['model-grant-unavailable','当前模型授权不可用，请刷新账号或联系管理员。'];
  return ['model-not-admitted','当前模型请求未获准，请稍后重试。'];
}

/** Emits validated non-terminal SSE events immediately. The supplier's [DONE]
 * remains withheld until the durable completion receipt is settled. */
function terminalGate(res){
  let lineBuffer='',event='',terminal='';
  return {
    push(part){
      lineBuffer+=part;
      for(;;){const end=lineBuffer.indexOf('\n');if(end<0)break;
        const line=lineBuffer.slice(0,end+1);lineBuffer=lineBuffer.slice(end+1);event+=line;
        if(line==='\n'||line==='\r\n'){
          const data=event.split(/\r?\n/).filter(item=>item.startsWith('data:')).map(item=>item.slice(5).trimStart()).join('\n');
          if(data==='[DONE]')terminal=event;
          else if(!res.destroyed)res.write(event);
          event='';
        }
      }
      if(lineBuffer.length>65536||event.length>65536)throw new Error('Oversized model stream event');
    },
    finish(){if(lineBuffer||event||!terminal)throw new Error('Incomplete model stream');if(!res.destroyed)res.end(terminal);},
  };
}

/** Host-origin model endpoint. The URL selects a grant, never an account, key,
 * supplier URL, pricing, request fingerprint or provider model. All of those
 * are resolved from the authenticated launch and server-owned SQLite stores. */
export function createAgentModelRoute({hostOrigin,authorize,getLaunch,catalog,vault,ledger,providers,fetchImpl=fetch}){
  if(new URL(hostOrigin).origin!==hostOrigin||!hostOrigin.startsWith('https://')||typeof authorize!=='function'||typeof getLaunch!=='function'||!catalog?.get||!vault?.withSecret||!vault?.metadata||!ledger?.ownedGrantBinding||!ledger?.reserve||!(providers instanceof Map)||typeof fetchImpl!=='function')throw new TypeError('Invalid Agent model route');
  return async(req,res)=>{
    const match=pathPattern.exec(req.url??'');if(!match)return false;
    res.setHeader('Cache-Control','private, no-store');res.setHeader('X-Content-Type-Options','nosniff');res.setHeader('Cross-Origin-Resource-Policy','same-origin');
    const finish=(status,payload)=>{if(res.destroyed)return true;res.statusCode=status;res.setHeader('Content-Type','application/json; charset=utf-8');res.end(JSON.stringify(payload));return true;};
    const [,_launchId,resource,grantId]=match,launchId=_launchId;
    const method=resource==='model-config'?'GET':'POST';
    if(req.method!==method){res.setHeader('Allow',method);return finish(405,{error:'method-not-allowed'});}
    if(req.headers['sec-fetch-site']==='cross-site'||(resource!=='model-config'?req.headers.origin!==hostOrigin:req.headers.origin&&req.headers.origin!==hostOrigin))return finish(403,{error:'wrong-origin'});
    const clientId=req.headers['x-studio-model-request-id'];
    if(resource!=='model-config'&&!requestIdentity(clientId))return finish(400,{error:'request-id-required'});
    const disconnect=new AbortController(),onDisconnect=()=>disconnect.abort(new Error('Agent model client disconnected'));
    req.once('aborted',onDisconnect);res.once('close',onDisconnect);
    try{
      const grant=await authorize(req,launchId),launch=await getLaunch(launchId);
      if(!grant||!launch||grant.accountId!==launch.config.accountId||grant.projectId!==launch.config.projectId||grant.generation!==launch.config.generation)return finish(403,{error:'agent-launch-forbidden'});
      const owned=ledger.ownedGrantBinding(grant.accountId,grantId);
      if(!owned)return finish(403,{error:'model-grant-forbidden'});
      const config=catalog.get(owned.apiId);
      if(!config||config.kind!=='shared'||config.ownerId!=='platform'||config.enabled!==true||!config.pricing)return finish(503,{error:'model-configuration-unavailable'});
      const provider=providers.get(config.providerId);
      if(!provider)return finish(503,{error:'provider-unavailable'});
      const profile=getAgentProviderProfile(config.providerId);
      if(!profile)return finish(503,{error:'provider-profile-unavailable'});
      if(resource==='model-config'){
        if(req.url.includes('?'))return finish(400,{error:'invalid-model-config-request'});
        if(!vault.metadata({kind:'shared',ownerId:'platform',configurationId:config.id})?.available)return finish(503,{error:'model-secret-unavailable'});
        // Provider-specific auxiliary fields intentionally stay nested. The
        // original Agent applies them only to memory consolidation, not to the
        // normal decision loop.
        const customOptions={auxiliaryOptions:profile.auxiliaryOptions};
        const visionProfile=profile.vision;
        return finish(200,{version:1,grantId,configurationVersion:config.version,llmConfig:{url:`${hostOrigin}/agent-host/${launchId}/model/${grantId}`,
          model:config.model,apiKey:'studio-agent',contextWindow:profile.contextWindow,temperature:profile.temperature,maxTokens:profile.maxTokens,
          customOptions,supportsFunctionCalling:profile.supportsFunctionCalling,studioGateway:true,
          ...(visionProfile?{studioVision:{...visionProfile,url:`${hostOrigin}/agent-host/${launchId}/vision/${grantId}`}}:{})}});
      }
      const visionProfile=resource==='vision'?profile.vision:undefined;
      if(resource==='vision'&&!visionProfile)return finish(503,{error:'vision-provider-unavailable'});
      const {body,bytes}=await readBody(req,resource==='vision'?visionBodyBytes:modelBodyBytes);
      const expectedModel=resource==='vision'?visionProfile.model:config.model;
      if(body.model!==expectedModel)return finish(403,{error:'model-mismatch'});
      if(resource==='vision'&&!validateVisionRequest(body))return finish(400,{error:'invalid-vision-request'});
      const outputTokens=maximumOutputTokens(body);
      const rates={inputNanoCnyPerMillion:BigInt(config.pricing.inputNanoCnyPerMillion),outputNanoCnyPerMillion:BigInt(config.pricing.outputNanoCnyPerMillion)};
      const reservation=tokenCharge({inputTokens:BigInt(Math.max(bytes,1024)),outputTokens},rates);
      const binding={kind:'shared',ownerId:'platform',configurationId:config.id};
      const ledgerId=`${launchId}_${clientId}`;
      const result=await vault.withSecret(binding,async(secret,{version:secretVersion})=>{
        const fingerprint=createHash('sha256').update(JSON.stringify({version:1,resource,launchId,accountId:grant.accountId,projectId:grant.projectId,grantId,configurationId:config.id,configurationVersion:config.version,secretVersion,body})).digest('hex');
        const intent={requestId:ledgerId,accountId:grant.accountId,apiId:config.id,grantId,fingerprint,reservation,configurationVersion:config.version,rates};
        const gate=body.stream?terminalGate(res):null;
        // Client loss cancels only before dispatch. Once sent, keep the supplier
        // call alive to obtain a terminal receipt instead of stranding a hold.
        const outcome=await executeModelRequest({ledger,intent,signal:disconnect.signal,send:()=>sendCompatibleCompletion({endpoint:provider.endpoint,key:secret,body,signal:AbortSignal.timeout(600000),includeStreamUsage:body.stream&&provider.includeStreamUsage===true,requestByteLimit:resource==='vision'?visionBodyBytes:modelBodyBytes,fetchImpl,...(gate?{onChunk:part=>gate.push(part)}:{})})});
        return {outcome,gate};
      });
      const {outcome,gate}=result;
      if(outcome.state==='settled'){
        if(gate){gate.finish();return true;}
        return finish(200,outcome.response);
      }
      if(res.headersSent){if(!res.destroyed)res.end();return true;}
      if(outcome.state==='existing')return finish(409,{error:'request-already-recorded',state:outcome.record.request.state});
      if(outcome.state==='queued')return gatewayFailure(res,body,'model-concurrency','当前模型并发已满，请稍后重试。');
      if(outcome.state==='needs-reconciliation'||outcome.state==='pending-usage')return gatewayFailure(res,body,'model-needs-reconciliation','上一笔模型请求仍在核对中，请稍后重试。');
      const [code,message]=admissionFailure(outcome.decision);
      return gatewayFailure(res,body,code,message);
    }catch(error){
      if(res.headersSent){if(!res.destroyed)res.end();return true;}
      if(error?.message==='Unsupported content type')return finish(415,{error:'unsupported-content-type'});
      if(error?.message==='Request too large')return finish(413,{error:'request-too-large'});
      if(['Invalid completion request','Invalid completion output limit'].includes(error?.message))return finish(400,{error:'invalid-completion-request'});
      if(error?.message==='Idempotency binding mismatch')return finish(409,{error:'request-binding-conflict'});
      if(error?.message==='Model secret unavailable')return finish(503,{error:'model-secret-unavailable'});
      return finish(503,{error:'model-unavailable'});
    }finally{req.off('aborted',onDisconnect);res.off('close',onDisconnect);}
  };
}
