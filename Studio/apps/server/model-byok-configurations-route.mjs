export function createByokConfigurationsRoute({studioOrigin,authenticate,catalog}) {
  const origin=new URL(studioOrigin);
  if(origin.origin!==studioOrigin||!['http:','https:'].includes(origin.protocol)||typeof authenticate!=='function'||typeof catalog?.listOwnedByok!=='function')throw new TypeError('Invalid model configuration route');
  return async(req,res)=>{
    if((req.url??'').split('?')[0]!=='/api/byok/configurations')return false;
    res.setHeader('Cache-Control','private, no-store');res.setHeader('X-Content-Type-Options','nosniff');
    const finish=status=>{res.statusCode=status;res.end();return true;};
    if(req.method!=='GET'){res.setHeader('Allow','GET');return finish(405);}
    if(req.headers.origin&&req.headers.origin!==studioOrigin)return finish(403);
    try{
      const params=new URL(req.url,studioOrigin).searchParams;
      if([...params.keys()].some(key=>!['after','limit'].includes(key))||params.getAll('after').length>1||params.getAll('limit').length>1)return finish(400);
      const after=params.get('after')??'',rawLimit=params.get('limit')??'20';
      if(after.length>128||!/^[1-9][0-9]?$/.test(rawLimit)||Number(rawLimit)>50)return finish(400);
      const account=await authenticate(req);if(res.destroyed)return true;if(!account?.accountId)return finish(401);
      const limit=Number(rawLimit),rows=catalog.listOwnedByok(account.accountId,{after,limit:limit+1});
      // Explicit field projection keeps future private catalog fields private.
      const configurations=rows.slice(0,limit).map(({id,label,model,providerId,enabled,version})=>({id,label,model,providerId,enabled,version}));
      res.statusCode=200;res.setHeader('Content-Type','application/json; charset=utf-8');
      res.end(JSON.stringify({version:1,configurations,nextCursor:rows.length>limit?configurations.at(-1).id:null}));return true;
    }catch{return finish(500);}
  };
}
