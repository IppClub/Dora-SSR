-- Execute the checked-in production Lua, including Lua/JS truthiness boundaries.
local root = arg[1] or '.'
package.path = root .. '/Assets/Script/Lib/?.lua;' .. package.path
local new = require('lualib_bundle').__TS__New
local StreamUpdates = require('Agent.Runtime.StreamUpdates').StreamUpdates
local calls = {}
local updates = new(StreamUpdates, function(session, task, step, value)
 calls[#calls + 1] = {session = session, task = task, step = step, value = value}
end)
updates:update(1, 10, 1, {content = 'answer'}, 0)
assert(#calls == 1)
updates:update(1, 10, 1, {content = '', reasoningContent = 'reasoning'}, 0.01)
assert(#calls == 1)
updates:flushDue(0.11)
assert(#calls == 2 and calls[2].value.content == 'answer' and calls[2].value.reasoningContent == 'reasoning')
updates:update(1, 10, 1, {content = 'latest'}, 0.12)
updates:clear(1, 10, 0.13)
assert(#calls == 3 and calls[3].value.content == 'latest' and not updates:hasPending())
updates:flushDue(1)
assert(#calls == 3)
updates:update(1, 11, 1, {content = 'new'}, 2)
updates:update(1, 11, 1, {content = 'pending'}, 2.01)
updates:finish(1, 11, 1)
updates:flushDue(3)
assert(#calls == 4 and not updates:hasPending())
print('PASS: production Lua streaming latency, mixed text/reasoning, terminal flush and cleanup')
