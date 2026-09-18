import {readSessionToken} from './session-authenticate.mjs';
import {validateSnapshot} from '../../packages/contracts/dist/index.js';
const exact=(value,keys)=>value&&typeof value==='object'&&!Array.isArray(value)&&Object.keys(value).every(key=>keys.includes(key));
export function createProjectWriteRoute({studioOrigin,authenticate,projects,maxBodyBytes=32*1024*1024,bodyTimeoutMs=30000}){
  const origin=new URL(studioOrigin);
  if(origin.origin!==studioOrigin||!['http:','https:'].includes(origin.protocol)||typeof authenticate!=='function'||typeof projects?.saveSession!=='function'||typeof projects?.remove!=='function'||!Number.isSafeInteger(maxBodyBytes)||maxBodyBytes<1||maxBodyBytes>32*1024*1024||!Number.isSafeInteger(bodyTimeoutMs)||bodyTimeoutMs<1)throw new TypeError('Invalid project write route');
  return async(req,res)=>{
    if(req.method!=='PUT'&&req.method!=='DELETE')return false;
    const match=/^\/api\/projects\/([^/?]+)$/.exec((req.url??'').split('?')[0]);if(!match)return false;
    res.setHeader('Cache-Control','private, no-store');res.setHeader('X-Content-Type-Options','nosniff');
    const finish=status=>{res.statusCode=status;res.end();return true;};
    if(req.headers.origin!==studioOrigin||req.headers['sec-fetch-site']==='cross-site')return finish(403);
    if(req.url.includes('?')||req.url.length>4096)return finish(400);
    let id;try{id=decodeURIComponent(match[1]);}catch{return finish(400);}
    if(!id.trim()||id.length>256||/[\u0000-\u001f\u007f]/.test(id))return finish(400);
    if(req.method==='DELETE'){
      if(req.url.includes('?')||Number(req.headers['content-length']??0)!==0||req.headers['transfer-encoding'])return finish(400);
      try{
        const actor=await authenticate(req);if(res.destroyed)return true;if(!actor)return finish(401);
        if(req.headers['x-studio-account']!==encodeURIComponent(actor.accountId))return finish(409);
        projects.remove(actor.accountId,id);return finish(204);
      }catch{return finish(500);}
    }
    if((req.headers['content-type']??'').split(';')[0].trim().toLowerCase()!=='application/json')return finish(415);
    let timer;
    try{
      const actor=await authenticate(req);if(res.destroyed)return true;if(!actor)return finish(401);
      if(Number(req.headers['content-length'])>maxBodyBytes)return finish(413);
      timer=setTimeout(()=>req.destroy(),bodyTimeoutMs);timer.unref();
      const chunks=[];let size=0;
      for await(const chunk of req){size+=chunk.length;if(size>maxBodyBytes)return finish(413);chunks.push(chunk);}
      clearTimeout(timer);
      let body,snapshot;
      try{
        body=JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(Buffer.concat(chunks)));
        if(!exact(body,['expectedAccountId','requestId','baseRevision','name','snapshot'])||typeof body.expectedAccountId!=='string'||!body.expectedAccountId.trim()||body.expectedAccountId.length>256
          ||typeof body.name!=='string'||!body.name.trim()||body.name.length>200||!body.name.isWellFormed()||/[\u0000-\u001f\u007f]/.test(body.name)
          ||!exact(body.snapshot,['version','projectId','revision','entry','files'])||!Array.isArray(body.snapshot.files))throw new Error();
        snapshot={...body.snapshot,files:body.snapshot.files.map(file=>{
          if(file?.kind==='text'&&exact(file,['path','kind','text']))return file;
          if(file?.kind!=='binary'||!exact(file,['path','kind','base64'])||typeof file.base64!=='string')throw new Error();
          const bytes=Buffer.from(file.base64,'base64');if(bytes.toString('base64')!==file.base64)throw new Error();
          return {path:file.path,kind:'binary',bytes:new Uint8Array(bytes)};
        })};
        if(snapshot.projectId!==id||validateSnapshot(snapshot).length||typeof body.requestId!=='string'||!body.requestId.trim()||body.requestId.length>256||!body.requestId.isWellFormed()||/[\u0000-\u001f\u007f]/.test(body.requestId)||!Number.isSafeInteger(body.baseRevision)||body.baseRevision<0||body.baseRevision>=Number.MAX_SAFE_INTEGER)throw new Error();
      }catch{return finish(400);}
      // A binding precondition, never an alternative source of authorization.
      if(body.expectedAccountId!==actor.accountId)return finish(409);
      const result=projects.saveSession(actor.accountId,{requestId:body.requestId,baseRevision:body.baseRevision,name:body.name,snapshot},readSessionToken(req));
      res.setHeader('Content-Type','application/json; charset=utf-8');res.statusCode=200;res.end(JSON.stringify({version:1,projectId:id,requestId:body.requestId,...result}));return true;
    }catch(error){
      if(res.destroyed)return true;
      if(error.message==='Project revision conflict')res.setHeader('X-Studio-Project-Error','revision-conflict');
      if(error.message==='Project was deleted')res.setHeader('X-Studio-Project-Error','project-deleted');
      return finish(error.message==='Project session required'||error.message==='Project account disabled'?401:error.message==='Project storage quota exceeded'?413:error.message==='Project was deleted'||/^Project (request|revision) conflict$/.test(error.message)?409:500);
    }finally{clearTimeout(timer);}
  };
}
