import {createSessionAuthenticator,readSessionToken} from './session-authenticate.mjs';

export function createAdminAccountWriteRoute({studioOrigin,sessions,accounts}){
  const origin=new URL(studioOrigin);
  if(origin.origin!==studioOrigin||!['http:','https:'].includes(origin.protocol)||typeof accounts?.isAdministrator!=='function'||typeof accounts?.updateByAdministratorSession!=='function')throw new TypeError('Invalid admin write route');
  const authenticate=createSessionAuthenticator({sessions,allowAccount:accounts.isAllowed});
  return async(req,res)=>{
    const match=/^\/api\/admin\/accounts\/([^/?]+)$/.exec((req.url??'').split('?')[0]);if(!match)return false;
    res.setHeader('Cache-Control','private, no-store');res.setHeader('X-Content-Type-Options','nosniff');
    const finish=status=>{res.statusCode=status;res.end();return true;};
    if(req.method!=='PUT'){res.setHeader('Allow','PUT');return finish(405);}
    if(req.headers.origin!==studioOrigin||req.headers['sec-fetch-site']==='cross-site')return finish(403);
    if(req.url.includes('?'))return finish(400);
    if((req.headers['content-type']??'').split(';')[0].trim().toLowerCase()!=='application/json')return finish(415);
    let target;try{target=decodeURIComponent(match[1]);}catch{return finish(400);}
    if(!target.trim()||target.length>256||/[\u0000-\u001f\u007f]/.test(target))return finish(400);
    try{
      const actor=await authenticate(req);if(res.destroyed)return true;if(!actor)return finish(401);
      if(!accounts.isAdministrator(actor.accountId))return finish(403);
      if(Number(req.headers['content-length'])>4096){req.resume();return finish(413);}
      const chunks=[];let size=0;
      for await(const chunk of req){size+=chunk.length;if(size>4096){req.resume();return finish(413);}chunks.push(chunk);}
      let body;try{body=JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(Buffer.concat(chunks)));}catch{return finish(400);}
      if(!body||typeof body!=='object'||Array.isArray(body)||Object.keys(body).some(key=>!['enabled','administrator','expectedVersion'].includes(key))||typeof body.enabled!=='boolean'||typeof body.administrator!=='boolean'||!Number.isSafeInteger(body.expectedVersion)||body.expectedVersion<1||body.expectedVersion>=Number.MAX_SAFE_INTEGER)return finish(400);
      // Storage rechecks both this exact cookie session and administrator status
      // under the same writer lock as the account mutation and audit.
      const saved=accounts.updateByAdministratorSession(target,{enabled:body.enabled,administrator:body.administrator},{expectedVersion:body.expectedVersion,actorId:actor.accountId,sessionToken:readSessionToken(req)});
      res.statusCode=200;res.setHeader('Content-Type','application/json; charset=utf-8');res.end(JSON.stringify(saved));return true;
    }catch(error){
      if(error.message==='Administrator session required')return finish(401);
      if(error.message==='Administrator authorization required')return finish(403);
      if(error.message==='Unknown account')return finish(404);
      if(['Account version conflict','Cannot remove last active administrator'].includes(error.message))return finish(409);
      return finish(500);
    }
  };
}
