/** Same-origin read-only endpoint. Authentication is provided by the platform;
 * neither the path nor client headers can select an account through this API.
 * Values are exact integer nano-CNY strings, not provider account balances.
 */
export function createModelAllowanceRoute({studioOrigin,authenticate,ledger,catalog}) {
  const origin=new URL(studioOrigin);
  if(origin.origin!==studioOrigin||!['http:','https:'].includes(origin.protocol)||typeof authenticate!=='function'||typeof ledger?.allowance!=='function')throw new TypeError('Invalid allowance route dependencies');
  if(catalog&&(typeof catalog.get!=='function'||typeof ledger.ownedGrantBinding!=='function'))throw new TypeError('Invalid allowance catalog');
  return async(req,res)=>{
    const match=/^\/api\/model-grants\/([A-Za-z0-9_-]{1,128})\/allowance$/.exec(req.url??'');
    if(!match)return false;
    res.setHeader('Cache-Control','private, no-store');res.setHeader('X-Content-Type-Options','nosniff');
    const finish=status=>{res.statusCode=status;res.end();return true;};
    if(req.method!=='GET'){res.setHeader('Allow','GET');return finish(405);}
    if(req.headers.origin&&req.headers.origin!==studioOrigin)return finish(403);
    try {
      const identity=await authenticate(req);
      if(res.destroyed)return true;
      if(!identity?.accountId)return finish(401);
      const allowance=ledger.allowance(identity.accountId,match[1]);
      if(!allowance)return finish(404);
      if(catalog){
        const binding=ledger.ownedGrantBinding(identity.accountId,match[1]);
        const configuration=binding?catalog.get(binding.apiId):undefined;
        if(!configuration||configuration.kind!=='shared'||configuration.ownerId!=='platform')return finish(404);
        if(!configuration.enabled){allowance.state='unavailable';allowance.available=null;}
      }
      res.statusCode=200;res.setHeader('Content-Type','application/json; charset=utf-8');
      res.end(JSON.stringify(allowance));return true;
    }catch{return finish(500);}
  };
}
