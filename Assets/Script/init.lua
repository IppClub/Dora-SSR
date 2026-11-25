-- [yue]: init.yue
local _ENV = Dora -- 9
local Content <const> = Content -- 10
local Path <const> = Path -- 10
local App <const> = App -- 10
local require <const> = require -- 10
local error <const> = error -- 10
local tostring <const> = tostring -- 10
Content.searchPaths = { -- 14
	Path(Content.assetPath, "Script"), -- 14
	Path(Content.assetPath, "Script", "Lib"), -- 15
	Path(Content.assetPath, "Script", "Lib", "Dora", App.locale:match("^zh") and "zh-Hans" or "en") -- 16
} -- 13
local bootstrap = require("Script.Dev.Bootstrap") -- 18
local status = bootstrap.check() -- 19
if not status.ok then -- 20
	local recovery = require("Script.Dev.Recovery") -- 21
	local ok, reason = recovery.recover(status) -- 22
	if not ok then -- 23
		error("failed to initialize Dora database: " .. tostring(reason)) -- 23
	end -- 23
	status = bootstrap.check() -- 24
	if not status.ok then -- 25
		error("failed to initialize Dora database after recovery") -- 25
	end -- 25
end -- 20
return require("Script.Dev.Entry") -- 27
