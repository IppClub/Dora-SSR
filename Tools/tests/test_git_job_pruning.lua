-- Run from the repository root with Lua 5.4+.
local file = assert(io.open('Assets/Script/Dev/WebServer.lua'))
local source = file:read('*a')
file:close()
local first = assert(source:find('local GitJobs =', 1, true))
local last = assert(source:find('local gitInvalidRepoPath', first, true))
local code = source:sub(first, last - 1) .. [[
GitJobs[1] = {status={state='done'}, updatedAt=1399}
GitJobs[2] = {status={state='error'}, updatedAt=1399}
GitJobs[3] = {status={state='canceled'}, updatedAt=1399}
GitJobs[4] = {status={state='running'}, updatedAt=1}
GitJobs[5] = {status={state='queued'}, updatedAt=1}
GitJobs[6] = {status={state='done'}, updatedAt=1400}
GitJobs[7] = {status={state='done'}, updatedAt=1999}
GitJobs[8] = {status={state='done'}}
GitJobs[9] = {updatedAt=1}
gitPruneJobs()
for i=1,3 do assert(GitJobs[i] == nil, 'expired terminal job retained') end
for i=4,9 do assert(GitJobs[i] ~= nil, 'live or fresh job removed') end
]]
local env = setmetatable({os={time=function() return 2000 end}}, {__index=_G})
assert(load(code, 'production git pruning', 't', env))()
assert(source:find('gitStartJob = function.-gitPruneJobs%(%)'), 'pruning must run when starting jobs')
print('Git job pruning: 9 state and TTL boundary cases passed')
