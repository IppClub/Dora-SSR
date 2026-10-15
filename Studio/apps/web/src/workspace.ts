import { PROTOCOL_VERSION, validateSnapshot, validateProjectArchive, type ProjectArchive, type ProjectFile, type ProjectSnapshot } from '@dora-studio/contracts';
import { createVisionBudget } from '@dora-studio/agent-contracts/vision-budget';
const visionBudget=createVisionBudget({TABLE_STEP:'',DB:{query(){throw new Error('Use the persisted Studio reservation ledger');}}});
export interface CaptureCompletion {taskId:number;operationId:string;success:boolean;interrupted:boolean;message?:string;files:string[]}
interface VisionReservations {projectId:string;taskId:number;operations:{id:string;frames:number;binding?:string;result? : Omit<CaptureCompletion,'taskId'|'operationId'> & {revision:number}}[]}

export class WorkspaceError extends Error {
  constructor(readonly code: 'conflict' | 'invalid' | 'quota' | 'unavailable' | 'blocked' | 'closed' | 'corrupt', message: string, options?: ErrorOptions) {
    super(message, options); this.name = 'WorkspaceError';
  }
}

function storageError(error: unknown): WorkspaceError {
  if (error instanceof WorkspaceError) return error;
  const quota = error instanceof DOMException && error.name === 'QuotaExceededError';
  return new WorkspaceError(quota ? 'quota' : 'unavailable', quota ? 'Not enough browser storage' : 'Browser storage operation failed', { cause: error });
}

type StoredFile = Extract<ProjectFile, { kind: 'text' }> | { path: string; kind: 'binary'; hash: string };
interface StoredProject {
  projectId: string; name: string; revision: number; entry: string;
  createdAt: number; updatedAt: number; files: StoredFile[]; creation?:CreationIntent; iterations?:AgentIteration[];
}
interface Asset { hash: string; bytes: Uint8Array; references: number }
export interface LocalProject {
  name: string; createdAt: number; updatedAt: number; snapshot: ProjectSnapshot; creation?:CreationIntent; iterations?:AgentIteration[];
}
export interface CreationIntent {accountId:string;prompt:string;createdAt:number;grantId?:string;requestId?:string;dispatchState?:'attempted'|'confirmed';taskId?:number;writebackState?:'attempted'|'confirmed';writebackRevision?:number}
export interface AgentIteration {prompt:string;createdAt:number;grantId:string;requestId:string;dispatchState?:'attempted'|'confirmed';taskId?:number;writebackState?:'attempted'|'confirmed';writebackRevision?:number}
export type ProjectSummary = Omit<StoredProject, 'files'|'creation'|'iterations'>;
export interface LocalArchive {name:string;createdAt:number;archive:ProjectArchive}
export interface CloudSyncRecord {accountId:string;projectId:string;cloudRevision:number;syncedLocalRevision?:number;pending?:{requestId:string;snapshot:ProjectSnapshot;name:string};rejected?:{requestId:string;snapshot:ProjectSnapshot;name:string;baseRevision:number}}

const request = <T>(r: IDBRequest<T>) => new Promise<T>((resolve, reject) => {
  r.onsuccess = () => resolve(r.result); r.onerror = () => reject(r.error);
});
const hashes = (project: StoredProject | undefined) => new Set(project?.files.flatMap(f => f.kind === 'binary' ? [f.hash] : []) ?? []);
const validCreation=(value:CreationIntent)=>typeof value?.accountId==='string'&&value.accountId.trim().length>0&&value.accountId.length<=256&&!/[\x00-\x1f\x7f]/.test(value.accountId)
  &&typeof value.prompt==='string'&&value.prompt.trim().length>0&&value.prompt.length<=5000&&!/[\uD800-\uDFFF]/u.test(value.prompt)&&!/[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]/.test(value.prompt)
  &&Number.isSafeInteger(value.createdAt)&&value.createdAt>0
  &&(value.grantId===undefined&&value.requestId===undefined&&value.dispatchState===undefined&&value.taskId===undefined&&value.writebackState===undefined&&value.writebackRevision===undefined
    ||typeof value.grantId==='string'&&/^[A-Za-z0-9_-]{1,128}$/.test(value.grantId)&&typeof value.requestId==='string'&&/^[0-9a-f-]{36}$/i.test(value.requestId)
      &&(value.dispatchState===undefined||value.dispatchState==='attempted'||value.dispatchState==='confirmed')
      &&(value.dispatchState==='confirmed'?typeof value.taskId==='number'&&Number.isSafeInteger(value.taskId)&&value.taskId>0:value.taskId===undefined)
      &&(value.writebackState===undefined&&value.writebackRevision===undefined||value.dispatchState==='confirmed'&&['attempted','confirmed'].includes(value.writebackState??'')
        &&(value.writebackState==='confirmed'?Number.isSafeInteger(value.writebackRevision)&&typeof value.writebackRevision==='number'&&value.writebackRevision>=0:value.writebackRevision===undefined)));
