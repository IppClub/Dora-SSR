-- Stable native Web IDE entry. Runtime generations change only while idle.
local Dora = require("Dora")
local Content, Path, App = Dora.Content, Dora.Path, Dora.App
local Host = {}
local current, sources, lastFailure
local generation, leases, checking = 0, 0, false
local lastCheck = -math.huge
local automatic = true
local failedSources, pendingFiles
local proxies = {}
local failedBuilds = {}
local taskEntries = {
	sendPrompt = true, sendLocalPrompt = true, continuePrompt = true,
	resendPrompt = true, respondQuestionnaire = true, cancelQuestionnaire = true,
	finishSubSessionHandoff = true,
}
-- These services own database initialization or trusted host subscriptions.
-- Changes to their implementation need a host restart, not an implicit migration.
local services = {
	["Agent.Storage.Database"] = true,
	["Agent.Runtime.SessionEvents"] = true,
	["Agent.Runtime.TaskAdmission"] = true,
}
local function canonical(name) return name:gsub("/", ".") end
local function agentModule(name) return type(name) == "string" and name:match("^Agent[./]") ~= nil end
local function readSources()
	local root = Path(Content.assetPath, "Script", "Lib", "Agent")
	local result = {}
	for _, file in ipairs(Content:getAllFiles(root)) do
		if Path:getExt(file) == "lua" then
			local text = Content:load(Path(root, file))
			if not text then error("Cannot read Agent module: " .. file) end
			result[file] = text
		end
	end
	if not result["Session.lua"] then error("Agent Session.lua is missing") end
	return result
