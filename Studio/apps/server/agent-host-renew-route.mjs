/** Extend a live Agent host's short resource lease only after checking the
 * current cookie session, account, launch generation and cloud ownership. */
export function createAgentHostRenewRoute({hostOrigin,authorize,getLaunch,store}){
  if(new URL(hostOrigin).origin!==hostOrigin||!['http:','https:'].includes(new URL(hostOrigin).protocol)||typeof authorize!=='function'||typeof getLaunch!=='function'||!store?.renew)throw new TypeError('Invalid Agent host renewal route');
  return async(req,res)=>{
    const match=/^\/agent-host\/([A-Za-z0-9_-]{1,128})\/renew$/.exec(req.url??'');if(!match)return false;
    res.setHeader('Cache-Control','private, no-store');res.setHeader('X-Content-Type-Options','nosniff');res.setHeader('Cross-Origin-Resource-Policy','same-origin');
    const finish=(status,payload)=>{res.statusCode=status;res.setHeader('Content-Type','application/json; charset=utf-8');res.end(JSON.stringify(payload));return true;};
    if(req.method!=='POST'){res.setHeader('Allow','POST');return finish(405,{error:'method-not-allowed'});}
    if(req.headers.origin!==hostOrigin||req.headers['sec-fetch-site']==='cross-site')return finish(403,{error:'wrong-origin'});
    try{
      for await(const chunk of req)if(chunk.length)return finish(400,{error:'unexpected-body'});
      const id=match[1],grant=await authorize(req,id),launch=await getLaunch(id);
      if(!grant||!launch||grant.accountId!==launch.config.accountId||grant.projectId!==launch.config.projectId||grant.generation!==launch.config.generation)return finish(403,{error:'agent-launch-forbidden'});
      const renewed=store.renew(id);
      if(!renewed)return finish(404,{error:'agent-launch-expired'});
      return finish(200,{version:1,expiresAt:renewed.expiresAt});
    }catch{return finish(503,{error:'agent-renew-unavailable'});}
  };
}
