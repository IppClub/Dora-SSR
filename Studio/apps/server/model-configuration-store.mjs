import {DatabaseSync} from 'node:sqlite';
import {assertAdministratorSession} from './admin-session-sqlite.mjs';
const identity=value=>{if(typeof value!=='string'||!value.length||value.length>256)throw new TypeError('Invalid configuration identity');return value;};
const pricing=value=>{
  if(value===undefined)return undefined;
  if(!value||typeof value!=='object'||Array.isArray(value)||Object.keys(value).sort().join(',')!=='inputNanoCnyPerMillion,outputNanoCnyPerMillion')throw new TypeError('Invalid shared pricing');
  for(const name of ['inputNanoCnyPerMillion','outputNanoCnyPerMillion'])if(typeof value[name]!=='string'||!/^(?:0|[1-9][0-9]{0,18})$/.test(value[name]))throw new TypeError('Invalid shared pricing');
  return {...value};
};
/** Non-secret catalog. Provider IDs refer to trusted deployment definitions;
 * no user-supplied URL, headers or credentials are accepted here. */
export class ConfigurationCapacityError extends Error {
  constructor(){super('Configuration capacity reached');this.name='ConfigurationCapacityError';}
}
export function openModelConfigurationStore(path,{providerIds,maxByokConfigurationsPerAccount=100}) {
  if(!(providerIds instanceof Set)||!providerIds.size)throw new TypeError('Missing provider catalog');
  if(!Number.isSafeInteger(maxByokConfigurationsPerAccount)||maxByokConfigurationsPerAccount<0)throw new TypeError('Invalid configuration capacity');
  const providers=new Set([...providerIds].map(identity)),db=new DatabaseSync(path);
  db.exec(`PRAGMA busy_timeout=5000; PRAGMA journal_mode=WAL; PRAGMA synchronous=FULL;
    CREATE TABLE IF NOT EXISTS model_configurations(id TEXT PRIMARY KEY,kind TEXT NOT NULL,owner_id TEXT NOT NULL,data TEXT NOT NULL);
    CREATE INDEX IF NOT EXISTS owned_model_configurations ON model_configurations(kind,owner_id,id);
    CREATE TABLE IF NOT EXISTS model_configuration_audit(sequence INTEGER PRIMARY KEY AUTOINCREMENT,data TEXT NOT NULL);`);
  const get=id=>{const row=db.prepare('SELECT data FROM model_configurations WHERE id=?').get(identity(id));return row?JSON.parse(row.data):undefined;};
  return {
    close:()=>db.close(),
    get,
    put({id,kind,ownerId,label,model,providerId,enabled,pricing:rate},{expectedVersion,actorId,sessionToken}) {
      for(const value of [id,ownerId,label,model,providerId,actorId])identity(value);
      if(!/^[A-Za-z0-9_-]{1,128}$/.test(id)||!['shared','byok'].includes(kind)||kind==='shared'&&ownerId!=='platform'||typeof enabled!=='boolean'||!providers.has(providerId)||!Number.isSafeInteger(expectedVersion)||expectedVersion<0||expectedVersion>=Number.MAX_SAFE_INTEGER)throw new TypeError('Invalid model configuration');
      if(kind==='byok'&&rate!==undefined)throw new TypeError('BYOK pricing belongs to user estimates, not the shared catalog');
      const fixedPricing=pricing(rate);
      db.exec('BEGIN IMMEDIATE');
      try{
        if(sessionToken!==undefined)assertAdministratorSession(db,{actorId,sessionToken});
        const before=get(id);
        if((before?.version??0)!==expectedVersion)throw new Error('Configuration version conflict');
        if(before&&(before.ownerId!==ownerId||before.kind!==kind))throw new Error('Cannot transfer model configuration');
        if(sessionToken!==undefined&&kind==='shared'){
          if(!(fixedPricing??before?.pricing))throw new Error('Shared pricing required');
          if(enabled){
            const secret=db.prepare("SELECT ciphertext FROM model_secrets WHERE kind='shared' AND owner_id='platform' AND configuration_id=?").get(id);
            const api=db.prepare("SELECT data FROM model_scopes WHERE kind='api' AND id=?").get(id);
            const scope=api?JSON.parse(api.data):null;
            if(!secret?.ciphertext||scope?.enabled!==true||!Number.isSafeInteger(scope.limit)||scope.limit<1)throw new Error('Shared configuration not ready');
          }
        }
        if(!before&&kind==='byok'){
          const {count}=db.prepare("SELECT COUNT(*) AS count FROM model_configurations WHERE kind='byok' AND owner_id=?").get(ownerId);
          if(count>=maxByokConfigurationsPerAccount)throw new ConfigurationCapacityError();
        }
        const after={id,kind,ownerId,label,model,providerId,enabled,version:expectedVersion+1,
          ...(kind==='shared'&&(fixedPricing??before?.pricing)?{pricing:fixedPricing??before.pricing}:{})};
        db.prepare('INSERT INTO model_configurations VALUES(?,?,?,?) ON CONFLICT(id) DO UPDATE SET data=excluded.data').run(id,kind,ownerId,JSON.stringify(after));
        db.prepare('INSERT INTO model_configuration_audit(data) VALUES(?)').run(JSON.stringify({actorId,before:before??null,after,createdAt:Date.now()}));
        db.exec('COMMIT');return after;
      }catch(error){db.exec('ROLLBACK');throw error;}
    },
    ownedByok(accountId,configurationId) {
      identity(accountId);const record=get(configurationId);
      return record?.kind==='byok'&&record.ownerId===accountId?record:undefined;
    },
    listShared({after='',limit=50}={}){
      if(after!==''&&!/^[A-Za-z0-9_-]{1,128}$/.test(after)||!Number.isSafeInteger(limit)||limit<1||limit>100)throw new TypeError('Invalid shared configuration page');
      return db.prepare("SELECT data FROM model_configurations WHERE kind='shared' AND owner_id='platform' AND id>? ORDER BY id LIMIT ?").all(after,limit).map(row=>JSON.parse(row.data));
    },
    listOwnedByok(accountId,{after='',limit=50}={}) {
      identity(accountId);
      if(typeof after!=='string'||after.length>128||!Number.isSafeInteger(limit)||limit<1||limit>100)throw new TypeError('Invalid configuration page');
      return db.prepare("SELECT data FROM model_configurations WHERE kind='byok' AND owner_id=? AND id>? ORDER BY id LIMIT ?").all(accountId,after,limit).map(row=>JSON.parse(row.data));
    },
  };
}

/** Fits createByokSecretRoute's ownership callback. Real session authentication
 * is still required; a client account ID is not an authentication result. */
export function authorizeOwnedByok(store,authenticate) {
  if(typeof authenticate!=='function'||typeof store?.ownedByok!=='function')throw new TypeError('Invalid configuration authorizer');
  return async(req,configurationId)=>{
    const account=await authenticate(req);
    if(!account?.accountId)return undefined;
    const config=store.ownedByok(account.accountId,configurationId);
    return config?{accountId:account.accountId,configurationId:config.id}:undefined;
  };
}