end
local function changedFiles(nextSources)
	local changed = {}
	for file, text in pairs(nextSources) do
		if not sources or sources[file] ~= text then changed[#changed + 1] = file end
	end
	for file in pairs(sources or {}) do
		if not nextSources[file] then changed[#changed + 1] = file end
	end
	table.sort(changed)
	return changed
end
local function idle()
	return leases == 0 and (not current or current.isRuntimeIdle())
end
local function result(success, fields)
	fields = fields or {}
	fields.success, fields.generation, fields.busy = success, generation, not idle()
	return fields
end
local function initialize()
	if current then return end
	-- Capture the code associated with this initial generation before loading it.
	local initialSources = readSources()
	current = require("Agent.Session")
	sources, generation = initialSources, 1
end
function Host.reload()
	initialize()
	if checking then return result(false, {code = "RELOAD_IN_PROGRESS"}) end
	if not idle() then return result(false, {code = "AGENT_BUSY", pending = true, message = "Agent work is still active; reload deferred"}) end
	if next(failedBuilds) then return result(false, {code = "AGENT_BUILD_FAILED", pending = true, message = "Finish a successful Agent source build before reloading"}) end
	checking = true
	local saved = {}
	local nextSources
	local ok, err = pcall(function()
		nextSources = readSources()
		for _, file in ipairs(changedFiles(nextSources)) do
			local name = "Agent." .. file:gsub("%.lua$", ""):gsub("/", ".")
			if services[name] then error("Long-lived Agent service changed; host restart required: " .. name) end
		end
		-- Validate the entire candidate before executing any module initializers.
		for file, text in pairs(nextSources) do
			local compiled, failure = load(text, "@Agent/" .. file, "t")
			if not compiled then error(failure) end
		end
		for name, value in pairs(package.loaded) do
			if agentModule(name) then saved[name] = value end
		end
		for name in pairs(saved) do
			if not services[canonical(name)] then package.loaded[name] = nil end
		end
		local candidate = require("Agent.Session")
		local tools = require("Agent.Tools")
		local registry = require("Agent.Tool.Registry")
		assert(type(candidate.isRuntimeIdle) == "function" and candidate.isRuntimeIdle(), "Candidate runtime is not idle")
		assert(type(candidate.sendPrompt) == "function" and type(tools.build) == "function", "Candidate Agent entry is incomplete")
		assert(registry.getToolDefinition("build").handler, "Candidate build handler is missing")
		current, sources = candidate, nextSources
		generation = generation + 1
	end)
	if not ok then
		-- A require failure can leave new dependencies cached. Restore the whole
		-- previous graph, including removed aliases, before accepting another task.
		if next(saved) then
			local remove = {}
			for name in pairs(package.loaded) do if agentModule(name) then remove[#remove + 1] = name end end
			for _, name in ipairs(remove) do package.loaded[name] = nil end
			for name, value in pairs(saved) do package.loaded[name] = value end
		end
		lastFailure = tostring(err)
	else lastFailure, failedSources, pendingFiles = nil, nil, nil end
	checking = false
	lastCheck = App.runningTime
	return result(ok, {code = not ok and "AGENT_RELOAD_FAILED" or nil, message = lastFailure})
end
function Host.checkUpdates(force)
	initialize()
	if checking or not automatic then return result(true) end
	if not force and App.runningTime - lastCheck < 2 then return result(true) end
	lastCheck = App.runningTime
	local ok, candidate = pcall(readSources)
	if not ok then lastFailure = tostring(candidate); return result(false, {message = lastFailure}) end
	local changed = changedFiles(candidate)
	pendingFiles = #changed > 0 and changed or nil
	if #changed == 0 then
		failedSources, lastFailure = nil, nil
		return result(true, {pending = false})
	end
	if not idle() then return result(true, {pending = true, changedFiles = changed}) end
	if next(failedBuilds) then return result(false, {pending = true, code = "AGENT_BUILD_FAILED"}) end
	-- Don't repeatedly execute the same broken candidate on every UI poll.
	if lastFailure and failedSources then
		local same = true
		for k, v in pairs(candidate) do if failedSources[k] ~= v then same = false; break end end
		for k in pairs(failedSources) do if candidate[k] == nil then same = false; break end end
		if same then return result(false, {pending = true, message = lastFailure}) end
	end
	local reloaded = Host.reload()
	failedSources = not reloaded.success and candidate or nil
	return reloaded
end
function Host.status()
	Host.checkUpdates()
	local blocked = {}
	for path in pairs(failedBuilds) do blocked[#blocked + 1] = path end
	table.sort(blocked)
	return result(true, {automatic = automatic, pending = pendingFiles ~= nil, changedFiles = pendingFiles, lastFailure = lastFailure, failedBuildPaths = #blocked > 0 and blocked or nil})
end
function Host.setAutomatic(enabled)
	automatic = enabled == true
	lastCheck = -math.huge
	return Host.status()
end
-- Synchronous APIs and promise-returning tools share this entry. Scheduled
-- HTTP command/preview bodies use acquire() for their entire yielding lifetime.
function Host.acquire(force)
	Host.checkUpdates(force ~= false)
	leases = leases + 1
	local released = false
	return function()
		if not released then leases = leases - 1; released = true end
	end
end
-- A multi-file compiler request is one source-update boundary. Failed batches
-- must not expose only their successfully emitted files as a new generation.
function Host.holdSourceUpdate(path)
	local root = Path(Content.assetPath, "Script", "Lib", "Agent")
	local target = type(path) == "string" and (Content:isAbsolutePath(path) and Path(path) or Content:getFullPath(path)) or ""
	local function covers(parent, child) return parent == child or child:sub(1, #parent + 1) == parent .. "/" end
	if target == "" or not (covers(root, target) or covers(target, root)) then return function() end end
	leases = leases + 1
	local released = false
	return function(success)
		if released then return end
		released = true
		leases = leases - 1
		if success then
			for failed in pairs(failedBuilds) do if covers(target, failed) then failedBuilds[failed] = nil end end
		else failedBuilds[target] = true end
		lastCheck = -math.huge
	end
end
function Host.proxy(name)
	if proxies[name] then return proxies[name] end
	local proxy = setmetatable({}, {__index = function(_, key)
		return function(...)
			-- A new task checks immediately; read-only UI polling is throttled.
			local release = Host.acquire(name == "Agent.Session" and taskEntries[key] == true)
			local args = table.pack(...)
			local values = table.pack(pcall(function()
				local module = name == "Agent.Session" and current or require(name)
				return module[key](table.unpack(args, 1, args.n))
			end))
			if not values[1] then release(); error(values[2]) end
			local value = values[2]
			if type(value) == "table" and type(value.addCallbacks) == "function" then
				value:addCallbacks(function() release() end, function() release() end)
			else release() end
			return table.unpack(values, 2, values.n)
		end
	end})
	proxies[name] = proxy
	return proxy
end
return Host
