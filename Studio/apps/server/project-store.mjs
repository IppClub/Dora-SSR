import {DatabaseSync} from 'node:sqlite';
import {createHash} from 'node:crypto';
import {validateSnapshot} from '../../packages/contracts/dist/index.js';

function identity(value){
  if(typeof value!=='string'||!value.trim()||value.length>256||!value.isWellFormed()||/[\u0000-\u001f\u007f]/.test(value))throw new TypeError('Invalid project identity');
  return value;
}
function decode(data){
  const value=JSON.parse(data);
  return {...value,files:value.files.map(file=>file.kind==='binary'?{path:file.path,kind:'binary',bytes:new Uint8Array(Buffer.from(file.base64,'base64'))}:file)};
}
function pageLimit(value){if(!Number.isSafeInteger(value)||value<1||value>100)throw new TypeError('Invalid project page limit');return value;}
function projectName(value){if(typeof value!=='string'||!value.trim()||value.length>200||!value.isWellFormed()||/[\u0000-\u001f\u007f]/.test(value))throw new TypeError('Invalid project name');return value.trim();}
/** Trusted storage only: HTTP callers must authenticate the owner. Cloud revision
 * is separate from the browser snapshot revision. No implicit public access. */
export function openProjectStore(path,{maxProjects=100,maxVersions=10000,maxBytes=512*1024*1024}={}){
  for(const value of [maxProjects,maxVersions,maxBytes])if(!Number.isSafeInteger(value)||value<1)throw new TypeError('Invalid project quota');
  const db=new DatabaseSync(path);
  db.exec(`PRAGMA busy_timeout=5000; PRAGMA journal_mode=WAL; PRAGMA synchronous=FULL;
    CREATE TABLE IF NOT EXISTS studio_projects(owner TEXT NOT NULL,project TEXT NOT NULL,revision INTEGER NOT NULL,name TEXT NOT NULL,data TEXT NOT NULL,updated_at INTEGER NOT NULL,PRIMARY KEY(owner,project,revision));
    CREATE TABLE IF NOT EXISTS studio_project_uploads(owner TEXT NOT NULL,request TEXT NOT NULL,fingerprint TEXT NOT NULL,project TEXT NOT NULL,revision INTEGER NOT NULL,PRIMARY KEY(owner,request));
    CREATE TABLE IF NOT EXISTS studio_project_tombstones(owner TEXT NOT NULL,project TEXT NOT NULL,deleted_at INTEGER NOT NULL,PRIMARY KEY(owner,project));`);
  const usage=owner=>{
    const row=db.prepare('SELECT COUNT(DISTINCT project) AS projects,COUNT(*) AS versions,COALESCE(SUM(length(CAST(data AS BLOB))),0) AS bytes FROM studio_projects WHERE owner=?').get(identity(owner));
    return {projects:row.projects,versions:row.versions,bytes:row.bytes};
  };
  const store={
    usage(owner){return {...usage(owner),limits:{maxProjects,maxVersions,maxBytes}};},
    list(owner,{after='',limit=20}={}){
      identity(owner);if(after!=='')identity(after);pageLimit(limit);
      const rows=db.prepare(`SELECT current.project AS projectId,current.revision AS cloudRevision,current.updated_at AS updatedAt,current.name
        FROM studio_projects current JOIN (
          SELECT project,MAX(revision) AS revision FROM studio_projects WHERE owner=? AND project>? GROUP BY project ORDER BY project LIMIT ?
        ) latest ON latest.project=current.project AND latest.revision=current.revision
        WHERE current.owner=? ORDER BY current.project`).all(owner,after,limit+1,owner);
      const items=rows.slice(0,limit).map(row=>({projectId:row.projectId,name:row.name,cloudRevision:row.cloudRevision,updatedAt:row.updatedAt}));
      return {items,nextCursor:rows.length>limit?items.at(-1).projectId:null};
    },
    history(owner,projectId,{after=0,limit=20}={}){
      identity(owner);identity(projectId);pageLimit(limit);
      if(!Number.isSafeInteger(after)||after<0)throw new TypeError('Invalid project history cursor');
      const rows=db.prepare('SELECT revision AS cloudRevision,updated_at AS updatedAt FROM studio_projects WHERE owner=? AND project=? AND revision>? ORDER BY revision LIMIT ?').all(owner,projectId,after,limit+1);
      const items=rows.slice(0,limit).map(row=>({...row}));
      return {items,nextCursor:rows.length>limit?items.at(-1).cloudRevision:null};
    },
    getVersion(owner,projectId,cloudRevision){
      identity(owner);identity(projectId);
      if(!Number.isSafeInteger(cloudRevision)||cloudRevision<1)throw new TypeError('Invalid cloud revision');
      const row=db.prepare('SELECT revision,name,data,updated_at FROM studio_projects WHERE owner=? AND project=? AND revision=?').get(owner,projectId,cloudRevision);
      return row?{cloudRevision:row.revision,name:row.name,updatedAt:row.updated_at,snapshot:decode(row.data)}:null;
    },
    get(owner,projectId){
      const row=db.prepare('SELECT revision,name,data,updated_at FROM studio_projects WHERE owner=? AND project=? ORDER BY revision DESC LIMIT 1').get(identity(owner),identity(projectId));
      return row?{cloudRevision:row.revision,name:row.name,updatedAt:row.updated_at,snapshot:decode(row.data)}:null;
    },
    saveSession(owner,request,sessionToken){
      if(typeof sessionToken!=='string'||!/^[A-Za-z0-9_-]{43}$/.test(sessionToken))throw new Error('Project session required');
      return store.save(owner,request,{sessionToken});
    },
    save(owner,{requestId,baseRevision,snapshot,name},{sessionToken}={}){
      identity(owner);identity(requestId);identity(snapshot?.projectId);
      name=projectName(name);
      if(!Number.isSafeInteger(baseRevision)||baseRevision<0||baseRevision>=Number.MAX_SAFE_INTEGER||validateSnapshot(snapshot).length)throw new TypeError('Invalid project save');
      const files=[...snapshot.files].sort((a,b)=>a.path<b.path?-1:a.path>b.path?1:0).map(file=>file.kind==='text'?{path:file.path,kind:'text',text:file.text}:{path:file.path,kind:'binary',base64:Buffer.from(file.bytes).toString('base64')});
      const data=JSON.stringify({version:snapshot.version,projectId:snapshot.projectId,revision:snapshot.revision,entry:snapshot.entry,files});
      if(Buffer.byteLength(data)>32*1024*1024)throw new RangeError('Project snapshot exceeds storage limit');
      const fingerprint=createHash('sha256').update(JSON.stringify([baseRevision,name,data])).digest('hex');
      db.exec('BEGIN IMMEDIATE');
      try{
        if(sessionToken!==undefined){
          const now=Date.now(),hash=createHash('sha256').update(sessionToken).digest('hex');
          const session=db.prepare('SELECT account_id FROM studio_sessions WHERE token_hash=? AND revoked_at IS NULL AND created_at<=? AND expires_at>?').get(hash,now,now);
          if(!session||session.account_id!==owner)throw new Error('Project session required');
          const account=db.prepare('SELECT enabled FROM studio_accounts WHERE id=?').get(owner);
          if(account?.enabled!==1)throw new Error('Project account disabled');
        }
        if(db.prepare('SELECT 1 FROM studio_project_tombstones WHERE owner=? AND project=?').get(owner,snapshot.projectId))throw new Error('Project was deleted');
        const previous=db.prepare('SELECT fingerprint,revision FROM studio_project_uploads WHERE owner=? AND request=?').get(owner,requestId);
        if(previous){
          if(previous.fingerprint!==fingerprint)throw new Error('Project request conflict');
          db.exec('COMMIT');return {cloudRevision:previous.revision,replayed:true};
        }
        const latest=db.prepare('SELECT MAX(revision) AS revision FROM studio_projects WHERE owner=? AND project=?').get(owner,snapshot.projectId).revision??0;
        if(latest!==baseRevision)throw new Error('Project revision conflict');
        const used=usage(owner),bytes=Buffer.byteLength(data);
        if(latest===0&&used.projects>=maxProjects||used.versions>=maxVersions||bytes>maxBytes-used.bytes)throw new Error('Project storage quota exceeded');
        const revision=latest+1;
        db.prepare('INSERT INTO studio_projects(owner,project,revision,name,data,updated_at) VALUES(?,?,?,?,?,?)').run(owner,snapshot.projectId,revision,name,data,Date.now());
        db.prepare('INSERT INTO studio_project_uploads VALUES(?,?,?,?,?)').run(owner,requestId,fingerprint,snapshot.projectId,revision);
        db.exec('COMMIT');return {cloudRevision:revision,replayed:false};
      }catch(error){db.exec('ROLLBACK');throw error;}
    },
    remove(owner,projectId){
      owner=identity(owner);projectId=identity(projectId);
      db.exec('BEGIN IMMEDIATE');
      try{
        const existed=!!db.prepare('SELECT 1 FROM studio_projects WHERE owner=? AND project=? LIMIT 1').get(owner,projectId);
        db.prepare('DELETE FROM studio_project_uploads WHERE owner=? AND project=?').run(owner,projectId);
        db.prepare('DELETE FROM studio_projects WHERE owner=? AND project=?').run(owner,projectId);
        db.prepare('INSERT INTO studio_project_tombstones(owner,project,deleted_at) VALUES(?,?,?) ON CONFLICT(owner,project) DO UPDATE SET deleted_at=excluded.deleted_at').run(owner,projectId,Date.now());
        db.exec('COMMIT');return {removed:existed};
      }catch(error){db.exec('ROLLBACK');throw error;}
    },
    close(){db.close();}
  };
  return store;
}
