-- [ts]: WebIDESync.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local HttpServer = ____Dora.HttpServer -- 2
local emit = ____Dora.emit -- 2
local ____Utils = require("Agent.Utils") -- 3
local Log = ____Utils.Log -- 3
local safeJsonEncode = ____Utils.safeJsonEncode -- 3
local ____Workspace = require("Agent.Tool.Workspace") -- 4
local resolveWorkspaceFilePath = ____Workspace.resolveWorkspaceFilePath -- 4
local function encodePayload(value) -- 6
	local text = safeJsonEncode(value) -- 7
	return text -- 8
end -- 6
function ____exports.sendWebIDEFileUpdate(file, exists, content) -- 11
	if HttpServer.wsConnectionCount == 0 then -- 11
		return true -- 12
	end -- 12
	local payload = encodePayload({name = "UpdateFile", file = file, exists = exists, content = content}) -- 13
	if not payload then -- 13
		return false -- 14
	end -- 14
	emit("AppWS", "Send", payload) -- 15
	return true -- 16
end -- 11
function ____exports.sendWebIDERefreshTree() -- 19
	if HttpServer.wsConnectionCount == 0 then -- 19
		return true -- 20
	end -- 20
	local payload = encodePayload({name = "RefreshTree"}) -- 21
	if not payload then -- 21
		return false -- 22
	end -- 22
	emit("AppWS", "Send", payload) -- 23
	return true -- 24
end -- 19
function ____exports.syncWebIDEFile(file, warningScope) -- 27
	if warningScope == nil then -- 27
		warningScope = "Agent.Tools" -- 27
	end -- 27
	if not Content:exist(file) then -- 27
		return ____exports.sendWebIDEFileUpdate(file, false, "") -- 28
	end -- 28
	if Content:isdir(file) then -- 28
		return ____exports.sendWebIDERefreshTree() -- 29
	end -- 29
	local content = "" -- 30
	do -- 30
		local function ____catch(e) -- 30
			Log( -- 38
				"Warn", -- 38
				(((("[" .. warningScope) .. "] failed to inspect file for Web IDE update file=") .. file) .. ": ") .. tostring(e) -- 38
			) -- 38
		end -- 38
		local ____try, ____hasReturned = pcall(function() -- 38
			local ____, isBinary = Content:getAttr(file) -- 32
			if not isBinary then -- 32
				local loaded = Content:load(file) -- 34
				content = type(loaded) == "string" and loaded or "" -- 35
			end -- 35
		end) -- 35
		if not ____try then -- 35
			____catch(____hasReturned) -- 35
		end -- 35
	end -- 35
	return ____exports.sendWebIDEFileUpdate(file, true, content) -- 40
end -- 27
function ____exports.syncWorkspaceFile(workDir, path, warningScope) -- 43
	if warningScope == nil then -- 43
		warningScope = "Agent.Tools" -- 43
	end -- 43
	local target = resolveWorkspaceFilePath(workDir, path) -- 44
	if not target then -- 44
		return false -- 45
	end -- 45
	return ____exports.syncWebIDEFile(target, warningScope) -- 46
end -- 43
function ____exports.refreshWorkspaceTree(workDir, path, warningScope) -- 49
	if warningScope == nil then -- 49
		warningScope = "Agent.Tools" -- 49
	end -- 49
	local normalized = type(path) == "string" and __TS__StringTrim(path) or "" -- 50
	if normalized == "" then -- 50
		return ____exports.sendWebIDERefreshTree() -- 51
	end -- 51
	return ____exports.syncWorkspaceFile(workDir, normalized, warningScope) -- 52
end -- 49
return ____exports -- 49