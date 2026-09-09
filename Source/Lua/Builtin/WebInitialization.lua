-- Minimal Web Player runtime helpers. Keep this file limited to APIs present
-- in LuaBindingWeb.pkg so the profile cannot silently grow native features.
local table_insert <const> = table.insert
local table_remove <const> = table.remove
local coroutine_create <const> = coroutine.create
local coroutine_resume <const> = coroutine.resume
local coroutine_close <const> = coroutine.close
local coroutine_status <const> = coroutine.status
local coroutine_yield <const> = coroutine.yield
local xpcall <const> = xpcall
local Dora <const> = Dora

Dora.App = Dora.Application()
Dora.Application = nil
Dora.Keyboard = Dora.Keyboard()
Dora.Controller = Dora.Controller()
Dora.Audio = Dora.Audio()
Dora.Content = Dora.Content()
Dora.Director = Dora.Director()

os.clock = nil
os.execute = nil
os.exit = nil
os.remove = nil
os.rename = nil
os.tmpname = nil
package.path = "?.lua"

local function traceback(err)
	Dora.Log("Error", debug.traceback(err, 2))
end

local function wait(cond)
	repeat
		coroutine_yield(false)
	until cond()
end

local function once(work)
	return coroutine_create(function(...)
		xpcall(work, traceback, ...)
		coroutine_yield(false)
		return true
	end)
end

local Routine = {
	remove = function(self, routine)
		for i = 1, #self do
			if self[i] == routine then
				local status = coroutine_status(routine)
				if status == "dead" or status == "suspended" then
					coroutine_close(routine)
				end
				self[i] = false
				return true
			end
		end
		return false
	end,
	clear = function(self)
		while #self > 0 do
			local routine = table_remove(self)
			local status = coroutine_status(routine)
			if status == "dead" or status == "suspended" then
				coroutine_close(routine)
			end
		end
	end,
}

setmetatable(Routine, {
	__call = function(self, routine)
		table_insert(self, routine)
		return routine
	end,
})

Dora.Director.postScheduler:schedule(function()
	local i, count = 1, #Routine
	while i <= count do
		local routine = Routine[i]
		local success, result = false, true
		if routine then
			success, result = coroutine_resume(routine)
			if not success then
				coroutine_close(routine)
				Dora.Log("Error", result)
			end
		end
		if (success and result) or not success then
			Routine[i] = Routine[count]
			table_remove(Routine, count)
			i = i - 1
			count = count - 1
		end
		i = i + 1
	end
	return false
end)

Dora.Routine = Routine
Dora.wait = wait
Dora.thread = function(work)
	return Routine(once(work))
end

local Content = getmetatable(Dora.Content)
local Content_loadAsync = Content.loadAsync
Content.loadAsync = function(self, filename)
	local _, mainThread = coroutine.running()
	assert(not mainThread, "Content.loadAsync should be run in a thread")
	local loadedData
	local done = false
	Content_loadAsync(self, filename, function(data)
		loadedData = data
		done = true
	end)
	wait(function()
		return done
	end)
	return loadedData
end

-- Game chunks use `_ENV = Dora`; mirror the standard Lua globals into that
-- environment after the minimal helpers are installed.
Dora.Dora = Dora
for key, value in pairs(_G) do
	if Dora[key] == nil then
		Dora[key] = value
	end
end
setmetatable(package.loaded, {__index = Dora})
