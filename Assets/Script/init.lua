-- [yue]: Script/init.yue
local _ENV = Dora -- 9
local Content <const> = Content -- 10
local Path <const> = Path -- 10
local App <const> = App -- 10
Content.searchPaths = { -- 14
	Path(Content.assetPath, "Script", "Lib"), -- 14
	Path(Content.assetPath, "Script", "Lib", "Dora", App.locale:match("^zh") and "zh-Hans" or "en") -- 15
} -- 13
return require("Script.Dev.Entry") -- 17
