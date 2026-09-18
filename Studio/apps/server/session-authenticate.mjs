export const SESSION_COOKIE_NAME='__Host-dora-studio-session';

export function readSessionToken(req) {
  const header=req.headers.cookie;
  if(typeof header!=='string'||header.length>8192||/[\u0000-\u001f\u007f]/.test(header))return null;
  let token;
  for(const part of header.split(';')){
    const segment=part.trim(),equals=segment.indexOf('=');
    if((equals<0?segment:segment.slice(0,equals).trim())!==SESSION_COOKIE_NAME)continue;
    if(token!==undefined||equals<0)return null;
    token=segment.slice(equals+1);
    if(!/^[A-Za-z0-9_-]{43}$/.test(token))return null;
  }
  return token??null;
}

/** Cookie issuance belongs to the verified login flow: HTTPS, Secure, HttpOnly,
 * Path=/, no Domain, and an explicit SameSite policy are required there.
 * This reader neither issues cookies nor authorizes project/admin operations. */
export function createSessionAuthenticator({sessions,allowAccount}) {
  if(typeof sessions?.resolve!=='function'||typeof allowAccount!=='function')throw new TypeError('Missing session authorization dependencies');
  return async req=>{
    const token=readSessionToken(req);
    if(!token)return null;
    const initial=sessions.resolve(token);if(!initial)return null;
    if(await allowAccount(initial.accountId)!==true)return null;
    // Account checks can await a remote database. A session revoked/expired
    // during that await must not be resurrected by the earlier lookup.
    const current=sessions.resolve(token);
    return current?.accountId===initial.accountId?{accountId:current.accountId}:null;
  };
}
