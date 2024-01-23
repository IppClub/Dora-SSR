--[[ Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. ]]

local table_insert <const> = table.insert
local table_remove <const> = table.remove
local type <const> = type
local unpack <const> = table.unpack
local dora <const> = dora
local package <const> = package
local coroutine <const> = coroutine
local assert <const> = assert
local xpcall <const> = xpcall
local rawset <const> = rawset
local setmetatable <const> = setmetatable
local tostring <const> = tostring
local select <const> = select
local pairs <const>, ipairs <const> = pairs, ipairs

-- setup Yuescript loader
package.path = "?.lua"

local yue = require("yue")
yue.insert_loader(3)

debug.traceback = function(err, level)
	return yue.traceback(err, (level or 1) + 1)
end

debug.debug = nil

local function traceback(err)
	print(yue.traceback(err))
end

-- prepare singletons
do
	dora.App = dora.Application()
	dora.Application = nil
	package.cpath = dora.App.platform == "Windows" and "?.dll" or "?.so"

	dora.Content = dora.Content()
	dora.Director = dora.Director()
	dora.View = dora.View()
	dora.Audio = dora.Audio()
	dora.Controller = dora.Controller()
	dora.Keyboard = dora.Keyboard()
	dora.DB = dora.DB()
	dora.HttpServer = dora.HttpServer()
	dora.Platformer.Decision.AI = dora.Platformer.Decision.AI()
	dora.Platformer.Data = dora.Platformer.Data()
end

-- setup loader profilers
do
	local App = dora.App
	local Profiler = dora.Profiler
	local EventName = Profiler.EventName
	local loaders = package.loaders or package.searchers
	for i = 1, #loaders do
		local loader = loaders[i]
		loaders[i] = function(name)
			local lastTime = App.elapsedTime
			local loaded
			Profiler.level = Profiler.level + 1
			local _ <close> = setmetatable({}, {
				__close = function()
					if type(loaded) ~= "string" then
						local deltaTime = App.elapsedTime - lastTime
						dora.emit(EventName, "Loader", name .. " [Compile]", Profiler.level, deltaTime)
					end
					Profiler.level = Profiler.level - 1
				end
			})
			loaded = loader(name)
			return loaded
		end
	end

	Profiler[2] = function(_, func)
		local lastTime = App.elapsedTime
		xpcall(func, traceback)
		local deltaTime = App.elapsedTime - lastTime
		return deltaTime
	end

	local require = _G.require
	_G.require = function(name)
		local result = package.loaded[name]
		if result then
			return result
		end
		local lastTime = App.elapsedTime
		Profiler.level = Profiler.level + 1
		local _ <close> = setmetatable({}, {
			__close = function()
				local deltaTime = App.elapsedTime - lastTime
				dora.emit(EventName, "Loader", name, Profiler.level, deltaTime)
				Profiler.level = Profiler.level - 1
			end
		})
		return require(name)
	end
end

-- coroutine wrapper
do
	local coroutine_yield = coroutine.yield
	local coroutine_create = coroutine.create
	local coroutine_resume = coroutine.resume
	local coroutine_close = coroutine.close
	local coroutine_status = coroutine.status
	local App = dora.App

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
			local stoped = false
			repeat
				local success, result = xpcall(work, traceback, ...)
				stoped = not success or result
				coroutine_yield(false)
			until stoped
			return true
		end)
	end

	local function cycle(duration, work)
		local time = 0
		local function worker()
			local deltaTime = App.deltaTime
			time = time + deltaTime
			if time < duration then
				work(time / duration)
				return true
			else
				work(1)
				return false
			end
		end
		work(0)
		if time < duration then
			coroutine_yield(false)
			while worker() do
				coroutine_yield(false)
			end
		end
	end

	local function Routine_close(routine)
		if type(routine) == "thread" then
			local status = coroutine_status(routine)
			if status == "dead" or status == "suspended" then
				coroutine_close(routine)
			end
		end
	end
	local Routine = {
		remove = function(self, routine)
			for i = 1, #self do
				if self[i] == routine then
					Routine_close(routine)
					self[i] = false
					return true
				end
			end
			return false
		end,
		clear = function(self)
			while #self > 0 do
				Routine_close(table_remove(self))
			end
		end
	}

	setmetatable(Routine, {
		__call = function(self, routine)
			table_insert(self, routine)
			return routine
		end
	})

	dora.Director.postScheduler:schedule(function()
		local i, count = 1, #Routine
		while i <= count do
			local routine = Routine[i]
			local success, result = false, true
			if routine then
				success, result = coroutine_resume(routine)
				if not success then
					coroutine_close(routine)
					print(result)
				end
			end
			if (success and result) or (not success) then
				Routine[i] = Routine[count]
				table_remove(Routine, count)
				i = i - 1
				count = count - 1
			end
			i = i + 1
		end
		return false
	end)

	dora.Routine = Routine
	dora.wait = wait
	dora.once = once
	dora.loop = loop
	dora.cycle = cycle

	dora.thread = function(routine)
		return Routine(once(routine))
	end

	dora.threadLoop = function(routine)
		return Routine(loop(routine))
	end

	dora.sleep = function(duration)
		if duration then
			local time = 0
			repeat
				coroutine_yield(false)
				time = time + App.deltaTime
			until time >= duration
		else
			coroutine_yield(false)
		end
	end
