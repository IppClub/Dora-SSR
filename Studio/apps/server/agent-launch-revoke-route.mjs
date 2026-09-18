/** Revokes only the server launch snapshot. The caller must stop/persist its
 * browser runtime separately; this operation does not terminate game execution.
 */
export function createAgentLaunchRevokeRoute({studioOrigin,authorizeProject,store}) {
  const origin=new URL(studioOrigin);
  if(origin.origin!==studioOrigin || !['http:','https:'].includes(origin.protocol)
    || typeof authorizeProject!=='function' || !store?.get || !store?.revoke)throw new Error('Invalid launch revocation dependencies');
  return async(req,res)=>{
    const match=/^\/api\/projects\/([A-Za-z0-9_-]{1,128})\/agent-launch\/([a-f0-9-]{36})$/.exec(req.url??'');
    if(!match)return false;
    res.setHeader('Cache-Control','private, no-store');res.setHeader('X-Content-Type-Options','nosniff');
    const finish=status=>{res.statusCode=status;res.end();return true;};
    if(req.method!=='DELETE'){res.setHeader('Allow','DELETE');return finish(405);}
    if(req.headers.origin!==studioOrigin)return finish(403);
    try {
      for await(const chunk of req)if(chunk.length)return finish(400);
      const [,projectId,id]=match,grant=await authorizeProject(req,projectId);
      if(!grant?.accountId || grant.projectId!==projectId)return finish(403);
      const launch=store.get(id);
      if(!launch)return finish(204);
      if(launch.config.accountId!==grant.accountId || launch.config.projectId!==projectId)return finish(403);
      store.revoke(id);return finish(204);
    }catch{return finish(500);}
  };
}
