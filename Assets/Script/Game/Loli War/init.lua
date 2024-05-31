-- [yue]: init.yue
local Path = Dora.Path -- 1
local Content = Dora.Content -- 1
local scriptPath = Path:getScriptPath(...) -- 11
if scriptPath then -- 11
	Content:insertSearchPath(1, scriptPath) -- 12
	local _list_0 = { -- 14
		"Constant", -- 14
		"Bullet", -- 15
		"Unit", -- 16
		"AI", -- 17
		"Action", -- 18
		"Logic", -- 19
		"Control", -- 20
		"Scene" -- 21
	} -- 13
	for _index_0 = 1, #_list_0 do -- 22
		local mod = _list_0[_index_0] -- 13
		require(Path(scriptPath, mod)) -- 13
	end -- 13
end -- 11
