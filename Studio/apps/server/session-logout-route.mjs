import {readSessionToken,SESSION_COOKIE_NAME} from './session-authenticate.mjs';

/** Revokes only the presented session, including for disabled accounts. */
export function createSessionLogoutRoute({studioOrigin,sessions}) {
  const origin=new URL(studioOrigin);
  if(origin.origin!==studioOrigin||!['http:','https:'].includes(origin.protocol)||typeof sessions?.revoke!=='function')throw new TypeError('Invalid logout route');
  return async(req,res)=>{
    if((req.url??'').split('?')[0]!=='/api/session/logout')return false;
    res.setHeader('Cache-Control','private, no-store');res.setHeader('X-Content-Type-Options','nosniff');
    const finish=status=>{res.statusCode=status;res.end();return true;};
    if(req.method!=='POST'){res.setHeader('Allow','POST');return finish(405);}
    if(req.headers.origin!==studioOrigin||req.headers['sec-fetch-site']==='cross-site')return finish(403);
    if(req.url.includes('?'))return finish(400);
    try{
      const token=readSessionToken(req);if(token)sessions.revoke(token);
      res.setHeader('Set-Cookie',`${SESSION_COOKIE_NAME}=; Path=/; Max-Age=0; Secure; HttpOnly; SameSite=Lax`);
      return finish(204);
    }catch{return finish(500);}
  };
}
