-- Run against the production TypeScript compiled to Lua, with an in-memory
-- store, deterministic token estimates, and a local model stub. No project data.
local L = require('lualib_bundle')
local J = require('dkjson')
local requests, writes, archives = {}, 0, 0
local modelMode = 'success'
package.preload['Dora'] = function()
  return {
    App = {estimateTokens = function(_, text) return math.ceil(#text / 4) end},
    json = {
      null = J.null,
      encode = function(value) return J.encode(value) end,
      decode = function(text) local value, _, err = J.decode(text); return value, err end,
    },
    Log = function() end,
  }
end
package.preload['Agent.Config.LLMConfigMigration'] = function() return {} end
package.preload['Agent.Tool.WebIDESync'] = function() return {} end
package.preload['Agent.Tool.Registry'] = function()
  return {AGENT_TOOL_DEFINITIONS_DETAILED = '', MAIN_AGENT_TOOL_DEFINITIONS_DETAILED = ''}
end
local U = require('Agent.Utils')
local originalCall = U.callLLM
U.callLLM = function(messages, options, stopToken)
  return L.__TS__AsyncAwaiter(function()
    requests[#requests + 1] = {messages = messages, options = options}
    if modelMode == 'cancel' then stopToken.stopped = true end
    if modelMode == 'xml' and options.tools then
      return {success = true, response = {choices = {{message = {content = 'use XML'}}}}}
    end
    if modelMode == 'failure' then return {success = false, message = 'fixture unavailable'} end
    if not options.tools then
      return {success = true, response = {choices = {{message = {content = '<memory_update_result><history_entry>fixture history</history_entry><memory_update>core</memory_update><project_memory_update>project</project_memory_update><session_summary_update>summary</session_summary_update></memory_update_result>'}}}}}
    end
    local args = J.encode({history_entry = 'fixture history', memory_update = 'core', project_memory_update = 'project', session_summary_update = 'summary'})
    return {success = true, response = {choices = {{message = {tool_calls = {{['function'] = {name = 'save_memory', arguments = args}}}}}}}}
  end)
end
local M = require('Agent.Runtime.Memory')
local function await(promise)
  local done, result, failure = false
  promise['then'](promise, function(_, value) done, result = true, value end,
    function(_, err) done, failure = true, err end)
  assert(done, 'unexpected asynchronous dependency')
  assert(not failure, tostring(failure))
  return result
end
local function fixture(context, output, project, summary)
  requests, writes, archives = {}, 0, 0
  modelMode = 'success'
  local memory = 'core'
  project, summary = project or '', summary or ''
  local storage = {
    readMemory = function() return memory end,
    readProjectMemory = function() return project end,
    readSessionSummary = function() return summary end,
    writeMemory = function(_, value) writes = writes + 1; memory = value end,
    writeProjectMemory = function(_, value) writes = writes + 1; project = value end,
    writeSessionSummary = function(_, value) writes = writes + 1; summary = value end,
    appendHistoryRecord = function(_, record) if record.rawArchive then archives = archives + 1 end end,
  }
  local config = {contextWindow = context, maxTokens = output, model = 'fixture', customOptions = {auxiliaryOptions = {}}}
  local compressor = setmetatable({config = {
    llmConfig = config, promptPack = M.DEFAULT_AGENT_PROMPT_PACK,
    compressionTargetThreshold = .5, maxCompressionRounds = 3,
  }, storage = storage, consecutiveFailures = 0}, M.MemoryCompressor.prototype)
  return compressor, {max_tokens = output}, config
end
local function history(count, size)
  local messages = {}
  for i = 1, count do messages[i] = {role = 'assistant', content = ('item-' .. i .. ':') .. string.rep('x', size)} end
  return messages
end
local function compress(c, options, messages, context, mode)
  return await(c:compress(messages, options, 1, 'tool_calling', context, mode or 'budget_max'))
end

-- Empty memory allocations must be available to history, and every selected
-- message, including those in the middle, must reach the model verbatim.
local c, options, config = fixture(64000, 8000)
local messages = history(33, 4000)
local result = compress(c, options, messages)
assert(result.success and result.compressedCount == 33, '33 small chunks should fit one request')
assert(#requests == 1 and archives == 0)
local prompt = requests[1].messages[2].content
for _, message in ipairs(messages) do assert(prompt:find(message.content, 1, true), 'selected history was clipped') end
local fit = U.fitMessagesToContext(requests[1].messages, requests[1].options, config)
assert(not fit.trimmed and fit.fittedTokens <= fit.budgetTokens)

-- Large stored memory must be budgeted after bounding, not included in static
-- prompts in its unbounded form. Only the memory sections may be clipped.
c, options = fixture(64000, 8000, string.rep('p', 120000), string.rep('s', 120000))
local emptyStatic = c:buildCompressionStaticPrompt('tool_calling')
assert(not emptyStatic:find(string.rep('p', 100), 1, true))
local parts = c:buildBoundedCompressionSections('core', '', options)
assert(parts.historyBudget > 20000, 'large raw memories incorrectly collapsed the history budget')
result = compress(c, options, history(12, 4000))
assert(result.success and result.compressedCount == 12)

-- Quoted placeholders are source data, not another template expansion. This
-- exact history shape triggered a real post-merge compression budget failure.
c, options = fixture(131072, 65536, string.rep('project', 3000), 'summary')
local literalHistory = 'SOURCE {{CURRENT_MEMORY}} {{CURRENT_PROJECT_MEMORY}} {{CURRENT_SESSION_SUMMARY}} {{HISTORY_TEXT}} {{LAST_ERROR}} END'
local literalCore = 'core quotes {{HISTORY_TEXT}} and {{CURRENT_PROJECT_MEMORY}}'
local expanded = c:buildCompressionPromptBody(literalCore, literalHistory, options)
assert(expanded:find(literalHistory, 1, true), 'history placeholders were recursively expanded')
assert(expanded:find(literalCore, 1, true), 'memory placeholders were recursively expanded')
result = compress(c, options, {{role='assistant',content=literalHistory}})
assert(result.success and #requests==1 and requests[1].messages[2].content:find(literalHistory,1,true))

-- Caller overrides and the provider's max_completion_tokens field use the same
-- output reserve as HTTP. Impossible configurations do not call or mutate memory.
c, options = fixture(64000, 8000)
result = compress(c, {max_tokens = 64000}, messages)
assert(not result.success and result.compressedCount == 0 and #requests == 0 and writes == 0 and archives == 0)
c.config.llmConfig.customOptions = {max_tokens = J.null, max_completion_tokens = 64000, auxiliaryOptions = {}}
result = compress(c, options, messages)
assert(not result.success and writes == 0 and archives == 0 and #requests == 0)

-- A tool call and all its results must fit together. Never exceed the budget
-- simply to reach the next boundary, and never archive a budget failure.
c, options = fixture(64000, 8000)
local pair = {
  {role = 'assistant', tool_calls = {{id = 'one', ['function'] = {name = 'read_file', arguments = '{}'}}}},
  {role = 'tool', tool_call_id = 'one', content = string.rep('x', 1000)},
  {role = 'assistant', content = 'next'},
}
local b = c:findCompressionBoundary(pair, pair, 100)
assert(b.compressedCount == 0)
b = c:findCompressionBoundary(pair, pair, c:estimateCompressionMessageTokens(pair[1], 0) + c:estimateCompressionMessageTokens(pair[2], 1))
assert(b.compressedCount == 2)
result = compress(c, options, {{role = 'assistant', content = string.rep('x', 400000)}})
assert(not result.success and #requests == 0 and writes == 0 and archives == 0)

-- A carried instruction consumes input space but does not count as reclaimed
-- decision context in a partial chunk.
local carried = {{role = 'user', content = string.rep('u', 20000)}}
for i = 1, 5 do carried[#carried + 1] = {role = 'assistant', content = string.rep('a', 8000)} end
b = c:findCompressionBoundary(carried, carried, 20000, 5500)
assert(b.compressedCount == 4 and b.carryMessageIndex == 0)

-- Preflight catches additional prompt expansion too; budget failures cannot
-- fall through to raw-archive recovery and advance history.
c, options = fixture(64000, 8000)
c.config.promptPack = {}
for key, value in pairs(M.DEFAULT_AGENT_PROMPT_PACK) do c.config.promptPack[key] = value end
c.config.promptPack.memoryCompressionBodyPrompt = '{{HISTORY_TEXT}}\n{{HISTORY_TEXT}}'
result = compress(c, options, history(40, 4000))
assert(not result.success and #requests == 0 and writes == 0 and archives == 0)

-- The target comes from the effective next decision request, not 50% of context.
c, options = fixture(64000, 40000)
messages = history(24, 4000)
result = compress(c, options, messages, {targetTokens = 12000}, 'default')
assert(result.success and result.compressedCount >= 12, 'automatic compaction regressed to one-message chunks')
assert(result.compressedCount < 24)

-- XML fallback must receive the same uncut history, and retries must fit too.
c, options = fixture(64000, 8000)
modelMode = 'xml'
result = compress(c, options, history(3, 1000))
assert(result.success and #requests == 2)
assert(requests[1].messages[2].content == requests[2].messages[2].content)
for _, request in ipairs(requests) do
  assert(not U.fitMessagesToContext(request.messages, request.options, c.config.llmConfig).trimmed)
end

-- Cancellation never writes or raw-archives, including after model completion.
c, options = fixture(64000, 8000)
modelMode = 'cancel'
result = compress(c, options, history(3, 1000), {stopToken = {stopped = false}})
assert(not result.success and writes == 0 and archives == 0)

-- Existing raw-archive recovery remains explicit for actual model failures.
c, options = fixture(64000, 8000)
modelMode = 'failure'
result = compress(c, options, history(3, 1000))
assert(result.success and result.fallbackArchived and archives == 1)

-- The HTTP path rejects impossible output/context combinations before transport.
c, options, config = fixture(64000, 64000)
local impossible = await(originalCall({{role = 'user', content = 'hello'}}, options, nil, config))
assert(not impossible.success and impossible.message:find('context budget'))
assert(U.getInputTokenBudget({{role = 'user'}}, options, config) == 0)

-- The exported storage-scope command uses the same full-compaction semantics:
-- a large history progresses beyond three requests and persists every chunk.
c, options, config = fixture(64000, 8000)
local scopeMessages, consolidated = history(200, 4000), 0
c.storage.readSessionState = function() return {messages = scopeMessages, lastConsolidatedIndex = 0} end
c.storage.writeSessionState = function(_, _, index) consolidated = index end
local constructor = M.MemoryCompressor.prototype.____constructor
M.MemoryCompressor.prototype.____constructor = function(self)
  self.config, self.storage, self.consecutiveFailures = c.config, c.storage, 0
end
local scoped = await(M.compactSessionMemoryScope({projectDir = 'fixture', llmConfig = config}))
M.MemoryCompressor.prototype.____constructor = constructor
assert(scoped.success and consolidated == #scopeMessages and #requests > 3)
print('Native Lua memory budget regressions passed (full history coverage, packing, provider options, tool boundaries, XML fallback, cancellation, raw archive, invalid output reserve).')

local V = require('Agent.Tool.Validation')
assert(V.validateAgentToolInput('write_file', {path='game.ts',new_str='content'}).success)
assert(not V.validateAgentToolInput('write_file', {path='game.ts',old_str='x',new_str='y'}).success)
assert(not V.validateAgentToolInput('edit_file', {path='game.ts',old_str='',new_str='content'}).success)
assert(V.validateAgentToolInput('edit_file', {path='game.ts',delete=true}).success)
assert(not V.validateAgentToolInput('edit_file', {path='game.ts',delete=true,new_str='x'}).success)
assert(V.validateAgentToolInput('grep_files', {}).success)
assert(V.validateAgentToolInput('spawn_agent', {}).success)
assert(not V.validateAgentToolInput('spawn_agent', {prompt='work',title='task',status='RUNNING'}).success)
local H = require('Agent.Runtime.HistoryProjection')
local function read(startLine,endLine,success)
 return {role='tool',name='read_file',content=J.encode({success=success,results={{path='game.ts',success=success,startLine=startLine,endLine=endLine,content=string.rep('X',350)}}})}
end
-- No range-based reads or failed results may disappear merely because the same file was read later.
local a,b=read(1,100,true),read(101,200,true)
local projected=H.projectMessagesForLLMContext({a,b})
assert(projected[1].content:find(string.rep('X',350),1,true))
local errorText=string.rep('prefix ',80)..'UNIQUE_ERROR_DETAIL_AT_END'
projected=H.projectMessagesForLLMContext({{role='tool',name='edit_file',content=J.encode({success=false,message=errorText})}})
assert(projected[1].content:find('UNIQUE_ERROR_DETAIL_AT_END',1,true))
print('Tool consolidation and lossless history regressions passed.')

-- The production estimator weights CJK differently from bytes. Clipping must
-- honor the requested budget even for tiny budgets and mixed UTF-8 content.
local D = require('Dora')
local originalEstimator = D.App.estimateTokens
D.App.estimateTokens = function(_, text)
  local tokens = 0
  for _, cp in utf8.codes(text) do tokens = tokens + (cp < 128 and .4 or 2) end
  return math.ceil(tokens)
end
for _, text in ipairs({string.rep('中', 1000), string.rep('🙂', 500), string.rep('abc中文🙂\n', 250), string.rep('abc', 1000)}) do
  for _, budget in ipairs({0, 1, 2, 3, 8, 99, 100, 500, 10000}) do
    local clipped = U.clipTextToTokenBudget(text, budget)
    assert(utf8.len(clipped), 'clipped text is not valid UTF-8')
    assert(D.App:estimateTokens(clipped) <= budget, 'clipping exceeded token budget')
    if D.App:estimateTokens(text) <= budget then assert(clipped == text, 'fitting text changed') end
  end
end
-- Stress stored Chinese memories and real chunk packing with strict clipping.
c, options, config = fixture(131072, 65536, string.rep('项目记忆中文🙂', 5000), string.rep('当前进度中文', 2500))
result = compress(c, options, {{role='user',content='保留约束'}, {role='assistant',content=string.rep('历史上下文中文', 1800)}})
assert(result.success and #requests == 1 and archives == 0)
fit = U.fitMessagesToContext(requests[1].messages, requests[1].options, config)
assert(not fit.trimmed and fit.originalTokens <= fit.budgetTokens, 'Chinese compression request exceeded budget')
D.App.estimateTokens = originalEstimator

-- Run the real write/edit/delete handlers and policy against an in-memory
-- checkpoint adapter. Documentation must not create or clear source-build debt.
D.Path = setmetatable({
  getExt = function(_, path) return path:match('%.([^./]+)$') or '' end,
  getFilename = function(_, path) return path:match('([^/]+)$') or path end,
}, {__call = function(_, ...) return table.concat({...}, '/') end})
local files, checkpoints = {}, 0
local tools = {
  inspectWorkspaceTextTarget = function(_, path) return {success=true,exists=files[path]~=nil,content=files[path] or ''} end,
  readFileRaw = function(_, path) return {success=files[path]~=nil,content=files[path]} end,
  applyFileChanges = function(_, _, changes)
    checkpoints = checkpoints + 1
    for _, change in ipairs(changes) do files[change.path] = change.content end
    return {success=true,checkpointId=checkpoints,checkpointSeq=checkpoints}
  end,
  deleteFile = function(_, _, path)
    if not files[path] then return {success=false,message='missing file'} end
    files[path]=nil;checkpoints=checkpoints+1
    return {success=true,checkpointed=true,checkpointId=checkpoints,checkpointSeq=checkpoints}
  end,
}
package.loaded['Agent.Tools'] = tools
package.loaded['Agent.Tool.VisionAnalysis'] = {}
local policy = require('Agent.Runtime.Policy')
local handlers = require('Agent.Tool.Handlers').AGENT_TOOL_HANDLERS
for _, path in ipairs({'AUDIT.md','docs/Guide.MD','notes.rst','README','LICENSE.txt','.agent/main/MEMORY.md'}) do
  assert(not policy.requiresAgentBuildForPath(path), path)
end
for _, path in ipairs({'init.ts','main.lua','data.txt','settings.json','image.png','README.ts'}) do
  assert(policy.requiresAgentBuildForPath(path), path)
end
local ctx = {workingDir='/fixture',taskId=1,workMode='code',workflow={}}
local function tool(name, input) local output=await(handlers[name](ctx,input)).output;assert(output.success, output.message);return output end
local checkpoint=tool('write_file',{path='AUDIT.md',new_str='first draft'}).checkpointId
assert(checkpoint and not ctx.workflow.unbuiltEdits)
tool('edit_file',{path='AUDIT.md',old_str='first',new_str='second'})
assert(not ctx.workflow.unbuiltEdits and not ctx.workflow.editedPathsSinceBuild)
tool('edit_file',{path='AUDIT.md',delete=true})
assert(not ctx.workflow.unbuiltEdits)
ctx.workflow={failedTestNeedsBuild=true,lastBuildSucceeded=false}
tool('write_file',{path='README.md',new_str='documentation'})
assert(ctx.workflow.failedTestNeedsBuild and not ctx.workflow.failedTestHasSourceEdit and ctx.workflow.lastBuildSucceeded==false)
tool('write_file',{path='init.ts',new_str='source v1'})
assert(ctx.workflow.unbuiltEdits and ctx.workflow.failedTestHasSourceEdit and ctx.workflow.editsSinceBuild==1)
tool('write_file',{path='FINAL.md',new_str='summary'})
assert(ctx.workflow.unbuiltEdits and ctx.workflow.editsSinceBuild==1 and #ctx.workflow.editedPathsSinceBuild==1)
ctx.workflow={}
tool('edit_file',{edits={{path='README.md',old_str='documentation',new_str='updated docs'},{path='init.ts',old_str='v1',new_str='v2'}}})
assert(ctx.workflow.unbuiltEdits and ctx.workflow.editsSinceBuild==1 and ctx.workflow.editedPathsSinceBuild[1]=='init.ts')
ctx.workflow={}
tool('edit_file',{path='init.ts',delete=true})
assert(ctx.workflow.unbuiltEdits and ctx.workflow.editsSinceBuild==1)
print('UTF-8 budget enforcement, Chinese compression packing, and document/source build-debt regressions passed.')
