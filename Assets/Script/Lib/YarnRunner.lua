-- [yue]: Script/Lib/YarnRunner.yue
local tonumber = _G.tonumber -- 1
local tostring = _G.tostring -- 1
local setmetatable = _G.setmetatable -- 1
local coroutine = _G.coroutine -- 1
local load = _G.load -- 1
local error = _G.error -- 1
local pcall = _G.pcall -- 1
local pairs = _G.pairs -- 1
local getmetatable = _G.getmetatable -- 1
local math = _G.math -- 1
local _module_0 = nil -- 1
local yarncompile = require("yarncompile") -- 9
local Content = require("Content") -- 10
local json = require("json") -- 11
local rewriteError -- 13
rewriteError = function(err, luaCode, title) -- 13
	local line, msg = err:match(".*:(%d+):%s*(.*)") -- 14
	line = tonumber(line) -- 15
	local current = 1 -- 16
	local lastLine = 1 -- 17
	local lineMap = { } -- 18
	for lineCode in luaCode:gmatch("([^\r\n]*)\r?\n?") do -- 19
		local num = lineCode:match("--%s*(%d+)%s*$") -- 20
		if num then -- 21
			lastLine = tonumber(num) -- 21
		end -- 21
		lineMap[current] = lastLine -- 22
		current = current + 1 -- 23
	end -- 23
	line = lineMap[line] or line -- 24
	return tostring(title) .. ":" .. tostring(line) .. ": " .. tostring(msg) -- 25
end -- 13
local _anon_func_0 = function(json, jsonCode) -- 60
	return json.load(jsonCode) -- 60
