-- Studio Web entry lifecycle adapter. Loaded by the trusted command host;
-- not a sandbox and not intended to be resolved from uploaded project files.
local Dora = require("Dora")
local Struct = require("Utils").Struct
local entry = {}
local runId, current = 0, nil
local searchPaths = Dora.Content.searchPaths
local modules, routines = {}, {}

local function rememberHostState()
	modules, routines = {}, {}
	for name in pairs(package.loaded) do modules[name] = true end
	for _, routine in ipairs(Dora.Routine) do routines[routine] = true end
end
rememberHostState()

function entry.getCurrentEntryStatus()
	local status = {success = true, running = current ~= nil, runId = runId}
	if current then
		status.kind = current.runKind or "file"
		for _, key in ipairs({"entryName", "fileName", "workDir", "projectRoot"}) do
			status[key] = current[key]
		end
	end
	return status
end

function entry.allClear()
	-- Keep host routines; only routines created after project startup are owned.
	local removed = {}
	for _, routine in ipairs(Dora.Routine) do
		if current and not routines[routine] then removed[#removed + 1] = routine end
	end
	for _, routine in ipairs(removed) do Dora.Routine:remove(routine) end
	local unloaded = {}
	for name in pairs(package.loaded) do
		if current and not modules[name] then unloaded[#unloaded + 1] = name end
	end
	for _, name in ipairs(unloaded) do package.loaded[name] = nil end
	Dora.Director:cleanup()
	Dora.Entity:clear()
	Dora.Platformer.Data:clear()
	Dora.Platformer.UnitAction:clear()
	Dora.Audio:stopAll(0.2)
	Struct:clear()
	Dora.View.nearPlaneDistance = 0.1
	Dora.View.farPlaneDistance = 10000
	Dora.View.fieldOfView = 45
	Dora.View.postEffect = nil
	Dora.View.scale = 1
	Dora.Director.clearColor = Dora.Color(0xff1a1a1a)
	Dora.Content.searchPaths = searchPaths
	current = nil
end

function entry.stop()
	if not current then return false end
	entry.allClear()
	return true
end

function entry.enterEntryAsync(descriptor)
	assert(not current, "Dora entry runtime is already running")
	assert(type(descriptor) == "table" and type(descriptor.fileName) == "string", "missing entry file")
	runId = runId + 1 -- EntryLease predicts this before the first yield.
	current = descriptor
	rememberHostState()
	Dora.App.idled = false
	local ok, message = xpcall(function()
		Dora.sleep()
		local workDir = descriptor.workDir or Dora.Path:getPath(descriptor.fileName)
		Dora.Content:insertSearchPath(1, workDir)
		local scriptPath = Dora.Path(workDir, "Script")
		if Dora.Content:exist(scriptPath) then Dora.Content:insertSearchPath(1, scriptPath) end
		local result = require(descriptor.fileName)
		if type(result) == "function" then result() end
	end, debug.traceback)
	if not ok then
		local cleaned, cleanupError = pcall(entry.allClear)
		if not cleaned then message = tostring(message) .. "; cleanup failed: " .. tostring(cleanupError) end
		return false, message
	end
	return true
end

return entry
