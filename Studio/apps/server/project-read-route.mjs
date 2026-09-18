/** Owner comes exclusively from authentication. This route never grants source
 * access through public play links or administrator status. */
export function createProjectReadRoute({studioOrigin,authenticate,projects}){
  const origin=new URL(studioOrigin);
  if(origin.origin!==studioOrigin||!['http:','https:'].includes(origin.protocol)||typeof authenticate!=='function'||!['list','history','get','getVersion'].every(key=>typeof projects?.[key]==='function'))throw new TypeError('Invalid project route');
  return async(req,res)=>{
    const path=(req.url??'').split('?')[0];
    if(path!=='/api/projects'&&!path.startsWith('/api/projects/'))return false;
    res.setHeader('Cache-Control','private, no-store');res.setHeader('X-Content-Type-Options','nosniff');
    const finish=status=>{res.statusCode=status;res.end();return true;};
    if(req.method!=='GET'){res.setHeader('Allow','GET');return finish(405);}
    if(req.headers.origin&&req.headers.origin!==studioOrigin||req.headers['sec-fetch-site']==='cross-site')return finish(403);
    try{
      const account=await authenticate(req);if(res.destroyed)return true;if(!account)return finish(401);
      if(req.headers['x-studio-account']!==undefined&&req.headers['x-studio-account']!==encodeURIComponent(account.accountId))return finish(409);
      if(req.url.length>4096)return finish(400);
      const match=/^\/api\/projects\/([^/]+)(?:\/(history|versions\/([1-9][0-9]*)))?$/.exec(path);
      if(path!=='/api/projects'&&!match)return finish(404);
      let projectId;
      if(match){try{projectId=decodeURIComponent(match[1]);}catch{return finish(400);}
        if(!projectId.trim()||projectId.length>256||/[\u0000-\u001f\u007f]/.test(projectId))return finish(400);
      }
      const query=new URL(req.url,studioOrigin).searchParams;
      const paged=!match||match[2]==='history';
      if([...query.keys()].some(key=>!paged||!['after','limit'].includes(key))||query.getAll('after').length>1||query.getAll('limit').length>1)return finish(400);
      let result;
      if(paged){
        const rawLimit=query.get('limit')??'20';if(!/^[1-9][0-9]{0,2}$/.test(rawLimit)||Number(rawLimit)>100)return finish(400);
        const after=query.get('after')??(match?'0':'');
        if(match?(!/^(0|[1-9][0-9]*)$/.test(after)||!Number.isSafeInteger(Number(after))):(after.length>256||after!==''&&!after.trim()||/[\u0000-\u001f\u007f]/.test(after)))return finish(400);
        result=match?projects.history(account.accountId,projectId,{after:Number(after),limit:Number(rawLimit)}):projects.list(account.accountId,{after,limit:Number(rawLimit)});
      }else{
        if(match[3]&&!Number.isSafeInteger(Number(match[3])))return finish(400);
        const record=match[3]?projects.getVersion(account.accountId,projectId,Number(match[3])):projects.get(account.accountId,projectId);
        if(!record)return finish(404);
        result={...record,snapshot:{...record.snapshot,files:record.snapshot.files.map(file=>file.kind==='binary'?{path:file.path,kind:'binary',base64:Buffer.from(file.bytes).toString('base64')}:file)}};
      }
      res.setHeader('Content-Type','application/json; charset=utf-8');res.statusCode=200;res.end(JSON.stringify({version:1,...result}));return true;
    }catch{return finish(500);}
  };
}