end -- 60
local YarnRunner -- 27
do -- 27
	local _class_0 -- 27
	local _base_0 = { -- 27
		gotoStory = function(self, title) -- 28
			local storyFunc = self.funcs[title] -- 29
			if not storyFunc then -- 30
				local yarnCode = self.codes[title] -- 31
				local luaCode, err = yarncompile(yarnCode) -- 32
				if not luaCode then -- 33
					if self.startTitle then -- 34
						return false, tostring(title) .. ":" .. tostring(err) -- 35
					else -- 37
						coroutine.yield("Error", tostring(title) .. ":" .. tostring(err)) -- 37
						return -- 38
					end -- 34
				end -- 33
				self.codes[title] = luaCode -- 39
				local luaFunc -- 40
				luaFunc, err = load(luaCode, title) -- 40
				if not luaFunc then -- 41
					err = rewriteError(err, luaCode, title) -- 42
					if self.startTitle then -- 43
						return false, err -- 44
					else -- 46
						coroutine.yield("Error", err) -- 46
						return -- 47
					end -- 43
				end -- 41
				storyFunc = luaFunc() -- 48
				self.funcs[title] = storyFunc -- 49
			end -- 30
			local visitedCount -- 50
			do -- 50
				local _exp_0 = self.visited[title] -- 50
				if _exp_0 ~= nil then -- 50
					visitedCount = _exp_0 -- 50
				else -- 50
					visitedCount = 0 -- 50
				end -- 50
			end -- 50
			self.visited[title] = 1 + visitedCount -- 51
			do -- 52
				local _obj_0 = self.stories -- 52
				_obj_0[#_obj_0 + 1] = { -- 52
					title, -- 52
					coroutine.create(function() -- 52
						return storyFunc(title, self.state, self.command, self.yarn, (function() -- 53
							local _base_1 = self -- 53
							local _fn_0 = _base_1.gotoStory -- 53
							return _fn_0 and function(...) -- 53
								return _fn_0(_base_1, ...) -- 53
							end -- 53
						end)()) -- 53
					end) -- 52
				} -- 52
			end -- 54
			return true -- 55
		end, -- 98
		advance = function(self, choice) -- 98
			if self.startTitle then -- 99
				local success, err = self:gotoStory(self.startTitle) -- 100
				self.startTitle = nil -- 101
				if not success then -- 102
					return "Error", err -- 102
				end -- 102
			end -- 99
			if choice then -- 103
				if not self.option then -- 104
					return "Error", "there is no option to choose" -- 105
				end -- 104
				local title, branches -- 106
				do -- 106
					local _obj_0 = self.option -- 106
					title, branches = _obj_0.title, _obj_0.branches -- 106
				end -- 106
				if not (1 <= choice and choice <= #branches) then -- 107
					return "Error", "choice " .. tostring(choice) .. " is out of range" -- 108
				end -- 107
				local optionBranch = branches[choice] -- 109
				self.option = nil -- 110
				local _obj_0 = self.stories -- 111
				_obj_0[#_obj_0 + 1] = { -- 111
					title, -- 111
					coroutine.create(optionBranch) -- 111
				} -- 111
			elseif self.option then -- 112
				return "Error", "required a choice to continue" -- 113
			end -- 103
			local title -- 114
			local success, resultType, body, branches -- 115
			do -- 115
				local storyItem = self.stories[#self.stories] -- 115
				if storyItem then -- 115
					local story -- 116
					title, story = storyItem[1], storyItem[2] -- 116
					success, resultType, body, branches = coroutine.resume(story) -- 117
				end -- 115
			end -- 115
			if not success and #self.stories > 0 then -- 118
				self.stories = { } -- 119
				local err = rewriteError(resultType, self.codes[title], title) -- 120
				return "Error", err -- 121
			end -- 118
			if not resultType then -- 122
				if #self.stories > 0 then -- 123
					self.stories[#self.stories] = nil -- 124
					return self:advance() -- 125
				end -- 123
			end -- 122
			if "Dialog" == resultType then -- 127
				return "Text", body -- 128
			elseif "Option" == resultType then -- 129
				self.option = { -- 130
					title = title, -- 130
					branches = branches -- 130
				} -- 130
				return "Option", body -- 131
			elseif "Goto" == resultType then -- 132
				return self:advance() -- 133
			elseif "Command" == resultType then -- 134
				return "Command", body -- 135
			elseif "Error" == resultType or "Stop" == resultType then -- 136
				self.stories = { } -- 137
				return "Error", body -- 138
			else -- 140
				return nil, "end of the story" -- 140
			end -- 140
		end -- 27
	} -- 27
	if _base_0.__index == nil then -- 27
		_base_0.__index = _base_0 -- 27
	end -- 140
	_class_0 = setmetatable({ -- 27
		__init = function(self, filename, startTitle, state, command, testing) -- 57
			if state == nil then -- 57
				state = { } -- 57
			end -- 57
			if command == nil then -- 57
				command = { } -- 57
			end -- 57
			if testing == nil then -- 57
				testing = false -- 57
			end -- 57
			local jsonCode = Content:load(filename) -- 58
			if not jsonCode then -- 59
				error("failed to read yarn file \"" .. tostring(filename) .. "\"") -- 59
			end -- 59
			local success, jsonObject = pcall(_anon_func_0, json, jsonCode) -- 60
			if not (success and jsonObject) then -- 61
				error("failed to load yarn json code") -- 61
			end -- 61
			self.codes = { } -- 63
			self.funcs = { } -- 64
			self.state = state -- 65
			do -- 67
				local _tab_0 = { -- 67
					stop = function() -- 67
						return coroutine.yield("Stop") -- 67
					end -- 67
				} -- 68
				local _idx_0 = 1 -- 68
				for _key_0, _value_0 in pairs(command) do -- 68
					if _idx_0 == _key_0 then -- 68
						_tab_0[#_tab_0 + 1] = _value_0 -- 68
						_idx_0 = _idx_0 + 1 -- 68
					else -- 68
						_tab_0[_key_0] = _value_0 -- 68
					end -- 68
				end -- 68
				self.command = _tab_0 -- 67
			end -- 67
			setmetatable(self.command, getmetatable(command)) -- 70
			self.stories = { } -- 71
			self.visited = { } -- 72
			self.yarn = { -- 74
				dice = function(num) -- 74
					return math.random(num) -- 74
				end, -- 74
				random = function() -- 75
					return math.random() -- 75
				end, -- 75
				random_range = function(start, stop) -- 76
					return math.random(start, stop) -- 76
				end, -- 76
				visited = function(name) -- 77
					return (self.visited[name] ~= nil) -- 77
				end, -- 77
				visited_count = function(name) -- 78
					local _exp_0 = self.visited[name] -- 78
					if _exp_0 ~= nil then -- 78
						return _exp_0 -- 78
					else -- 78
						return 0 -- 78
					end -- 78
				end -- 78
			} -- 73
			self.startTitle = startTitle -- 80
			if testing then -- 81
				local variables -- 82
				local _obj_0 = jsonObject.header -- 82
				if _obj_0 ~= nil then -- 82
					do -- 82
						local _obj_1 = _obj_0.pluginStorage -- 82
						if _obj_1 ~= nil then -- 82
							do -- 82
								local _obj_2 = _obj_1.Runner -- 82
								if _obj_2 ~= nil then -- 82
									variables = _obj_2.variables -- 82
								end -- 82
							end -- 82
						end -- 82
					end -- 82
				end -- 82
				if variables then -- 82
					for _index_0 = 1, #variables do -- 83
						local _des_0 = variables[_index_0] -- 83
						local key, value = _des_0.key, _des_0.value -- 83
						if "true" == value then -- 84
							state[key] = true -- 85
						elseif "false" == value then -- 86
							state[key] = false -- 87
						else -- 89
							local num = tonumber(value) -- 89
							if num then -- 89
								state[key] = num -- 90
							else -- 92
								state[key] = value -- 92
							end -- 89
						end -- 92
					end -- 92
				end -- 82
			end -- 81
			local nodes = jsonObject.nodes -- 93
			if nodes then -- 93
				for _index_0 = 1, #nodes do -- 94
					local node = nodes[_index_0] -- 94
					local title, body = node.title, node.body -- 95
					self.codes[title] = body -- 96
				end -- 96
			end -- 93
		end, -- 27
		__base = _base_0, -- 27
		__name = "YarnRunner" -- 27
	}, { -- 27
		__index = _base_0, -- 27
		__call = function(cls, ...) -- 27
			local _self_0 = setmetatable({ }, _base_0) -- 27
			cls.__init(_self_0, ...) -- 27
			return _self_0 -- 27
		end -- 27
	}) -- 27
	_base_0.__class = _class_0 -- 27
	YarnRunner = _class_0 -- 27
end -- 140
_module_0 = YarnRunner -- 142
return _module_0 -- 142