end

-- async functions
do
	local Content = dora.Content
	local wait = dora.wait
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
	Content.unzipAsync = function(self, zipFile, folderPath, filter)
		local _, mainThread = coroutine.running()
		assert(not mainThread, "Content.unzipAsync should be run in a thread")
		filter = filter or function() return true end
		local result
		local done = false
		Content_unzipAsync(self, zipFile, folderPath, filter, function(success)
			result = success
			done = true
		end)
		wait(function()
			return done
		end)
		return result
	end

	local Cache = dora.Cache
	local Cache_loadAsync = Cache.loadAsync
	Cache.loadAsync = function(self, target, handler)
		local _, mainThread = coroutine.running()
		assert(not mainThread, "Cache.loadAsync should be run in a thread")
		local files
		if type(target) == "table" then
			files = target
		else
			files = {
				target
			}
		end
		local count = 0
		local total = #files
		for i = 1, total do
			Cache_loadAsync(self, files[i], function()
				count = count + 1
				if handler then
					handler(count / total)
				end
			end)
		end
		wait(function()
			return count == total
		end)
	end

	local RenderTarget = dora.RenderTarget
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

	local DB = dora.DB
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

	local Wasm = dora.Wasm
	local Wasm_executeMainFileAsync = Wasm.executeMainFileAsync
	Wasm.executeMainFileAsync = function(self, filename)
		local _, mainThread = coroutine.running()
		assert(not mainThread, "Wasm.executeMainFileAsync should be run in a thread")
		local result
		local done = false
		Wasm_executeMainFileAsync(self, filename, function(res)
			result = res
			done = true
		end)
		wait(function()
			return done
		end)
		return result
	end

	local HttpServer = dora.HttpServer
	local HttpServer_postSchedule = HttpServer.postSchedule
	HttpServer.postSchedule = function(self, pattern, scheduleFunc)
		HttpServer_postSchedule(self, pattern, function(req)
			return coroutine.wrap(function()
				return scheduleFunc(req)
			end)
		end)
	end

	local yue_checkAsync = yue.checkAsync
	yue.checkAsync = function(codes, searchPath)
		local _, mainThread = coroutine.running()
		assert(not mainThread, "yue.checkAsync should be run in a thread")
		local result, lcodes
		local done = false
		yue_checkAsync(codes, searchPath, function(info, luaCodes)
			result, lcodes = info, luaCodes
			done = true
		end)
		wait(function()
			return done
		end)
		return result, lcodes
	end

	local teal = dora.teal
	local teal_toluaAsync = teal.toluaAsync
	teal.toluaAsync = function(codes, moduleName, searchPath)
		local _, mainThread = coroutine.running()
		assert(not mainThread, "teal.toluaAsync should be run in a thread")
		local result, err
		local done = false
		teal_toluaAsync(codes, moduleName, searchPath, function(luaCodes, msg)
			result, err = luaCodes, msg
			done = true
		end)
		wait(function()
			return done
		end)
		return result, err
	end

	local teal_checkAsync = teal.checkAsync
	teal.checkAsync = function(codes, moduleName, lax, searchPath)
		local _, mainThread = coroutine.running()
		assert(not mainThread, "teal.checkAsync should be run in a thread")
		local result, errs
		local done = false
		teal_checkAsync(codes, moduleName, lax, searchPath, function(success, info)
			result, errs = success, info
			done = true
		end)
		wait(function()
			return done
		end)
		return result, errs
	end

	local teal_completeAsync = teal.completeAsync
	teal.completeAsync = function(codes, line, row, searchPath)
		local _, mainThread = coroutine.running()
		assert(not mainThread, "teal.completeAsync should be run in a thread")
		local result
		local done = false
		teal_completeAsync(codes, line, row, searchPath, function(completeList)
			result = completeList
			done = true
		end)
		wait(function()
			return done
		end)
		return result
	end

	local teal_inferAsync = teal.inferAsync
	teal.inferAsync = function(codes, line, row, searchPath)
		local _, mainThread = coroutine.running()
		assert(not mainThread, "teal.inferAsync should be run in a thread")
		local result
		local done = false
		teal_inferAsync(codes, line, row, searchPath, function(infered)
			result = infered
			done = true
		end)
		wait(function()
			return done
		end)
		return result
	end

	local teal_getSignatureAsync = teal.getSignatureAsync
	teal.getSignatureAsync = function(codes, line, row, searchPath)
		local _, mainThread = coroutine.running()
		assert(not mainThread, "teal.inferAsync should be run in a thread")
		local result
		local done = false
		teal_getSignatureAsync(codes, line, row, searchPath, function(infered)
			result = infered
			done = true
		end)
		wait(function()
			return done
		end)
		return result
	end