const validIteration=(value:AgentIteration)=>typeof value?.prompt==='string'&&value.prompt.trim().length>0&&value.prompt.length<=5000&&!/[\uD800-\uDFFF]/u.test(value.prompt)&&!/[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]/.test(value.prompt)
  &&Number.isSafeInteger(value.createdAt)&&value.createdAt>0&&typeof value.grantId==='string'&&/^[A-Za-z0-9_-]{1,128}$/.test(value.grantId)
  &&typeof value.requestId==='string'&&/^[0-9a-f-]{36}$/i.test(value.requestId)
  &&(value.dispatchState===undefined||value.dispatchState==='attempted'||value.dispatchState==='confirmed')
  &&(value.dispatchState==='confirmed'?typeof value.taskId==='number'&&Number.isSafeInteger(value.taskId)&&value.taskId>0:value.taskId===undefined)
  &&(value.writebackState===undefined&&value.writebackRevision===undefined||value.dispatchState==='confirmed'&&['attempted','confirmed'].includes(value.writebackState??'')
    &&(value.writebackState==='confirmed'?Number.isSafeInteger(value.writebackRevision)&&typeof value.writebackRevision==='number'&&value.writebackRevision>=0:value.writebackRevision===undefined));
const validIterations=(value:AgentIteration[]|undefined)=>value===undefined||Array.isArray(value)&&value.every(validIteration)
  &&new Set(value.map(item=>item.requestId)).size===value.length;

async function hashBytes(bytes: Uint8Array): Promise<string> {
  const digest = await crypto.subtle.digest('SHA-256', new Uint8Array(bytes));
  return [...new Uint8Array(digest)].map(b => b.toString(16).padStart(2, '0')).join('');
}

/** Authoring storage only. Engine FS receives a copy, never the authoritative draft. */
export class LocalWorkspace {
  private closed = false;
  private constructor(private readonly db: IDBDatabase) {
    db.onversionchange = () => this.close();
    db.onclose = () => { this.closed = true; };
  }

  static open(name = 'dora-studio-projects'): Promise<LocalWorkspace> {
    return new Promise((resolve, reject) => {
      let failed = false;
      try {
        const opening = indexedDB.open(name, 5);
        opening.onupgradeneeded = () => {
          if (!opening.result.objectStoreNames.contains('projects')) opening.result.createObjectStore('projects', { keyPath: 'projectId' });
          if (!opening.result.objectStoreNames.contains('assets')) opening.result.createObjectStore('assets', { keyPath: 'hash' });
          if (!opening.result.objectStoreNames.contains('retired')) opening.result.createObjectStore('retired', { keyPath: 'projectId' });
          if (!opening.result.objectStoreNames.contains('checkpoints')) opening.result.createObjectStore('checkpoints', { keyPath: ['snapshot.projectId', 'snapshot.revision'] });
          if (!opening.result.objectStoreNames.contains('visionReservations')) opening.result.createObjectStore('visionReservations', {keyPath:['projectId','taskId']});
          if (!opening.result.objectStoreNames.contains('archives')) opening.result.createObjectStore('archives', {keyPath:'archive.projectId'});
          if (!opening.result.objectStoreNames.contains('cloudSync')) opening.result.createObjectStore('cloudSync', {keyPath:['accountId','projectId']});
        };
        opening.onblocked = () => { failed = true; reject(new WorkspaceError('blocked', 'Close other Studio tabs to open this workspace')); };
        opening.onerror = () => { failed = true; reject(storageError(opening.error)); };
        opening.onsuccess = () => {
          if (failed) opening.result.close(); else resolve(new LocalWorkspace(opening.result));
        };
      } catch (error) { reject(storageError(error)); }
    });
  }

  close(): void { this.closed = true; this.db.close(); }

  async cloudSync(accountId:string,projectId:string):Promise<CloudSyncRecord|undefined>{
    return this.transaction('readonly',tx=>request(tx.objectStore('cloudSync').get([accountId,projectId])));
  }

  async bindCloudBaseline(accountId:string,projectId:string,cloudRevision:number):Promise<CloudSyncRecord>{
    if(!accountId.trim()||!projectId||!Number.isSafeInteger(cloudRevision)||cloudRevision<1)throw new WorkspaceError('invalid','Invalid cloud baseline');
    return this.transaction('readwrite',async tx=>{
      const sync=tx.objectStore('cloudSync'),current:CloudSyncRecord|undefined=await request(sync.get([accountId,projectId]));
      if(current)return current;
      if(!await request(tx.objectStore('projects').get(projectId)))throw new WorkspaceError('conflict','Local project is missing');
      const next:CloudSyncRecord={accountId,projectId,cloudRevision};await request(sync.add(next));return next;
    });
  }

  async acceptCloudBaseline(accountId:string,projectId:string,cloudRevision:number):Promise<CloudSyncRecord>{
    if(!accountId.trim()||!projectId||!Number.isSafeInteger(cloudRevision)||cloudRevision<1)throw new WorkspaceError('invalid','Invalid cloud baseline');
    return this.transaction('readwrite',async tx=>{
      const sync=tx.objectStore('cloudSync'),current:CloudSyncRecord|undefined=await request(sync.get([accountId,projectId]));
      if(current?.pending)throw new WorkspaceError('conflict','Cloud upload is still pending');
      if(current&&current.cloudRevision>cloudRevision)throw new WorkspaceError('conflict','Cloud baseline moved backwards');
      // Acknowledging a newer remote baseline invalidates the previous upload
      // receipt. Keeping local content must therefore trigger a fresh upload.
      const next:CloudSyncRecord={accountId,projectId,cloudRevision};
      await request(sync.put(next));return next;
    });
  }

