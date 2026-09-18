/** Read-only identity projection. The deployment authenticates the request;
 * this route never creates sessions or trusts client-provided account IDs. */
export function createSessionRoute({studioOrigin,authenticate}) {
  const origin=new URL(studioOrigin);
  if(origin.origin!==studioOrigin||!['http:','https:'].includes(origin.protocol)||typeof authenticate!=='function')throw new TypeError('Invalid session route');
  return async(req,res)=>{
    if((req.url??'').split('?')[0]!=='/api/session')return false;
    res.setHeader('Cache-Control','private, no-store');
    res.setHeader('X-Content-Type-Options','nosniff');
    const finish=status=>{res.statusCode=status;res.end();return true;};
    if(req.method!=='GET'){res.setHeader('Allow','GET');return finish(405);}
    if(req.headers.origin&&req.headers.origin!==studioOrigin||req.headers['sec-fetch-site']==='cross-site')return finish(403);
    if(req.url.includes('?'))return finish(400);
    try{
      const account=await authenticate(req);
      if(res.destroyed)return true;
      if(!account)return finish(401);
      const accountId=account.accountId;
      if(typeof accountId!=='string'||!accountId.trim()||accountId.length>256||/[\u0000-\u001f\u007f]/.test(accountId)||!accountId.isWellFormed())return finish(500);
      res.setHeader('Content-Type','application/json; charset=utf-8');
      res.statusCode=200;res.end(JSON.stringify({version:1,account:{accountId}}));return true;
    }catch{return finish(500);}
  };
}
