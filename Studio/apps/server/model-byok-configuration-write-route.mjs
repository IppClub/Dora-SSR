import {ConfigurationCapacityError} from './model-configuration-store.mjs';
/** Metadata only. Secrets use the separate consent-gated vault route. */
export function createByokConfigurationWriteRoute({studioOrigin,authenticate,catalog,providerIds}) {
  const origin=new URL(studioOrigin);
  if(origin.origin!==studioOrigin||!['http:','https:'].includes(origin.protocol)||typeof authenticate!=='function'||typeof catalog?.put!=='function'||typeof catalog?.get!=='function'||!(providerIds instanceof Set))throw new TypeError('Invalid configuration write route');
  const providers=new Set(providerIds);
  return async(req,res)=>{
    const match=/^\/api\/byok\/configurations\/([A-Za-z0-9_-]{1,128})$/.exec((req.url??'').split('?')[0]);
    if(!match)return false;
    res.setHeader('Cache-Control','private, no-store');res.setHeader('X-Content-Type-Options','nosniff');
    const finish=status=>{res.statusCode=status;res.end();return true;};
    if(req.method==='GET'){
      if(req.headers.origin&&req.headers.origin!==studioOrigin)return finish(403);
      if(req.url.includes('?'))return finish(400);
      try{
        const account=await authenticate(req);if(res.destroyed)return true;if(!account?.accountId)return finish(401);
        const saved=catalog.get(match[1]);if(!saved||saved.kind!=='byok'||saved.ownerId!==account.accountId)return finish(404);
        res.statusCode=200;res.setHeader('Content-Type','application/json; charset=utf-8');
        res.end(JSON.stringify({id:saved.id,label:saved.label,model:saved.model,providerId:saved.providerId,enabled:saved.enabled,version:saved.version}));return true;
      }catch{return finish(500);}
    }
    if(req.method!=='PUT'){res.setHeader('Allow','GET, PUT');return finish(405);}
    if(req.headers.origin!==studioOrigin)return finish(403);
    if(req.url.includes('?'))return finish(400);
    if((req.headers['content-type']??'').split(';')[0].trim().toLowerCase()!=='application/json')return finish(415);
    try{
      const account=await authenticate(req);if(res.destroyed)return true;if(!account?.accountId)return finish(401);
      const chunks=[];let size=0;
      if(Number(req.headers['content-length'])>8192){req.resume();return finish(413);}
      for await(const chunk of req){size+=chunk.length;if(size>8192){req.resume();return finish(413);}chunks.push(chunk);}
      let body;
      try{body=JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(Buffer.concat(chunks)));}catch{return finish(400);}
      if(!body||typeof body!=='object'||Array.isArray(body)||Object.keys(body).some(key=>!['label','model','providerId','enabled','expectedVersion'].includes(key)))return finish(400);
      const {label,model,providerId,enabled,expectedVersion}=body;
      if([label,model,providerId].some(value=>typeof value!=='string'||!value.trim()||value.length>256||/[\u0000-\u001f\u007f]/.test(value))||!providers.has(providerId)||typeof enabled!=='boolean'||!Number.isSafeInteger(expectedVersion)||expectedVersion<0||expectedVersion>=Number.MAX_SAFE_INTEGER)return finish(400);
      // Body delivery may outlive a session. Recheck before the synchronous CAS.
      const current=await authenticate(req);if(res.destroyed)return true;if(current?.accountId!==account.accountId)return finish(401);
      const id=match[1],before=catalog.get(id);
      if(before&&(before.kind!=='byok'||before.ownerId!==account.accountId))return finish(404);
      let saved;
      try{saved=catalog.put({id,kind:'byok',ownerId:account.accountId,label,model,providerId,enabled},{expectedVersion,actorId:account.accountId});}
      catch(error){if(error instanceof ConfigurationCapacityError)return finish(429);if(error.message==='Configuration version conflict')return finish(409);throw error;}
      res.statusCode=before?200:201;res.setHeader('Content-Type','application/json; charset=utf-8');
      res.end(JSON.stringify({id:saved.id,label:saved.label,model:saved.model,providerId:saved.providerId,enabled:saved.enabled,version:saved.version}));return true;
    }catch{return finish(500);}
  };
}