  async prepareCloudUpload(accountId:string,snapshot:ProjectSnapshot,requestId:string,name:string):Promise<CloudSyncRecord>{
    if(!accountId.trim()||accountId.length>256||!requestId.trim()||requestId.length>256||validateSnapshot(snapshot).length
      ||typeof name!=='string'||!name.trim()||name.length>200||/[\u0000-\u001f\u007f]/.test(name)||/[\ud800-\udfff]/u.test(name))throw new WorkspaceError('invalid','Invalid cloud upload');
    // Capture before the first await; caller edits must not change a pending request.
    const fixed=structuredClone(snapshot);
    return this.transaction('readwrite',async tx=>{
      const store=tx.objectStore('cloudSync');
      const current=await request<CloudSyncRecord|undefined>(store.get([accountId,fixed.projectId]));
      if(current?.pending)throw new WorkspaceError('conflict','Resolve the pending cloud upload first');
      const next:CloudSyncRecord={accountId,projectId:fixed.projectId,cloudRevision:current?.cloudRevision??0,...(current?.syncedLocalRevision===undefined?{}:{syncedLocalRevision:current.syncedLocalRevision}),...(current?.rejected?{rejected:current.rejected}:{}),pending:{requestId,snapshot:fixed,name:name.trim()}};
      await request(store.put(next));return next;
    });
  }

  async confirmCloudUpload(accountId:string,projectId:string,requestId:string,cloudRevision:number):Promise<void>{
    await this.transaction('readwrite',async tx=>{
      const store=tx.objectStore('cloudSync');
      const current=await request<CloudSyncRecord|undefined>(store.get([accountId,projectId]));
      if(!current?.pending||current.pending.requestId!==requestId||cloudRevision!==current.cloudRevision+1)throw new WorkspaceError('conflict','Cloud receipt does not match pending upload');
      await request(store.put({accountId,projectId,cloudRevision,syncedLocalRevision:current.pending.snapshot.revision,...(current.rejected?{rejected:current.rejected}:{})} satisfies CloudSyncRecord));
    });
  }

  async rejectCloudUpload(accountId:string,projectId:string,requestId:string):Promise<void>{
    await this.transaction('readwrite',async tx=>{
      const store=tx.objectStore('cloudSync');const current=await request<CloudSyncRecord|undefined>(store.get([accountId,projectId]));
      if(!current?.pending||current.pending.requestId!==requestId)throw new WorkspaceError('conflict','Rejected upload no longer matches');
      await request(store.put({accountId,projectId,cloudRevision:current.cloudRevision,...(current.syncedLocalRevision===undefined?{}:{syncedLocalRevision:current.syncedLocalRevision}),rejected:{...current.pending,baseRevision:current.cloudRevision}} satisfies CloudSyncRecord));
    });
  }

  private async transaction<T>(mode: IDBTransactionMode, action: (tx: IDBTransaction) => Promise<T>): Promise<T> {
    if (this.closed) throw new WorkspaceError('closed', 'Workspace connection is closed');
    let tx: IDBTransaction;
    try { tx = this.db.transaction(['projects', 'assets', 'retired', 'checkpoints', 'visionReservations', 'archives', 'cloudSync'], mode); }
    catch (error) { throw storageError(error); }
    // Register before issuing requests. Success means committed, not merely put() success.
    const completed = new Promise<void>((resolve, reject) => {
      tx.oncomplete = () => resolve();
      tx.onabort = () => reject(tx.error ?? new DOMException('Transaction aborted', 'AbortError'));
    });
    void completed.catch(() => {});
    try {
      const value = await action(tx);
      await completed;
      return value;
    } catch (error) {
      try { tx.abort(); } catch { /* Transaction already ended. */ }
      await completed.catch(() => {});
      throw storageError(error);
    }
  }

  async list(): Promise<ProjectSummary[]> {
    return this.transaction('readonly', async tx => {
      const projects: StoredProject[] = await request(tx.objectStore('projects').getAll());
      return projects.map(({ files: _files, creation: _creation, iterations: _iterations, ...summary }) => summary)
        .sort((a, b) => b.updatedAt - a.updatedAt || a.projectId.localeCompare(b.projectId));
    });
  }

  /** Immutable original archive. Promotion must create a distinct author project. */
  async preserveArchive(name:string,input:ProjectArchive):Promise<LocalArchive> {
    const errors=validateProjectArchive(input);
    if(errors.length||input.revision!==0||typeof name!=='string'||!name.trim()||name.length>200)throw new WorkspaceError('invalid','Invalid source archive');
    const record:LocalArchive={name:name.trim(),createdAt:Date.now(),archive:structuredClone(input)};
    return this.transaction('readwrite',async tx=>{
      const id=record.archive.projectId;
      for(const store of ['projects','archives','retired'])if(await request(tx.objectStore(store).get(id)))throw new WorkspaceError('conflict','Archive identity already exists');
      await request(tx.objectStore('archives').add(record));return record;
    });
  }

  async loadArchive(projectId:string):Promise<LocalArchive|undefined> {
    return this.transaction('readonly',async tx=>{
      const record:LocalArchive|undefined=await request(tx.objectStore('archives').get(projectId));
      if(record&&(validateProjectArchive(record.archive).length||record.archive.revision!==0||record.archive.projectId!==projectId||typeof record.name!=='string'||!record.name.trim()||record.name.length>200||!Number.isSafeInteger(record.createdAt)))throw new WorkspaceError('corrupt','Stored archive is invalid');
      return record;
    });
  }

