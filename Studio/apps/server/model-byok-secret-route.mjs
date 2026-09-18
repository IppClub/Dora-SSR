/** The authorizer returns a currently owned configuration, not client claims.
 * This route never accepts provider URLs, ownership or funding-source changes.
 */
export function createByokSecretRoute({studioOrigin,authorizeConfiguration,vault}) {
  const url=new URL(studioOrigin);
  if(url.origin!==studioOrigin||!['https:','http:'].includes(url.protocol)||typeof authorizeConfiguration!=='function'||!vault?.put||!vault?.revoke||!vault?.metadata)throw new TypeError('Invalid BYOK secret route');
  return async(req,res)=>{
    const match=/^\/api\/byok\/configurations\/([A-Za-z0-9_-]{1,128})\/secret$/.exec(req.url??'');
    if(!match)return false;
    res.setHeader('Cache-Control','private, no-store');res.setHeader('X-Content-Type-Options','nosniff');
    const finish=(status,data)=>{res.statusCode=status;if(data){res.setHeader('Content-Type','application/json; charset=utf-8');res.end(JSON.stringify(data));}else res.end();return true;};
    if(!['GET','PUT','DELETE'].includes(req.method)){res.setHeader('Allow','GET, PUT, DELETE');return finish(405);}
    if(req.method!=='GET'?req.headers.origin!==studioOrigin:req.headers.origin&&req.headers.origin!==studioOrigin)return finish(403);
    let bytes,chunks=[];
    try{
      const configurationId=match[1],owner=await authorizeConfiguration(req,configurationId);
      if(res.destroyed)return true;
      if(!owner?.accountId||owner.configurationId!==configurationId)return finish(404);
      const binding={kind:'byok',ownerId:owner.accountId,configurationId};
      if(req.method==='GET')return finish(200,vault.metadata(binding)??{version:0,available:false});
      if(!/^application\/json(?:\s*;|$)/i.test(req.headers['content-type']??''))return finish(415);
      if(Number(req.headers['content-length'])>65536){req.resume();return finish(413);}
      let size=0;
      for await(const chunk of req){size+=chunk.length;if(size>65536)return finish(413);chunks.push(Buffer.from(chunk));}
      bytes=Buffer.concat(chunks);
      let body;try{body=JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(bytes));}catch{return finish(400);}
      if(!body||Array.isArray(body)||typeof body!=='object'||!Number.isSafeInteger(body.expectedVersion)||body.expectedVersion<0||body.expectedVersion>=Number.MAX_SAFE_INTEGER)return finish(400);
      const allowed=req.method==='PUT'?['expectedVersion','key','consent']:['expectedVersion'];
      if(Object.keys(body).some(key=>!allowed.includes(key)))return finish(400);
      if(req.method==='PUT'&&(body.consent!==true||typeof body.key!=='string'||!body.key.length||!body.key.isWellFormed()||Buffer.byteLength(body.key)>16384||/[\u0000-\u001f\u007f]/.test(body.key)))return finish(400);
      // Recheck after reading the upload, before any durable mutation.
      const current=await authorizeConfiguration(req,configurationId);
      if(res.destroyed)return true;
      if(!current||current.accountId!==owner.accountId||current.configurationId!==configurationId)return finish(404);
      const options={expectedVersion:body.expectedVersion,actorId:owner.accountId};
      if(req.method==='DELETE')return finish(200,vault.revoke(binding,options));
      const secret=Buffer.from(body.key);delete body.key;
      try{return finish(200,vault.put(binding,secret,options));}finally{secret.fill(0);}
    }catch(error){return finish(error?.message==='Secret version conflict'?409:500);}
    finally{bytes?.fill(0);for(const chunk of chunks)chunk.fill(0);}
  };
}
