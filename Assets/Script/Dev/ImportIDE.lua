-- [ts]: ImportIDE.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Dictionary = ____Dora.Dictionary -- 2
local Director = ____Dora.Director -- 2
local HttpServer = ____Dora.HttpServer -- 2
local Node = ____Dora.Node -- 2
local emit = ____Dora.emit -- 2
local json = ____Dora.json -- 2
local function send(message) -- 4
	local encoded = json.encode(message) -- 5
	if encoded == nil then -- 5
		return -- 6
	end -- 6
	local event = Dictionary() -- 7
	event.type = "Send" -- 7
	event.msg = encoded -- 7
	emit("AppWS", event) -- 7
end -- 4
local targets = {} -- 11
local nativeState = "stopped" -- 12
local serial = 0 -- 13
local pending = {} -- 14
local listener = Node() -- 15
listener:addTo(Director.systemUI) -- 16
listener:gslot( -- 17
	"AppIDEState", -- 17
	function(state) -- 17
		nativeState = state -- 17
	end -- 17
) -- 17
listener:gslot( -- 18
	"AppWS", -- 18
	function(event) -- 18
		if type(event) == "string" or event.type ~= "Receive" then -- 18
			return -- 19
		end -- 19
		local message = json.decode(event.msg) -- 20
		if not message or type(message) ~= "table" then -- 20
			return -- 21
		end -- 21
		local data = message -- 22
		if type(data.id) ~= "string" or #data.id > 100 then -- 22
			return -- 23
		end -- 23
		if data.name == "ImportIDEClient" then -- 23
			local previous = targets[data.id] -- 25
			targets[data.id] = {id = data.id, embedded = data.embedded == true, seenAt = App.runningTime, activeAt = data.active == true and App.runningTime or (previous and previous.activeAt or 0)} -- 26
		elseif data.name == "ImportIDEClosed" then -- 26
			__TS__Delete(targets, data.id) -- 29
		elseif data.name == "ImportIDEOpened" and type(data.requestId) == "string" then -- 29
			local ____opt_2 = pending[(data.id .. ":") .. data.requestId] -- 29
			if ____opt_2 ~= nil then -- 29
				____opt_2(data.success == true) -- 31
			end -- 31
		end -- 31
	end -- 18
) -- 18
function ____exports.getNativeState() -- 34
	return nativeState -- 34
end -- 34
local lastProbe = -math.huge -- 35
function ____exports.getTargets() -- 36
	if HttpServer.wsConnectionCount == 0 then -- 36
		return {} -- 37
	end -- 37
	if App.runningTime - lastProbe > 5 then -- 37
		lastProbe = App.runningTime -- 38
		send({name = "ImportIDEProbe"}) -- 38
	end -- 38
	local result = {} -- 39
	for id, target in pairs(targets) do -- 40
		do -- 40
			if App.runningTime - target.seenAt > 45 then -- 40
				__TS__Delete(targets, id) -- 41
				goto __continue16 -- 41
			end -- 41
			if target.embedded and (not App.webIDEEnabled or nativeState == "stopped" or nativeState == "failed") then -- 41
				goto __continue16 -- 42
			end -- 42
			result[#result + 1] = target -- 43
		end -- 43
		::__continue16:: -- 43
	end -- 43
	__TS__ArraySort( -- 45
		result, -- 45
		function(____, a, b) return b.activeAt - a.activeAt end -- 45
	) -- 45
	return result -- 46
end -- 36
function ____exports.openProject(target, root) -- 48
	return __TS__New( -- 49
		__TS__Promise, -- 49
		function(____, resolve) -- 49
			serial = serial + 1 -- 50
			local requestId = tostring(serial) -- 51
			local key = (target.id .. ":") .. requestId -- 52
			local settled = false -- 53
			local function finish(success) -- 54
				if settled then -- 54
					return -- 54
				end -- 54
				settled = true -- 54
				__TS__Delete(pending, key) -- 54
				resolve(nil, success) -- 54
			end -- 54
			pending[key] = finish -- 55
			local started = App.runningTime -- 56
			send({name = "ImportIDEOpen", target = target.id, requestId = requestId, root = root}) -- 57
			Director.systemScheduler:schedule(function() -- 58
				if settled then -- 58
					return true -- 59
				end -- 59
				if HttpServer.wsConnectionCount == 0 or App.runningTime - started > 8 then -- 59
					finish(false) -- 60
					return true -- 60
				end -- 60
				return false -- 61
			end) -- 58
		end -- 49
	) -- 49
end -- 48
return ____exports -- 48