  async listArchives():Promise<{projectId:string;name:string;createdAt:number;fileCount:number}[]> {
    return this.transaction('readonly',tx=>new Promise((resolve,reject)=>{
      const rows:{projectId:string;name:string;createdAt:number;fileCount:number}[]=[];
      const cursor=tx.objectStore('archives').openCursor();
      cursor.onerror=()=>reject(cursor.error);
      cursor.onsuccess=()=>{
        const item=cursor.result;if(!item){resolve(rows.sort((a,b)=>b.createdAt-a.createdAt));return;}
        const value=item.value as LocalArchive;
        if(!value?.archive||validateProjectArchive(value.archive).length){reject(new WorkspaceError('corrupt','Stored archive is invalid'));return;}
        rows.push({projectId:value.archive.projectId,name:value.name,createdAt:value.createdAt,fileCount:value.archive.files.length});item.continue();
      };
    }));
  }

  async load(projectId: string): Promise<LocalProject | undefined> {
    return this.transaction('readonly', async tx => {
      const project: StoredProject | undefined = await request(tx.objectStore('projects').get(projectId));
      if (!project) return undefined;
      const assets = tx.objectStore('assets');
      const files: ProjectFile[] = await Promise.all(project.files.map(async file => {
        if (file.kind === 'text') return file;
        const asset: Asset | undefined = await request(assets.get(file.hash));
        if (!asset || !(asset.bytes instanceof Uint8Array) || asset.references < 1) throw new WorkspaceError('corrupt', `Missing project asset: ${file.path}`);
        return { path: file.path, kind: 'binary', bytes: asset.bytes };
      }));
      const snapshot: ProjectSnapshot = { version: PROTOCOL_VERSION, projectId, revision: project.revision, entry: project.entry, files };
      if (validateSnapshot(snapshot).length) throw new WorkspaceError('corrupt', 'Stored project is invalid');
      if(project.creation && !validCreation(project.creation))throw new WorkspaceError('corrupt','Stored creation intent is invalid');
      if(!validIterations(project.iterations))throw new WorkspaceError('corrupt','Stored Agent iteration history is invalid');
      return { name: project.name, createdAt: project.createdAt, updatedAt: project.updatedAt, snapshot,
        ...(project.creation?{creation:structuredClone(project.creation)}:{}),...(project.iterations?{iterations:structuredClone(project.iterations)}:{}) };
    });
  }

  /** Project and its first description commit together; network work starts later. */
  createFromPrompt(name:string,input:ProjectSnapshot,accountId:string,prompt:string,grantId?:string):Promise<LocalProject>{
    const creation:CreationIntent={accountId,prompt:prompt.trim(),createdAt:Date.now(),...(grantId?{grantId,requestId:crypto.randomUUID()}:{})};
    if(!validCreation(creation)||input.revision!==0)throw new WorkspaceError('invalid','Invalid first game description');
    return this.save(name,input,null,false,undefined,undefined,undefined,creation);
  }

  /** Bind an existing saved project to its first Agent task without changing
   * the author revision. This is used by blank/imported projects when their
   * owner starts Agent creation for the first time. */
  async beginProjectAgent(projectId:string,expectedRevision:number,accountId:string,prompt:string,grantId:string):Promise<CreationIntent>{
    const creation:CreationIntent={accountId,prompt:prompt.trim(),createdAt:Date.now(),grantId,requestId:crypto.randomUUID()};
    if(!projectId||!Number.isSafeInteger(expectedRevision)||expectedRevision<0||!validCreation(creation))throw new WorkspaceError('invalid','Invalid initial Agent task');
    return this.transaction('readwrite',async tx=>{
      const projects=tx.objectStore('projects'),record:StoredProject|undefined=await request(projects.get(projectId));
      if(!record||record.revision!==expectedRevision)throw new WorkspaceError('conflict','Project changed before Agent setup');
      if(record.creation||record.iterations?.length)throw new WorkspaceError('conflict','Project already has an Agent task history');
      await request(projects.put({...record,creation}));
      return structuredClone(creation);
    });
  }

  /** A durable, one-way prompt dispatch marker. An uncertain acknowledgement
   * must be inspected in the original Agent session, never auto-resubmitted. */
  async markPromptDispatch(projectId:string,requestId:string,state:'attempted'|'confirmed',taskId?:number):Promise<CreationIntent>{
    if(!projectId||!/^[0-9a-f-]{36}$/i.test(requestId)||!['attempted','confirmed'].includes(state)||state==='confirmed'&&(typeof taskId!=='number'||!Number.isSafeInteger(taskId)||taskId<=0))throw new WorkspaceError('invalid','Invalid Agent prompt dispatch marker');
    return this.transaction('readwrite',async tx=>{
      const projects=tx.objectStore('projects'),record:StoredProject|undefined=await request(projects.get(projectId));
      if(!record?.creation||!validCreation(record.creation)||record.creation.requestId!==requestId)throw new WorkspaceError('conflict','Prompt binding changed');
      if(state==='attempted'&&record.creation.dispatchState||state==='confirmed'&&record.creation.dispatchState!=='attempted')throw new WorkspaceError('conflict','Prompt dispatch has already advanced');
      const creation:CreationIntent={...record.creation,dispatchState:state,...(state==='confirmed'?{taskId:taskId as number}:{})};
      await request(projects.put({...record,creation}));return structuredClone(creation);
    });
  }

