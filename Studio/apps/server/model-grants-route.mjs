/** API scope IDs bind to shared catalog configuration IDs. Missing bindings
 * are not exposed as usable configurations; pagination still advances. */
export function createModelGrantsRoute({studioOrigin,authenticate,ledger,catalog,vault,gatewayProviders}) {
  const origin=new URL(studioOrigin);
  if(origin.origin!==studioOrigin||!['http:','https:'].includes(origin.protocol)||typeof authenticate!=='function'||typeof ledger?.grantsForAccount!=='function'||typeof catalog?.get!=='function')throw new TypeError('Invalid grants route');
  if(gatewayProviders!==undefined&&(!(gatewayProviders instanceof Map)||typeof vault?.metadata!=='function'||typeof ledger?.allowance!=='function'))throw new TypeError('Invalid model gateway readiness dependencies');
  return async(req,res)=>{
    if((req.url??'').split('?')[0]!=='/api/model-grants')return false;
    res.setHeader('Cache-Control','private, no-store');res.setHeader('X-Content-Type-Options','nosniff');
    const finish=status=>{res.statusCode=status;res.end();return true;};
    if(req.method!=='GET'){res.setHeader('Allow','GET');return finish(405);}
    if(req.headers.origin&&req.headers.origin!==studioOrigin)return finish(403);
    try{
      const params=new URL(req.url,studioOrigin).searchParams;
      if([...params.keys()].some(key=>!['after','limit'].includes(key))||params.getAll('after').length>1||params.getAll('limit').length>1)return finish(400);
      const after=params.get('after')??'',raw=params.get('limit')??'20';
      if(after.length>256||!/^[1-9][0-9]?$/.test(raw)||Number(raw)>50)return finish(400);
      const account=await authenticate(req);if(res.destroyed)return true;if(!account?.accountId)return finish(401);
      const limit=Number(raw),rows=ledger.grantsForAccount(account.accountId,{after,limit:limit+1}),page=rows.slice(0,limit);
      const configurations=[];
      for(const row of page){
        // Internal legacy scope IDs may not be addressable by the allowance API.
        if(!/^[A-Za-z0-9_-]{1,128}$/.test(row.grantId))continue;
        const config=catalog.get(row.apiId);
        if(!config||config.kind!=='shared'||config.ownerId!=='platform')continue;
        let enabled=config.enabled;
        if(gatewayProviders){
          // Admin catalog enablement is not enough to start an Agent task:
          // the deployment endpoint, encrypted Key and all three account
          // scopes must be ready before this grant is selectable.
          const secret=vault.metadata({kind:'shared',ownerId:'platform',configurationId:config.id});
          let allowance;try{allowance=ledger.allowance(account.accountId,row.grantId);}catch{/* incomplete legacy scope */}
          enabled=enabled&&gatewayProviders.has(config.providerId)&&secret?.available===true&&allowance?.state==='available';
        }
        configurations.push({grantId:row.grantId,label:config.label,model:config.model,enabled:!!enabled});
      }
      res.statusCode=200;res.setHeader('Content-Type','application/json; charset=utf-8');res.end(JSON.stringify({version:1,configurations,nextCursor:rows.length>limit?page.at(-1).grantId:null}));return true;
    }catch{return finish(500);}
  };
}
