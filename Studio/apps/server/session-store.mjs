import {DatabaseSync} from 'node:sqlite';
import {createHash,randomBytes} from 'node:crypto';

const account=value=>{
  if(typeof value!=='string'||!value.trim()||value.length>256||/[\u0000-\u001f\u007f]/.test(value)||!value.isWellFormed())throw new TypeError('Invalid session account');
  return value;
};
const digest=token=>typeof token==='string'&&/^[A-Za-z0-9_-]{43}$/.test(token)?createHash('sha256').update(token).digest('hex'):null;

/** Internal capability store, not login authorization. Only an already verified
 * login flow may issue sessions. Callers must additionally check account status.
 * Tokens are returned once; no plaintext bearer credential is stored in SQLite. */
export function openSessionStore(path,{now=Date.now}={}) {
  if(typeof now!=='function')throw new TypeError('Invalid session clock');
  const time=()=>{const value=now();if(!Number.isSafeInteger(value)||value<0)throw new TypeError('Invalid session time');return value;};
  const db=new DatabaseSync(path);
  db.exec(`PRAGMA busy_timeout=5000; PRAGMA journal_mode=WAL; PRAGMA synchronous=FULL;
    CREATE TABLE IF NOT EXISTS studio_sessions(token_hash TEXT PRIMARY KEY,account_id TEXT NOT NULL,created_at INTEGER NOT NULL,expires_at INTEGER NOT NULL,revoked_at INTEGER);
    CREATE INDEX IF NOT EXISTS studio_account_sessions ON studio_sessions(account_id);`);
  return {
    close:()=>db.close(),
    issue(accountId,{ttlMs}) {
      account(accountId);
      if(!Number.isSafeInteger(ttlMs)||ttlMs<1||ttlMs>30*24*60*60*1000)throw new TypeError('Invalid session lifetime');
      const createdAt=time(),expiresAt=createdAt+ttlMs;
      if(!Number.isSafeInteger(expiresAt))throw new TypeError('Invalid session expiry');
      const token=randomBytes(32).toString('base64url');
      db.prepare('INSERT INTO studio_sessions VALUES(?,?,?,?,NULL)').run(digest(token),accountId,createdAt,expiresAt);
      return {token,expiresAt};
    },
    resolve(token) {
      const hash=digest(token);if(!hash)return null;
      const timestamp=time();
      const row=db.prepare('SELECT account_id,expires_at FROM studio_sessions WHERE token_hash=? AND revoked_at IS NULL AND created_at<=? AND expires_at>?').get(hash,timestamp,timestamp);
      return row?{accountId:row.account_id,expiresAt:row.expires_at}:null;
    },
    revoke(token) {
      const hash=digest(token);if(!hash)return;
      db.prepare('UPDATE studio_sessions SET revoked_at=? WHERE token_hash=? AND revoked_at IS NULL').run(time(),hash);
    },
    // Trusted administrative operation; this does not itself disable an account
    // or prevent an independently authorized future login issuing another token.
    revokeAccount(accountId) {
      db.prepare('UPDATE studio_sessions SET revoked_at=? WHERE account_id=? AND revoked_at IS NULL').run(time(),account(accountId));
    },
  };
}
