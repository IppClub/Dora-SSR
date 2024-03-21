-- [yue]: Script/Game/Loli War/init.yue
local Path = dora.Path -- 1
local Content = dora.Content -- 1
local scriptPath = Path:getScriptPath(...) -- 3
if scriptPath then -- 3
	Content:insertSearchPath(1, scriptPath) -- 4
	local _list_0 = { -- 6
		"Constant", -- 6
		"Bullet", -- 7
		"Unit", -- 8
		"AI", -- 9
		"Action", -- 10
		"Logic", -- 11
		"Control", -- 12
		"Scene" -- 13
	} -- 5
	for _index_0 = 1, #_list_0 do -- 14
		local mod = _list_0[_index_0] -- 5
		require(Path(scriptPath, mod)) -- 5
	end -- 5
end -- 3