end

-- node actions
do
	local Action = dora.Action
	local Node = dora.Node
	local Node_runAction = Node.runAction
	Node.runAction = function(self, action)
		if type(action) == "table" then
			return Node_runAction(self, Action(action))
		else
			return Node_runAction(self, action)
		end
	end
	local Node_perform = Node.perform
	Node.perform = function(self, action)
		if type(action) == "table" then
			return Node_perform(self, Action(action))
		else
			return Node_perform(self, action)
		end
	end

	for _, actionName in ipairs {
		"X",
		"Y",
		"Z",
		"ScaleX",
		"ScaleY",
		"SkewX",
		"SkewY",
		"Angle",
		"AngleX",
		"AngleY",
		"Width",
		"Height",
		"AnchorX",
		"AnchorY",
		"Opacity",
		"Tint",
		"Roll",
		"Hide",
		"Show",
		"Delay",
		"Event",
		"Spawn",
		"Sequence"
	} do
		dora[actionName] = function(...)
			return {
				actionName,
				...
			}
		end
	end

	local Spawn = dora.Spawn
	local X = dora.X
	local Y = dora.Y
	local ScaleX = dora.ScaleX
	local ScaleY = dora.ScaleY

	dora.Move = function(duration, start, stop, ease)
		return Spawn(
			X(duration, start.x, stop.x, ease),
			Y(duration, start.y, stop.y, ease)
		)
	end

	dora.Scale = function(duration, start, stop, ease)
		return Spawn(
			ScaleX(duration, start, stop, ease),
			ScaleY(duration, start, stop, ease)
		)
	end
end

-- fix array indicing
do
	local Array = dora.Array
	local Array_index = Array.__index
	local Array_get = Array.get
	Array.__index = function(self, key)
		if type(key) == "number" then
			return Array_get(self, key)
		end
		return Array_index(self, key)
	end

	local Array_newindex = Array.__newindex
	local Array_set = Array.set
	Array.__newindex = function(self, key, value)
		if type(key) == "number" then
			Array_set(self, key, value)
		else
			Array_newindex(self, key, value)
		end
	end

	Array.__len = function(self)
		return self.count
	end
end

-- mock dictionary as Lua table
do
	local Dictionary = dora.Dictionary
	local Dictionary_index = Dictionary.__index
	local Dictionary_get = Dictionary.get
	Dictionary.__index = function(self, key)
		local item = Dictionary_get(self, key)
		if item ~= nil then
			return item
		end
		return Dictionary_index(self, key)
	end

	Dictionary.__newindex = Dictionary.set

	Dictionary.__len = function(self)
		return self.count
	end
end

