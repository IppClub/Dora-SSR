import {isProjectPath,serializeArtifactContent,type BuildArtifact,type ProjectFile} from '@dora-studio/contracts';
import {readInstalledAgentFiles,type AgentProjectFS} from './agent-project-install';
import type {AgentToolReply,AgentToolRequest} from './agent-wasm-source';

export interface AgentPreviewCapture {png:Uint8Array;width:number;height:number;elapsedSeconds:number}
export type AgentPreviewBroker=(artifact:BuildArtifact,captureAtSeconds:readonly number[],signal:AbortSignal)=>Promise<readonly AgentPreviewCapture[]>;

const decoder=new TextDecoder('utf-8',{fatal:true});
const encoder=new TextEncoder();
const pngSignature=[137,80,78,71,13,10,26,10];
const root='/user/studio-project';

async function sha256(value:string):Promise<string>{
  const digest=await crypto.subtle.digest('SHA-256',encoder.encode(value));
  return [...new Uint8Array(digest)].map(byte=>byte.toString(16).padStart(2,'0')).join('');
}

/** Original Agent `previewGame` only: package already-built Lua for the
 * isolated browser Player. No Studio task-end compiler or game runner.
 */
export async function previewAgentGameTool(fs:AgentProjectFS,projectId:string,revision:number,request:AgentToolRequest,
  broker:AgentPreviewBroker,signal:AbortSignal):Promise<AgentToolReply>{
  if(request.operation!=='preview-game'||request.projectRoot!==root||!request.file.startsWith(root+'/'))return {success:false,message:'Invalid Agent preview target'};
  const entry=request.file.slice(root.length+1);
  if(!isProjectPath(entry)||!entry.endsWith('.lua'))return {success:false,message:'Invalid Agent preview entry'};
  let options:{entry?:unknown;captureAtSeconds?:unknown};
  try{options=JSON.parse(request.content);}catch{return {success:false,message:'Invalid Agent preview options'};}
  const source=options.entry;
  const times=options.captureAtSeconds;
  if(typeof source!=='string'||!isProjectPath(source)||source.replace(/\.[^/.]+$/,'')+'.lua'!==entry
    ||!Array.isArray(times)||times.length<1||times.length>3
    ||times.some((time,index)=>typeof time!=='number'||!Number.isFinite(time)||time<0||time>10||(index>0&&time<=times[index-1])))return {success:false,message:'Invalid Agent preview options'};
  signal.throwIfAborted();
  const installed=readInstalledAgentFiles(fs);
  if(!installed.some(file=>file.path===entry))return {success:false,message:'Build the entry before previewGame'};
  const files:ProjectFile[]=installed.map(file=>{
    try{return {path:file.path,kind:'text',text:decoder.decode(file.bytes)};}
    catch{return {path:file.path,kind:'binary',bytes:file.bytes};}
  });
  const content={compilerVersion:'dora-agent-tool-preview-1',entry,files,sourceMaps:{}};
  const artifact:BuildArtifact={...content,buildId:crypto.randomUUID(),projectId,revision,sha256:await sha256(serializeArtifactContent(content))};
  signal.throwIfAborted();
  const captures=await broker(artifact,times,signal);
  signal.throwIfAborted();
  if(captures.length!==times.length||captures.some(frame=>!(frame.png instanceof Uint8Array)||frame.png.byteLength<8
    ||frame.png.byteLength>12*1024*1024||pngSignature.some((byte,index)=>frame.png[index]!==byte)
    ||!Number.isSafeInteger(frame.width)||frame.width<1||frame.width>8192||!Number.isSafeInteger(frame.height)||frame.height<1||frame.height>8192
    ||!Number.isFinite(frame.elapsedSeconds)||frame.elapsedSeconds<0||frame.elapsedSeconds>30))return {success:false,message:'Invalid Agent Player capture'};
  const dir=root+'/.agent/vision';
  const saved:string[]=[];
  try{
    fs.mkdirTree(dir);
    const frames=captures.map(frame=>{
      signal.throwIfAborted();
      const name=`${Math.floor(Date.now()/1000)}-${crypto.getRandomValues(new Uint32Array(1))[0]}.png`;
      const path=`.agent/vision/${name}`;
      fs.writeFile(root+'/'+path,new Uint8Array(frame.png));saved.push(root+'/'+path);
      return {path,width:frame.width,height:frame.height,elapsedSeconds:frame.elapsedSeconds};
    });
    signal.throwIfAborted();
    return {success:true,resultJSON:JSON.stringify({success:true,files:frames.map(frame=>frame.path),frames})};
  }catch(error){for(const path of saved)try{fs.unlink(path);}catch{/* Keep first failure. */}throw error;}
}
