import {DatabaseSync} from 'node:sqlite';
import {randomBytes,createHash,scrypt as scryptCallback,timingSafeEqual} from 'node:crypto';
import {promisify} from 'node:util';

const scrypt=promisify(scryptCallback);
const hash=value=>createHash('sha256').update(value).digest('hex');
const validId=value=>typeof value==='string'&&/^[a-zA-Z0-9][a-zA-Z0-9._-]{2,63}$/.test(value);
const validPassword=value=>typeof value==='string'&&value.length>=12&&value.length<=128&&value.isWellFormed()&&!/[\u0000-\u001f\u007f]/.test(value);
const validInvite=value=>typeof value==='string'&&/^[A-Za-z0-9_-]{43}$/.test(value);
const derive=async(password,salt)=>await scrypt(password,Buffer.from(salt,'hex'),64,{N:16384,r:8,p:1,maxmem:64*1024*1024});
const dummySalt='7e6b80a4c5d8e904b7ad620679c57d5e';
const dummyHash=Buffer.alloc(64);

/** Invite and password storage uses the same SQLite file as accounts/sessions.
 * Only a trusted bootstrap or authenticated administrator can call issueInvite.
 * Raw invite codes and plaintext passwords never enter the database. */
export function openLoginStore(path){
  const db=new DatabaseSync(path);
  db.exec(`PRAGMA busy_timeout=5000; PRAGMA journal_mode=WAL; PRAGMA synchronous=FULL;
    CREATE TABLE IF NOT EXISTS studio_invites(code_hash TEXT PRIMARY KEY,administrator INTEGER NOT NULL,expires_at INTEGER NOT NULL,consumed_at INTEGER,created_by TEXT NOT NULL);
    CREATE UNIQUE INDEX IF NOT EXISTS studio_one_bootstrap_invite ON studio_invites(created_by) WHERE created_by='bootstrap';
    CREATE TABLE IF NOT EXISTS studio_passwords(account_id TEXT PRIMARY KEY,salt TEXT NOT NULL,verifier TEXT NOT NULL);
    CREATE TABLE IF NOT EXISTS studio_login_attempts(key TEXT PRIMARY KEY,started_at INTEGER NOT NULL,count INTEGER NOT NULL);`);
  const limit=(key,now,max)=>{
    const row=db.prepare('SELECT started_at,count FROM studio_login_attempts WHERE key=?').get(key);
    if(row&&now-row.started_at<15*60*1000&&row.count>=max)return false;
    if(!row||now-row.started_at>=15*60*1000)db.prepare('INSERT INTO studio_login_attempts VALUES(?,?,1) ON CONFLICT(key) DO UPDATE SET started_at=excluded.started_at,count=1').run(key,now);
    else db.prepare('UPDATE studio_login_attempts SET count=count+1 WHERE key=?').run(key);
    return true;
  };
  return {
    close:()=>db.close(),
    issueInvite({administrator=false,ttlMs=7*24*60*60*1000,createdBy='bootstrap',actorSessionToken}){
      if(typeof administrator!=='boolean'||!Number.isSafeInteger(ttlMs)||ttlMs<60000||ttlMs>30*24*60*60*1000||!validId(createdBy)&&createdBy!=='bootstrap')throw new TypeError('Invalid invitation');
      const code=randomBytes(32).toString('base64url'),now=Date.now();
      db.exec('BEGIN IMMEDIATE');
      try{
        if(actorSessionToken!==undefined){
          if(!validInvite(actorSessionToken))throw new Error('Administrator session required');
          const row=db.prepare('SELECT a.id FROM studio_sessions s JOIN studio_accounts a ON a.id=s.account_id WHERE s.token_hash=? AND s.revoked_at IS NULL AND s.created_at<=? AND s.expires_at>? AND a.enabled=1 AND a.administrator=1').get(hash(actorSessionToken),now,now);
          if(row?.id!==createdBy)throw new Error('Administrator session required');
        }else if(createdBy!=='bootstrap')throw new Error('Administrator session required');
        else if(db.prepare('SELECT 1 FROM studio_accounts LIMIT 1').get())throw new Error('Bootstrap already completed');
        db.prepare('INSERT INTO studio_invites VALUES(?,?,?,?,?)').run(hash(code),administrator?1:0,now+ttlMs,null,createdBy);
        db.exec('COMMIT');return {code,expiresAt:now+ttlMs};
      }catch(error){db.exec('ROLLBACK');throw error;}
    },
    async redeem({code,accountId,password,remoteKey}){
      if(!validInvite(code)||!validId(accountId)||!validPassword(password))throw new TypeError('Invalid registration');
      const now=Date.now();
      if(remoteKey!==undefined&&!limit(`register:${hash(remoteKey)}`,now,20))throw new Error('Registration rate limited');
      if(!db.prepare('SELECT 1 FROM studio_invites WHERE code_hash=? AND consumed_at IS NULL AND expires_at>?').get(hash(code),now))throw new Error('Invitation unavailable');
      const salt=randomBytes(16).toString('hex'),verifier=(await derive(password,salt)).toString('hex');
      db.exec('BEGIN IMMEDIATE');
      try{
        const transactionNow=Date.now();
        const invite=db.prepare('SELECT administrator FROM studio_invites WHERE code_hash=? AND consumed_at IS NULL AND expires_at>?').get(hash(code),transactionNow);
        if(!invite)throw new Error('Invitation unavailable');
        if(db.prepare('SELECT id FROM studio_accounts WHERE id=?').get(accountId))throw new Error('Account unavailable');
        db.prepare('INSERT INTO studio_accounts(id,enabled,version,administrator) VALUES(?,1,1,?)').run(accountId,invite.administrator);
        db.prepare('INSERT INTO studio_passwords VALUES(?,?,?)').run(accountId,salt,verifier);
        db.prepare('UPDATE studio_invites SET consumed_at=? WHERE code_hash=? AND consumed_at IS NULL').run(transactionNow,hash(code));
        db.prepare('INSERT INTO studio_account_audit(data) VALUES(?)').run(JSON.stringify({actorId:'invitation',before:null,after:{accountId,enabled:true,administrator:invite.administrator===1,version:1},createdAt:transactionNow}));
        db.exec('COMMIT');return {accountId};
      }catch(error){db.exec('ROLLBACK');throw error;}
    },
    async verify({accountId,password,remoteKey=''}){
      if(!validId(accountId)||typeof password!=='string'||password.length>128||!password.isWellFormed())return false;
      const now=Date.now(),key=hash(`${remoteKey}\0${accountId}`);
      if(!limit(`login-ip:${hash(remoteKey)}`,now,30)||!limit(`login-account:${key}`,now,10))return false;
      const row=db.prepare('SELECT p.salt,p.verifier FROM studio_passwords p JOIN studio_accounts a ON a.id=p.account_id WHERE p.account_id=? AND a.enabled=1').get(accountId);
      const actual=await derive(password,row?.salt??dummySalt);
      const valid=row?timingSafeEqual(actual,Buffer.from(row.verifier,'hex')):timingSafeEqual(actual,dummyHash)&&false;
      if(valid)db.prepare('DELETE FROM studio_login_attempts WHERE key=?').run(`login-account:${key}`);
      return valid;
    },
  };
}