  /** One-shot automatic writeback receipt for the initial prompt task. A
   * crash after attempt stays inspectable instead of silently recapturing a
   * different Agent/author state on reload. */
  async markAgentWriteback(projectId:string,requestId:string,taskId:number,state:'attempted'|'confirmed',revision?:number):Promise<CreationIntent>{
    if(!projectId||!/^[0-9a-f-]{36}$/i.test(requestId)||!Number.isSafeInteger(taskId)||taskId<1||!['attempted','confirmed'].includes(state)
      ||state==='confirmed'&&(!Number.isSafeInteger(revision)||typeof revision!=='number'||revision<0))throw new WorkspaceError('invalid','Invalid Agent writeback receipt');
    return this.transaction('readwrite',async tx=>{
      const projects=tx.objectStore('projects'),record:StoredProject|undefined=await request(projects.get(projectId));
      const prior=record?.creation;
      if(!prior||!validCreation(prior)||prior.requestId!==requestId||prior.dispatchState!=='confirmed'||prior.taskId!==taskId)throw new WorkspaceError('conflict','Agent task binding changed');
      if(state==='attempted'&&prior.writebackState||state==='confirmed'&&prior.writebackState!=='attempted')throw new WorkspaceError('conflict','Agent writeback receipt already advanced');
      if(state==='confirmed'&&revision!==record.revision)throw new WorkspaceError('conflict','Author revision changed before Agent writeback receipt');
      const creation:CreationIntent={...prior,writebackState:state,...(state==='confirmed'?{writebackRevision:revision as number}:{})};
      await request(projects.put({...record,creation}));return structuredClone(creation);
    });
  }

  /** Persist each follow-up before sending it. Earlier tasks and writeback may
   * still be active; a new user instruction is a distinct idempotent request. */
  async beginAgentIteration(projectId:string,accountId:string,prompt:string,grantId:string):Promise<AgentIteration>{
    const next:AgentIteration={prompt:prompt.trim(),createdAt:Date.now(),grantId,requestId:crypto.randomUUID()};
    if(!projectId||!accountId||!validIteration(next))throw new WorkspaceError('invalid','Invalid Agent iteration');
    return this.transaction('readwrite',async tx=>{
      const projects=tx.objectStore('projects'),record:StoredProject|undefined=await request(projects.get(projectId));
      if(!record?.creation||!validCreation(record.creation)||record.creation.accountId!==accountId)throw new WorkspaceError('conflict','Agent project is not available for this account');
      if(!validIterations(record.iterations))throw new WorkspaceError('corrupt','Stored Agent iteration history is invalid');
      const iterations=record.iterations??[];
      const updated=[...iterations,next];await request(projects.put({...record,iterations:updated}));return structuredClone(next);
    });
  }

  async markAgentIterationDispatch(projectId:string,requestId:string,state:'attempted'|'confirmed',taskId?:number):Promise<AgentIteration>{
    if(!projectId||!/^[0-9a-f-]{36}$/i.test(requestId)||!['attempted','confirmed'].includes(state)||state==='confirmed'&&(typeof taskId!=='number'||!Number.isSafeInteger(taskId)||taskId<=0))throw new WorkspaceError('invalid','Invalid Agent iteration dispatch marker');
    return this.transaction('readwrite',async tx=>{
      const projects=tx.objectStore('projects'),record:StoredProject|undefined=await request(projects.get(projectId));
      if(!record||!validIterations(record.iterations))throw new WorkspaceError('conflict','Agent iteration history changed');
      const iterations=record.iterations;
      if(!iterations)throw new WorkspaceError('conflict','Agent iteration binding changed');
      const index=iterations.findIndex(item=>item.requestId===requestId);
      if(index<0||index!==iterations.length-1)throw new WorkspaceError('conflict','Agent iteration binding changed');
      const prior=iterations[index]!;
      if(state==='attempted'&&prior.dispatchState||state==='confirmed'&&prior.dispatchState!=='attempted')throw new WorkspaceError('conflict','Agent iteration dispatch has already advanced');
      const next:AgentIteration={...prior,dispatchState:state,...(state==='confirmed'?{taskId:taskId as number}:{})};
      const updated=iterations.map((item,position)=>position===index?next:item);await request(projects.put({...record,iterations:updated}));return structuredClone(next);
    });
  }

  async markAgentIterationWriteback(projectId:string,requestId:string,taskId:number,state:'attempted'|'confirmed',revision?:number):Promise<AgentIteration>{
    if(!projectId||!/^[0-9a-f-]{36}$/i.test(requestId)||!Number.isSafeInteger(taskId)||taskId<1||!['attempted','confirmed'].includes(state)
      ||state==='confirmed'&&(!Number.isSafeInteger(revision)||typeof revision!=='number'||revision<0))throw new WorkspaceError('invalid','Invalid Agent iteration writeback receipt');
    return this.transaction('readwrite',async tx=>{
      const projects=tx.objectStore('projects'),record:StoredProject|undefined=await request(projects.get(projectId));
      if(!record||!validIterations(record.iterations))throw new WorkspaceError('conflict','Agent iteration history changed');
      const iterations=record.iterations;
      if(!iterations)throw new WorkspaceError('conflict','Agent iteration task binding changed');
      const index=iterations.findIndex(item=>item.requestId===requestId),prior=index<0?undefined:iterations[index];
      if(!prior||prior.dispatchState!=='confirmed'||prior.taskId!==taskId)throw new WorkspaceError('conflict','Agent iteration task binding changed');
      if(state==='attempted'&&prior.writebackState||state==='confirmed'&&prior.writebackState!=='attempted')throw new WorkspaceError('conflict','Agent iteration writeback has already advanced');
      if(state==='confirmed'&&revision!==record.revision)throw new WorkspaceError('conflict','Author revision changed before Agent iteration receipt');
      const next:AgentIteration={...prior,writebackState:state,...(state==='confirmed'?{writebackRevision:revision as number}:{})};
      const updated=iterations.map((item,position)=>position===index?next:item);await request(projects.put({...record,iterations:updated}));return structuredClone(next);
    });
  }

