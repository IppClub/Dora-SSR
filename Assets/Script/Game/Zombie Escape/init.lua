-- [yue]: Script/Game/Zombie Escape/init.yue
local Path = Dora.Path -- 1
local Content = Dora.Content -- 1
local scriptPath = Path:getScriptPath(...) -- 13
if scriptPath then -- 13
	Content:insertSearchPath(1, scriptPath) -- 14
	local _list_0 = { -- 16
		"Constant", -- 16
		"Unit", -- 17
		"Body", -- 18
		"Bullet", -- 19
		"Action", -- 20
		"AI", -- 21
		"Logic", -- 22
		"Control", -- 23
		"Scene", -- 24
		"Debug" -- 25
	} -- 15
	for _index_0 = 1, #_list_0 do -- 26
		local mod = _list_0[_index_0] -- 15
		require(Path(scriptPath, mod)) -- 15
	end -- 15
end -- 13
