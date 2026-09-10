-- Minimal Web Player runtime helpers. Keep this file limited to APIs present
-- in LuaBindingWeb.pkg so the profile cannot silently grow native features.
local table_insert <const> = table.insert
local table_remove <const> = table.remove
local type <const> = type
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
Dora.Content:insertSearchPath(1, "/builtin")
Dora.Director = Dora.Director()
Dora.View = Dora.View()
Dora.DB = Dora.DB()
Dora.HttpClient = Dora.HttpClient()
Dora.Shader = Dora.Shader()
Dora.json = require("json")
if package.loaded.yue then Dora.yue = package.loaded.yue end
-- TypeScript/Teal generated code calls the named vector methods instead of
-- Lua operators. Keep the same API as the native initialization helpers.
Dora.Vec2.add = function(self, value) return self + value end
Dora.Vec2.sub = function(self, value) return self - value end
Dora.Vec2.mul = function(self, value) return self * value end
Dora.Vec2.div = function(self, value) return self / value end
Dora.Vec2.equals = function(self, value) return self == value end
Dora.Size.equals = function(self, value) return self == value end
Dora.Size.mul = function(self, value) return self * value end
Dora.Rect.equals = function(self, value) return self == value end
if Dora.Content:exist("/builtin/Font/sarasa-mono-sc-regular.ttf") then
	Dora.Director.systemScheduler:schedule(function()
		Dora.ImGui.SetDefaultFont("/builtin/Font/sarasa-mono-sc-regular.ttf", 20)
		return true
	end)
end
if Dora.Platformer then
	Dora.Platformer.Decision.AI = Dora.Platformer.Decision.AI()
	Dora.Platformer.Data = Dora.Platformer.Data()
end

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

local function loop(work)
	return coroutine_create(function(...)
		local stopped = false
		repeat
			local success, result = xpcall(work, traceback, ...)
			stopped = not success or result
			coroutine_yield(false)
		until stopped
		return true
	end)
end

local function cycle(duration, work)
	local time = 0
	work(0)
	coroutine_yield(false)
	while true do
		time = time + Dora.App.deltaTime
		if time < duration then
			work(time / duration)
			coroutine_yield(false)
		else
			work(1)
			coroutine_yield(false)
			return
		end
	end
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
Dora.once = once
Dora.loop = loop
Dora.cycle = cycle
Dora.thread = function(work)
	return Routine(once(work))
end
Dora.threadLoop = function(work)
	return Routine(loop(work))
end
Dora.sleep = function(duration)
	if duration then
		local time = 0
		repeat
			coroutine_yield(false)
			time = time + Dora.App.deltaTime
		until time >= duration
	else
		coroutine_yield(false)
	end
end

Dora.Node.once = function(self, work)
	self:schedule(once(work))
end
Dora.Node.loop = function(self, work)
	self:schedule(loop(work))
end

