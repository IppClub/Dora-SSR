import {isProjectPath,type ProjectFile,type ProjectSnapshot} from '@dora-studio/contracts';
import {readInstalledAgentFiles,type AgentProjectFS} from './agent-project-install';
import type {AgentToolReply,AgentToolRequest} from './agent-wasm-source';

const root='/user/studio-project';
const decoder=new TextDecoder('utf-8',{fatal:true});
type CompilerResult={success:boolean;code?:string;tic80?:boolean;message?:string;interrupted?:boolean};
export type AgentScriptCompiler=(snapshot:ProjectSnapshot,path:string,signal:AbortSignal)=>Promise<CompilerResult>;

/** Uses Dora's Teal/Lua or Yarn compiler in an isolated Worker, not WebServer route setup. */
export async function compileAgentScriptWorker(snapshot:ProjectSnapshot,path:string,signal:AbortSignal):Promise<CompilerResult>{
  const tealBase=new URL('./teal/',location.href),yarnBase=new URL('./yarn/',location.href);
  const isYarn=path.endsWith('.yarn');
  const api=await import(/* @vite-ignore */ new URL('api.js',tealBase).href) as {
    createTealWorkerBuild:(worker:()=>Worker,declarations:unknown,options:{signal:AbortSignal;timeoutMs:number})=>(request:{snapshot:ProjectSnapshot;path:string;signal:AbortSignal})=>Promise<CompilerResult>;
  };
  let declarations:unknown=[];
  if(!isYarn){
    const response=await fetch(new URL('declarations.json',tealBase),{credentials:'same-origin',cache:'no-store',signal});
    if(!response.ok)throw new Error('Lua/Teal compiler declarations unavailable');
    declarations=await response.json();
  }
  signal.throwIfAborted();
  const worker=api.createTealWorkerBuild(()=>new Worker(new URL('worker.mjs',isYarn?yarnBase:tealBase),{type:'module'}),declarations,{signal,timeoutMs:30000});
  return worker({snapshot,path,signal});
}

/** Only the original Agent `build` tool can call this in the trusted host. */
export async function buildAgentScriptTool(fs:AgentProjectFS,projectId:string,request:AgentToolRequest,signal:AbortSignal,
  compile:AgentScriptCompiler=compileAgentScriptWorker):Promise<AgentToolReply>{
  if(request.operation!=='build-script'||request.projectRoot!==root||!request.file.startsWith(root+'/'))return {success:false,message:'Invalid Agent script build target'};
  const relative=request.file.slice(root.length+1);
  if(!isProjectPath(relative)||!/\.(tl|lua|yarn)$/.test(relative)||relative.endsWith('.d.tl'))return {success:false,message:'Invalid Agent script build target'};
  signal.throwIfAborted();
  const installed=readInstalledAgentFiles(fs);
  const source=installed.find(file=>file.path===relative);
  if(!source)return {success:false,message:'Agent script changed before build'};
  let content:string;
  try{content=decoder.decode(source.bytes);}catch{return {success:false,message:'Agent script is not UTF-8 text'};}
  if(content!==request.content)return {success:false,message:'Agent script changed before build'};
  const files:ProjectFile[]=installed.map(file=>{
    try{return {path:file.path,kind:'text' as const,text:decoder.decode(file.bytes)};}
    catch{return {path:file.path,kind:'binary' as const,bytes:file.bytes};}
  });
  const snapshot:ProjectSnapshot={version:1,projectId,revision:0,entry:relative,files};
  const result=await compile(snapshot,relative,signal);
  signal.throwIfAborted();
  if(result.interrupted)return {success:false,message:'Lua/Teal build canceled'};
  if(!result.success)return {success:false,message:(result.message||'Lua/Teal build failed').slice(0,4096)};
  if(relative.endsWith('.lua')||relative.endsWith('.yarn'))return {success:true,luaCode:''};
  if(typeof result.code!=='string'||!result.code)return {success:false,message:'Teal output missing'};
  if(typeof result.tic80!=='boolean')return {success:false,message:'Teal TIC80 status missing'};
  const header=`-- [tl]: ${relative}`;
  const luaCode=result.tic80
    ?result.code.startsWith('-- tic80\n')?result.code.replace(/^([^\r\n]*\r?\n)/,`$1${header}\n`):`-- tic80\n${header}\n${result.code}`
    :`${header}\n${result.code}`;
  if(new TextEncoder().encode(luaCode).byteLength>1048576)return {success:false,message:'Teal output too large'};
  return {success:true,luaCode};
}
