import {DatabaseSync} from 'node:sqlite';
import {tokenCharge,availableModelAmount} from './model-amount.mjs';
import {normalizeModelUsage} from './model-usage.mjs';
import {reserveModelRequest,markModelRequestDispatched,cancelUndispatchedModelRequest,finishModelRequest} from './model-reservation.mjs';
import {assertAdministratorSession} from './admin-session-sqlite.mjs';

// Single-host adapter. Keep the database on a local disk, not a network share.
// All mutations use BEGIN IMMEDIATE: independent processes serialize the read,
// authorization check, counters and request transition as one durable commit.
// This is an internal service API, never an unauthenticated HTTP interface.
const encode=value=>JSON.stringify(value,(_,v)=>typeof v==='bigint'?{$nano:v.toString()}:v);
const decode=value=>JSON.parse(value,(_,v)=>v&&typeof v==='object'&&Object.keys(v).length===1&&typeof v.$nano==='string'?BigInt(v.$nano):v);
const id=value=>{
  if(typeof value!=='string'||!value.length||value.length>256)throw new TypeError('Invalid ledger identity');
  return value;
};
export function openModelLedger(path,{requireConfigurationVersion=false}={}) {
  if(typeof requireConfigurationVersion!=='boolean')throw new TypeError('Invalid configuration binding policy');
  const db=new DatabaseSync(path);
  db.exec(`PRAGMA busy_timeout=5000; PRAGMA journal_mode=WAL; PRAGMA synchronous=FULL;
    CREATE TABLE IF NOT EXISTS model_scopes(kind TEXT NOT NULL, id TEXT NOT NULL, data TEXT NOT NULL, PRIMARY KEY(kind,id));
    CREATE INDEX IF NOT EXISTS model_account_grants ON model_scopes(json_extract(data,'$.accountId'),id) WHERE kind='grant';
    CREATE TABLE IF NOT EXISTS model_requests(id TEXT PRIMARY KEY, data TEXT NOT NULL);
    CREATE TABLE IF NOT EXISTS model_audit(sequence INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT NOT NULL);
    CREATE TABLE IF NOT EXISTS byok_requests(id TEXT PRIMARY KEY, account_id TEXT NOT NULL, data TEXT NOT NULL);
    CREATE INDEX IF NOT EXISTS byok_account_requests ON byok_requests(account_id,id);
    CREATE INDEX IF NOT EXISTS model_receipt_recovery ON model_requests(id)
      WHERE json_extract(data,'$.request.state')='in-flight' AND json_type(data,'$.receipt')='object';`);
  const audit=data=>db.prepare('INSERT INTO model_audit(data) VALUES(?)').run(encode({timestamp:Date.now(),...data}));
  const transaction=fn=>{
    db.exec('BEGIN IMMEDIATE');
    try{const result=fn();db.exec('COMMIT');return result;}
    catch(error){db.exec('ROLLBACK');throw error;}
  };
  const readScope=(kind,key)=>{
    const row=db.prepare('SELECT data FROM model_scopes WHERE kind=? AND id=?').get(kind,id(key));
    if(!row)throw new Error('Unknown model scope');
    return decode(row.data);
  };
  const writeScope=(kind,key,data)=>db.prepare('UPDATE model_scopes SET data=? WHERE kind=? AND id=?').run(encode(data),kind,key);
  const readRequest=key=>{
    const row=db.prepare('SELECT data FROM model_requests WHERE id=?').get(id(key));
    return row?decode(row.data):undefined;
  };
  // Bound requests read the catalog on this connection while BEGIN IMMEDIATE
  // holds the writer lock. The catalog must live in the same SQLite database.
  const configurationDenied=binding=>{
    if(binding.configurationVersion===undefined)return requireConfigurationVersion;
    const row=db.prepare("SELECT data FROM model_configurations WHERE id=? AND kind='shared' AND owner_id='platform'").get(binding.apiId);
    if(!row)return true;
    const config=JSON.parse(row.data);
    return config.enabled!==true||config.version!==binding.configurationVersion;
  };
  const admit=(binding,rates)=>configurationDenied(binding)
    ?{decision:{state:'denied',reason:'configuration-unavailable'}}
    :reserveModelRequest(snapshot(binding),rates);
  const snapshot=binding=>{
    const api=readScope('api',binding.apiId),account=readScope('account',binding.accountId),grant=readScope('grant',binding.grantId);
    if(grant.accountId!==binding.accountId||grant.apiId!==binding.apiId)throw new Error('Grant binding mismatch');
    return {api,account,grant,reservation:binding.reservation,amounts:{
      accountLimit:account.amountLimit,accountSpent:account.spent,accountReserved:account.reserved,
      grantLimit:grant.amountLimit,grantSpent:grant.spent,grantReserved:grant.reserved,
    }};
  };
  const save=(binding,next)=>{
    for(const kind of ['api','account','grant']){
      const row=next[kind];
      if(kind!=='api'){
        row.spent=next.amounts[`${kind}Spent`];row.reserved=next.amounts[`${kind}Reserved`];
      }
      writeScope(kind,binding[`${kind}Id`],row);
    }
  };
  return {
    close:()=>db.close(),
    // Trusted provisioning only. Existing counters cannot be reset by admin edits.
    configure(kind,key,{enabled,limit,amountLimit=0n,accountId,apiId},{actorId,sessionToken}={}) {
      id(actorId);
      if(!['api','account','grant'].includes(kind)||typeof enabled!=='boolean'||!Number.isSafeInteger(limit)||limit<0||typeof amountLimit!=='bigint'||amountLimit<0n)throw new TypeError('Invalid scope configuration');
      id(key);if(kind==='grant'){id(accountId);id(apiId);}
      return transaction(()=>{
        if(sessionToken!==undefined)assertAdministratorSession(db,{actorId,sessionToken});
        if(sessionToken!==undefined&&kind==='account'&&!db.prepare('SELECT 1 FROM studio_accounts WHERE id=?').get(key))throw new Error('Unknown account');
        if(sessionToken!==undefined&&(kind==='api'||kind==='grant')){
          const configId=kind==='api'?key:apiId;
          const row=db.prepare("SELECT data FROM model_configurations WHERE id=? AND kind='shared' AND owner_id='platform'").get(configId);
          if(!row)throw new Error('Unknown shared configuration');
        }
        const existing=db.prepare('SELECT data FROM model_scopes WHERE kind=? AND id=?').get(kind,key);
        const row=existing?decode(existing.data):{active:0,spent:0n,reserved:0n};
        if(kind==='grant'){
          readScope('account',accountId);readScope('api',apiId);
          if(existing&&(row.accountId!==accountId||row.apiId!==apiId))throw new Error('Cannot rebind grant');
          row.accountId=accountId;row.apiId=apiId;
        }
        Object.assign(row,{enabled,limit,amountLimit});
        db.prepare('INSERT INTO model_scopes(kind,id,data) VALUES(?,?,?) ON CONFLICT(kind,id) DO UPDATE SET data=excluded.data').run(kind,key,encode(row));
        audit({action:'configure',actorId,kind,scopeId:key,before:existing?decode(existing.data):null,after:row});
      });
    },
    // requestId and fingerprint are server-validated; fingerprint binds the full
    // normalized provider payload/model/config version, without storing secrets.
    reserve({requestId,accountId,apiId,grantId,fingerprint,reservation,rates,configurationVersion}) {
      for(const value of [requestId,accountId,apiId,grantId,fingerprint])id(value);
      if(typeof reservation!=='bigint'||reservation<0n)throw new TypeError('Invalid reservation');
      tokenCharge({inputTokens:0n,outputTokens:0n},rates);
      // Canonical owned pricing fields: key insertion order and unrelated caller
      // properties must not alter persistent idempotency or retain secrets.
      rates={inputNanoCnyPerMillion:rates.inputNanoCnyPerMillion,outputNanoCnyPerMillion:rates.outputNanoCnyPerMillion};
      const binding={accountId,apiId,grantId,fingerprint,reservation,rates};
      if(configurationVersion!==undefined){
        if(!Number.isSafeInteger(configurationVersion)||configurationVersion<1)throw new TypeError('Invalid configuration version');
        binding.configurationVersion=configurationVersion;
      }
      return transaction(()=>{
        if(db.prepare('SELECT 1 FROM byok_requests WHERE id=?').get(requestId))throw new Error('Request funding source mismatch');
        const old=readRequest(requestId);
        if(old){
          if(encode(old.binding)!==encode(binding))throw new Error('Idempotency binding mismatch');
          return {replayed:true,record:old};
        }
        const result=admit(binding,rates);
        if(result.decision.state==='queued'){
          const record={binding,version:1,request:{state:'queued',reservation,rates}};
          db.prepare('INSERT INTO model_requests(id,data) VALUES(?,?)').run(requestId,encode(record));
          audit({action:'queue',requestId,accountId,apiId,grantId,version:1});
          return {replayed:false,decision:result.decision,record};
        }
        if(result.decision.state!=='admitted')return {replayed:false,decision:result.decision};
        save(binding,result.next);
        const record={binding,version:1,request:result.request};
        db.prepare('INSERT INTO model_requests(id,data) VALUES(?,?)').run(requestId,encode(record));
        audit({action:'reserve',requestId,accountId,apiId,grantId,version:1,request:record.request});
        return {replayed:false,record};
      });
    },
    admitQueued(requestId,expectedVersion) {
      if(!Number.isSafeInteger(expectedVersion)||expectedVersion<1||expectedVersion===Number.MAX_SAFE_INTEGER)throw new TypeError('Invalid request version');
      return transaction(()=>{
        const record=readRequest(requestId);
        if(!record||record.version!==expectedVersion||record.request.state!=='queued')throw new Error('Request version conflict');
        const result=admit(record.binding,record.binding.rates);
        if(result.decision.state==='queued')return {decision:result.decision,record};
        if(result.decision.state==='admitted'){
          save(record.binding,result.next);record.request=result.request;
        }else record.request={...record.request,state:'rejected-before-dispatch',reason:result.decision.reason};
        record.version++;
        db.prepare('UPDATE model_requests SET data=? WHERE id=?').run(encode(record),requestId);
        audit({action:'queue-admission',requestId,accountId:record.binding.accountId,version:record.version,decision:result.decision});
        return {decision:result.decision,record};
      });
    },
    transition(requestId,expectedVersion,action,usage) {
      if(!Number.isSafeInteger(expectedVersion)||expectedVersion<1||expectedVersion===Number.MAX_SAFE_INTEGER)throw new TypeError('Invalid request version');
      return transaction(()=>{
        const record=readRequest(requestId);
        if(!record||record.version!==expectedVersion)throw new Error('Request version conflict');
        const current=snapshot(record.binding);
        if(action==='cancel'&&record.request.state==='queued')record.request={...record.request,state:'cancelled-before-dispatch'};
        else if(action==='receipt'){
          if(record.request.state!=='in-flight'||record.receipt)throw new Error('Request cannot accept a completion receipt');
          if(usage!==null)tokenCharge(usage,record.request.rates);
          record.receipt={usage:usage===null?null:normalizeModelUsage(usage)};
        }
        else if(action==='dispatch'){
          if(configurationDenied(record.binding)){
            const result=cancelUndispatchedModelRequest(current,record.request);
            save(record.binding,result.next);
            record.request={...result.request,state:'rejected-before-dispatch',reason:'configuration-unavailable'};
          }else record.request=markModelRequestDispatched(record.request,current);
        }
        else {
          let result;
          if(action==='cancel')result=cancelUndispatchedModelRequest(current,record.request);
          else if(action==='finish'){
            if(record.request.state==='in-flight'&&record.receipt){
              if(usage!==undefined&&encode(usage===null?null:normalizeModelUsage(usage))!==encode(record.receipt.usage))throw new Error('Completion receipt mismatch');
              usage=record.receipt.usage;
            }
            result=finishModelRequest(current,record.request,usage);
          }
          else throw new Error('Unknown ledger transition');
          save(record.binding,result.next);record.request=result.request;
        }
        record.version++;
        db.prepare('UPDATE model_requests SET data=? WHERE id=?').run(encode(record),requestId);
        const {accountId,apiId,grantId}=record.binding;
        audit({action,requestId,accountId,apiId,grantId,version:record.version,request:record.request,...(action==='receipt'?{receipt:record.receipt}:{})});
        return record;
      });
    },
    request:readRequest,
    scope:readScope,
    // Usage journal only, NOT permission to dispatch. The trusted gateway must
    // enforce BYOK ownership, concurrency and request identity before invoking.
    beginByok({requestId,accountId,projectId,configurationId,model,fingerprint}) {
      for(const value of [requestId,accountId,projectId,configurationId,model,fingerprint])id(value);
      const binding={accountId,projectId,configurationId,model,fingerprint};
      return transaction(()=>{
        if(readRequest(requestId))throw new Error('Request funding source mismatch');
        const old=db.prepare('SELECT data FROM byok_requests WHERE id=?').get(requestId);
        if(old){const record=decode(old.data);if(encode(record.binding)!==encode(binding))throw new Error('Idempotency binding mismatch');return {replayed:true,record};}
        readScope('account',accountId);
        const record={binding,version:1,state:'pending-usage',usage:null,createdAt:Date.now()};
        db.prepare('INSERT INTO byok_requests(id,account_id,data) VALUES(?,?,?)').run(requestId,accountId,encode(record));
        audit({action:'byok-begin',requestId,accountId,projectId,configurationId,model});
        return {replayed:false,record};
      });
    },
    recordByokUsage(accountId,requestId,expectedVersion,usage) {
      id(accountId);id(requestId);
      if(!Number.isSafeInteger(expectedVersion)||expectedVersion<1||expectedVersion===Number.MAX_SAFE_INTEGER)throw new TypeError('Invalid request version');
      const normalized=normalizeModelUsage(usage);
      return transaction(()=>{
        const row=db.prepare('SELECT data FROM byok_requests WHERE id=? AND account_id=?').get(requestId,accountId);
        if(!row)throw new Error('Unknown BYOK request');
        const record=decode(row.data);
        if(record.version!==expectedVersion||record.state!=='pending-usage')throw new Error('Request version conflict');
        record.usage=normalized;record.state='recorded';record.version++;record.recordedAt=Date.now();
        db.prepare('UPDATE byok_requests SET data=? WHERE id=? AND account_id=?').run(encode(record),requestId,accountId);
        audit({action:'byok-usage',requestId,accountId,version:record.version,usage:normalized});
        return record;
      });
    },
    grantsForAccount(accountId,{after='',limit=50}={}) {
      id(accountId);
      if(typeof after!=='string'||after.length>256||!Number.isSafeInteger(limit)||limit<1||limit>100)throw new TypeError('Invalid grants page');
      return db.prepare("SELECT id,data FROM model_scopes WHERE kind='grant' AND json_extract(data,'$.accountId')=? AND id>? ORDER BY id LIMIT ?").all(accountId,after,limit).map(row=>({grantId:row.id,apiId:decode(row.data).apiId}));
    },
    ownedGrantBinding(accountId,grantId) {
      id(accountId);id(grantId);
      const row=db.prepare("SELECT data FROM model_scopes WHERE kind='grant' AND id=?").get(grantId);
      if(!row)return undefined;
      const grant=decode(row.data);return grant.accountId===accountId?{grantId,apiId:grant.apiId}:undefined;
    },
    byokUsagePage(accountId,{after='',limit=100}={}) {
      id(accountId);
      if(typeof after!=='string'||after.length>256||!Number.isSafeInteger(limit)||limit<1||limit>1000)throw new TypeError('Invalid BYOK page');
      return db.prepare('SELECT id,data FROM byok_requests WHERE account_id=? AND id>? ORDER BY id LIMIT ?').all(accountId,after,limit)
        .map(row=>{
          const {binding,version,state,usage,createdAt,recordedAt}=decode(row.data);
          // Do not expose fingerprint, credentials or an invented vendor balance.
          return {requestId:row.id,projectId:binding.projectId,configurationId:binding.configurationId,model:binding.model,version,state,usage,createdAt,...(recordedAt!==undefined?{recordedAt}:{})};
        });
    },
    byokUsageReport(accountId,options={}) {
      id(accountId);
      // One WAL read snapshot for the page and summary. No floating SQL SUM:
      // persisted token counts may exceed Number.MAX_SAFE_INTEGER.
      db.exec('BEGIN');
      try{
        const records=this.byokUsagePage(accountId,options);
        const summary={registeredRequests:0n,knownUsageRequests:0n,pendingUsageRequests:0n,inputTokens:0n,outputTokens:0n};
        for(const row of db.prepare('SELECT data FROM byok_requests WHERE account_id=?').iterate(accountId)){
          const record=decode(row.data);summary.registeredRequests++;
          if(record.usage===null)summary.pendingUsageRequests++;
          else{summary.knownUsageRequests++;summary.inputTokens+=record.usage.inputTokens;summary.outputTokens+=record.usage.outputTokens;}
        }
        db.exec('COMMIT');return {records,summary};
      }catch(error){db.exec('ROLLBACK');throw error;}
    },
    // Identity MUST come from authenticated server context, not request input.
    allowance(accountId,grantId) {
      id(accountId);id(grantId);
      return transaction(()=>{
        const row=db.prepare("SELECT data FROM model_scopes WHERE kind='grant' AND id=?").get(grantId);
        if(!row)return undefined;
        const grant=decode(row.data);
        if(grant.accountId!==accountId)return undefined;
        const current=snapshot({accountId,apiId:grant.apiId,grantId,reservation:0n});
        const scopes=['api','account','grant'];
        const enabled=scopes.every(kind=>current[kind].enabled);
        const capacity=scopes.every(kind=>current[kind].limit>0);
        const available=availableModelAmount(current.amounts);
        const saturated=scopes.filter(kind=>current[kind].active>=current[kind].limit);
        const state=!enabled?'unavailable':!capacity?'zero-capacity':available===0n?'insufficient-amount':saturated.length?'concurrency':'available';
        return {version:1,funding:'platform',currency:'CNY',unit:'nano-CNY',grantId,
          state,available:enabled&&capacity?available.toString():null,
          account:{spent:current.account.spent.toString(),reserved:current.account.reserved.toString(),limit:current.account.amountLimit.toString()},
          grant:{spent:grant.spent.toString(),reserved:grant.reserved.toString(),limit:grant.amountLimit.toString()},
          saturated:enabled&&capacity?saturated:[]};
      });
    },
    recoveryReceipts({after='',limit=100}={}) {
      if(typeof after!=='string'||after.length>256||!Number.isSafeInteger(limit)||limit<1||limit>1000)throw new TypeError('Invalid recovery page');
      return db.prepare(`SELECT id,data FROM model_requests WHERE id>?
        AND json_extract(data,'$.request.state')='in-flight' AND json_type(data,'$.receipt')='object'
        ORDER BY id LIMIT ?`).all(after,limit).map(row=>({requestId:row.id,version:decode(row.data).version}));
    },
    // Administrative internal read. Callers must authorize before exposing it.
    audit({after=0,limit=100}={}) {
      if(!Number.isSafeInteger(after)||after<0||!Number.isSafeInteger(limit)||limit<1||limit>1000)throw new TypeError('Invalid audit page');
      return db.prepare('SELECT sequence,data FROM model_audit WHERE sequence>? ORDER BY sequence LIMIT ?').all(after,limit)
        .map(row=>({sequence:row.sequence,...decode(row.data)}));
    },
  };
}