do
	local Action = Dora.Action
	local Node = Dora.Node
	local Node_runAction = Node.runAction
	Node.runAction = function(self, action, repeatAction)
		return Node_runAction(self, type(action) == "table" and Action(action) or action, repeatAction)
	end
	local Node_perform = Node.perform
	Node.perform = function(self, action, repeatAction)
		return Node_perform(self, type(action) == "table" and Action(action) or action, repeatAction)
	end
	local function commonEvent(nodeClass, name)
		nodeClass["on" .. name] = function(self, callback) self:slot(name, callback) end
	end
	for _, name in ipairs({"Enter", "Exit", "Cleanup", "ActionEnd"}) do commonEvent(Node, name) end
	local function touchEvent(name)
		Node["on" .. name] = function(self, callback)
			self.touchEnabled = true
			self:slot(name, callback)
		end
	end
	for _, name in ipairs({"TapFilter", "TapBegan", "TapEnded", "Tapped", "TapMoved", "MouseMove", "MouseWheel", "Gesture"}) do touchEvent(name) end
	local function keyboardEvent(name)
		Node["on" .. name] = function(self, callback)
			self.keyboardEnabled = true
			self:slot(name, callback)
		end
	end
	for _, name in ipairs({"KeyDown", "KeyUp", "KeyPressed"}) do keyboardEvent(name) end
	for _, name in ipairs({"AttachIME", "DetachIME", "TextInput", "TextEditing"}) do commonEvent(Node, name) end
	local function controllerEvent(name)
		Node["on" .. name] = function(self, callback)
			self.controllerEnabled = true
			self:slot(name, callback)
		end
	end
	for _, name in ipairs({"ButtonDown", "ButtonUp", "ButtonPressed", "Axis"}) do controllerEvent(name) end
	for _, name in ipairs({"AppEvent", "AppChange", "AppWS"}) do
		Node["on" .. name] = function(self, callback) self:gslot(name, callback) end
	end
	for _, event in ipairs({{Dora.Particle, "Finished"}, {Dora.Playable, "AnimationEnd"},
		{Dora.Body, "BodyEnter"}, {Dora.Body, "BodyLeave"}, {Dora.AlignNode, "AlignLayout"}, {Dora.EffekNode, "EffekEnd"}}) do
		if event[1] then commonEvent(event[1], event[2]) end
	end
	if Dora.Body then
		for _, name in ipairs({"ContactStart", "ContactEnd"}) do
			Dora.Body["on" .. name] = function(self, callback)
				self.receivingContact = true
				self:slot(name, callback)
			end
		end
	end
	for _, actionName in ipairs({
		"X", "Y", "Z", "ScaleX", "ScaleY", "SkewX", "SkewY", "Angle", "AngleX", "AngleY",
		"Width", "Height", "AnchorX", "AnchorY", "Opacity", "Tint", "Roll", "Hide", "Show",
		"Delay", "Event", "Spawn", "Sequence", "Frame",
	}) do
		Dora[actionName] = function(...) return {actionName, ...} end
	end
	Dora.Move = function(duration, start, stop, ease)
		return Dora.Spawn(Dora.X(duration, start.x, stop.x, ease), Dora.Y(duration, start.y, stop.y, ease))
	end
	Dora.Scale = function(duration, start, stop, ease)
		return Dora.Spawn(Dora.ScaleX(duration, start, stop, ease), Dora.ScaleY(duration, start, stop, ease))
	end
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

Dora.Path.getScriptPath = function(_, filename)
	if not filename then return nil end
	if filename:match("[\\/]") then
		return Dora.Path:getPath(filename)
	end
	return Dora.Path:getPath(filename:gsub("%.", "/"))
end

do
	local Array = Dora.Array
	local Array_index = Array.__index
	local Array_get = Array.get
	Array.__index = function(self, key)
		if type(key) == "number" then return Array_get(self, key) end
		return Array_index(self, key)
	end
	local Array_newindex = Array.__newindex
	local Array_set = Array.set
	Array.__newindex = function(self, key, value)
		if type(key) == "number" then Array_set(self, key, value) else Array_newindex(self, key, value) end
	end
	Array.__len = function(self) return self.count end
end

do
	local Dictionary = Dora.Dictionary
	local Dictionary_index = Dictionary.__index
	local Dictionary_get = Dictionary.get
	Dictionary.__index = function(self, key)
		local item = Dictionary_get(self, key)
		if item ~= nil then return item end
		return Dictionary_index(self, key)
	end
	Dictionary.__newindex = Dictionary.set
	Dictionary.__len = function(self) return self.count end
end

