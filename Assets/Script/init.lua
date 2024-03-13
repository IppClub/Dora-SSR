-- [yue]: Script/init.yue
local Content = dora.Content -- 1
local Path = dora.Path -- 1
local App = dora.App -- 1
do -- 3
	local _with_0 = Content -- 3
	_with_0.searchPaths = { -- 5
		_with_0.writablePath, -- 5
		Path(_with_0.assetPath, "Script"), -- 6
		Path(_with_0.assetPath, "Script", "Lib"), -- 7
		Path(_with_0.assetPath, "Script", "Lib", "Dora", App.locale:match("^zh") and "zh-Hans" or "en") -- 8
	} -- 4
end -- 3
return require("Dev.Entry") -- 10
