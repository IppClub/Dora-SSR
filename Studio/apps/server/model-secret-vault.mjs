import {DatabaseSync} from 'node:sqlite';
import {createCipheriv,createDecipheriv,randomBytes} from 'node:crypto';
import {assertAdministratorSession} from './admin-session-sqlite.mjs';

const identifier=value=>{
  if(typeof value!=='string'||!value.length||value.length>256)throw new TypeError('Invalid secret identity');
  return value;
};
const bindingValues=({kind,ownerId,configurationId})=>{
  if(!['shared','byok'].includes(kind)||kind==='shared'&&ownerId!=='platform')throw new TypeError('Invalid secret ownership');
  return [kind,identifier(ownerId),identifier(configurationId)];
};
/** Internal vault: callers authorize owner/admin and explicit BYOK consent.
 * Master keys must come from deployment secret management, never this database.
 * withSecret is for trusted provider transports, never user/Agent callbacks.
 */
export function openModelSecretVault(path,{activeKeyId,keys}) {
  identifier(activeKeyId);
  if(!(keys instanceof Map)||!keys.has(activeKeyId))throw new TypeError('Missing active vault key');
  for(const [keyId,key] of keys){identifier(keyId);if(!(key instanceof Uint8Array)||key.byteLength!==32)throw new TypeError('Vault keys must be 32 bytes');}
  const keyring=new Map([...keys].map(([name,key])=>[name,Buffer.from(key)]));
  const db=new DatabaseSync(path);
  db.exec(`PRAGMA busy_timeout=5000; PRAGMA journal_mode=WAL; PRAGMA synchronous=FULL;
    CREATE TABLE IF NOT EXISTS model_secrets(kind TEXT NOT NULL,owner_id TEXT NOT NULL,configuration_id TEXT NOT NULL,
      version INTEGER NOT NULL,key_id TEXT,nonce BLOB,ciphertext BLOB,tag BLOB,
      PRIMARY KEY(kind,owner_id,configuration_id));
    CREATE TABLE IF NOT EXISTS model_secret_audit(sequence INTEGER PRIMARY KEY AUTOINCREMENT,action TEXT NOT NULL,actor_id TEXT NOT NULL,
      kind TEXT NOT NULL,owner_id TEXT NOT NULL,configuration_id TEXT NOT NULL,version INTEGER NOT NULL,created_at INTEGER NOT NULL);`);
  const transaction=fn=>{db.exec('BEGIN IMMEDIATE');try{const result=fn();db.exec('COMMIT');return result;}catch(error){db.exec('ROLLBACK');throw error;}};
  const read=values=>db.prepare('SELECT * FROM model_secrets WHERE kind=? AND owner_id=? AND configuration_id=?').get(...values);
  const aad=(values,version,keyId)=>Buffer.from(JSON.stringify(['dora-studio-model-secret',1,...values,version,keyId]));
  const validateVersion=version=>{if(!Number.isSafeInteger(version)||version<0||version>=Number.MAX_SAFE_INTEGER)throw new TypeError('Invalid secret version');};
  const audit=(action,actorId,values,version)=>db.prepare('INSERT INTO model_secret_audit(action,actor_id,kind,owner_id,configuration_id,version,created_at) VALUES(?,?,?,?,?,?,?)').run(action,actorId,...values,version,Date.now());
  return {
    close(){db.close();for(const key of keyring.values())key.fill(0);keyring.clear();},
    metadata(binding){const row=read(bindingValues(binding));return row?{version:row.version,available:row.ciphertext!==null}:undefined;},
    put(binding,secret,{expectedVersion,actorId,sessionToken}) {
      const values=bindingValues(binding);validateVersion(expectedVersion);identifier(actorId);
      if(!(secret instanceof Uint8Array)||secret.byteLength<1||secret.byteLength>16384)throw new TypeError('Invalid secret bytes');
      const plaintext=Buffer.from(secret);
      try{return transaction(()=>{
        if(sessionToken!==undefined){
          assertAdministratorSession(db,{actorId,sessionToken});
          if(binding.kind!=='shared'||!db.prepare("SELECT 1 FROM model_configurations WHERE id=? AND kind='shared' AND owner_id='platform'").get(binding.configurationId))throw new Error('Unknown shared configuration');
        }
        const old=read(values);if((old?.version??0)!==expectedVersion)throw new Error('Secret version conflict');
        const version=expectedVersion+1,nonce=randomBytes(12),cipher=createCipheriv('aes-256-gcm',keyring.get(activeKeyId),nonce);
        cipher.setAAD(aad(values,version,activeKeyId));
        const ciphertext=Buffer.concat([cipher.update(plaintext),cipher.final()]),tag=cipher.getAuthTag();
        db.prepare(`INSERT INTO model_secrets VALUES(?,?,?,?,?,?,?,?) ON CONFLICT(kind,owner_id,configuration_id)
          DO UPDATE SET version=excluded.version,key_id=excluded.key_id,nonce=excluded.nonce,ciphertext=excluded.ciphertext,tag=excluded.tag`).run(...values,version,activeKeyId,nonce,ciphertext,tag);
        audit('put',actorId,values,version);return {version,available:true};
      });}finally{plaintext.fill(0);}
    },
    revoke(binding,{expectedVersion,actorId,sessionToken}) {
      const values=bindingValues(binding);validateVersion(expectedVersion);identifier(actorId);
      return transaction(()=>{
        if(sessionToken!==undefined){
          assertAdministratorSession(db,{actorId,sessionToken});
          const config=db.prepare("SELECT data FROM model_configurations WHERE id=? AND kind='shared' AND owner_id='platform'").get(binding.configurationId);
          if(binding.kind!=='shared'||!config)throw new Error('Unknown shared configuration');
          if(JSON.parse(config.data).enabled)throw new Error('Disable shared configuration before revoking secret');
        }
        const old=read(values);if(!old||old.version!==expectedVersion)throw new Error('Secret version conflict');
        const version=expectedVersion+1;
        db.prepare('UPDATE model_secrets SET version=?,key_id=NULL,nonce=NULL,ciphertext=NULL,tag=NULL WHERE kind=? AND owner_id=? AND configuration_id=?').run(version,...values);
        audit('revoke',actorId,values,version);return {version,available:false};
      });
    },
    async withSecret(binding,consume) {
      const values=bindingValues(binding);
      if(typeof consume!=='function')throw new TypeError('Missing trusted secret consumer');
      const row=read(values);let plaintext;
      try{
        if(!row?.ciphertext||!keyring.has(row.key_id))throw new Error('Unavailable');
        const decipher=createDecipheriv('aes-256-gcm',keyring.get(row.key_id),row.nonce);
        decipher.setAAD(aad(values,row.version,row.key_id));decipher.setAuthTag(row.tag);
        plaintext=Buffer.concat([decipher.update(row.ciphertext),decipher.final()]);
      }catch{throw new Error('Model secret unavailable');}
      try{return await consume(plaintext,{version:row.version});}finally{plaintext.fill(0);}
    },
  };
}
