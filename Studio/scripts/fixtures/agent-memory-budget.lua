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
