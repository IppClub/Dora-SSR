/** Account identity is supplied by platform authentication, never a query. */
export function createByokUsageRoute({studioOrigin,authenticate,ledger}) {
  const origin=new URL(studioOrigin);
  if(origin.origin!==studioOrigin||!['http:','https:'].includes(origin.protocol)||typeof authenticate!=='function'||typeof ledger?.byokUsageReport!=='function')throw new TypeError('Invalid BYOK usage route');
  return async(req,res)=>{
    if((req.url??'').split('?')[0]!=='/api/byok/usage')return false;
    res.setHeader('Cache-Control','private, no-store');res.setHeader('X-Content-Type-Options','nosniff');
    const finish=status=>{res.statusCode=status;res.end();return true;};
    if(req.method!=='GET'){res.setHeader('Allow','GET');return finish(405);}
    if(req.headers.origin&&req.headers.origin!==studioOrigin)return finish(403);
    try{
      const params=new URL(req.url,studioOrigin).searchParams;
      if([...params.keys()].some(key=>!['after','limit'].includes(key))||params.getAll('after').length>1||params.getAll('limit').length>1)return finish(400);
      const after=params.get('after')??'',rawLimit=params.get('limit')??'50';
      if(after.length>256||!/^[1-9][0-9]{0,2}$/.test(rawLimit)||Number(rawLimit)>100)return finish(400);
      const identity=await authenticate(req);if(res.destroyed)return true;if(!identity?.accountId)return finish(401);
      const limit=Number(rawLimit),report=ledger.byokUsageReport(identity.accountId,{after,limit:limit+1});
      const hasMore=report.records.length>limit;
      report.records=report.records.slice(0,limit);
      res.setHeader('Content-Type','application/json; charset=utf-8');res.statusCode=200;
      res.end(JSON.stringify({version:1,funding:'byok',...report,nextCursor:hasMore?report.records.at(-1).requestId:null},(_,value)=>typeof value==='bigint'?value.toString():value));return true;
    }catch{return finish(500);}
  };
}
