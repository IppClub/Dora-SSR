-- [ts]: Operation.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Path = ____Dora.Path -- 2
local ____Workspace = require("Agent.Tool.Workspace") -- 3
local ENGINE_LOG_DOWNLOAD_DIR = ____Workspace.ENGINE_LOG_DOWNLOAD_DIR -- 3
local AGENT_DOWNLOAD_TEMP_DIR = "agent" -- 5
function ____exports.createOperationId() -- 7
	local raw = (tostring(os.time()) .. "-") .. tostring(math.floor(math.random() * 1000000000)) -- 8
	local safe = string.gsub(raw, "[^%w%-_]", "-") -- 9
	return safe -- 10
end -- 7
function ____exports.getAgentDownloadTempRoot() -- 13
	return Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR, AGENT_DOWNLOAD_TEMP_DIR) -- 14
end -- 13
function ____exports.cleanupPath(path) -- 17
	if not path or path == "" or not Content:exist(path) then -- 17
		return nil -- 18
	end -- 18
	if Content:remove(path) then -- 18
		return nil -- 19
	end -- 19
	return "failed to remove temporary path: " .. path -- 20
end -- 17
return ____exports -- 17