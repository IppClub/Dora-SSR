// Host-side policy tests complement the authored TS tests running inside Dora.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const ts = require(process.argv[2] || 'typescript');
const root = path.resolve(__dirname, '../../..');
const source = fs.readFileSync(path.join(root, 'Assets/Script/Lib/Agent/DoraAgent.ts'), 'utf8');
const ast = ts.createSourceFile('DoraAgent.ts', source, ts.ScriptTarget.Latest, true);
const fn = name => ast.statements.find(n => ts.isFunctionDeclaration(n) && n.name?.text === name).getText(ast);
const cls = ast.statements.find(n => ts.isClassDeclaration(n) && n.name?.text === 'MainDecisionAgent');
const exec = cls.members.find(n => n.name?.getText(ast) === 'exec').getText(ast);
const setup = globals => {
  const c = vm.createContext({math: Math, os: {date: () => 'fixture'}, ...globals});
  vm.runInContext(ts.transpile(`${fn('commitCompressedSessionState')}\n${fn('maybeCompressHistory')}\nclass TestDecision { ${exec} }; globalThis.TestDecision=TestDecision;`), c);
  return c;
};
let passed = 0;
const test = async (name, run) => { await run(); passed++; console.log('PASS ' + name); };
(async () => {
  const utilsSource=fs.readFileSync(path.join(root,'Assets/Script/Lib/Agent/Utils.ts'),'utf8');
  const utilsAst=ts.createSourceFile('Utils.ts',utilsSource,ts.ScriptTarget.Latest,true);
  const helpers=['getLLMFailureKind','ensureConversationUserMessage','useFastGlmToolDecision'].map(name=>utilsAst.statements.find(n=>ts.isFunctionDeclaration(n)&&n.name?.text===name).getText(utilsAst)).join('\n');
  const u=vm.createContext({exports:{},tostring:String,safeJsonDecode:s=>{try{return [JSON.parse(s)];}catch{return [undefined];}}});
  vm.runInContext(ts.transpile(helpers),u);
  for(const [message,raw,expected] of [
    ['request id 503; invalid arguments','','other'],['HTTP 401 unauthorized','','other'],
    ['maximum context length exceeded','','context'],['failed to get http response','','transport'],
    ['invalid','{"error":{"code":"server_error"}}','transport'],
    ['no choices','data: {"error":{"code":"server_error"}}\n\ndata: [DONE]\n','transport'],
  ]) await test('failure classification: '+message,()=>assert.equal(u.exports.getLLMFailureKind(message,raw),expected));
  await test('provider continuation preserves history and tool pairing',()=>{
    const a=[{role:'system',content:'checkpoint'},{role:'assistant',tool_calls:[{id:'x'}]},{role:'tool',tool_call_id:'x',content:'result'}];
    const b=u.exports.ensureConversationUserMessage(a);assert.equal(a.length,3);assert.equal(b.length,4);assert.equal(b[1].role,'user');assert.equal(b[2],a[1]);assert.equal(b[3],a[2]);
    const current=[...a,{role:'user',content:'latest correction'}];assert.equal(u.exports.ensureConversationUserMessage(current),current);
  });
  await test('GLM generations honor explicit reasoning override',()=>{
    assert.equal(u.exports.useFastGlmToolDecision('glm-5.2',{}),true);assert.equal(u.exports.useFastGlmToolDecision('glm-5.3',{}),true);
    assert.equal(u.exports.useFastGlmToolDecision('glm-5.3',{reasoning_effort:'high'}),false);assert.equal(u.exports.useFastGlmToolDecision('other',{}),false);
  });
  await test('failed memory compression retains history and opens breaker',()=>{
    const text=fs.readFileSync(path.join(root,'Assets/Script/Lib/Agent/Runtime/Memory.ts'),'utf8');const a=ts.createSourceFile('Memory.ts',text,ts.ScriptTarget.Latest,true);
    const c=a.statements.find(n=>ts.isClassDeclaration(n)&&n.name?.text==='MemoryCompressor');
    const methods=['handleCompressionFailure','isCompressionBreakerOpen'].map(name=>c.members.find(n=>n.name?.getText(a)===name).getText(a)).join('\n');
    const ctx=vm.createContext({Log:()=>{}});vm.runInContext(ts.transpile(`class CheckMemory {consecutiveFailures=0;storage={readMemory:()=>"unchanged"}; ${methods}};globalThis.CheckMemory=CheckMemory;`),ctx);
    const m=new ctx.CheckMemory();for(let i=0;i<3;i++){const r=m.handleCompressionFailure([{role:'user',content:'keep'}],'failure');assert.equal(r.success,false);assert.equal(r.compressedCount,0);assert.equal(r.memoryUpdate,'unchanged');}assert.equal(m.isCompressionBreakerOpen(),true);
  });
  await test('checkpoint is published only after durable session save', () => {
    let fail = true;
    const c = setup({applyCompressedSessionState(s) {s.lastConsolidatedIndex=2;s.workflow.resumeRequiredTool='build';},
      appendConversationMessage(s,m) {s.messages.push(m);},persistHistoryState() {if(fail) throw Error('disk full');}});
    const shared={messages:[{role:'user',content:'goal'},{role:'assistant',content:'done'}],lastConsolidatedIndex:0,workflow:{}};
    const result={compressedCount:2};
    assert.throws(()=>c.commitCompressedSessionState(shared,result),/disk full/);
    assert.equal(shared.messages.length,2);assert.equal(shared.lastConsolidatedIndex,0);assert.equal(shared.workflow.resumeRequiredTool,undefined);
    fail=false;c.commitCompressedSessionState(shared,result);
    assert.equal(shared.messages.length,2);assert.equal(shared.lastConsolidatedIndex,2);
  });
  for(const [name,tokens,breaker,success,expected] of [
    ['below trigger',89,false,false,'skip'],['instructions fit without history',95,false,false,'skip'],['breaker below hard tier',95,true,false,'skip'],
    ['hard tier bypasses breaker',98,true,false,'try'],['failed proactive compression preserves request',95,false,false,'try'],
    ['over-budget failure stops without clipping',101,false,false,'throw'],
    ['successful proactive compression returns to decision',95,false,true,'try'],
    ['nonshrinking proactive checkpoint cannot loop',95,false,'nonshrinking','try'],
    ['carried instruction alone is not compression progress',95,false,'carried','try'],
  ]) await test(name,async()=>{
    let calls=0,committed=0;
    const fit=()=>({originalTokens:committed && success!=='nonshrinking'?50:tokens,budgetTokens:100});
    const c=setup({buildAgentSystemPrompt:()=>'',sanitizeMessagesForLLMInput:x=>x,getActiveConversationMessages:s=>s.messages,
      projectMessagesForLLMContext:x=>x,projectMessagesForCompression:x=>x,AgentRuntimePolicy:{getUncoveredConversationMessages:()=>[]},
      getDecisionToolSchemaText:()=>'',buildDecisionMessages:()=>[],getDecisionDisabledAgentTools:()=>[],
      AgentToolRegistry:{buildDecisionToolSchema:()=>[]},AgentConfig:{AGENT_LIMITS:{}},
      AgentUtils:{fitMessagesToContext:fit,useFastGlmToolDecision:()=>false,Log:()=>{}},getActiveRealMessageCount:s=>s.messages.length,emitAgentEvent:()=>{},
      getMemoryCompressionStartReason:()=>'',getMemoryCompressionFailureReason:()=>'',getMemoryCompressionSuccessReason:()=>'',
      summarizeHistoryEntryPreview:()=>'',commitCompressedSessionState:()=>{committed++;},
      persistHistoryState:()=>{},getCancelledReason:()=> 'cancelled',saveStepLLMDebugInput:()=>{},saveStepLLMDebugOutput:()=>{},recordLLMTokenUsage:()=>{}});
    // Install after evaluation so this test isolates the loop from the separately tested commit helper.
    c.commitCompressedSessionState=()=>{committed++;};
    const shared={messages:name==='instructions fit without history'?[]:[{},{}],carryMessageIndex:success==='carried'?0:undefined,lastConsolidatedIndex:0,step:0,agentStepCount:1,llmOptions:{},llmMaxTry:2,
      llmConfig:{model:'fixture'},memory:{compressor:{isCompressionBreakerOpen:()=>breaker,compress:async()=>{
        calls++;assert.ok(calls<=1,'proactive loop must stop');return success?{success:true,compressedCount:success==='carried'?1:2}:{success:false,compressedCount:0,error:'provider down'};}}},stopToken:{stopped:false}};
    if(expected==='throw') await assert.rejects(c.maybeCompressHistory(shared),/provider down/);else await c.maybeCompressHistory(shared);
    assert.equal(calls,expected==='skip'?0:1);
    if(!success) assert.equal(shared.lastConsolidatedIndex,0);
  });
  for(const [name,errors,cancel,expectedCalls] of [
    ['transient decision failure retries', ['transport'],false,2],
    ['nontransient decision failure does not retry',['other'],false,1],
    ['transport retries are bounded',['transport','transport','transport'],false,3],
    ['cancel during retry prevents another request',['transport'],true,1],
  ]) await test(name,async()=>{
    let calls=0,waits=0;
    const shared={messages:[],stopToken:{stopped:false},agentStepCount:0,maxSteps:5,llmMaxTry:3,step:0,resumeCheckpointPending:true,pendingTruncationRecovery:true};
    const c=setup({getUnconsolidatedMessages:()=>[],getCancelledReason:()=> 'cancelled',
      AgentUtils:{Log:()=>{},getLLMFailureKind:x=>x,waitForLLMRetry:async()=>{waits++;if(cancel)shared.stopToken.stopped=true;}},truncateText:x=>x});
    const decision=new c.TestDecision();
    decision.callDecisionByToolCalling=async(s,lastError)=>{
      assert.ok(!lastError,'transport errors must not add a validation retry prompt');
      assert.equal(s.resumeCheckpointPending,true,'resume guidance must survive transport failure');
      assert.equal(s.pendingTruncationRecovery,true,'truncation guidance must survive transport failure');
      s.resumeCheckpointPending=false;s.pendingTruncationRecovery=false;
      if(shared.stopToken.stopped)return {success:false,message:'cancelled'};
      const error=errors[calls++];return error?{success:false,requestFailed:true,message:error}:{success:true};
    };
    const result=await decision.exec({shared});
    assert.equal(calls,expectedCalls);assert.equal(result.success,errors.length===1 && errors[0]==='transport' && !cancel);
    assert.ok(waits<=2);
  });
  console.log(`${passed} policy checks passed`);
})().catch(e=>{console.error(e);process.exitCode=1;});
