-- [yue]: Script/Lib/YarnRunner.yue
local tonumber = _G.tonumber -- 1
local tostring = _G.tostring -- 1
local setmetatable = _G.setmetatable -- 1
local coroutine = _G.coroutine -- 1
local load = _G.load -- 1
local error = _G.error -- 1
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
local YarnRunner -- 27
do -- 27
	local _class_0 -- 27
	local _base_0 = { -- 27
		gotoStory = function(self, title) -- 28
			local storyFunc = self.funcs[title] -- 29
			if not storyFunc then -- 30
				local yarnCode = self.codes[title] -- 31
				if not yarnCode then -- 32
					local err = "node \"" .. tostring(title) .. "\" is not exist" -- 33
					if self.startTitle then -- 34
						return false, err -- 35
					else -- 37
						coroutine.yield("Error", err) -- 37
						return -- 38
					end -- 34
				end -- 32
				local luaCode, err = yarncompile(yarnCode) -- 39
				if not luaCode then -- 40
					if self.startTitle then -- 41
						return false, tostring(title) .. ":" .. tostring(err) -- 42
					else -- 44
						coroutine.yield("Error", tostring(title) .. ":" .. tostring(err)) -- 44
						return -- 45
					end -- 41
				end -- 40
				self.codes[title] = luaCode -- 46
				local luaFunc -- 47
				luaFunc, err = load(luaCode, title) -- 47
				if not luaFunc then -- 48
					err = rewriteError(err, luaCode, title) -- 49
					if self.startTitle then -- 50
						return false, err -- 51
					else -- 53
						coroutine.yield("Error", err) -- 53
						return -- 54
					end -- 50
				end -- 48
				storyFunc = luaFunc() -- 55
				self.funcs[title] = storyFunc -- 56
			end -- 30
			local visitedCount -- 57
			do -- 57
				local _exp_0 = self.visited[title] -- 57
				if _exp_0 ~= nil then -- 57
					visitedCount = _exp_0 -- 57
				else -- 57
					visitedCount = 0 -- 57
				end -- 57
			end -- 57
			self.visited[title] = 1 + visitedCount -- 58
			do -- 59
				local _obj_0 = self.stories -- 59
				_obj_0[#_obj_0 + 1] = { -- 59
					title, -- 59
					coroutine.create(function() -- 59
						return storyFunc(title, self.state, self.command, self.yarn, (function() -- 60
							local _base_1 = self -- 60
							local _fn_0 = _base_1.gotoStory -- 60
							return _fn_0 and function(...) -- 60
								return _fn_0(_base_1, ...) -- 60
							end -- 60
						end)()) -- 60
					end) -- 59
				} -- 59
			end -- 61
			return true -- 62
		end, -- 105
		advance = function(self, choice) -- 105
			if self.startTitle then -- 106
				local success, err = self:gotoStory(self.startTitle) -- 107
				self.startTitle = nil -- 108
				if not success then -- 109
					return "Error", err -- 109
				end -- 109
			end -- 106
			if choice then -- 110
				if not self.option then -- 111
					return "Error", "there is no option to choose" -- 112
				end -- 111
				local title, branches -- 113
				do -- 113
					local _obj_0 = self.option -- 113
					title, branches = _obj_0.title, _obj_0.branches -- 113
				end -- 113
				if not (1 <= choice and choice <= #branches) then -- 114
					return "Error", "choice " .. tostring(choice) .. " is out of range" -- 115
				end -- 114
				local optionBranch = branches[choice] -- 116
				self.option = nil -- 117
				local _obj_0 = self.stories -- 118
				_obj_0[#_obj_0 + 1] = { -- 118
					title, -- 118
					coroutine.create(optionBranch) -- 118
				} -- 118
			elseif self.option then -- 119
				return "Error", "required a choice to continue" -- 120
			end -- 110
			local title -- 121
			local success, resultType, body, branches -- 122
			do -- 122
				local storyItem = self.stories[#self.stories] -- 122
				if storyItem then -- 122
					local story -- 123
					title, story = storyItem[1], storyItem[2] -- 123
					success, resultType, body, branches = coroutine.resume(story) -- 124
				end -- 122
			end -- 122
			if not success and #self.stories > 0 then -- 125
				self.stories = { } -- 126
				local err = rewriteError(resultType, self.codes[title], title) -- 127
				return "Error", err -- 128
			end -- 125
			if not resultType then -- 129
				if #self.stories > 0 then -- 130
					self.stories[#self.stories] = nil -- 131
					return self:advance() -- 132
				end -- 130
			end -- 129
			if "Dialog" == resultType then -- 134
				return "Text", body -- 135
			elseif "Option" == resultType then -- 136
				self.option = { -- 137
					title = title, -- 137
					branches = branches -- 137
				} -- 137
				return "Option", body -- 138
			elseif "Goto" == resultType then -- 139
				return self:advance() -- 140
			elseif "Command" == resultType then -- 141
				return "Command", body -- 142
			elseif "Error" == resultType or "Stop" == resultType then -- 143
				self.stories = { } -- 144
				return "Error", body -- 145
			else -- 147
				return nil, "end of the story" -- 147
			end -- 147
		end -- 27
	} -- 27
	if _base_0.__index == nil then -- 27
		_base_0.__index = _base_0 -- 27
	end -- 147
	_class_0 = setmetatable({ -- 27
		__init = function(self, filename, startTitle, state, command, testing) -- 64
			if state == nil then -- 64
				state = { } -- 64
			end -- 64
			if command == nil then -- 64
				command = { } -- 64
			end -- 64
			if testing == nil then -- 64
				testing = false -- 64
			end -- 64
			local jsonCode = Content:load(filename) -- 65
			if not jsonCode then -- 66
				error("failed to read yarn file \"" .. tostring(filename) .. "\"") -- 66
			end -- 66
			local jsonObject = json.load(jsonCode) -- 67
			if not jsonObject then -- 68
				error("failed to load yarn json code") -- 68
			end -- 68
			self.codes = { } -- 70
			self.funcs = { } -- 71
			self.state = state -- 72
			do -- 74
				local _tab_0 = { -- 74
					stop = function() -- 74
						return coroutine.yield("Stop") -- 74
					end -- 74
				} -- 75
				local _idx_0 = 1 -- 75
				for _key_0, _value_0 in pairs(command) do -- 75
					if _idx_0 == _key_0 then -- 75
						_tab_0[#_tab_0 + 1] = _value_0 -- 75
						_idx_0 = _idx_0 + 1 -- 75
					else -- 75
						_tab_0[_key_0] = _value_0 -- 75
					end -- 75
				end -- 75
				self.command = _tab_0 -- 74
			end -- 74
			setmetatable(self.command, getmetatable(command)) -- 77
			self.stories = { } -- 78
			self.visited = { } -- 79
			self.yarn = { -- 81
				dice = function(num) -- 81
					return math.random(num) -- 81
				end, -- 81
				random = function() -- 82
					return math.random() -- 82
				end, -- 82
				random_range = function(start, stop) -- 83
					return math.random(start, stop) -- 83
				end, -- 83
				visited = function(name) -- 84
					return (self.visited[name] ~= nil) -- 84
				end, -- 84
				visited_count = function(name) -- 85
					local _exp_0 = self.visited[name] -- 85
					if _exp_0 ~= nil then -- 85
						return _exp_0 -- 85
					else -- 85
						return 0 -- 85
					end -- 85
				end -- 85
			} -- 80
			self.startTitle = startTitle -- 87
			if testing then -- 88
				local variables -- 89
				local _obj_0 = jsonObject.header -- 89
				if _obj_0 ~= nil then -- 89
					do -- 89
						local _obj_1 = _obj_0.pluginStorage -- 89
						if _obj_1 ~= nil then -- 89
							do -- 89
								local _obj_2 = _obj_1.Runner -- 89
								if _obj_2 ~= nil then -- 89
									variables = _obj_2.variables -- 89
								end -- 89
							end -- 89
						end -- 89
					end -- 89
				end -- 89
				if variables then -- 89
					for _index_0 = 1, #variables do -- 90
						local _des_0 = variables[_index_0] -- 90
						local key, value = _des_0.key, _des_0.value -- 90
						if "true" == value then -- 91
							state[key] = true -- 92
						elseif "false" == value then -- 93
							state[key] = false -- 94
						else -- 96
							local num = tonumber(value) -- 96
							if num then -- 96
								state[key] = num -- 97
							else -- 99
								state[key] = value -- 99
							end -- 96
						end -- 99
					end -- 99
				end -- 89
			end -- 88
			local nodes = jsonObject.nodes -- 100
			if nodes then -- 100
				for _index_0 = 1, #nodes do -- 101
					local node = nodes[_index_0] -- 101
					local title, body = node.title, node.body -- 102
					self.codes[title] = body -- 103
				end -- 103
			end -- 100
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
end -- 147
_module_0 = YarnRunner -- 149
return _module_0 -- 149
