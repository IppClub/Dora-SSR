import {mkdtemp,readFile,writeFile,mkdir,rm} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import {join,dirname} from 'node:path';
import {execFileSync} from 'node:child_process';
import {compileAgentCommand} from './compile-agent.mjs';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import ts from 'typescript';

// Exercise the actual private decision validation and prompt functions with
// deterministic engine adapters, as in the memory decision-loop regressions.
const source=await readFile('../Assets/Script/Lib/Agent/DoraAgent.ts','utf8');
const ast=ts.createSourceFile('DoraAgent.ts',source,ts.ScriptTarget.Latest,true);
const names=['getDecisionDisabledAgentTools','isToolAllowedForRole','validateDecisionForShared','buildAgentSystemPrompt'];
const functions=ast.statements.filter(node=>ts.isFunctionDeclaration(node)&&names.includes(node.name?.text));
assert.equal(functions.length,names.length);
const code=ts.transpileModule(functions.map(node=>node.getText(ast).replace(/^export /,'')).join('\n'),{
 compilerOptions:{target:ts.ScriptTarget.ES2022,module:ts.ModuleKind.None},
}).outputText;
const context=vm.createContext({
 VISION_UNAVAILABLE_MESSAGE:'VISION_ROUTE_UNAVAILABLE: check service settings',
 resolveVisionBinding:config=>config.bound?{}:undefined,
 isFinalDecisionTurn:()=>false,getReplyLanguageDirective:()=>'',buildSkillsSection:()=>'',
 Path:()=>'',Content:{exist:()=>false},AgentRuntimePolicy:{},
 AgentToolRegistry:{getAllowedToolsForRole:(_role,options)=>options.disabledAgentTools.includes('analyze_image')?[]:['analyze_image']},
});
vm.runInContext(code,context);
for(const role of ['main','sub'])for(const workMode of ['code','plan']){
 const shared={role,workMode,llmConfig:{bound:false},disabledAgentTools:['analyze_image'],promptPack:{},
  memory:{compressor:{getMemoryContextBudget:()=>0,getStorage:()=>({getRelevantMemoryContext:()=>''})}}};
 const denied=context.validateDecisionForShared(shared,'analyze_image',{});
 assert.equal(denied.success,false);
 assert.match(denied.message,/VISION_ROUTE_UNAVAILABLE/);
 assert.doesNotMatch(denied.message,/not allowed in/);
 assert.match(context.buildAgentSystemPrompt(shared),/VISION_ROUTE_UNAVAILABLE/);
 shared.llmConfig.bound=true;
 assert.match(context.validateDecisionForShared(shared,'analyze_image',{}).message,/disabled for this task/);
 assert.match(context.buildAgentSystemPrompt(shared),/disabled for this task/);
 shared.disabledAgentTools=[];
 assert.equal(context.validateDecisionForShared(shared,'analyze_image',{}).success,true);
 assert.doesNotMatch(context.buildAgentSystemPrompt(shared),/unavailable|disabled/);
}
console.log('PASS: decision validation and system prompt explain unavailable vision versus explicit task disabling in both roles and modes.');

const temp=await mkdtemp(join(tmpdir(),'dora-vision-input-'));
try{
 for(const file of await compileAgentCommand({fullAgent:true})){
  const path=join(temp,file.path);await mkdir(dirname(path),{recursive:true});await writeFile(path,file.text);
 }
 await writeFile(join(temp,'lualib_bundle.lua'),await readFile('../Assets/Script/Lib/lualib_bundle.lua'));
 let output='';
 for(const fixture of ['agent-vision-input.lua','agent-vision-failures.lua']){
  await writeFile(join(temp,'test.lua'),`package.path=${JSON.stringify(temp+'/?.lua;')}..package.path\n`+await readFile('scripts/fixtures/'+fixture,'utf8'));
  const result=execFileSync(process.env.LUA||'lua',[join(temp,'test.lua')],{encoding:'utf8'});output+=result;process.stdout.write(result);
 }
 await mkdir('../build/agent-vision-input-qa',{recursive:true});await writeFile('../build/agent-vision-input-qa/regression.log',output);
}finally{await rm(temp,{recursive:true,force:true});}
