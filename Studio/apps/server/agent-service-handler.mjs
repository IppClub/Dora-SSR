import {createSessionAuthenticator} from './session-authenticate.mjs';
import {createAgentLaunchStore} from './agent-launch-store.mjs';
import {createAgentLaunchRoute} from './agent-launch-route.mjs';
import {createAgentLaunchRevokeRoute} from './agent-launch-revoke-route.mjs';
import {createAgentHostRoute} from './agent-host-route.mjs';
import {createAgentHostAssetsRoute} from './agent-host-assets.mjs';
import {createAgentModelRoute} from './agent-model-route.mjs';
import {createAgentHostRenewRoute} from './agent-host-renew-route.mjs';

/** Binds existing launch routes to durable account/project ownership. The host
 * listener must still serve only trusted Agent/engine assets, on hostOrigin.
 */
export function createAgentServiceHandler({studioOrigin,hostOrigin,sessions,accounts,projects,createSnapshot,engineVersion,assets,modelGateway,store=createAgentLaunchStore()}) {
  const authenticate=createSessionAuthenticator({sessions,allowAccount:accounts?.isAllowed});
  const authorizeProject=async(req,projectId)=>{
    const session=await authenticate(req);
    if(!session)return null;
    const record=projects.get(session.accountId,projectId);
    if(!record || record.snapshot.projectId!==projectId)return null;
    return {accountId:session.accountId,projectId,title:`Studio 项目 ${projectId.slice(0,8)}`};
  };
  const launch=createAgentLaunchRoute({studioOrigin,hostOrigin,authorizeProject,createSnapshot,store,engineVersion});
  const revoke=createAgentLaunchRevokeRoute({studioOrigin,authorizeProject,store});
  const authorizeLaunch=async(req,id)=>{
    const session=await authenticate(req),snapshot=store.get(id);
    if(!session || !snapshot || session.accountId!==snapshot.config.accountId)return null;
    const project=await authorizeProject(req,snapshot.config.projectId);
    if(!project || project.accountId!==session.accountId)return null;
    return {accountId:session.accountId,projectId:snapshot.config.projectId,generation:snapshot.config.generation};
  };
  const privateFiles=createAgentHostRoute({getLaunch:id=>store.get(id),authorize:authorizeLaunch});
  const staticFiles=assets?createAgentHostAssetsRoute({getLaunch:id=>store.get(id),authorize:authorizeLaunch,assets}):null;
  const model=modelGateway?createAgentModelRoute({hostOrigin,authorize:authorizeLaunch,getLaunch:id=>store.get(id),...modelGateway}):null;
  const renew=createAgentHostRenewRoute({hostOrigin,authorize:authorizeLaunch,getLaunch:id=>store.get(id),store});
  return {api:async(req,res)=>await revoke(req,res)||await launch(req,res),host:async(req,res)=>await renew(req,res)||await model?.(req,res)||await privateFiles(req,res)||await staticFiles?.(req,res)||false,store};
}
