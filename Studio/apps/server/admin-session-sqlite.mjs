import {createHash} from 'node:crypto';

/** Called only while a SQLite BEGIN IMMEDIATE writer lock is held in the same
 * database as studio_sessions/studio_accounts. A preflight HTTP auth check is
 * not enough when a slow admin upload races revocation. */
export function assertAdministratorSession(db,{actorId,sessionToken}){
  if(typeof actorId!=='string'||!actorId||actorId.length>256||typeof sessionToken!=='string'||!/^[A-Za-z0-9_-]{43}$/.test(sessionToken))throw new Error('Administrator session required');
  const now=Date.now(),hash=createHash('sha256').update(sessionToken).digest('hex');
  const session=db.prepare('SELECT account_id FROM studio_sessions WHERE token_hash=? AND revoked_at IS NULL AND created_at<=? AND expires_at>?').get(hash,now,now);
  if(session?.account_id!==actorId)throw new Error('Administrator session required');
  const actor=db.prepare('SELECT enabled,administrator FROM studio_accounts WHERE id=?').get(actorId);
  if(actor?.enabled!==1||actor.administrator!==1)throw new Error('Administrator authorization required');
}
