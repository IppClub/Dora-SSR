-- [yue]: Script/Example/SQLite.yue
local DB = Dora.DB -- 1
local print = _G.print -- 1
local p = _G.p -- 1
local thread = Dora.thread -- 1
local pairs = _G.pairs -- 1
local threadLoop = Dora.threadLoop -- 1
local App = Dora.App -- 1
local ImGui = Dora.ImGui -- 1
local Vec2 = Dora.Vec2 -- 1
local result = DB:transaction({ -- 4
	"DROP TABLE IF EXISTS test", -- 4
	"CREATE TABLE test (id INTEGER PRIMARY KEY, value TEXT)", -- 5
	{ -- 7
		"INSERT INTO test VALUES(?, ?)", -- 7
		{ -- 9
			{ -- 9
				false, -- 9
				"hello" -- 9
			}, -- 9
			{ -- 10
				false, -- 10
				"world" -- 10
			}, -- 10
			{ -- 11
				false, -- 11
				"ok" -- 11
			} -- 11
		} -- 8
	} -- 6
}) -- 3
print(result and "Success" or "Failure") -- 16
print(DB:exist("test")) -- 18
p(DB:query("SELECT * FROM test", true)) -- 20
print("row changed:", DB:exec("DELETE FROM test WHERE id > 1")) -- 22
print("row changed:", DB:exec("UPDATE test SET value = ? WHERE id = 1", { -- 24
	"hello world!" -- 24
})) -- 24
local _anon_func_0 = function(items) -- 33
	local _accum_0 = { } -- 33
	local _len_0 = 1 -- 33
	for _index_0 = 1, #items do -- 33
		local item = items[_index_0] -- 33
		_accum_0[_len_0] = item[1] -- 33
		_len_0 = _len_0 + 1 -- 33
	end -- 33
	return _accum_0 -- 33
end -- 33
thread(function() -- 26
	print("insert async") -- 27
	local data -- 28
	do -- 28
		local _accum_0 = { } -- 28
		local _len_0 = 1 -- 28
		for k in pairs(_G) do -- 28
			_accum_0[_len_0] = { -- 28
				false, -- 28
				k -- 28
			} -- 28
			_len_0 = _len_0 + 1 -- 28
		end -- 28
		data = _accum_0 -- 28
	end -- 28
	p(DB:insertAsync("test", data)) -- 29
	print("query async...") -- 31
	local items = DB:queryAsync("SELECT value FROM test WHERE value NOT LIKE 'hello%' ORDER BY value ASC") -- 32
	return p(_anon_func_0(items)) -- 33
end) -- 26
print("OK") -- 35
local windowFlags = { -- 40
	"NoDecoration", -- 40
	"AlwaysAutoResize", -- 40
	"NoSavedSettings", -- 40
	"NoFocusOnAppearing", -- 40
	"NoNav", -- 40
	"NoMove" -- 40
} -- 40
return threadLoop(function() -- 48
	local width -- 49
	width = App.visualSize.width -- 49
	ImGui.SetNextWindowBgAlpha(0.35) -- 50
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 51
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 52
	return ImGui.Begin("SQLite", windowFlags, function() -- 53
		ImGui.Text("SQLite (Yuescript)") -- 54
		ImGui.Separator() -- 55
		return ImGui.TextWrapped("Doing database operations in synchronous and asynchronous ways.") -- 56
	end) -- 56
end) -- 56
