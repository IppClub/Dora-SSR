import {createSessionAuthenticator,readSessionToken} from './session-authenticate.mjs';

const identity=value=>typeof value==='string'&&/^[A-Za-z0-9_-]{1,128}$/.test(value);
const text=value=>typeof value==='string'&&value.trim().length>0&&value.length<=256&&value.isWellFormed()&&!/[\x00-\x1f\x7f]/.test(value);
async function readJSON(req,limit){
  if((req.headers['content-type']??'').split(';')[0].trim().toLowerCase()!=='application/json')throw new Error('Unsupported content type');
  if(Number(req.headers['content-length'])>limit){req.resume();throw new Error('Request too large');}
  const chunks=[];let size=0;
  try{
    for await(const chunk of req){size+=chunk.length;if(size>limit){req.resume();throw new Error('Request too large');}chunks.push(Buffer.from(chunk));}
    const bytes=Buffer.concat(chunks);
    try{return JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(bytes));}
    catch{throw new Error('Invalid JSON');}
    finally{bytes.fill(0);}
  }finally{for(const chunk of chunks)chunk.fill(0);}
}

/** Administrator-facing shared pool. Every durable write also checks this
 * exact live administrator cookie inside its own SQLite writer transaction. */
export function createAdminSharedModelsHandler({studioOrigin,sessions,accounts,catalog,vault,ledger}){
  const origin=new URL(studioOrigin);
  if(origin.origin!==studioOrigin||!['http:','https:'].includes(origin.protocol)||!sessions||!accounts?.isAdministrator||!catalog?.get||!catalog?.put||!catalog?.listShared||!vault?.metadata||!vault?.put||!vault?.revoke||!ledger?.configure||!ledger?.scope)throw new TypeError('Invalid shared model administration');
  const authenticate=createSessionAuthenticator({sessions,allowAccount:accounts.isAllowed});
  const detail=/^\/api\/admin\/shared-models\/([A-Za-z0-9_-]{1,128})(?:\/(secret|limits))?$/;
  const binding=id=>({kind:'shared',ownerId:'platform',configurationId:id});
  const readApi=id=>{try{const row=ledger.scope('api',id);return {enabled:row.enabled,limit:row.limit,active:row.active};}catch{return null;}};
  const project=id=>{const config=catalog.get(id);return config?.kind==='shared'&&config.ownerId==='platform'?config:null;};
  return async(req,res)=>{
    const path=(req.url??'').split('?')[0],match=detail.exec(path),list=path==='/api/admin/shared-models';
    if(!match&&!list)return false;
    res.setHeader('Cache-Control','private, no-store');res.setHeader('X-Content-Type-Options','nosniff');
    const finish=(status,data)=>{res.statusCode=status;if(data!==undefined){res.setHeader('Content-Type','application/json; charset=utf-8');res.end(JSON.stringify(data));}else res.end();return true;};
    if(req.method==='GET'?req.headers.origin&&req.headers.origin!==studioOrigin:req.headers.origin!==studioOrigin)return finish(403);
    if(req.headers['sec-fetch-site']==='cross-site')return finish(403);
    if(req.url.length>4096)return finish(400);
    const allowed=match?.[2]==='secret'?['GET','PUT','DELETE']:match?.[2]==='limits'?['PUT']:list?['GET']:['GET','PUT'];
    if(!allowed.includes(req.method)){res.setHeader('Allow',allowed.join(', '));return finish(405);}
    try{
      const actor=await authenticate(req);if(res.destroyed)return true;
      if(!actor?.accountId)return finish(401);
      if(!accounts.isAdministrator(actor.accountId))return finish(403);
      const id=match?.[1],resource=match?.[2];
      if(req.method==='GET'){
        if(list){
          const params=new URL(req.url,studioOrigin).searchParams;
          if([...params.keys()].some(key=>!['after','limit'].includes(key))||params.getAll('after').length>1||params.getAll('limit').length>1)return finish(400);
          const after=params.get('after')??'',raw=params.get('limit')??'20';
          if(after!==''&&!identity(after)||!/^[1-9][0-9]?$/.test(raw)||Number(raw)>50)return finish(400);
          const limit=Number(raw),rows=catalog.listShared({after,limit:limit+1}),items=rows.slice(0,limit);
          return finish(200,{version:1,items,nextCursor:rows.length>limit?items.at(-1).id:null});
        }
        if(req.url.includes('?'))return finish(400);
        const config=project(id);if(!config)return finish(404);
        return finish(200,{version:1,configuration:config,secret:vault.metadata(binding(id))??{version:0,available:false},api:readApi(id)});
      }
      if(req.url.includes('?'))return finish(400);
      const body=await readJSON(req,resource==='secret'?65536:4096);
      if(!body||typeof body!=='object'||Array.isArray(body))return finish(400);
      const options={actorId:actor.accountId,sessionToken:readSessionToken(req)};
      if(resource==='secret'){
        if(!project(id))return finish(404);
        if(!Number.isSafeInteger(body.expectedVersion)||body.expectedVersion<0||body.expectedVersion>=Number.MAX_SAFE_INTEGER)return finish(400);
        if(req.method==='DELETE'){
          if(Object.keys(body).some(key=>key!=='expectedVersion'))return finish(400);
          return finish(200,vault.revoke(binding(id),{...options,expectedVersion:body.expectedVersion}));
        }
        if(Object.keys(body).some(key=>!['expectedVersion','key','consent'].includes(key))||body.consent!==true||typeof body.key!=='string'||!body.key||!body.key.isWellFormed()||Buffer.byteLength(body.key)>16384||/[\x00-\x1f\x7f]/.test(body.key))return finish(400);
        const secret=Buffer.from(body.key);delete body.key;
        try{return finish(200,vault.put(binding(id),secret,{...options,expectedVersion:body.expectedVersion}));}
        finally{secret.fill(0);}
      }
      if(resource==='limits'){
        if(!project(id))return finish(404);
        if(Object.keys(body).some(key=>!['enabled','limit'].includes(key))||typeof body.enabled!=='boolean'||!Number.isSafeInteger(body.limit)||body.limit<0||body.limit>1000)return finish(400);
        ledger.configure('api',id,{enabled:body.enabled,limit:body.limit},options);
        return finish(200,{version:1,api:readApi(id)});
      }
      if(Object.keys(body).some(key=>!['expectedVersion','label','model','providerId','enabled','pricing'].includes(key))||!Number.isSafeInteger(body.expectedVersion)||body.expectedVersion<0||body.expectedVersion>=Number.MAX_SAFE_INTEGER||!text(body.label)||!text(body.model)||!identity(body.providerId)||typeof body.enabled!=='boolean'||!body.pricing)return finish(400);
      const saved=catalog.put({id,kind:'shared',ownerId:'platform',label:body.label,model:body.model,providerId:body.providerId,enabled:body.enabled,pricing:body.pricing},{...options,expectedVersion:body.expectedVersion});
      return finish(200,{version:1,configuration:saved});
    }catch(error){
      if(error?.message==='Unsupported content type')return finish(415);
      if(error?.message==='Request too large')return finish(413);
      if(error?.message==='Invalid JSON'||error instanceof TypeError)return finish(400);
      if(error?.message==='Administrator session required')return finish(401);
      if(error?.message==='Administrator authorization required')return finish(403);
      if(error?.message==='Unknown shared configuration')return finish(404);
      if(['Configuration version conflict','Secret version conflict','Shared configuration not ready','Shared pricing required','Disable shared configuration before revoking secret'].includes(error?.message))return finish(409);
      return finish(500);
    }
  };
}
