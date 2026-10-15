import {isProjectPath,serializeArtifactContent,type BuildArtifact,type ProjectFile} from '@dora-studio/contracts';
import {readInstalledAgentFiles,type AgentProjectFS} from './agent-project-install';
import type {AgentToolReply,AgentToolRequest} from './agent-wasm-source';

export interface AgentLuaCommandResult {success:boolean;output:string;message?:string;phase?:string;
  files?:readonly {path:string;bytes:Uint8Array}[];deletedPaths?:readonly string[]}
export type AgentLuaBroker=(artifact:BuildArtifact,commandId:string,timeoutSeconds:number,signal:AbortSignal)=>Promise<AgentLuaCommandResult>;

const decoder=new TextDecoder('utf-8',{fatal:true});
const encoder=new TextEncoder();
const root='/user/studio-project';

async function sha256(value:string):Promise<string>{
  const digest=await crypto.subtle.digest('SHA-256',encoder.encode(value));
  return [...new Uint8Array(digest)].map(byte=>byte.toString(16).padStart(2,'0')).join('');
}

function luaLongString(value:string):string{
  for(let level=0;level<32;level++){
    const equals='='.repeat(level),close=`]${equals}]`;
    if(!value.includes(close))return `[${equals}[${value}${close}`;
  }
  throw new Error('Agent Lua command cannot be encoded safely');
}

function commandEntry(code:string,commandId:string):string{
  const source=luaLongString(code),resultPath=luaLongString(`/tmp/studio-agent-command-${commandId}.json`);
  return `local Dora = require("Dora")
local json = Dora.json
local output, outputBytes, truncated = {}, 0, false
local function capture(...)
  local parts = {}
  for i = 1, select("#", ...) do parts[i] = tostring(select(i, ...)) end
  local line = table.concat(parts, "\\t")
  if outputBytes + #line + 1 <= 65536 then
    output[#output + 1] = line
    outputBytes = outputBytes + #line + 1
  elseif not truncated then
    truncated = true
    output[#output + 1] = "[output truncated]"
  end
end
local env = setmetatable({
  print = capture,
  projectDir = "/game",
  reportProgress = function() end,
  refreshTree = function() return true end,
  getEntryStatus = function() return {success = true, running = true, runId = 1} end,
  enterEntryAsync = function() return false, "The isolated Player is already the active game runtime; use previewGame for a project entry" end,
  stopEntry = function() return false end,
  requireProjectModule = function(moduleName)
    if type(moduleName) ~= "string" or moduleName == "" or moduleName:find("..", 1, true) then
      error("requireProjectModule expects a project module name without '..'")
    end
    return require((moduleName:gsub("/", ".")))
  end,
}, {__index = function(_, key)
  local value = Dora[key]
  if value ~= nil then return value end
  return _G[key]
end})
local fn, compileError = load(${source}, "=(agent_command)", "t", env)
local function finish(result)
  local encoded, encodeError = json.encode(result)
  if not encoded then
    error("failed to encode Agent Lua command result: " .. tostring(encodeError))
  end
  if not Dora.Content:save(${resultPath}, encoded) then
    error("failed to save Agent Lua command result")
  end
end
if not fn then
  finish({success = false, output = table.concat(output, "\\n"), message = tostring(compileError), phase = "compile"})
else
  -- The isolated Player owns cancellation and timeout by destroying this run,
  -- so its command wrapper only needs Dora's native frame-driven coroutine.
  local started, startError = pcall(Dora.thread, function()
    local ok, runtimeError = xpcall(fn, debug.traceback)
    finish(ok
      and {success = true, output = table.concat(output, "\\n")}
      or {success = false, output = table.concat(output, "\\n"), message = tostring(runtimeError), phase = "execute"})
  end)
  if not started then
    finish({success = false, output = table.concat(output, "\\n"), message = tostring(startError), phase = "execute"})
  end
end
`;
}

export async function executeAgentLuaTool(fs:AgentProjectFS,projectId:string,revision:number,request:AgentToolRequest,
  broker:AgentLuaBroker,signal:AbortSignal):Promise<AgentToolReply>{
  if(request.operation!=='execute-lua'||request.projectRoot!==root||!request.file.startsWith(root+'/')||!request.file.endsWith('.lua'))return {success:false,message:'Invalid Agent Lua target'};
  let options:{code?:unknown;timeoutSeconds?:unknown};
  try{options=JSON.parse(request.content);}catch{return {success:false,message:'Invalid Agent Lua options'};}
  const code=options.code,timeoutSeconds=options.timeoutSeconds;
  if(typeof code!=='string'||!code.trim()||encoder.encode(code).byteLength>131072
    ||typeof timeoutSeconds!=='number'||!Number.isSafeInteger(timeoutSeconds)||timeoutSeconds<1||timeoutSeconds>600)return {success:false,message:'Invalid Agent Lua options'};
  signal.throwIfAborted();
  const commandId=crypto.randomUUID(),entry=`.agent/commands/${commandId}.lua`;
  if(!isProjectPath(entry))return {success:false,message:'Invalid Agent Lua entry'};
  const installed=readInstalledAgentFiles(fs,true).filter(file=>!file.path.startsWith('.agent/commands/'));
  const files:ProjectFile[]=installed.map(file=>{
    try{return {path:file.path,kind:'text',text:decoder.decode(file.bytes)};}
    catch{return {path:file.path,kind:'binary',bytes:file.bytes};}
  });
  files.push({path:entry,kind:'text',text:commandEntry(code,commandId)});
  const content={compilerVersion:'dora-agent-lua-player-1',entry,files,sourceMaps:{}};
  const artifact:BuildArtifact={...content,buildId:crypto.randomUUID(),projectId,revision,sha256:await sha256(serializeArtifactContent(content))};
  signal.throwIfAborted();
  try{
    const result=await broker(artifact,commandId,timeoutSeconds,signal);
    if(!result||typeof result.success!=='boolean'||typeof result.output!=='string'||encoder.encode(result.output).byteLength>131072
      ||(result.message!==undefined&&(typeof result.message!=='string'||encoder.encode(result.message).byteLength>16384)))return {success:false,message:'Invalid Agent Lua Player result'};
    const changed=new Set<string>();
    for(const file of result.files??[]){
      if(!isProjectPath(file.path)||file.path==='.agent'||file.path.startsWith('.agent/')||changed.has(file.path)
        ||!(file.bytes instanceof Uint8Array)||file.bytes.byteLength>64*1024*1024)return {success:false,message:'Invalid Agent Lua Player files'};
      changed.add(file.path);const target=root+'/'+file.path;
      fs.mkdirTree(target.slice(0,target.lastIndexOf('/')));fs.writeFile(target,new Uint8Array(file.bytes));
    }
    for(const path of result.deletedPaths??[]){
      if(!isProjectPath(path)||path==='.agent'||path.startsWith('.agent/')||changed.has(path))return {success:false,message:'Invalid Agent Lua Player deletions'};
      changed.add(path);const target=root+'/'+path;
      if(fs.analyzePath(target).exists){const stat=fs.lstat(target);if(!fs.isFile(stat.mode))return {success:false,message:'Invalid Agent Lua Player deletion'};fs.unlink(target);}
    }
    const {files:_,deletedPaths:__,...commandResult}=result;
    return {success:true,resultJSON:JSON.stringify(commandResult)};
  }catch(error){return {success:false,message:error instanceof Error?error.message.slice(0,4096):'Agent Lua Player failed'};}
}
