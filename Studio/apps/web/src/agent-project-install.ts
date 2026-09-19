import {isProjectPath,validateSnapshot,type ProjectSnapshot} from '@dora-studio/contracts';

export interface AgentProjectFS {
  analyzePath(path:string):{exists:boolean};
  lstat(path:string):{mode:number;size:number};
  isDir(mode:number):boolean;
  isFile(mode:number):boolean;
  readdir(path:string):string[];
  readFile(path:string):Uint8Array;
  writeFile(path:string,bytes:Uint8Array):void;
  mkdirTree(path:string):void;
  rename(from:string,to:string):void;
  unlink(path:string):void;
  rmdir(path:string):void;
}
const root='/user/studio-project';

/** Read only under the caller's project quiescence hold. Bytes are current state,
 * not historical checkpoint contents, an author revision, or a persistence receipt.
 * Classification into text/binary belongs to reconciliation with the author manifest.
 */
export function readInstalledAgentFiles(fs:AgentProjectFS):Array<{path:string;bytes:Uint8Array}> {
  const files:Array<{path:string;bytes:Uint8Array}>=[];
  let visited=0,total=0;
  // /user is a trusted loader-owned alias to the leased IDBFS mount. Reject
  // links starting at the project root, not that host-configured mount alias.
  const visit=(path:string,relative:string,depth:number)=>{
    if(++visited>65536 || depth>256)throw new Error('Agent project traversal bounds exceeded');
    const stat=fs.lstat(path);
    if(fs.isDir(stat.mode)){
      const seen=new Set<string>();
      for(const name of fs.readdir(path).sort()){
        if(name==='.'||name==='..'||(!relative&&name==='.agent'))continue;
        const child=relative?relative+'/'+name:name;
        if(seen.has(name)||name.includes('/')||name.includes('\\')||!isProjectPath(child))throw new Error('Invalid Agent project path');
        seen.add(name);visit(path+'/'+name,child,depth+1);
      }
      return;
    }
    if(!relative||!fs.isFile(stat.mode))throw new Error('Agent project links or special files cannot be read');
    if(!Number.isSafeInteger(stat.size)||stat.size<0||stat.size>64*1024*1024||total+stat.size>256*1024*1024||files.length>=4096)
      throw new Error('Agent project file bounds exceeded');
    const bytes=new Uint8Array(fs.readFile(path));
    if(bytes.byteLength!==stat.size)throw new Error('Agent project changed during capture');
    total+=bytes.byteLength;files.push({path:relative,bytes});
  };
  visit(root,'',0);
  return files;
}

/** Byte equality only, not a revision ledger or permission to overwrite changes. */
export function matchesInstalledAgentProject(fs:AgentProjectFS,input:ProjectSnapshot):boolean {
  if(validateSnapshot(input).length || input.files.some(file=>file.path==='.agent'||file.path.startsWith('.agent/')))return false;
  const expected=new Map(input.files.map(file=>[file.path,file]));
  const found=new Set<string>(),encoder=new TextEncoder();let visited=0;
  const visit=(path:string,relative:string,depth:number):boolean=>{
    if(++visited>65536 || depth>256)return false;
    const stat=fs.lstat(path);
    if(fs.isDir(stat.mode))return fs.readdir(path).every(name=>{
      if(name==='.'||name==='..'||(!relative&&name==='.agent'))return true;
      if(name.includes('/')||name.includes('\\'))return false;
      return visit(path+'/'+name,relative?relative+'/'+name:name,depth+1);
    });
    const file=expected.get(relative);
    if(!file || !fs.isFile(stat.mode))return false;
    const bytes=file.kind==='text'?encoder.encode(file.text):file.bytes;
    if(stat.size!==bytes.byteLength)return false;
    const actual=fs.readFile(path);
    if(actual.length!==bytes.length || actual.some((byte,index)=>byte!==bytes[index]))return false;
    found.add(relative);return true;
  };
  try{return visit(root,'',0)&&found.size===expected.size;}catch{return false;}
}

/** Caller must hold Agent quiescence and reconcile prior tool writes first.
 * This changes the runtime copy only, not the authoritative author workspace.
 * Synchronous FS transaction: never yield while the root is being exchanged.
 */
export function installAgentProjectSnapshot(fs:AgentProjectFS,input:ProjectSnapshot) {
  if(validateSnapshot(input).length)throw new Error('Invalid author project');
  const snapshot=structuredClone(input);
  if(snapshot.files.some(file=>file.path==='.agent'||file.path.startsWith('.agent/')))
    throw new Error('Imported .agent data conflicts with the active Agent session; project was not installed');
  const id=crypto.randomUUID(),stage=`/user/.studio-author-stage-${id}`,backup=`/user/.studio-author-backup-${id}`;
  const remove=(path:string)=>{
    if(!fs.analyzePath(path).exists)return;
    if(fs.isDir(fs.lstat(path).mode)){
      for(const name of fs.readdir(path))if(name!=='.'&&name!=='..')remove(path+'/'+name);
      fs.rmdir(path);
    }else fs.unlink(path);
  };
  let count=0,total=0,visited=0;
  const write=(path:string,bytes:Uint8Array)=>{
    if(++count>8192 || bytes.byteLength>64*1024*1024 || (total+=bytes.byteLength)>256*1024*1024)throw new Error('Author installation exceeds storage bounds');
    fs.mkdirTree(path.slice(0,path.lastIndexOf('/')));fs.writeFile(path,bytes);
  };
  const preserve=(source:string,target:string,depth=0)=>{
    if(depth>64 || ++visited>8192)throw new Error('Agent session directory bounds exceeded');
    const {mode,size}=fs.lstat(source);
    if(fs.isDir(mode)){
      fs.mkdirTree(target);
      for(const name of fs.readdir(source))if(name!=='.'&&name!=='..'){
        if(name.includes('/')||name.includes('\\'))throw new Error('Invalid Agent session path');
        preserve(source+'/'+name,target+'/'+name,depth+1);
      }
    }else if(fs.isFile(mode)){
      if(size>64*1024*1024 || total+size>256*1024*1024)throw new Error('Agent session data exceeds storage bounds');
      write(target,new Uint8Array(fs.readFile(source)));
    }
    else throw new Error('Agent session links or special files cannot be copied');
  };
  const hadRoot=fs.analyzePath(root).exists;
  if(hadRoot && !fs.isDir(fs.lstat(root).mode))throw new Error('Author project root is not a directory');
  let moved=false;
  try{
    fs.mkdirTree(stage);
    if(fs.analyzePath(root+'/.agent').exists)preserve(root+'/.agent',stage+'/.agent');
    const encoder=new TextEncoder();
    for(const file of snapshot.files)write(stage+'/'+file.path,file.kind==='text'?encoder.encode(file.text):file.bytes);
    if(hadRoot){fs.rename(root,backup);moved=true;}
    try{fs.rename(stage,root);}catch(error){
      if(moved){fs.rename(backup,root);moved=false;}
      throw error;
    }
  }catch(error){
    try{remove(stage);}catch{/* Preserve original failure; staging may need recovery cleanup. */}
    throw error;
  }
  // Once exchanged, a cleanup failure must not be misreported as an uncommitted write.
  let cleanupPending=false;
  if(moved)try{remove(backup);}catch{cleanupPending=true;}
  return {projectId:snapshot.projectId,revision:snapshot.revision,cleanupPending};
}