  /** null creates revision 0; existing drafts must advance exactly one local revision. */
  async save(name: string, input: ProjectSnapshot, baseRevision: number | null, checkpoint = false, captureCompletion?:CaptureCompletion, cloudImport?:{accountId:string;cloudRevision:number}, cloudMerge?:{accountId:string;expectedCloudRevision:number;cloudRevision:number;synced?:boolean}, creationIntent?:CreationIntent): Promise<LocalProject> {
    const merge=cloudMerge?{...cloudMerge}:undefined;
    if(merge&&(cloudImport||captureCompletion||baseRevision===null||!checkpoint||!merge.accountId.trim()||merge.accountId.length>256||!Number.isSafeInteger(merge.expectedCloudRevision)||merge.expectedCloudRevision<1||!Number.isSafeInteger(merge.cloudRevision)||merge.cloudRevision<merge.expectedCloudRevision))throw new WorkspaceError('invalid','Invalid cloud merge binding');
    const binding=cloudImport?{...cloudImport}:undefined;
    if(binding&&(baseRevision!==null||captureCompletion||!binding.accountId.trim()||binding.accountId.length>256||!Number.isSafeInteger(binding.cloudRevision)||binding.cloudRevision<1))throw new WorkspaceError('invalid','Invalid cloud import binding');
    const errors = validateSnapshot(input);
    if (errors.length) throw new WorkspaceError('invalid', errors.join('; '));
    if (typeof name !== 'string' || !name.trim() || name.length > 200) throw new WorkspaceError('invalid', 'Project name must contain 1–200 characters');
    if (baseRevision !== null && (!Number.isSafeInteger(baseRevision) || baseRevision < 0)) throw new WorkspaceError('invalid', 'Invalid base revision');
    if(creationIntent&&(baseRevision!==null||cloudImport||cloudMerge||captureCompletion||!validCreation(creationIntent)))throw new WorkspaceError('invalid','Invalid creation intent binding');
    if (input.revision !== (baseRevision === null ? 0 : baseRevision + 1)) throw new WorkspaceError('invalid', 'Revision must advance exactly once');
    const snapshot = structuredClone(input);
    const completion=captureCompletion ? structuredClone(captureCompletion) : undefined;
    if(completion && (!Number.isSafeInteger(completion.taskId) || completion.taskId<=0 || !/^[a-zA-Z0-9_-]{1,128}$/.test(completion.operationId) ||
      typeof completion.success!=='boolean' || typeof completion.interrupted!=='boolean' ||
      (completion.message!==undefined && (typeof completion.message!=='string' || completion.message.length>8192)) ||
      !Array.isArray(completion.files) || completion.files.length<1 || completion.files.length>3 || new Set(completion.files).size!==completion.files.length ||
      completion.files.some(path=>!/^\.agent\/vision\/\d+-\d+\.png$/.test(path) || !snapshot.files.some(file=>file.path===path && file.kind==='binary'))))
      throw new WorkspaceError('invalid','Invalid capture completion');
    const assetData = new Map<string, Uint8Array>();
    // Hash before opening a transaction: non-IDB awaits would allow it to auto-commit.
    const files: StoredFile[] = await Promise.all(snapshot.files.map(async file => {
      if (file.kind === 'text') return file;
      const hash = await hashBytes(file.bytes); assetData.set(hash, file.bytes);
      return { path: file.path, kind: 'binary', hash };
    }));
    return this.transaction('readwrite', async tx => {
      const projects = tx.objectStore('projects');
      const prior: StoredProject | undefined = await request(projects.get(snapshot.projectId));
      const retired = await request(tx.objectStore('retired').get(snapshot.projectId));
      if(await request(tx.objectStore('archives').get(snapshot.projectId)))throw new WorkspaceError('conflict','Archive identity is reserved; create a separate project');
      if (retired) throw new WorkspaceError('conflict', 'Project was deleted; save this draft under a new project ID');
      if (baseRevision === null ? prior !== undefined : prior?.revision !== baseRevision) {
        throw new WorkspaceError('conflict', 'Project changed in another tab; keep this draft and reload before merging');
      }
      if(prior?.creation&&!validCreation(prior.creation))throw new WorkspaceError('corrupt','Stored creation intent is invalid');
      if(!validIterations(prior?.iterations))throw new WorkspaceError('corrupt','Stored Agent iteration history is invalid');
      if(binding){
        const sync=tx.objectStore('cloudSync');
        if(await request(sync.get([binding.accountId,snapshot.projectId])))throw new WorkspaceError('conflict','Cloud binding already exists; reconcile before restoring');
        await request(sync.add({accountId:binding.accountId,projectId:snapshot.projectId,cloudRevision:binding.cloudRevision,syncedLocalRevision:snapshot.revision} satisfies CloudSyncRecord));
      }
      if(merge){
        const sync=tx.objectStore('cloudSync');
        const current=await request<CloudSyncRecord|undefined>(sync.get([merge.accountId,snapshot.projectId]));
        if(!current||current.pending||current.cloudRevision!==merge.expectedCloudRevision)throw new WorkspaceError('conflict','Cloud baseline changed before merge');
        await request(sync.put({accountId:merge.accountId,projectId:snapshot.projectId,cloudRevision:merge.cloudRevision,...(merge.synced?{syncedLocalRevision:snapshot.revision}:{}),...(current.rejected&&!merge.synced?{rejected:current.rejected}:{})} satisfies CloudSyncRecord));
      }
      if(completion) {
        const store=tx.objectStore('visionReservations');
        const ledger:VisionReservations|undefined=await request(store.get([snapshot.projectId,completion.taskId]));
        const operation=ledger?.operations.find(op=>op.id===completion.operationId);
        if(!ledger || !operation || operation.result || completion.files.length>operation.frames)
          throw new WorkspaceError('conflict','Capture reservation is missing or already completed');
        operation.result={success:completion.success,interrupted:completion.interrupted,files:completion.files,revision:snapshot.revision,...(completion.message===undefined?{}:{message:completion.message})};
        await request(store.put(ledger));
      }
      if (checkpoint && prior) {
        const checkpointFiles: ProjectFile[] = await Promise.all(prior.files.map(async file => {
          if (file.kind === 'text') return file;
          const asset: Asset | undefined = await request(tx.objectStore('assets').get(file.hash));
          if (!asset) throw new WorkspaceError('corrupt', 'Checkpoint asset is missing');
          return { path: file.path, kind: 'binary' as const, bytes: new Uint8Array(asset.bytes) };
        }));
        await request(tx.objectStore('checkpoints').add({ name: prior.name, createdAt: prior.createdAt, updatedAt: prior.updatedAt,
          snapshot: { version: PROTOCOL_VERSION, projectId: prior.projectId, revision: prior.revision, entry: prior.entry, files: checkpointFiles } } satisfies LocalProject));
      }
      const now = Date.now();
      const next: StoredProject = { projectId: snapshot.projectId, name: name.trim(), entry: snapshot.entry,
        revision: snapshot.revision, createdAt: prior?.createdAt ?? now, updatedAt: now, files,
        ...(prior?.creation?{creation:prior.creation}:creationIntent?{creation:structuredClone(creationIntent)}:{}),...(prior?.iterations?{iterations:prior.iterations}:{}) };
      await this.updateAssets(tx, hashes(prior), hashes(next), assetData);
      await request(projects.put(next));
      return { name: next.name, createdAt: next.createdAt, updatedAt: next.updatedAt, snapshot,
        ...(next.creation?{creation:structuredClone(next.creation)}:{}),...(next.iterations?{iterations:structuredClone(next.iterations)}:{}) };
    });
  }

