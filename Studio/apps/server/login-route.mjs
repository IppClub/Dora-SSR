import {readSessionToken,SESSION_COOKIE_NAME} from './session-authenticate.mjs';

const maxBody=2048;
async function jsonBody(req){
  if(Number(req.headers['content-length'])>maxBody)throw new Error('too large');
  const chunks=[];let size=0;
  for await(const chunk of req){size+=chunk.length;if(size>maxBody)throw new Error('too large');chunks.push(chunk);}
  return JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(Buffer.concat(chunks)));
}
const exact=(body,keys)=>body&&typeof body==='object'&&!Array.isArray(body)&&Object.keys(body).length===keys.length&&keys.every(key=>Object.hasOwn(body,key));

export function createLoginRoute({studioOrigin,login,sessions,accounts,ttlMs=7*24*60*60*1000}){
  if(new URL(studioOrigin).protocol!=='https:'||!['redeem','verify','issueInvite'].every(key=>typeof login?.[key]==='function')||typeof sessions?.issue!=='function'||typeof accounts?.isAllowed!=='function')throw new TypeError('HTTPS login route and stores required');
  const issue=(res,accountId)=>{
    if(!accounts.isAllowed(accountId))throw new Error('Account disabled');
    const {token}=sessions.issue(accountId,{ttlMs});
    res.setHeader('Set-Cookie',`${SESSION_COOKIE_NAME}=${token}; Path=/; Max-Age=${Math.floor(ttlMs/1000)}; Secure; HttpOnly; SameSite=Lax`);
    res.setHeader('Content-Type','application/json; charset=utf-8');res.statusCode=200;
    res.end(JSON.stringify({version:1,account:{accountId}}));return true;
  };
  return async(req,res)=>{
    const path=(req.url??'').split('?')[0];
    if(!['/api/auth/register','/api/auth/login','/api/admin/invitations'].includes(path))return false;
    res.setHeader('Cache-Control','private, no-store');res.setHeader('X-Content-Type-Options','nosniff');
    const finish=status=>{res.statusCode=status;res.end();return true;};
    if(req.method!=='POST'){res.setHeader('Allow','POST');return finish(405);}
    if(req.socket.encrypted!==true)return finish(403);
    if(req.url.includes('?'))return finish(400);
    if(req.headers.origin!==studioOrigin||req.headers['sec-fetch-site']==='cross-site')return finish(403);
    if((req.headers['content-type']??'').split(';')[0].trim().toLowerCase()!=='application/json')return finish(415);
    let body;try{body=await jsonBody(req);}catch{return finish(400);}
    try{
      if(path==='/api/admin/invitations'){
        if(!exact(body,['administrator']))return finish(400);
        const token=readSessionToken(req),session=token&&sessions.resolve(token);
        if(!session||!accounts.isAllowed(session.accountId))return finish(401);
        if(!accounts.isAdministrator(session.accountId))return finish(403);
        const result=login.issueInvite({administrator:body.administrator,createdBy:session.accountId,actorSessionToken:token});
        res.setHeader('Content-Type','application/json; charset=utf-8');res.statusCode=201;res.end(JSON.stringify({version:1,...result}));return true;
      }
      if(path==='/api/auth/register'){
        if(!exact(body,['code','accountId','password']))return finish(400);
        const {accountId}=await login.redeem({...body,remoteKey:req.socket.remoteAddress??''});return issue(res,accountId);
      }
      if(!exact(body,['accountId','password']))return finish(400);
      const remoteKey=req.socket.remoteAddress??'';
      if(!await login.verify({...body,remoteKey}))return finish(401);
      return issue(res,body.accountId);
    }catch(error){
      if(error instanceof TypeError)return finish(400);
      if(['Invitation unavailable','Account unavailable'].includes(error.message))return finish(409);
      if(error.message==='Registration rate limited')return finish(429);
      if(error.message==='Administrator session required')return finish(401);
      if(error.message==='Account disabled')return finish(401);
      return finish(500);
    }
  };
}
