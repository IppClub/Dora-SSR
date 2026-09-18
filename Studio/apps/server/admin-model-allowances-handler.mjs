import {createSessionAuthenticator,readSessionToken} from './session-authenticate.mjs';

const scopeId=value=>typeof value==='string'&&value.trim()&&value.length<=256&&value.isWellFormed()&&!/[\x00-\x1f\x7f]/.test(value);
const grantId=value=>typeof value==='string'&&/^[A-Za-z0-9_-]{1,128}$/.test(value);
const amount=value=>typeof value==='string'&&/^(?:0|[1-9][0-9]{0,18})$/.test(value)?BigInt(value):null;
const view=row=>({enabled:row.enabled,limit:row.limit,active:row.active,amountLimit:row.amountLimit.toString(),spent:row.spent.toString(),reserved:row.reserved.toString(),...(row.accountId?{accountId:row.accountId,apiId:row.apiId}:{})});
async function readBody(req){
  if((req.headers['content-type']??'').split(';')[0].trim().toLowerCase()!=='application/json')throw new Error('Unsupported content type');
  if(Number(req.headers['content-length'])>4096){req.resume();throw new Error('Request too large');}
  const chunks=[];let bytes;
  try{
    let size=0;for await(const chunk of req){size+=chunk.length;if(size>4096){req.resume();throw new Error('Request too large');}chunks.push(Buffer.from(chunk));}
    bytes=Buffer.concat(chunks);
    try{return JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(bytes));}catch{throw new Error('Invalid JSON');}
  }finally{bytes?.fill(0);for(const chunk of chunks)chunk.fill(0);}
}
/** Account total and account×API scopes; no client-supplied funding source or
 * pricing. Shared catalog and account status are checked by trusted stores. */
export function createAdminModelAllowancesHandler({studioOrigin,sessions,accounts,ledger,catalog}){
  const origin=new URL(studioOrigin);
  if(origin.origin!==studioOrigin||!['https:','http:'].includes(origin.protocol)||!sessions||!accounts?.isAdministrator||!accounts?.get||!ledger?.configure||!ledger?.scope||!ledger?.grantsForAccount||!catalog?.get)throw new TypeError('Invalid model allowance administration');
  const authenticate=createSessionAuthenticator({sessions,allowAccount:accounts.isAllowed});
  const account=/^\/api\/admin\/model-accounts\/([^/?]+)(?:\/(grants))?$/;
  const grant=/^\/api\/admin\/model-grants\/([A-Za-z0-9_-]{1,128})$/;
  return async(req,res)=>{
    const path=(req.url??'').split('?')[0],accountMatch=account.exec(path),grantMatch=grant.exec(path);
    if(!accountMatch&&!grantMatch)return false;
    res.setHeader('Cache-Control','private, no-store');res.setHeader('X-Content-Type-Options','nosniff');
    const finish=(status,data)=>{res.statusCode=status;if(data!==undefined){res.setHeader('Content-Type','application/json; charset=utf-8');res.end(JSON.stringify(data));}else res.end();return true;};
    if(req.method==='GET'?req.headers.origin&&req.headers.origin!==studioOrigin:req.headers.origin!==studioOrigin||req.headers['sec-fetch-site']==='cross-site')return finish(403);
    if(req.url.length>4096)return finish(400);
    if(!['GET','PUT'].includes(req.method)||accountMatch?.[2]&&req.method!=='GET'){res.setHeader('Allow',accountMatch?.[2]?'GET':'GET, PUT');return finish(405);}
    let accountId;
    try{if(accountMatch)accountId=decodeURIComponent(accountMatch[1]);}catch{return finish(400);}
    if(accountMatch&&!scopeId(accountId))return finish(400);
    try{
      const actor=await authenticate(req);if(res.destroyed)return true;if(!actor?.accountId)return finish(401);
      if(!accounts.isAdministrator(actor.accountId))return finish(403);
      if(req.method==='GET'){
        if(accountMatch?.[2]){
          if(!accounts.get(accountId))return finish(404);
          const params=new URL(req.url,studioOrigin).searchParams;
          if([...params.keys()].some(key=>!['after','limit'].includes(key))||params.getAll('after').length>1||params.getAll('limit').length>1)return finish(400);
          const after=params.get('after')??'',raw=params.get('limit')??'20';
          if(after&&!grantId(after)||!/^[1-9][0-9]?$/.test(raw)||Number(raw)>50)return finish(400);
          const limit=Number(raw),rows=ledger.grantsForAccount(accountId,{after,limit:limit+1}),items=rows.slice(0,limit).map(row=>({grantId:row.grantId,apiId:row.apiId,scope:view(ledger.scope('grant',row.grantId))}));
          return finish(200,{version:1,items,nextCursor:rows.length>limit?items.at(-1).grantId:null});
        }
        if(req.url.includes('?'))return finish(400);
        const key=accountMatch?accountId:grantMatch[1];let row;
        try{row=ledger.scope(accountMatch?'account':'grant',key);}catch{return finish(404);}
        return finish(200,{version:1,id:key,scope:view(row)});
      }
      if(req.url.includes('?'))return finish(400);
      const body=await readBody(req);
      if(!body||typeof body!=='object'||Array.isArray(body))return finish(400);
      const options={actorId:actor.accountId,sessionToken:readSessionToken(req)};
      if(accountMatch){
        if(!accounts.get(accountId))return finish(404);
        if(Object.keys(body).some(key=>!['enabled','limit','amountLimit'].includes(key))||typeof body.enabled!=='boolean'||!Number.isSafeInteger(body.limit)||body.limit<0||body.limit>1000||amount(body.amountLimit)===null)return finish(400);
        ledger.configure('account',accountId,{enabled:body.enabled,limit:body.limit,amountLimit:amount(body.amountLimit)},options);
        return finish(200,{version:1,id:accountId,scope:view(ledger.scope('account',accountId))});
      }
      if(Object.keys(body).some(key=>!['enabled','limit','amountLimit','accountId','apiId'].includes(key))||typeof body.enabled!=='boolean'||!Number.isSafeInteger(body.limit)||body.limit<0||body.limit>1000||amount(body.amountLimit)===null||!scopeId(body.accountId)||!grantId(body.apiId))return finish(400);
      if(!accounts.get(body.accountId))return finish(404);
      const config=catalog.get(body.apiId);if(config?.kind!=='shared'||config.ownerId!=='platform')return finish(404);
      const id=grantMatch[1];
      ledger.configure('grant',id,{enabled:body.enabled,limit:body.limit,amountLimit:amount(body.amountLimit),accountId:body.accountId,apiId:body.apiId},options);
      return finish(200,{version:1,id,scope:view(ledger.scope('grant',id))});
    }catch(error){
      if(error?.message==='Unsupported content type')return finish(415);
      if(error?.message==='Request too large')return finish(413);
      if(error?.message==='Invalid JSON'||error instanceof TypeError)return finish(400);
      if(error?.message==='Administrator session required')return finish(401);
      if(error?.message==='Administrator authorization required')return finish(403);
      if(['Unknown account','Unknown shared configuration','Unknown model scope'].includes(error?.message))return finish(404);
      if(error?.message==='Cannot rebind grant')return finish(409);
      return finish(500);
    }
  };
}