  async loadCheckpoint(projectId: string, revision: number): Promise<LocalProject | undefined> {
    if (!Number.isSafeInteger(revision) || revision < 0) throw new WorkspaceError('invalid', 'Invalid checkpoint revision');
    return this.transaction('readonly', async tx => {
      const saved: LocalProject | undefined = await request(tx.objectStore('checkpoints').get([projectId, revision]));
      if (saved && validateSnapshot(saved.snapshot).length) throw new WorkspaceError('corrupt', 'Invalid checkpoint snapshot');
      return saved;
    });
  }

  async listCheckpoints(projectId: string): Promise<number[]> {
    return this.transaction('readonly', async tx => {
      const keys = await request(tx.objectStore('checkpoints').getAllKeys(IDBKeyRange.bound([projectId, 0], [projectId, Number.MAX_SAFE_INTEGER])));
      return keys.map(key => (key as [string, number])[1]).sort((a, b) => b - a);
    });
  }

  async listCheckpointSummaries(projectId:string):Promise<{revision:number;updatedAt:number}[]>{
    return this.transaction('readonly',async tx=>{
      const saved:LocalProject[]=await request(tx.objectStore('checkpoints').getAll(IDBKeyRange.bound([projectId,0],[projectId,Number.MAX_SAFE_INTEGER])));
      return saved.map(item=>({revision:item.snapshot.revision,updatedAt:item.updatedAt})).sort((a,b)=>b.updatedAt-a.updatedAt);
    });
  }

  async restoreCheckpoint(projectId: string, checkpointRevision: number, baseRevision: number): Promise<LocalProject> {
    if (!Number.isSafeInteger(baseRevision) || baseRevision < 0) throw new WorkspaceError('invalid', 'Invalid base revision');
    const checkpoint = await this.loadCheckpoint(projectId, checkpointRevision);
    if (!checkpoint) throw new WorkspaceError('invalid', 'Checkpoint not found');
    const current = await this.load(projectId);
    if (!current || current.snapshot.revision !== baseRevision) throw new WorkspaceError('conflict', 'Project changed before checkpoint restore');
    // save rechecks revision inside the write transaction; intervening writes cannot be overwritten.
    return this.save(current.name, { ...checkpoint.snapshot, projectId, revision: baseRevision + 1 }, baseRevision, true);
  }

