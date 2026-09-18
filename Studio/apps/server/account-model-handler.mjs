import {createSessionAuthenticator} from './session-authenticate.mjs';
import {createSessionRoute} from './session-route.mjs';
import {createSessionLogoutRoute} from './session-logout-route.mjs';
import {createModelSettingsHandler} from './model-settings-handler.mjs';
import {createAdminAccountHandler} from './admin-account-handler.mjs';
import {createProjectReadRoute} from './project-read-route.mjs';
import {createProjectWriteRoute} from './project-write-route.mjs';
import {createLoginRoute} from './login-route.mjs';
import {createAdminSharedModelsHandler} from './admin-shared-models-handler.mjs';
import {createAdminModelAllowancesHandler} from './admin-model-allowances-handler.mjs';

/** Shared read/settings entry point. The caller owns stores and supplies a live
 * account authorization check; no anonymous/test identity fallback is present. */
export function createAccountModelHandler({studioOrigin,sessions,accounts,login,projects,catalog,vault,ledger,providers,gatewayProviders}) {
  const authenticate=createSessionAuthenticator({sessions,allowAccount:accounts?.isAllowed});
  const admin=createAdminAccountHandler({studioOrigin,sessions,accounts});
  const sharedModels=createAdminSharedModelsHandler({studioOrigin,sessions,accounts,catalog,vault,ledger});
  const modelAllowances=createAdminModelAllowancesHandler({studioOrigin,sessions,accounts,ledger,catalog});
  const projectReads=createProjectReadRoute({studioOrigin,authenticate,projects});
  const projectWrites=createProjectWriteRoute({studioOrigin,authenticate,projects});
  const session=createSessionRoute({studioOrigin,authenticate});
  const logout=createSessionLogoutRoute({studioOrigin,sessions});
  const settings=createModelSettingsHandler({studioOrigin,authenticate,catalog,vault,ledger,providers,gatewayProviders});
  const loginRoute=login?createLoginRoute({studioOrigin,login,sessions,accounts}):null;
  return async(req,res)=>await loginRoute?.(req,res)||await logout(req,res)||await session(req,res)||await admin(req,res)||await sharedModels(req,res)||await modelAllowances(req,res)||await projectWrites(req,res)||await projectReads(req,res)||await settings(req,res);
}
