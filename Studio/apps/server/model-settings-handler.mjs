import {createModelAllowanceRoute} from './model-allowance-route.mjs';
import {createModelGrantsRoute} from './model-grants-route.mjs';
import {createByokProvidersRoute} from './model-byok-providers-route.mjs';
import {createByokConfigurationsRoute} from './model-byok-configurations-route.mjs';
import {createByokConfigurationWriteRoute} from './model-byok-configuration-write-route.mjs';
import {createByokSecretRoute} from './model-byok-secret-route.mjs';
import {createByokUsageRoute} from './model-byok-usage-route.mjs';
import {authorizeOwnedByok} from './model-configuration-store.mjs';

/** Mount before static/SPA fallback. Caller owns stores and real authentication.
 * No identity default, provider transport, listener or model dispatch is created.
 */
export function createModelSettingsHandler({studioOrigin,authenticate,catalog,vault,ledger,providers,gatewayProviders}) {
  // The discovery constructor validates and copies the deployment definitions.
  const discover=createByokProvidersRoute({studioOrigin,authenticate,providers});
  const providerIds=new Set(providers.map(provider=>provider.id));
  const routes=[
    createModelGrantsRoute({studioOrigin,authenticate,ledger,catalog,vault,gatewayProviders}),
    discover,
    createByokConfigurationsRoute({studioOrigin,authenticate,catalog}),
    createByokConfigurationWriteRoute({studioOrigin,authenticate,catalog,providerIds}),
    createByokSecretRoute({studioOrigin,authorizeConfiguration:authorizeOwnedByok(catalog,authenticate),vault}),
    createByokUsageRoute({studioOrigin,authenticate,ledger}),
    createModelAllowanceRoute({studioOrigin,authenticate,ledger,catalog}),
  ];
  return async(req,res)=>{
    const path=(req.url??'').split('?')[0];
    if(!/^\/api\/(?:byok|model-grants)(?:\/|$)/.test(path))return false;
    for(const route of routes)if(await route(req,res))return true;
    // Malformed/unknown API paths never receive a successful HTML app shell.
    res.setHeader('Cache-Control','private, no-store');res.setHeader('X-Content-Type-Options','nosniff');
    res.statusCode=404;res.end();return true;
  };
}