  async remove(projectId: string, baseRevision: number): Promise<void> {
    if (!Number.isSafeInteger(baseRevision) || baseRevision < 0) throw new WorkspaceError('invalid', 'Invalid base revision');
    return this.transaction('readwrite', async tx => {
      const projects = tx.objectStore('projects');
      const prior: StoredProject | undefined = await request(projects.get(projectId));
      if (!prior || prior.revision !== baseRevision) throw new WorkspaceError('conflict', 'Project changed or was removed');
      await this.updateAssets(tx, hashes(prior), new Set(), new Map());
      await request(projects.delete(projectId));
      const checkpointKeys = await request(tx.objectStore('checkpoints').getAllKeys(IDBKeyRange.bound([projectId, 0], [projectId, Number.MAX_SAFE_INTEGER])));
      await Promise.all(checkpointKeys.map(key => request(tx.objectStore('checkpoints').delete(key))));
      const reservationStore=tx.objectStore('visionReservations');
      const reservationKeys=await request(reservationStore.getAllKeys(IDBKeyRange.bound([projectId,0],[projectId,Number.MAX_SAFE_INTEGER])));
      await Promise.all(reservationKeys.map(key=>request(reservationStore.delete(key))));
      const cloudSync=tx.objectStore('cloudSync'),cloudKeys=await request(cloudSync.getAllKeys());
      await Promise.all(cloudKeys.filter(key=>Array.isArray(key)&&key[1]===projectId).map(key=>request(cloudSync.delete(key))));
      // Keep only the ID, preventing a stale revision from targeting a recreated project.
      await request(tx.objectStore('retired').put({ projectId }));
    });
  }

  /** Reserve before dispatch; failed/interrupted work does not silently reset its budget. */
  async reserveVisionCapture(projectId:string, taskId:number, operationId:string, frames:number, binding?:string) {
    if (!projectId || !Number.isSafeInteger(taskId) || taskId <= 0 || !/^[a-zA-Z0-9_-]{1,128}$/.test(operationId) ||
      !Number.isSafeInteger(frames) || frames < 1 || frames > 3 || (binding!==undefined && (typeof binding!=='string' || binding.length>1024))) throw new WorkspaceError('invalid','Invalid vision reservation');
    return this.transaction('readwrite',async tx=>{
      if (!await request(tx.objectStore('projects').get(projectId))) throw new WorkspaceError('conflict','Project was removed');
      const store=tx.objectStore('visionReservations');
      const ledger:VisionReservations=await request(store.get([projectId,taskId])) ?? {projectId,taskId,operations:[]};
      if (!Array.isArray(ledger.operations) || ledger.operations.some(op=>!op || typeof op.id!=='string' || !Number.isSafeInteger(op.frames) || op.frames<1 || op.frames>3))
        throw new WorkspaceError('corrupt','Invalid vision reservation history');
      const usage=visionBudget.createEmptyVisionTaskUsage();
      usage.captureBatchCount=ledger.operations.length;usage.captureFrameCount=ledger.operations.reduce((sum,op)=>sum+op.frames,0);
      const prior=ledger.operations.find(op=>op.id===operationId);
      if (prior) {
        if(prior.frames!==frames || (binding!==undefined && prior.binding!==binding)) throw new WorkspaceError('conflict','Vision operation parameters changed');
        return {replayed:true,budget:visionBudget.getVisionBudgetState(usage),result:prior.result};
      }
      const budget=visionBudget.getVisionBudgetState(usage);
      if (budget.remaining.captureBatches<1 || budget.remaining.captureFrames<frames) throw new WorkspaceError('quota','Vision capture budget exhausted');
      ledger.operations.push({id:operationId,frames,...(binding===undefined?{}:{binding})});await request(store.put(ledger));
      usage.captureBatchCount++;usage.captureFrameCount+=frames;
      return {replayed:false,budget:visionBudget.getVisionBudgetState(usage)};
    });
  }

  /** Finish a reserved operation with no image output, without creating a project revision. */
  async completeVisionCaptureFailure(projectId:string,taskId:number,operationId:string,revision:number,message:string,interrupted:boolean) {
    if(!projectId || !Number.isSafeInteger(taskId) || taskId<=0 || !/^[a-zA-Z0-9_-]{1,128}$/.test(operationId) ||
      !Number.isSafeInteger(revision) || revision<0 || typeof message!=='string' || message.length>8192 || typeof interrupted!=='boolean')
      throw new WorkspaceError('invalid','Invalid capture failure');
    return this.transaction('readwrite',async tx=>{
      if(!await request(tx.objectStore('projects').get(projectId))) throw new WorkspaceError('conflict','Project was removed');
      const store=tx.objectStore('visionReservations');
      const ledger:VisionReservations|undefined=await request(store.get([projectId,taskId]));
      const operation=ledger?.operations.find(op=>op.id===operationId);
      if(!ledger || !operation) throw new WorkspaceError('conflict','Capture reservation is missing');
      if(operation.result) throw new WorkspaceError('conflict','Capture operation already completed');
      operation.result={success:false,interrupted,message,files:[],revision};
      await request(store.put(ledger));
    });
  }

  private async updateAssets(tx: IDBTransaction, before: Set<string>, after: Set<string>, data: Map<string, Uint8Array>): Promise<void> {
    const assets = tx.objectStore('assets');
    await Promise.all([...new Set([...before, ...after])].map(async hash => {
      const existing: Asset | undefined = await request(assets.get(hash));
      if (before.has(hash) && (!existing || existing.references < 1)) throw new WorkspaceError('corrupt', 'Asset reference is missing');
      const references = (existing?.references ?? 0) + Number(after.has(hash)) - Number(before.has(hash));
      if (references === 0) { await request(assets.delete(hash)); return; }
      const bytes = existing?.bytes ?? data.get(hash);
      if (!bytes) throw new WorkspaceError('corrupt', 'Asset content is missing');
      await request(assets.put({ hash, bytes, references } satisfies Asset));
    }));
  }
}
