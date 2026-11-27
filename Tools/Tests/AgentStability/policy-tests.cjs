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
const prep = cls.members.find(n => n.name?.getText(ast) === 'prep').getText(ast);
const memoryHelpers = ['buildAgentSystemPrompt', 'wrapMemorySelection', 'refreshMemoryContextMessage', 'hasConversationUserTurn'].map(fn).join('\n');
const setupMemory = globals => {
  const c = vm.createContext({math: Math, ...globals});
  vm.runInContext(ts.transpile(`${memoryHelpers}\nclass TestPrep { ${prep} }; globalThis.TestPrep=TestPrep;`), c);
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
  await test('model request serialization keeps nested tool keys stable', () => {
    const encoder = utilsAst.statements.find(n => ts.isFunctionDeclaration(n) && n.name?.text === 'encodeStableJSONValue');
    const context = vm.createContext({
      type: value => value !== null && typeof value === 'object' ? 'table' : typeof value,
      safeJsonEncode: value => [JSON.stringify(value)],
    });
    vm.runInContext(ts.transpile(encoder.getText(utilsAst)), context);
    const toolA = { function: { name: 'example', parameters: { properties: { z: { type: 'string' }, a: { type: 'array' } } } }, type: 'function' };
    const toolB = { type: 'function', function: { parameters: { properties: { a: { type: 'array' }, z: { type: 'string' } } }, name: 'example' } };
    const messages = [{ role: 'tool', content: '{"z":2,"a":1}' }];
    const requestA = { tools: [toolA], messages, stream: true };
    const requestB = { stream: true, messages, tools: [toolB] };
    const first = context.encodeStableJSONValue(requestA, true, 0);
    assert.equal(first, context.encodeStableJSONValue(requestB, true, 0));
    assert.deepEqual(JSON.parse(first), requestA);
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
  for(const [name,tokens,canFit,success,expected] of [
    ['below checkpoint range',80,true,false,'skip'],
    ['instructions fit without history',95,true,false,'skip'],
    ['checkpoint needs room for its directive and output',95,false,false,'skip'],
    ['failed proactive checkpoint keeps history and does not retry',95,true,false,'try'],
    ['over-budget failure stops without clipping',101,false,false,'throw'],
    ['successful proactive checkpoint returns to decision',95,true,true,'try'],
    ['nonshrinking proactive checkpoint cannot loop',95,true,'nonshrinking','try'],
    ['carried instruction alone is not compression progress',95,true,'carried','try'],
  ]) await test(name,async()=>{
    let calls=0,committed=0;
    const fit=()=>({messagesTokens:committed && success!=='nonshrinking'?50:tokens,inputBudget:100,contextWindow:100,options:{tools:[{}]}});
    const c=setup({buildAgentSystemPrompt:()=>'',sanitizeMessagesForLLMInput:x=>x,getActiveConversationMessages:s=>s.messages,
      projectMessagesForLLMContext:x=>x,projectMessagesForCompression:x=>x,AgentRuntimePolicy:{getUncoveredConversationMessages:()=>[]},
      getDecisionToolSchemaText:()=>'',buildDecisionMessages:()=>[],getDecisionDisabledAgentTools:()=>[],
      canUsePrefixHandoff:()=>true,planDecisionRequest:fit,
      AgentToolRegistry:{buildDecisionToolSchema:()=>[]},AgentConfig:{AGENT_LIMITS:{}},
      AgentUtils:{fitMessagesToContext:fit,useFastGlmToolDecision:()=>false,Log:()=>{}},getActiveRealMessageCount:s=>s.messages.length,emitAgentEvent:()=>{},
      getMemoryCompressionStartReason:()=>'',getMemoryCompressionFailureReason:()=>'',getMemoryCompressionSuccessReason:()=>'',
      summarizeHistoryEntryPreview:()=>'',commitCompressedSessionState:()=>{committed++;},
      persistHistoryState:()=>{},getCancelledReason:()=> 'cancelled',saveStepLLMDebugInput:()=>{},saveStepLLMDebugOutput:()=>{},recordLLMTokenUsage:()=>{}});
    // Install after evaluation so this test isolates the loop from the separately tested commit helper.
    c.commitCompressedSessionState=()=>{committed++;};
    const shared={messages:name==='instructions fit without history'?[]:Array.from({length:12},()=>({})),carryMessageIndex:success==='carried'?0:undefined,lastConsolidatedIndex:0,step:0,agentStepCount:1,llmOptions:{},llmMaxTry:2,
      llmConfig:{model:'fixture'},memory:{compressor:{canFitSharedPrefixCheckpoint:()=>canFit,compress:async(...args)=>{
        calls++;
        assert.ok(calls<=1,'proactive loop must stop');
        assert.equal(args[4].sharedPrefixOnly,tokens<=100);
        return success?{success:true,compressedCount:success==='carried'?1:2}:{success:false,compressedCount:0,error:'provider down'};}}},stopToken:{stopped:false}};
    if(expected==='throw') await assert.rejects(c.maybeCompressHistory(shared),/provider down/);else await c.maybeCompressHistory(shared);
    if (name==='failed proactive checkpoint keeps history and does not retry') await c.maybeCompressHistory(shared);
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
  // The memory selection is an appended conversation message, so the system prompt never changes with it.
  const memorySource=fs.readFileSync(path.join(root,'Assets/Script/Lib/Agent/Runtime/Memory.ts'),'utf8');
  const memoryAst=ts.createSourceFile('Memory.ts',memorySource,ts.ScriptTarget.Latest,true);
  const memoryCompressor=memoryAst.statements.find(n=>ts.isClassDeclaration(n)&&n.name?.text==='MemoryCompressor');
  const storageClass=memoryAst.statements.find(n=>ts.isClassDeclaration(n)&&n.name?.text==='DualLayerStorage');
  // Strip the module keyword so the host context needs no `exports` object.
  const topLevel=(source,name)=>source.statements.find(n=>ts.isFunctionDeclaration(n)&&n.name?.text===name).getText(source).replace(/^export\s+/, '');
  const member=(cls,name,source)=>cls.members.find(n=>n.name?.getText(source)===name).getText(source);
  const selectionMessage={role:'user',content:'<agent-memory-context>…</agent-memory-context>',memoryContext:true};
  const instructionCtx=vm.createContext({});
  vm.runInContext(ts.transpile(`${topLevel(memoryAst,'isTaskInstruction')}\nglobalThis.isTaskInstruction=isTaskInstruction;`),instructionCtx);
  const memoryShared=(selection,extra={})=>({userQuery:'task',messages:[{role:'user',content:'task'}],lastConsolidatedIndex:0,
    memory:{compressor:{getMemoryContextBudget:()=>4000,getStorage:()=>({getRelevantMemoryContext:()=>selection.value})}},...extra});
  await test('system prompt does not change when the memory selection changes',()=>{
    const selection={value:'#### Session Summary\n\nA'};
    const c=setupMemory({canUsePrefixHandoff:()=>false,getDecisionDisabledAgentTools:()=>[],getReplyLanguageDirective:()=>'',buildSkillsSection:()=>'SKILLS',
      AgentUtils:{sanitizeUTF8:s=>s},appendConversationMessage:(s,m)=>{s.messages.push(m);},persistHistoryState:()=>{}});
    const shared=memoryShared(selection,{workMode:'code',role:'main',promptPack:{agentIdentityPrompt:'ID',mainAgentRolePrompt:'ROLE',functionCallingPrompt:'FC'}});
    const before=c.buildAgentSystemPrompt(shared);
    assert.ok(before.includes('<agent-memory-context>')&&!before.includes('Session Summary'));
    c.refreshMemoryContextMessage(shared);
    selection.value='#### Session Summary\n\nB';
    c.refreshMemoryContextMessage(shared);
    assert.equal(c.buildAgentSystemPrompt(shared),before);
    assert.deepEqual(shared.messages.map(m=>m.role),['user','user','user']);
  });
  await test('memory selection is appended only when new, changed, or covered by compression',()=>{
    const selection={value:'A'};const appended=[];
    const c=setupMemory({AgentUtils:{sanitizeUTF8:s=>s},appendConversationMessage:(s,m)=>{s.messages.push(m);appended.push(m);},persistHistoryState:()=>{}});
    const shared=memoryShared(selection);
    c.refreshMemoryContextMessage(shared);c.refreshMemoryContextMessage(shared);
    assert.equal(appended.length,1);assert.equal(shared.messages[1].role,'user');assert.equal(shared.messages[1].memoryContext,true);
    assert.ok(shared.messages[1].content.startsWith('<agent-memory-context>')&&shared.messages[1].content.endsWith('</agent-memory-context>'));
    assert.ok(shared.messages[1].content.includes('\n\nA\n</agent-memory-context>'));
    selection.value='B';c.refreshMemoryContextMessage(shared);
    assert.equal(appended.length,2);assert.ok(shared.messages[2].content.includes('\n\nB\n</agent-memory-context>'));
    shared.lastConsolidatedIndex=3;c.refreshMemoryContextMessage(shared);
    assert.equal(appended.length,3);assert.equal(shared.messages[3].memoryContext,true);
    selection.value='';c.refreshMemoryContextMessage(shared);
    assert.equal(appended.length,3);
  });
  await test('prep refreshes the selection before and after the compression check',async()=>{
    const order=[];const selection={value:'A'};
    const c=setupMemory({AgentUtils:{sanitizeUTF8:s=>s},appendConversationMessage:(s,m)=>{s.messages.push(m);order.push(`append:${s.messages.length}`);},persistHistoryState:()=>{},
      consumePendingHandoffs:()=>{},consumePendingSteering:()=>{},
      maybeCompressHistory:async s=>{order.push('compress');s.lastConsolidatedIndex=s.messages.length;selection.value='B';}});
    const shared=memoryShared(selection,{stopToken:{stopped:false},agentStepCount:0,maxSteps:5});
    await new c.TestPrep().prep(shared);
    assert.equal(order.join(','),'append:2,compress,append:3');
    assert.equal(shared.messages[1].content.includes('\n\nA\n</agent-memory-context>'),true);
    assert.equal(shared.messages[2].content.includes('\n\nB\n</agent-memory-context>'),true);
    assert.equal(shared.messages[2].content.includes('\n\nA\n</agent-memory-context>'),false);
  });
  await test('memory selection is reference data, not a task instruction',()=>{
    assert.equal(instructionCtx.isTaskInstruction({role:'user',content:'goal'}),true);
    assert.equal(instructionCtx.isTaskInstruction(selectionMessage),false);
    assert.equal(instructionCtx.isTaskInstruction({role:'user',content:'handoff',handoffId:'h1'}),false);
    assert.equal(instructionCtx.isTaskInstruction({role:'user',content:'steer',inputKind:'steer'}),false);
  });
  await test('trailing memory selection does not carry an older instruction out of a compressed chunk',()=>{
    const b=vm.createContext({isTaskInstruction:instructionCtx.isTaskInstruction});
    vm.runInContext(ts.transpile(`class CheckBoundary { ${member(memoryCompressor,'buildCarryBoundary',memoryAst)} ${member(memoryCompressor,'buildSafeBoundary',memoryAst)} }; globalThis.CheckBoundary=CheckBoundary;`),b);
    const boundary=new b.CheckBoundary();
    const goal={role:'user',content:'goal'},done={role:'assistant',content:'done'};
    const trailing=last=>{const r=boundary.buildSafeBoundary([goal,done,last],3);return `${r.chunkEnd}:${r.compressedCount}:${r.carryMessageIndex}`;};
    assert.equal(trailing(selectionMessage),'3:3:undefined');
    assert.equal(trailing({role:'user',content:'newer instruction'}),'3:3:2');
    assert.equal(trailing({role:'user',content:'handoff',handoffId:'h1'}),'3:3:undefined');
  });
  await test('continuation instruction survives a request whose only user-role message is a memory selection',()=>{
    const c=setupMemory({getActiveConversationMessages:s=>s.messages});
    const shared={messages:[selectionMessage],lastConsolidatedIndex:0};
    const request=[{role:'system',content:'rules'},selectionMessage];
    const projected=u.ensureConversationUserMessage(request,c.hasConversationUserTurn(shared));
    assert.equal(projected.length,3);assert.equal(projected[1].role,'user');assert.ok(projected[1].content.startsWith('Continue the current task'));
    shared.messages.unshift({role:'user',content:'goal'});
    assert.equal(u.ensureConversationUserMessage(request,c.hasConversationUserTurn(shared)).length,2);
  });
  await test('selection marker survives storage and reaches the compressor, but not the provider request',()=>{
    const d=vm.createContext({isArray:Array.isArray,isRecord:v=>v!==null&&typeof v==='object',sanitizeUTF8:s=>s});
    vm.runInContext(ts.transpile(`class CheckStorage { ${member(storageClass,'decodeConversationMessage',memoryAst)} }; globalThis.CheckStorage=CheckStorage;`),d);
    const decode=new d.CheckStorage().decodeConversationMessage.bind(new d.CheckStorage());
    assert.equal(decode({role:'user',content:'sel',memoryContext:true}).memoryContext,true);
    assert.equal(decode({role:'user',content:'goal'}).memoryContext,undefined);
    const projectionSource=fs.readFileSync(path.join(root,'Assets/Script/Lib/Agent/Runtime/HistoryProjection.ts'),'utf8');
    const projectionAst=ts.createSourceFile('HistoryProjection.ts',projectionSource,ts.ScriptTarget.Latest,true);
    const project=['projectMessagesForLLMContext','projectMessagesForCompression'].map(name=>topLevel(projectionAst,name)).join('\n');
    const p=vm.createContext({Set,math:Math,isArray:Array.isArray,isRecord:v=>v!==null&&typeof v==='object',AgentUtils:{},AgentConfig:{AGENT_LIMITS:{}},toJson:JSON.stringify,
      truncateHistoryText:s=>s,projectToolResultContentForLLM:(t,c)=>c,projectVisionResultForCompression:s=>s,sanitizeActionParamsForHistory:(t,x)=>x,sanitizeVisionActionParamsForCompression:x=>x});
    vm.runInContext(ts.transpile(`${project}\nglobalThis.projectForLLM=projectMessagesForLLMContext;globalThis.projectForCompression=projectMessagesForCompression;`),p);
    const history=[{role:'user',content:'goal',inputKind:'prompt'},selectionMessage];
    const decision=p.projectForLLM(history);const compression=p.projectForCompression(history);
    assert.equal(Object.keys(decision[1]).includes('memoryContext'),false);
    assert.equal(compression[1].memoryContext,true);assert.equal(compression[0].inputKind,'prompt');assert.equal(compression[1].handoffId,undefined);
    const f=vm.createContext({compressionMessageSource:undefined,safeJsonEncode:v=>[JSON.stringify(v)]});
    vm.runInContext(ts.transpile(`${topLevel(memoryAst,'compressionMessageSource')}\nclass CheckFormat { ${member(memoryCompressor,'formatMessagesForCompression',memoryAst)} }; globalThis.CheckFormat=CheckFormat;`),f);
    const text=new f.CheckFormat().formatMessagesForCompression(history);
    assert.ok(text.includes('Message 1: role=user\n'));assert.ok(text.includes('Message 2: role=user source=memory_context\n'));
  });
  console.log(`${passed} policy checks passed`);
})().catch(e=>{console.error(e);process.exitCode=1;});
