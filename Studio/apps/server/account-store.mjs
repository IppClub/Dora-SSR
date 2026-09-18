import {DatabaseSync} from 'node:sqlite';
import {createHash} from 'node:crypto';

const identity=value=>{
  if(typeof value!=='string'||!value.trim()||value.length>256||/[\u0000-\u001f\u007f]/.test(value)||!value.isWellFormed())throw new TypeError('Invalid account identity');
  return value;
};
/** Trusted account provisioning after invitation/identity verification. Not a
 * registration endpoint, password store, or administrator authorization check. */
export function openAccountStore(path){
  const db=new DatabaseSync(path);
  db.exec(`PRAGMA busy_timeout=5000; PRAGMA journal_mode=WAL; PRAGMA synchronous=FULL;
    CREATE TABLE IF NOT EXISTS studio_accounts(id TEXT PRIMARY KEY,enabled INTEGER NOT NULL,version INTEGER NOT NULL);
    CREATE TABLE IF NOT EXISTS studio_account_audit(sequence INTEGER PRIMARY KEY AUTOINCREMENT,data TEXT NOT NULL);`);
  db.exec('BEGIN IMMEDIATE');
  try{
    if(!db.prepare('PRAGMA table_info(studio_accounts)').all().some(column=>column.name==='administrator'))db.exec('ALTER TABLE studio_accounts ADD COLUMN administrator INTEGER NOT NULL DEFAULT 0');
    db.exec('COMMIT');
  }catch(error){db.exec('ROLLBACK');db.close();throw error;}
  const project=row=>({accountId:row.id,enabled:row.enabled===1,administrator:row.administrator===1,version:row.version});
  const get=accountId=>{
    const row=db.prepare('SELECT * FROM studio_accounts WHERE id=?').get(identity(accountId));
    return row?project(row):null;
  };
  const store={
    close:()=>db.close(),get,
    isAllowed:accountId=>get(accountId)?.enabled===true,
    isAdministrator:accountId=>{const row=get(accountId);return row?.enabled===true&&row.administrator===true;},
    // Administrative reads only. Caller must authorize before exposing them.
    list({after='',limit=20}={}){
      if(after!=='')identity(after);
      if(!Number.isSafeInteger(limit)||limit<1||limit>100)throw new TypeError('Invalid account page');
      const rows=db.prepare('SELECT id,enabled,administrator,version FROM studio_accounts WHERE id>? ORDER BY id LIMIT ?').all(after,limit+1);
      const hasMore=rows.length>limit,items=rows.slice(0,limit).map(project);
      return {items,nextCursor:hasMore?items.at(-1).accountId:null};
    },
    audit({after=0,limit=20}={}){
      if(!Number.isSafeInteger(after)||after<0||!Number.isSafeInteger(limit)||limit<1||limit>100)throw new TypeError('Invalid account audit page');
      const rows=db.prepare('SELECT sequence,data FROM studio_account_audit WHERE sequence>? ORDER BY sequence LIMIT ?').all(after,limit+1);
      const hasMore=rows.length>limit,items=rows.slice(0,limit).map(row=>({sequence:row.sequence,...JSON.parse(row.data)}));
      return {items,nextCursor:hasMore?items.at(-1).sequence:null};
    },
    // Existing put is trusted bootstrap/provisioning. HTTP mutations must use
    // updateByAdministrator, never a client-supplied requireAdministrator flag.
    updateByAdministrator(accountId,changes,{expectedVersion,actorId}){
      return store.put(accountId,changes,{expectedVersion,actorId,requireAdministrator:true});
    },
    updateByAdministratorSession(accountId,changes,{expectedVersion,actorId,sessionToken}){
      if(typeof sessionToken!=='string'||!/^[A-Za-z0-9_-]{43}$/.test(sessionToken))throw new Error('Administrator session required');
      return store.put(accountId,changes,{expectedVersion,actorId,requireAdministrator:true,sessionToken});
    },
    put(accountId,{enabled,administrator},{expectedVersion,actorId,requireAdministrator=false,sessionToken}){
      identity(accountId);identity(actorId);
      if(typeof enabled!=='boolean'||!Number.isSafeInteger(expectedVersion)||expectedVersion<0||expectedVersion>=Number.MAX_SAFE_INTEGER)throw new TypeError('Invalid account update');
      if(administrator!==undefined&&typeof administrator!=='boolean')throw new TypeError('Invalid administrator state');
      if(typeof requireAdministrator!=='boolean')throw new TypeError('Invalid account authorization policy');
      db.exec('BEGIN IMMEDIATE');
      try{
        if(sessionToken!==undefined){
          if(typeof sessionToken!=='string'||!/^[A-Za-z0-9_-]{43}$/.test(sessionToken))throw new Error('Administrator session required');
          const hash=createHash('sha256').update(sessionToken).digest('hex'),now=Date.now();
          const session=db.prepare('SELECT account_id FROM studio_sessions WHERE token_hash=? AND revoked_at IS NULL AND created_at<=? AND expires_at>?').get(hash,now,now);
          if(session?.account_id!==actorId)throw new Error('Administrator session required');
        }
        const before=get(accountId);
        if(requireAdministrator){
          const actor=get(actorId);
          if(!actor?.enabled||!actor.administrator)throw new Error('Administrator authorization required');
          if(!before)throw new Error('Unknown account');
        }
        if((before?.version??0)!==expectedVersion)throw new Error('Account version conflict');
        const after={accountId,enabled,administrator:administrator??before?.administrator??false,version:expectedVersion+1};
        if(requireAdministrator&&before.enabled&&before.administrator&&(!after.enabled||!after.administrator)){
          const {count}=db.prepare('SELECT COUNT(*) AS count FROM studio_accounts WHERE enabled=1 AND administrator=1').get();
          if(count<=1)throw new Error('Cannot remove last active administrator');
        }
        db.prepare('INSERT INTO studio_accounts(id,enabled,version,administrator) VALUES(?,?,?,?) ON CONFLICT(id) DO UPDATE SET enabled=excluded.enabled,version=excluded.version,administrator=excluded.administrator').run(accountId,enabled?1:0,after.version,after.administrator?1:0);
        db.prepare('INSERT INTO studio_account_audit(data) VALUES(?)').run(JSON.stringify({actorId,before,after,createdAt:Date.now()}));
        db.exec('COMMIT');return after;
      }catch(error){db.exec('ROLLBACK');throw error;}
    },
  };
  return store;
}