if Dora.Entity then
	local Entity = Dora.Entity
	local Entity_create = Entity[2]
	local Entity_cache = {}
	local Entity_components = {}
	local function getComponentIndex(key)
		local index = Entity_components[key]
		if index == nil then
			index = Entity:getComIndex(key)
			Entity_components[key] = index
		end
		return index
	end
	local function tryGetComponentIndex(key)
		local index = Entity_components[key]
		if index == nil then
			index = Entity:tryGetComIndex(key)
			if index > 0 then
				Entity_components[key] = index
			end
		end
		return index
	end
	Entity[2] = function(cls, values)
		local components = {}
		for key, value in pairs(values) do
			components[getComponentIndex(key)] = value
		end
		local entity = Entity_create(cls, components)
		Entity_cache[entity.index + 1] = entity
		return entity
	end
	local Entity_clear = Entity.clear
	Entity.clear = function(cls)
		Entity_cache = {}
		Entity_components = {}
		Entity_clear(cls)
	end
	local Entity_getOld = Entity.getOld
	local oldValues
	oldValues = setmetatable({false}, {
		__mode = "v",
		__index = function(_, key)
			return Entity_getOld(oldValues[1], tryGetComponentIndex(key))
		end,
		__newindex = function()
			error("Can not assign value cache.")
		end,
	})
	local Entity_index = Entity.__index
	local Entity_get = Entity.get
	Entity.__index = function(self, key)
		if key == "oldValues" then
			rawset(oldValues, 1, self)
			return oldValues
		end
		local item = Entity_get(self, tryGetComponentIndex(key))
		if item ~= nil then return item end
		return Entity_index(self, key)
	end
	Entity.get = function(self, key)
		local item = Entity_get(self, tryGetComponentIndex(key))
		if item ~= nil then return item end
		return Entity_index(self, key)
	end
	local Entity_set = Entity.set
	Entity.__newindex = function(self, key, value)
		Entity_set(self, getComponentIndex(key), value)
	end
	Entity.set = function(self, key, value)
		Entity_set(self, getComponentIndex(key), value)
	end
end

if Dora.Platformer then
	local UnitAction = Dora.Platformer.UnitAction
	local UnitAction_add = UnitAction.add
	local function dummy() return true end
	UnitAction.add = function(self, name, params)
		return UnitAction_add(self, name, params.priority, params.reaction,
			params.recovery, params.queued or false, params.available or dummy,
			params.create, params.stop or dummy)
	end
	local Blackboard = Dora.Platformer.Behavior.Blackboard
	local Blackboard_index = Blackboard.__index
	local Blackboard_get = Blackboard.get
	Blackboard.__index = function(self, key)
		local item = Blackboard_get(self, key)
		if item ~= nil then return item end
		return Blackboard_index(self, key)
	end
	Blackboard.__newindex = Blackboard.set
end

