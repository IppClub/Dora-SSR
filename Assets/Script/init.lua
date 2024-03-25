-- [yue]: Script/init.yue
local Content = dora.Content -- 1
local Path = dora.Path -- 1
local App = dora.App -- 1
do -- 11
	local _with_0 = Content -- 11
	_with_0.searchPaths = { -- 13
		_with_0.writablePath, -- 13
		Path(_with_0.assetPath, "Script"), -- 14
		Path(_with_0.assetPath, "Script", "Lib"), -- 15
		Path(_with_0.assetPath, "Script", "Lib", "Dora", App.locale:match("^zh") and "zh-Hans" or "en") -- 16
	} -- 12
end -- 11
return require("Dev.Entry") -- 18
