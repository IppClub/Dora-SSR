/** Public projection of deployment-approved BYOK providers; never endpoints or headers. */
export function createByokProvidersRoute({studioOrigin,authenticate,providers}) {
  const origin=new URL(studioOrigin);
  if(origin.origin!==studioOrigin||!['http:','https:'].includes(origin.protocol)||typeof authenticate!=='function'||!Array.isArray(providers)||providers.length>100)throw new TypeError('Invalid providers route');
  const ids=new Set();
  const choices=providers.map(({id,label})=>{
    if(typeof id!=='string'||!id.length||id.length>256||ids.has(id)||typeof label!=='string'||!label.trim()||label.length>256)throw new TypeError('Invalid provider');
    ids.add(id);return {id,label};
  });
  return async(req,res)=>{
    if((req.url??'').split('?')[0]!=='/api/byok/providers')return false;
    res.setHeader('Cache-Control','private, no-store');res.setHeader('X-Content-Type-Options','nosniff');
    const finish=status=>{res.statusCode=status;res.end();return true;};
    if(req.method!=='GET'){res.setHeader('Allow','GET');return finish(405);}
    if(req.headers.origin&&req.headers.origin!==studioOrigin)return finish(403);
    if(req.url.includes('?'))return finish(400);
    try{
      const account=await authenticate(req);if(res.destroyed)return true;if(!account?.accountId)return finish(401);
      res.setHeader('Content-Type','application/json; charset=utf-8');res.statusCode=200;
      res.end(JSON.stringify({version:1,providers:choices}));return true;
    }catch{return finish(500);}
  };
}
