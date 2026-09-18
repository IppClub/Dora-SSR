import {randomUUID} from 'node:crypto';

/** Ephemeral launch snapshots, not project persistence or authentication.
 * A process restart invalidates its launch URLs; creation requires platform
 * authorization before calling put. Use a shared implementation for multi-node
 * deployment. Returned snapshots are copies to prevent cross-request mutation.
 */
export function createAgentLaunchStore({maxEntries=32,maxBytes=64*1024*1024,now=Date.now}={}) {
  if(!Number.isSafeInteger(maxEntries) || maxEntries<1 || !Number.isSafeInteger(maxBytes) || maxBytes<1 || typeof now!=='function')throw new Error('Invalid launch store limits');
  const entries=new Map();let bytes=0;
  const remove=id=>{const entry=entries.get(id);if(!entry)return false;entries.delete(id);bytes-=entry.bytes;return true;};
  const time=()=>{const value=now();if(!Number.isSafeInteger(value) || value<0)throw new Error('Invalid launch clock');return value;};
  const expire=timestamp=>{for(const [id,entry] of entries)if(entry.expiresAt<=timestamp)remove(id);};
  return {
    put(snapshot,ttlMs=5*60*1000) {
      if(!Number.isSafeInteger(ttlMs) || ttlMs<1 || ttlMs>24*60*60*1000)throw new Error('Invalid launch lifetime');
      if(!snapshot?.config?.accountId || !snapshot.config.projectId || !snapshot.config.generation || !Array.isArray(snapshot.files))throw new Error('Invalid launch snapshot');
      const timestamp=time();expire(timestamp);
      let size=Buffer.byteLength(JSON.stringify({config:snapshot.config,manifest:snapshot.manifest}));
      for(const file of snapshot.files){
        if(typeof file.path!=='string' || !(file.bytes instanceof Uint8Array))throw new Error('Invalid launch file');
        size+=Buffer.byteLength(file.path)+file.bytes.byteLength;
        if(size>maxBytes)throw new Error('Launch snapshot exceeds storage limit');
      }
      if(entries.size>=maxEntries || bytes+size>maxBytes)throw new Error('Launch storage capacity reached');
      const copy=structuredClone(snapshot),id=randomUUID(),expiresAt=timestamp+ttlMs;
      if(!Number.isSafeInteger(expiresAt))throw new Error('Invalid launch expiration');
      entries.set(id,{snapshot:copy,createdAt:timestamp,expiresAt,bytes:size});bytes+=size;
      return {id,expiresAt};
    },
    get(id) {expire(time());const entry=entries.get(id);return entry?structuredClone(entry.snapshot):undefined;},
    /** Authenticated host heartbeat: extend the short resource lease while
     * bounding a single launch's total lifetime to one day. */
    renew(id,ttlMs=5*60*1000) {
      if(!Number.isSafeInteger(ttlMs)||ttlMs<1||ttlMs>24*60*60*1000)throw new Error('Invalid launch lifetime');
      const timestamp=time();expire(timestamp);
      const entry=entries.get(id);if(!entry)return undefined;
      const expiresAt=Math.min(timestamp+ttlMs,entry.createdAt+24*60*60*1000);
      if(expiresAt<=timestamp){remove(id);return undefined;}
      entry.expiresAt=expiresAt;return {expiresAt};
    },
    revoke:remove,
    stats() {expire(time());return {entries:entries.size,bytes};},
  };
}
