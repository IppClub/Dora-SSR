-- [yue]: Script/Game/Zombie Escape/init.yue
local Path = dora.Path -- 1
local Content = dora.Content -- 1
do -- 4
	local scriptPath = Path:getScriptPath(...) -- 4
	if scriptPath then -- 4
		Content:insertSearchPath(1, scriptPath) -- 5
		local _list_0 = { -- 7
			"Constant", -- 7
			"Unit", -- 8
			"Body", -- 9
			"Bullet", -- 10
			"Action", -- 11
			"AI", -- 12
			"Logic", -- 13
			"Control", -- 14
			"Scene", -- 15
			"Debug" -- 16
		} -- 6
		for _index_0 = 1, #_list_0 do -- 17
			local mod = _list_0[_index_0] -- 6
			require(Path(scriptPath, mod)) -- 6
		end -- 6
	end -- 4
end -- 4
