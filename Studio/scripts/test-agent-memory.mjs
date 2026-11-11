import assert from 'node:assert/strict';
import {mkdtemp, readFile, writeFile, mkdir, rm} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import {join, dirname} from 'node:path';
import {execFileSync} from 'node:child_process';
import vm from 'node:vm';
import ts from 'typescript';
import {compileAgentCommand} from './compile-agent.mjs';

// Native Lua exercises the production runtime and request fitting. The small JS
// harness below isolates the private decision-loop functions from engine/UI I/O.
const temp = await mkdtemp(join(tmpdir(), 'dora-memory-test-'));
try {
  for (const file of await compileAgentCommand({fullAgent: true})) {
    const path = join(temp, file.path);
    await mkdir(dirname(path), {recursive: true});
    await writeFile(path, file.text);
  }
  await writeFile(join(temp, 'lualib_bundle.lua'), await readFile('../Assets/Script/Lib/lualib_bundle.lua'));
  const fixture = await readFile('scripts/fixtures/agent-memory-budget.lua', 'utf8');
  await writeFile(join(temp, 'test.lua'), `package.path = ${JSON.stringify(temp + '/?.lua;')} .. package.path\n` + fixture);
  process.stdout.write(execFileSync(process.env.LUA || 'lua', [join(temp, 'test.lua')], {encoding: 'utf8'}));
} finally {
  await rm(temp, {recursive: true, force: true});
}

const source = await readFile('../Assets/Script/Lib/Agent/DoraAgent.ts', 'utf8');
const ast = ts.createSourceFile('DoraAgent.ts', source, ts.ScriptTarget.Latest, true);
const names = ['maybeCompressHistory', 'compactActiveHistory', 'getActiveConversationMessages',
  'getActiveRealMessageCount', 'getUnconsolidatedMessages', 'applyCompressedSessionState'];
const functions = ast.statements.filter(node => ts.isFunctionDeclaration(node) && names.includes(node.name?.text));
assert.equal(functions.length, names.length);
const code = ts.transpileModule(functions.map(node => node.getText(ast)).join('\n'), {
  compilerOptions: {target: ts.ScriptTarget.ES2022, module: ts.ModuleKind.None},
}).outputText;
function setup({count = 50, chunk = 15, fixed = 0, growMemory = false, carry = false} = {}) {
  const events = [], targets = [], persisted = [];
  let calls = 0;
  const shared = {
    messages: Array.from({length: count + (carry ? 1 : 0)}, () => ({role: 'assistant', content: 'history'})),
    lastConsolidatedIndex: carry ? 1 : 0, carryMessageIndex: carry ? 0 : undefined,
    workflow: {}, step: 0, stopToken: {stopped: false}, llmOptions: {}, llmConfig: {model: 'fixture'},
    memory: {compressor: {compress: async (messages, options, tries, mode, context) => {
      calls++;
      targets.push(context.targetTokens);
      if (growMemory) fixed += chunk * 1000;
      const prefix = typeof shared.carryMessageIndex === 'number' ? 1 : 0;
      return {success: true, compressedCount: Math.min(chunk, messages.length - prefix) + prefix,
        carryMessageIndex: carry ? 0 : undefined};
    }}},
  };
  const context = vm.createContext({
    math: Math, Error,
    projectMessagesForCompression: messages => messages,
    projectMessagesForLLMContext: messages => messages,
    sanitizeMessagesForLLMInput: messages => messages,
    buildAgentSystemPrompt: () => '', getDecisionToolSchemaText: () => '', getDecisionDisabledAgentTools: () => [],
    AgentToolRegistry: {buildDecisionToolSchema: () => []}, AgentConfig: {AGENT_LIMITS: {}},
    AgentRuntimePolicy: {getUncoveredConversationMessages: (messages, start) => messages.slice(start)},
    AgentUtils: {Log() {}, fitMessagesToContext: messages => ({originalTokens: messages.length * 1000 + fixed, budgetTokens: 24000})},
    emitAgentEvent: (_, event) => events.push(event),
    getMemoryCompressionStartReason: () => 'start', getMemoryCompressionSuccessReason: () => 'success',
    getMemoryCompressionFailureReason: (_, error) => error, summarizeHistoryEntryPreview: text => text,
    persistHistoryState: state => persisted.push(state.lastConsolidatedIndex),
  });
  vm.runInContext(code, context);
  context.buildDecisionMessages = state => context.getUnconsolidatedMessages(state);
  return {shared, context, events, targets, persisted, calls: () => calls};
}
const normal = setup();
await normal.context.maybeCompressHistory(normal.shared);
assert.equal(normal.calls(), 2);
assert.deepEqual(normal.targets, [38000, 23000]);
assert.equal(normal.shared.lastConsolidatedIndex, 30);
await normal.context.maybeCompressHistory(normal.shared);
assert.equal(normal.calls(), 2, 'the next pre-decision check must not repeat successful compaction');
const large = setup({count: 100, chunk: 15});
await large.context.maybeCompressHistory(large.shared);
assert.equal(large.calls(), 6, 'continue making progress until the actual request fits, without resetting 3-round batches');
const stuck = setup({fixed: 25000, growMemory: true});
await assert.rejects(stuck.context.maybeCompressHistory(stuck.shared), /did not reduce/);
assert.equal(stuck.calls(), 1);
assert.deepEqual(stuck.persisted, [15], 'persist completed compaction before pausing');
const noHistory = setup({count: 0, fixed: 25000});
await assert.rejects(noHistory.context.maybeCompressHistory(noHistory.shared), /insufficient context/);
assert.equal(noHistory.calls(), 0);
const manual = setup({count: 33, chunk: 1, carry: true});
const compacted = await manual.context.compactActiveHistory(manual.shared);
assert.equal(compacted.rounds, 33, 'manual compaction has no arbitrary round cap');
assert.equal(compacted.totalCompressed, 33, 'carried prefix must not be counted twice');
assert.equal(manual.shared.lastConsolidatedIndex, 34);
const retention = setup({count: 0});
retention.shared.messages = [{role: 'user', taskId: 1, inputKind: 'prompt', content: 'original'},
  ...Array.from({length: 10}, () => ({role: 'user', taskId: 1, inputKind: 'steer', content: 'covered input'})),
  {role: 'assistant', content: 'tail'}];
retention.shared.taskId = 1;
retention.shared.lastConsolidatedIndex = 11;
retention.shared.carryMessageIndex = 0;
assert.deepEqual(Array.from(retention.context.getUnconsolidatedMessages(retention.shared), message => message.content), ['original', 'tail']);
console.log('Automatic/manual compaction regressions passed (effective targets, progress, no repeated checks, retained input reclamation, carry accounting, no arbitrary round cap).');