-- Coroutine signatures match native Dora rather than raw callback bindings.
do
	local Content = getmetatable(Dora.Content)
	local wait = Dora.wait
	local unpack = table.unpack
	local Content_loadExcelAsync = Content.loadExcelAsync
	Content.loadExcelAsync = function(self, filename, sheets)
		local _, mainThread = coroutine.running()
		assert(not mainThread, "Content.loadExcelAsync should be run in a thread")
		local loadedData
		local done = false
		if sheets then
			Content_loadExcelAsync(self, filename, sheets, function(data)
				loadedData = data
				done = true
			end)
		else
			Content_loadExcelAsync(self, filename, function(data)
				loadedData = data
				done = true
			end)
		end
		wait(function()
			return done
		end)
		return loadedData
	end

	local Content_saveAsync = Content.saveAsync
	Content.saveAsync = function(self, filename, content)
		local _, mainThread = coroutine.running()
		assert(not mainThread, "Content.saveAsync should be run in a thread")
		local result = nil
		local done = false
		Content_saveAsync(self, filename, content, function(success)
			result = success
			done = true
		end)
		wait(function()
			return done
		end)
		return result
	end

	local Content_copyAsync = Content.copyAsync
	Content.copyAsync = function(self, src, dst)
		local _, mainThread = coroutine.running()
		assert(not mainThread, "Content.copyAsync should be run in a thread")
		local result = nil
		local done = false
		Content_copyAsync(self, src, dst, function(success)
			result = success
			done = true
		end)
		wait(function()
			return done
		end)
		return result
	end

	local Content_zipAsync = Content.zipAsync
	Content.zipAsync = function(self, folderPath, zipFile, filter)
		local _, mainThread = coroutine.running()
		assert(not mainThread, "Content.zipAsync should be run in a thread")
		filter = filter or function() return true end
		local result
		local done = false
		Content_zipAsync(self, folderPath, zipFile, filter, function(success)
			result = success
			done = true
		end)
		wait(function()
			return done
		end)
		return result
	end

	local Content_unzipAsync = Content.unzipAsync
	Content.unzipAsync = function(self, zipFile, folderPath, filter, maxBytes, maxFiles)
		local _, mainThread = coroutine.running()
		assert(not mainThread, "Content.unzipAsync should be run in a thread")
		filter = filter or function() return true end
		local result
		local done = false
		Content_unzipAsync(self, zipFile, folderPath, filter, function(success)
			result = success
			done = true
		end, maxBytes or 0, maxFiles or 0)
		wait(function()
			return done
		end)
		return result
	end

	local Content_glob = Content.glob
	local Dictionary = Dora.Dictionary
	Content.glob = function(self, path, globs, extensionLevels)
		local dict = Dictionary()
		if extensionLevels then
			for k, v in pairs(extensionLevels) do
				dict[k] = v
			end
		end
		return Content_glob(self, path, globs, dict)
	end

	local Content_searchFilesAsync = Content.searchFilesAsync
	Content.searchFilesAsync = function(self, path, exts, extensionLevels, excludes, pattern, useRegex, caseSensitive, includeContent, contentWindow, callback)
		local _, mainThread = coroutine.running()
		assert(not mainThread, "Content.searchFilesAsync should be run in a thread")
		if contentWindow == nil then
			contentWindow = 0
		end
		if includeContent == nil then
			includeContent = false
		end
		if caseSensitive == nil then
			caseSensitive = false
		end
		if useRegex == nil then
			useRegex = false
		end
		local results = {}
		local done = false
		local stopped = false
		Content_searchFilesAsync(self, path, exts, extensionLevels, excludes, pattern, useRegex, caseSensitive, includeContent, contentWindow, function(result)
			if stopped then
				return false
			end
			if result == nil then
				done = true
				return false
			end
			results[#results + 1] = result
			if callback then
				if callback(result) then
					done = true
					stopped = true
					return true
				end
			end
			return false
		end)
		wait(function()
			return done
		end)
		return results
	end

	local RenderTarget = Dora.RenderTarget
	local RenderTarget_saveAsync = RenderTarget.saveAsync
	RenderTarget.saveAsync = function(self, filename)
		local _, mainThread = coroutine.running()
		assert(not mainThread, "RenderTarget.saveAsync should be run in a thread")
		local saved = false
		local done = false
		RenderTarget_saveAsync(self, filename, function(result)
			saved = result
			done = true
		end)
		wait(function()
			return done
		end)
		return saved
	end

	local DB = getmetatable(Dora.DB)
	local DB_queryAsync = DB.queryAsync
	DB.queryAsync = function(self, ...)
		local _, mainThread = coroutine.running()
		assert(not mainThread, "DB.queryAsync should be run in a thread")
		local result
		local args = {
			...
		}
		local done = false
		table_insert(args, 1, function(data)
			result = data
			done = true
		end)
		DB_queryAsync(self, unpack(args))
		wait(function()
			return done
		end)
		return result
	end

	local DB_insertAsync = DB.insertAsync
	DB.insertAsync = function(self, ...)
		local _, mainThread = coroutine.running()
		assert(not mainThread, "DB.insertAsync should be run in a thread")
		local result
		local args = {
			...
		}
		local done = false
		table_insert(args, function(res)
			result = res
			done = true
		end)
		DB_insertAsync(self, unpack(args))
		wait(function()
			return done
		end)
		return result
	end

	local DB_execAsync = DB.execAsync
	DB.execAsync = function(self, ...)
		local _, mainThread = coroutine.running()
		assert(not mainThread, "DB.execAsync should be run in a thread")
		local result
		local args = {
			...
		}
		local done = false
		table_insert(args, function(res)
			result = res
			done = true
		end)
		DB_execAsync(self, unpack(args))
		wait(function()
			return done
		end)
		return result
	end

	local DB_transactionAsync = DB.transactionAsync
	DB.transactionAsync = function(self, ...)
		local _, mainThread = coroutine.running()
		assert(not mainThread, "DB.transactionAsync should be run in a thread")
		local result
		local done = false
		local args = {
			...
		}
		table_insert(args, function(data)
			result = data
			done = true
		end)
		DB_transactionAsync(self, unpack(args))
		wait(function()
			return done
		end)
		return result
	end

	local HttpClient = getmetatable(Dora.HttpClient)
	local HttpClient_downloadAsync = HttpClient.downloadAsync
	HttpClient.download = HttpClient_downloadAsync
	HttpClient.downloadAsync = function(self, url, filePath, timeout, progress)
		local _, mainThread = coroutine.running()
		assert(not mainThread, "HttpClient.downloadAsync should be run in a thread")
		timeout = timeout or 30
		local failed = false
		local done = false
		HttpClient_downloadAsync(self, url, filePath, timeout, function(interrupted, current, total)
			if interrupted then
				failed = true
			else
				if progress then
					failed = progress(current, total)
				end
				done = current == total
			end
			return failed
		end)
		wait(function()
			return done or failed
		end)
		return not failed
	end

	local HttpClient_postAsync = HttpClient.postAsync
	HttpClient.post = HttpClient_postAsync
	HttpClient.postAsync = function(self, url, ...)
		local args = {...}
		if #args < 4 and type(args[#args]) ~= "number" then
			args[#args + 1] = 5
		end
		local _, mainThread = coroutine.running()
		assert(not mainThread, "HttpClient.postAsync should be run in a thread")
		local result = nil
		local done = false
		args[#args + 1] = function(data)
			result = data
			done = true
		end
		HttpClient_postAsync(self, url, unpack(args))
		wait(function()
			return done
		end)
		return result
	end

	local HttpClient_getAsync = HttpClient.getAsync
	HttpClient.get = HttpClient_getAsync
	HttpClient.getAsync = function(self, url, timeout)
		local _, mainThread = coroutine.running()
		assert(not mainThread, "HttpClient.getAsync should be run in a thread")
		timeout = timeout or 5
		local result = nil
		local done = false
		HttpClient_getAsync(self, url, timeout, function(data)
			result = data
			done = true
		end)
		wait(function()
			return done
		end)
		return result
	end

end

-- ShaderCompiler

do
	local Shader = getmetatable(Dora.Shader)
	local Shader_compile = Shader.compile
	Shader.compile = function(self, sourceFile, targetFile, stageName)
		local err = Shader_compile(self, sourceFile, targetFile, stageName)
		if err == "" then
			return true
		else
			return false, err
		end
	end

	local Shader_compileAsync = Shader.compileAsync
	Shader.compileAsync = function(self, sourceFile, targetFile, stageName)
		local _, mainThread = coroutine.running()
		assert(not mainThread, "Shader.compileAsync should be run in a thread")
		local err
		local done = false
		Shader_compileAsync(self, sourceFile, targetFile, stageName, function(e)
			err = e
			done = true
		end)
		wait(function()
			return done
		end)
		if err == "" then
			return true
		else
			return false, err
		end
	end
end

-- to string debugging helper
do
	Dora.Vec2.__tostring = function(self)
		return "Vec2(" .. tostring(self.x) .. ", " .. tostring(self.y) .. ")"
	end

	Dora.Rect.__tostring = function(self)
		return "Rect("
			.. tostring(self.x) .. ", "
			.. tostring(self.y) .. ", "
			.. tostring(self.width) .. ", "
			.. tostring(self.height) .. ")"
	end

	Dora.Size.__tostring = function(self)
		return "Size(" .. tostring(self.width) .. ", " .. tostring(self.height) .. ")"
	end

	Dora.Color.__tostring = function(self)
		return "Color(" .. string.format("0x%x", self:toARGB()) .. ")"
	end

	Dora.Color3.__tostring = function(self)
		return "Color3(" .. string.format("0x%x", self:toRGB()) .. ")"
	end
end

-- Dora json wrapper
do
	local json = Dora.json
	local jsonDecode = json.decode
	json.decode = function(str, maxdepth, allowcomment)
		local success, result = pcall(jsonDecode, str, maxdepth, allowcomment)
		if success then
			return result
		else
			return nil, result
		end
	end

	local jsonEncode = json.encode
	json.encode = function(obj, format, empty_as_array, num_as_str, maxdepth)
		local success, result = pcall(jsonEncode, obj, format, empty_as_array, num_as_str, maxdepth)
		if success then
			return result
		else
			return nil, result
		end
	end
end

-- Dora Color helper
Dora.rgba = function(r, g, b, a)
	return Dora.Color(r, g, b, a * 255)
end

if Dora.yue then
	local yue = Dora.yue
	yue.insert_loader(3)
	Dora.p = yue.p
	_G.p = yue.p
	local baseLoadfile, baseDofile = loadfile, dofile
	_G.loadfile = function(file, ...)
		if Dora.Path:getExt(file) == "yue" then return yue.loadfile(file, ...) end
		return baseLoadfile(file, ...)
	end
	_G.dofile = function(file, ...)
		if Dora.Path:getExt(file) == "yue" then return yue.dofile(file, ...) end
		return baseDofile(file, ...)
	end
	local yue_checkAsync = yue.checkAsync
	yue.checkAsync = function(codes, searchPath, lax)
		local _, mainThread = coroutine.running()
		assert(not mainThread, "yue.checkAsync should be run in a thread")
		local result, lcodes
		local done = false
		if lax == nil then
			lax = false
		end
		yue_checkAsync(codes, searchPath, lax, function(info, luaCodes)
			result, lcodes = info, luaCodes
			done = true
		end)
		wait(function()
			return done
		end)
		return result, lcodes
	end
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

local function disallowCreateGlobal(_, name)
	error("disallow creating global variable \"" .. name .. "\".")
end

local function getDoraLib(_, ...)
	if select("#", ...) == 0 then
		return Dora
	end
	local envs
	envs = {
		__index = function(_, key)
			for i = 1, #envs do
				local item = envs[i][key]
				if item ~= nil then return item end
			end
		end,
		__newindex = disallowCreateGlobal,
		Dora,
		...,
	}
	return setmetatable(envs, envs)
end

local unpack <const> = table.unpack
-- ImGui pair call wrappers
do
	local ImGui = Dora.ImGui

	local closeVar = setmetatable({}, {
		__close = function(self)
			self[#self]()
			self[#self] = nil
		end
	})

	local function pairCallA(beginFunc, endFunc)
		return function(...)
			local args = { ... }
			local callFunc = table_remove(args)
			if type(callFunc) ~= "function" then
				error("requires a function as last argument in 'Begin' function.")
			end
			local began, ret = beginFunc(unpack(args))
			closeVar[#closeVar + 1] = endFunc
			local _ <close> = closeVar
			if began then
				callFunc()
			end
			return ret
		end
	end

	local function pairCallB(beginFunc, endFunc)
		return function(...)
			local args = { ... }
			local callFunc = table_remove(args)
			if type(callFunc) ~= "function" then
				error("requires a function as last argument in 'Begin' function.")
			end
			local began, ret = beginFunc(unpack(args))
			if began then
				closeVar[#closeVar + 1] = endFunc
				local _ <close> = closeVar
				callFunc()
			end
			return ret
		end
	end

	local function pairCallC(beginFunc, endFunc)
		return function(...)
			local args = { ... }
			local callFunc = table_remove(args)
			if type(callFunc) ~= "function" then
				error("requires a function as last argument in 'Begin' function.")
			end
			local began, ret = beginFunc(unpack(args))
			closeVar[#closeVar + 1] = endFunc
			local _ <close> = closeVar
			callFunc()
			return began, ret
		end
	end

	ImGui.Begin = pairCallA(ImGui.Begin, ImGui.End)
	ImGui.End = nil
	ImGui.BeginChild = pairCallA(ImGui.BeginChild, ImGui.EndChild)
	ImGui.EndChild = nil
	ImGui.BeginPopup = pairCallB(ImGui.BeginPopup, ImGui.EndPopup)
	ImGui.BeginPopupModal = pairCallB(ImGui.BeginPopupModal, ImGui.EndPopup)
	ImGui.BeginPopupContextItem = pairCallB(ImGui.BeginPopupContextItem, ImGui.EndPopup)
	ImGui.BeginPopupContextWindow = pairCallB(ImGui.BeginPopupContextWindow, ImGui.EndPopup)
	ImGui.BeginPopupContextVoid = pairCallB(ImGui.BeginPopupContextVoid, ImGui.EndPopup)
	ImGui.EndPopup = nil
	ImGui.BeginGroup = pairCallC(ImGui.BeginGroup, ImGui.EndGroup)
	ImGui.EndGroup = nil
	ImGui.BeginDisabled = pairCallC(ImGui.BeginDisabled, ImGui.EndDisabled)
	ImGui.EndDisabled = nil
	ImGui.BeginTooltip = pairCallB(ImGui.BeginTooltip, ImGui.EndTooltip)
	ImGui.EndTooltip = nil
	ImGui.BeginMainMenuBar = pairCallB(ImGui.BeginMainMenuBar, ImGui.EndMainMenuBar)
	ImGui.EndMainMenuBar = nil
	ImGui.BeginMenuBar = pairCallB(ImGui.BeginMenuBar, ImGui.EndMenuBar)
	ImGui.EndMenuBar = nil
	ImGui.BeginMenu = pairCallB(ImGui.BeginMenu, ImGui.EndMenu)
	ImGui.EndMenu = nil
	ImGui.PushStyleColor = pairCallC(ImGui.PushStyleColor, ImGui.PopStyleColor)
	ImGui.PopStyleColor = nil
	ImGui.PushStyleVar = pairCallC(ImGui.PushStyleVar, ImGui.PopStyleVar)
	ImGui.PopStyleVar = nil
	ImGui.PushItemWidth = pairCallC(ImGui.PushItemWidth, ImGui.PopItemWidth)
	ImGui.PopItemWidth = nil
	ImGui.PushTextWrapPos = pairCallC(ImGui.PushTextWrapPos, ImGui.PopTextWrapPos)
	ImGui.PopTextWrapPos = nil
	ImGui.PushAllowKeyboardFocus = pairCallC(ImGui.PushAllowKeyboardFocus, ImGui.PopAllowKeyboardFocus)
	ImGui.PopAllowKeyboardFocus = nil
	ImGui.PushItemFlag = pairCallC(ImGui.PushItemFlag, ImGui.PopItemFlag)
	ImGui.PopItemFlag = nil
	ImGui.PushID = pairCallC(ImGui.PushID, ImGui.PopID)
	ImGui.PopID = nil
	local TreePop = ImGui.TreePop
	ImGui.TreePush = pairCallC(ImGui.TreePush, TreePop)
	ImGui.TreeNode = pairCallB(ImGui.TreeNode, TreePop)
	ImGui.TreeNodeEx = pairCallB(ImGui.TreeNodeEx, TreePop)
	ImGui.TreePop = nil
	ImGui.PushClipRect = pairCallC(ImGui.PushClipRect, ImGui.PopClipRect)
	ImGui.PopClipRect = nil
	ImGui.BeginTable = pairCallB(ImGui.BeginTable, ImGui.EndTable)
	ImGui.EndTable = nil
	ImGui.BeginListBox = pairCallB(ImGui.BeginListBox, ImGui.EndListBox)
	ImGui.EndListBox = nil
	ImGui.BeginTabBar = pairCallB(ImGui.BeginTabBar, ImGui.EndTabBar)
	ImGui.EndTabBar = nil
	ImGui.BeginTabItem = pairCallB(ImGui.BeginTabItem, ImGui.EndTabItem)
	ImGui.EndTabItem = nil
end

if Dora.ML then
	local build = Dora.ML.BuildDecisionTreeAsync
	Dora.ML.BuildDecisionTreeAsync = function(data, maxDepth, handler)
		local accuracy, err, done
		build(data, maxDepth, function(...)
			if not done then
				done = true
				accuracy = select(1, ...)
				if accuracy < 0 then accuracy, err = nil, select(2, ...) end
			else handler(...) end
		end)
		Dora.wait(function() return done end)
		return accuracy, err
	end
end

local globals = {}
_G.globals = globals
Dora.globals = globals
setmetatable(Dora, {
	__newindex = disallowCreateGlobal,
	__call = getDoraLib,
})