-- entity cache and old value accessing sugar
do
	local Entity = dora.Entity

	local Entity_create = Entity[2]
	local Entity_cache = {}
	local Entity_coms = {}
	local function Entity_getComIndex(key)
		local index = Entity_coms[key]
		if index == nil then
			index = Entity:getComIndex(key)
			Entity_coms[key] = index
		end
		return index
	end

	local function Entity_tryGetComIndex(key)
		local index = Entity_coms[key]
		if index == nil then
			index = Entity:tryGetComIndex(key)
			if index > 0 then
				Entity_coms[key] = index
			end
		end
		return index
	end

	Entity[2] = function(cls, tab)
		local coms = {}
		for key, value in pairs(tab) do
			local index = Entity_getComIndex(key)
			coms[index] = value
		end
		local entity = Entity_create(cls, coms)
		Entity_cache[entity.index + 1] = entity
	end

	local Entity_clear = Entity.clear
	Entity.clear = function(cls)
		Entity_cache = {}
		Entity_coms = {}
		Entity_clear(cls)
	end

	local Entity_getOld = Entity.getOld
	local Entity_oldValues
	Entity_oldValues = setmetatable({ false }, {
		__mode = "v",
		__index = function(_, key)
			local index = Entity_tryGetComIndex(key)
			return Entity_getOld(Entity_oldValues[1], index)
		end,
		__newindex = function()
			error("Can not assign value cache.")
		end
	})

	local Entity_index = Entity.__index
	local Entity_get = Entity.get
	Entity.__index = function(self, key)
		if key == "oldValues" then
			rawset(Entity_oldValues, 1, self)
			return Entity_oldValues
		end
		local index = Entity_tryGetComIndex(key)
		local item = Entity_get(self, index)
		if item ~= nil then
			return item
		end
		return Entity_index(self, key)
	end

	local Entity_set = Entity.set
	Entity.__newindex = function(self, key, value)
		local index = Entity_getComIndex(key)
		Entity_set(self, index, value)
	end
end

-- unit action creation
do
	local UnitAction = dora.Platformer.UnitAction
	local UnitAction_add = UnitAction.add
	local function dummy() end
	UnitAction.add = function(self, name, params)
		UnitAction_add(
			self, name,
			params.priority,
			params.reaction,
			params.recovery,
			params.queued or false,
			params.available,
			params.create,
			params.stop or dummy
		)
	end
end

-- ImGui pair call wrappers
do
	local ImGui = dora.ImGui

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
				error("ImGui paired calls now require a function as last argument in 'Begin' function.")
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
				error("ImGui paired calls now require a function as last argument in 'Begin' function.")
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
				error("ImGui paired calls now require a function as last argument in 'Begin' function.")
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
	ImGui.BeginChildFrame = pairCallA(ImGui.BeginChildFrame, ImGui.EndChildFrame)
	ImGui.EndChildFrame = nil
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
	ImGui.BeginTooltip = pairCallC(ImGui.BeginTooltip, ImGui.EndTooltip)
	ImGui.EndTooltip = nil
	ImGui.BeginMainMenuBar = pairCallC(ImGui.BeginMainMenuBar, ImGui.EndMainMenuBar)
	ImGui.EndMainMenuBar = nil
	ImGui.BeginMenuBar = pairCallC(ImGui.BeginMenuBar, ImGui.EndMenuBar)
	ImGui.EndMenuBar = nil
	ImGui.BeginMenu = pairCallC(ImGui.BeginMenu, ImGui.EndMenu)
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
	ImGui.PushButtonRepeat = pairCallC(ImGui.PushButtonRepeat, ImGui.PopButtonRepeat)
	ImGui.PopButtonRepeat = nil
	ImGui.PushID = pairCallC(ImGui.PushID, ImGui.PopID)
	ImGui.PopID = nil
	local TreePop = ImGui.TreePop
	ImGui.TreePop = nil
	ImGui.TreePush = pairCallB(ImGui.TreePush, TreePop)
	ImGui.TreeNode = pairCallB(ImGui.TreeNode, TreePop)
	ImGui.TreeNodeEx = pairCallB(ImGui.TreeNodeEx, TreePop)
	ImGui.PushClipRect = pairCallC(ImGui.PushClipRect, ImGui.PopClipRect)
	ImGui.PopClipRect = nil
	ImGui.BeginTable = pairCallB(ImGui.BeginTable, ImGui.EndTable)
	ImGui.EndTable = nil
