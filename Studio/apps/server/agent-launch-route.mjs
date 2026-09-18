import {randomUUID} from 'node:crypto';

/** Platform authenticates the request and returns its authorized project record.
 * No account ID, title, generation, engine URL or script comes from the body.
 */
export function createAgentLaunchRoute({studioOrigin,hostOrigin,authorizeProject,createSnapshot,store,engineVersion}) {
  for(const origin of [studioOrigin,hostOrigin]){
    const url=new URL(origin);if(url.origin!==origin || !['http:','https:'].includes(url.protocol))throw new Error('Invalid deployment origin');
  }
  if(studioOrigin===hostOrigin || typeof authorizeProject!=='function' || typeof createSnapshot!=='function' || !store?.put)throw new Error('Invalid launch dependencies');
  return async(req,res)=>{
    const match=/^\/api\/projects\/([A-Za-z0-9_-]{1,128})\/agent-launch$/.exec(req.url??'');
    if(!match)return false;
    res.setHeader('Cache-Control','private, no-store');res.setHeader('X-Content-Type-Options','nosniff');
    const finish=status=>{res.statusCode=status;res.end();return true;};
    if(req.method!=='POST'){res.setHeader('Allow','POST');return finish(405);}
    if(req.headers.origin!==studioOrigin)return finish(403);
    try {
      // The operation has no payload. Reject rather than accepting hidden claims.
      for await(const chunk of req)if(chunk.length)return finish(400);
      const projectId=match[1],grant=await authorizeProject(req,projectId);
      if(res.destroyed)return true;
      if(!grant?.accountId || grant.projectId!==projectId || typeof grant.title!=='string')return finish(403);
      const accountId=grant.accountId,title=grant.title;
      const generation=randomUUID();
      const snapshot=await createSnapshot({version:1,parentOrigin:studioOrigin,accountId,
        projectId,generation,projectRoot:'/user/studio-project',title},{engineVersion});
      if(res.destroyed)return true;
      const current=await authorizeProject(req,projectId);
      if(res.destroyed)return true;
      if(!current || current.accountId!==accountId || current.projectId!==projectId)return finish(403);
      const launch=store.put(snapshot);
      res.statusCode=201;res.setHeader('Content-Type','application/json; charset=utf-8');
      res.end(JSON.stringify({version:1,projectId,generation,expiresAt:launch.expiresAt,
        url:`${hostOrigin}/agent-host/${launch.id}/index.html`}));return true;
    }catch{return finish(500);}
  };
}
