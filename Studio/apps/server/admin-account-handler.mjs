import {createSessionAuthenticator} from './session-authenticate.mjs';
import {createAdminAccountWriteRoute} from './admin-account-write-route.mjs';

/** Account administration with shared session checks and transaction-bound writes. */
export function createAdminAccountHandler({studioOrigin,sessions,accounts}){
  const origin=new URL(studioOrigin);
  if(origin.origin!==studioOrigin||!['http:','https:'].includes(origin.protocol)||!['isAllowed','isAdministrator','list','audit'].every(key=>typeof accounts?.[key]==='function'))throw new TypeError('Invalid admin account handler');
  const authenticate=createSessionAuthenticator({sessions,allowAccount:accounts.isAllowed});
  const write=createAdminAccountWriteRoute({studioOrigin,sessions,accounts});
  return async(req,res)=>{
    if(req.method!=='GET'&&await write(req,res))return true;
    const path=(req.url??'').split('?')[0];
    const detail=/^\/api\/admin\/accounts\/([^/?]+)$/.exec(path);
    if(!detail&&path!=='/api/admin/accounts'&&path!=='/api/admin/account-audit')return false;
    res.setHeader('Cache-Control','private, no-store');res.setHeader('X-Content-Type-Options','nosniff');
    const finish=status=>{res.statusCode=status;res.end();return true;};
    if(req.method!=='GET'){res.setHeader('Allow','GET');return finish(405);}
    if(req.headers.origin&&req.headers.origin!==studioOrigin||req.headers['sec-fetch-site']==='cross-site')return finish(403);
    try{
      const account=await authenticate(req);if(res.destroyed)return true;
      if(!account)return finish(401);
      if(!accounts.isAdministrator(account.accountId))return finish(403);
      if(req.url.length>4096)return finish(400);
      if(detail){
        if(req.url.includes('?'))return finish(400);
        let id;try{id=decodeURIComponent(detail[1]);}catch{return finish(400);}
        if(!id.trim()||id.length>256||/[\u0000-\u001f\u007f]/.test(id))return finish(400);
        const row=accounts.get(id);if(!row)return finish(404);
        res.setHeader('Content-Type','application/json; charset=utf-8');res.statusCode=200;res.end(JSON.stringify(row));return true;
      }
      const query=new URL(req.url,studioOrigin).searchParams;
      if([...query.keys()].some(key=>!['after','limit'].includes(key))||query.getAll('after').length>1||query.getAll('limit').length>1)return finish(400);
      const rawLimit=query.get('limit')??'20';
      if(!/^[1-9][0-9]{0,2}$/.test(rawLimit)||Number(rawLimit)>100)return finish(400);
      const limit=Number(rawLimit),audit=path==='/api/admin/account-audit';
      const cursor=query.get('after')??(audit?'0':'');
      if(audit?(!/^(0|[1-9][0-9]*)$/.test(cursor)||!Number.isSafeInteger(Number(cursor))):(cursor.length>256||cursor!==''&&!cursor.trim()||/[\u0000-\u001f\u007f]/.test(cursor)))return finish(400);
      const page=audit?accounts.audit({after:Number(cursor),limit}):accounts.list({after:cursor,limit});
      res.setHeader('Content-Type','application/json; charset=utf-8');res.statusCode=200;
      res.end(JSON.stringify({version:1,...page}));return true;
    }catch{return finish(500);}
  };
}
