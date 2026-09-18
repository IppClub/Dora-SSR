/** Private launch resources. Authentication and launch storage are supplied by
 * the platform; this module does not trust account/project claims in URLs.
 * getLaunch must return a snapshot made by createAgentHostSnapshot.
 */
export function createAgentHostRoute({authorize,getLaunch}) {
  if(typeof authorize!=='function' || typeof getLaunch!=='function')throw new Error('Agent host authorization and storage are required');
  return async function handle(req,res) {
    const match=/^\/agent-host\/([A-Za-z0-9_-]{1,128})\/(host-config\.json|host-manifest\.json|host-files\/[A-Za-z0-9_./-]+)$/.exec(req.url??'');
    if(!match)return false;
    res.setHeader('Cache-Control','private, no-store');
    res.setHeader('X-Content-Type-Options','nosniff');
    res.setHeader('Cross-Origin-Resource-Policy','same-origin');
    const finish=code=>{res.statusCode=code;res.end();return true;};
    if(req.method!=='GET' && req.method!=='HEAD'){res.setHeader('Allow','GET, HEAD');return finish(405);}
    const [,launchId,resource]=match;
    if(resource.split('/').some(part=>part==='.' || part==='..' || !part))return finish(404);
    try {
      const grant=await authorize(req,launchId);
      if(!grant)return finish(403);
      const launch=await getLaunch(launchId);
      if(!launch)return finish(404);
      if(!grant.accountId || !grant.projectId || !grant.generation || grant.accountId!==launch.config.accountId
        || grant.projectId!==launch.config.projectId || grant.generation!==launch.config.generation)return finish(403);
      let bytes;
      if(resource==='host-config.json' || resource==='host-manifest.json'){
        res.setHeader('Content-Type','application/json; charset=utf-8');
        bytes=Buffer.from(JSON.stringify(resource==='host-config.json'?launch.config:launch.manifest));
      }else{
        const file=launch.files.find(file=>file.path===resource.slice('host-files/'.length));
        if(!file)return finish(404);
        res.setHeader('Content-Type','application/octet-stream');bytes=Buffer.from(file.bytes);
      }
      res.setHeader('Content-Length',bytes.length);
      res.statusCode=200;res.end(req.method==='HEAD'?undefined:bytes);return true;
    }catch{return finish(500);}
  };
}
