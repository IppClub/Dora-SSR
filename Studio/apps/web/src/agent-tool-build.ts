import {createBrowserCompiler} from '@dora-studio/compiler-web';
import {formatTypeScriptDiagnostics,isProjectPath,type ProjectFile,type ProjectSnapshot} from '@dora-studio/contracts';
import {readInstalledAgentFiles,type AgentProjectFS} from './agent-project-install';
import type {AgentToolRequest,AgentToolReply} from './agent-wasm-source';

const resources=['Dora.d.ts','es6-subset.d.ts','lua.d.ts','jsx.d.ts','lualib_bundle.lua'];
const decoder=new TextDecoder('utf-8',{fatal:true});

/** Called only by the original Agent `build` tool in its dedicated WASM host.
 * It does not schedule a Studio editor build or start a game Player.
 */
export async function transpileAgentTsTool(fs:AgentProjectFS,projectId:string,request:AgentToolRequest,signal:AbortSignal):Promise<AgentToolReply> {
  if(request.operation!=='transpile-ts'||request.projectRoot!=='/user/studio-project'||!request.file.startsWith(request.projectRoot+'/'))return {success:false,message:'Invalid Studio build target'};
  const relative=request.file.slice(request.projectRoot.length+1);
  if(!isProjectPath(relative)||!/\.tsx?$/.test(relative)||/\.d\.ts$/.test(relative))return {success:false,message:'Invalid Studio TypeScript target'};
  signal.throwIfAborted();
  const installed=readInstalledAgentFiles(fs,true);
  const source=installed.find(file=>file.path===relative);
  if(!source||decoder.decode(source.bytes)!==request.content)return {success:false,message:'Agent source changed before build'};
  const tsPaths=new Set(installed.filter(file=>/\.tsx?$/.test(file.path)&&!/\.d\.ts$/.test(file.path)).map(file=>file.path.replace(/\.tsx?$/,'.lua')));
  const files:ProjectFile[]=installed.filter(file=>!tsPaths.has(file.path)).map(file=>{
    try{return {path:file.path,kind:'text' as const,text:decoder.decode(file.bytes)};}
    catch{return {path:file.path,kind:'binary' as const,bytes:file.bytes};}
  });
  const snapshot:ProjectSnapshot={version:1,projectId,revision:0,entry:relative,files};
  const declarations=await Promise.all(resources.map(async path=>{
    const response=await fetch(new URL(`./declarations/${path}`,location.href),{credentials:'same-origin',cache:'no-store',signal});
    if(!response.ok)throw new Error(`Compiler resource unavailable: ${path}`);
    return {path,kind:'text' as const,text:await response.text()};
  }));
  signal.throwIfAborted();
  const compiler=createBrowserCompiler(new URL('./compiler/worker.js',location.href));
  try{
    const reply=await compiler.compile({version:1,sessionId:'studio-agent-build',projectId,revision:0,requestId:crypto.randomUUID(),buildId:crypto.randomUUID(),compilerVersion:'dora-tstl-0.1.0-ts5.9.3',type:'compile',snapshot,declarations,rootNames:[relative],options:{},timeoutMs:30000},signal);
    if(reply.type==='compiled'){
      const issues=reply.diagnostics.filter(d=>d.severity==='warning'||d.severity==='error');
      if(issues.length)return {success:false,message:formatTypeScriptDiagnostics(request.file,issues.slice(0,8),files).slice(0,4096)};
      const output=reply.artifact.files.find(file=>file.path===relative.replace(/\.tsx?$/,'.lua')&&file.kind==='text');
      return output?.kind==='text'&&new TextEncoder().encode(output.text).byteLength<=1048576?{success:true,luaCode:output.text}:{success:false,message:'TypeScript output missing or too large'};
    }
    if(reply.type==='compileFailed')return {success:false,message:formatTypeScriptDiagnostics(request.file,
      reply.diagnostics.filter(d=>d.severity==='warning'||d.severity==='error').slice(0,8),files).slice(0,4096)||'TypeScript compilation failed'};
    return {success:false,message:reply.type==='cancelled'?'TypeScript compilation canceled':reply.message.slice(0,4096)};
  }finally{compiler.dispose();}
}