end

-- ML
do
	local wait = dora.wait
	local BuildDecisionTreeAsync = dora.ML.BuildDecisionTreeAsync
	dora.ML.BuildDecisionTreeAsync = function(data, maxDepth, handler)
		local accuracy, err
		local done = false
		BuildDecisionTreeAsync(data, maxDepth, function(...)
			if not accuracy then
				done = true
				accuracy = select(1, ...)
				if accuracy < 0 then
					accuracy = nil
					err = select(2, ...)
				end
			else
				handler(...)
			end
		end)
		wait(function()
			return done
		end)
		return accuracy, err
	end
end

-- blackboard accessing sugar
do
	local Blackboard = dora.Platformer.Behavior.Blackboard
	local Blackboard_index = Blackboard.__index
	local Blackboard_get = Blackboard.get
	Blackboard.__index = function(self, key)
		local item = Blackboard_get(self, key)
		if item ~= nil then
			return item
		end
		return Blackboard_index(self, key)
	end

	Blackboard.__newindex = Blackboard.set
end

-- API for Typescript without operator overloading
do
	dora.Size.equals = function(self, var)
		return self == var
	end

	dora.Size.mul = function(self, var)
		return self * var
	end

	dora.Vec2.add = function(self, var)
		return self + var
	end

	dora.Vec2.sub = function(self, var)
		return self - var
	end

	dora.Vec2.mul = function(self, var)
		return self * var
	end

	dora.Vec2.div = function(self, var)
		return self / var
	end

	dora.Vec2.equals = function(self, var)
		return self == var
	end

	dora.Rect.equals = function(self, var)
		return self == var
	end
end

-- to string debugging helper
do
	dora.Vec2.__tostring = function(self)
		return "Vec2(" .. tostring(self.x) .. ", " .. tostring(self.y) .. ")"
	end

	dora.Rect.__tostring = function(self)
		return "Rect("
			.. tostring(self.x) .. ", "
			.. tostring(self.y) .. ", "
			.. tostring(self.width) .. ", "
			.. tostring(self.height) .. ")"
	end

	dora.Size.__tostring = function(self)
		return "Size(" .. tostring(self.width) .. ", " .. tostring(self.height) .. ")"
	end

	dora.Color.__tostring = function(self)
		return "Color(" .. string.format("0x%x", self:toARGB()) .. ")"
	end

	dora.Color3.__tostring = function(self)
		return "Color3(" .. string.format("0x%x", self:toRGB()) .. ")"
	end
end

-- dora helpers
do
	_G.p = yue.p
	dora.p = yue.p

	local Path = dora.Path

	local loadfile = _G.loadfile
	_G.loadfile = function(file, ...)
		if Path:getExt(file) == "yue" then
			return yue.loadfile(file, ...)
		end
		return loadfile(file, ...)
	end

	local dofile = _G.dofile
	_G.dofile = function(file, ...)
		if Path:getExt(file) == "yue" then
			return yue.dofile(file, ...)
		end
		return dofile(file, ...)
	end

	Path.getScriptPath = function(_, path)
		if not path then return nil end
		if path:match("[\\/]") then
			return Path:getPath(path)
		else
			path = path:gsub("%.", "/")
			return Path:getPath(path)
		end
	end

	local function disallowCreateGlobal(_, name)
		error("disallow creating global variable \"" .. name .. "\".")
	end

	local function Dora(...)
		if select("#", ...) == 0 then
			return dora
		else
			local envs
			envs = {
				__index = function(_, key)
					for i = 1, #envs do
						local item = envs[i][key]
						if item ~= nil then
							return item
						end
					end
					return nil
				end,
				__newindex = disallowCreateGlobal,
				dora,
				...
			}
			return setmetatable(envs, envs)
		end
	end
	_G.Dora = Dora
	dora.Dora = Dora

	for k, v in pairs(_G) do
		dora[k] = v
	end
	setmetatable(package.loaded, { __index = dora })

	local globals = {} -- available global value storage
	_G.globals = globals
	dora.globals = globals

	local doraMeta = { __newindex = disallowCreateGlobal }
	setmetatable(_G, doraMeta)
	setmetatable(dora, doraMeta)
end

-- default GC setting

-- collectgarbage("incremental", 100, 5000)
collectgarbage("generational", 20, 100)
