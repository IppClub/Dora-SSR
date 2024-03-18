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
local yarncompile = require("yarncompile") -- 1
local Content = require("Content") -- 2
local json = require("json") -- 3
local rewriteError -- 5
rewriteError = function(err, luaCode, title) -- 5
	local line, msg = err:match(".*:(%d+):%s*(.*)") -- 6
	line = tonumber(line) -- 7
	local current = 1 -- 8
	local lastLine = 1 -- 9
	local lineMap = { } -- 10
	for lineCode in luaCode:gmatch("([^\r\n]*)\r?\n?") do -- 11
		local num = lineCode:match("--%s*(%d+)%s*$") -- 12
		if num then -- 13
			lastLine = tonumber(num) -- 13
		end -- 13
		lineMap[current] = lastLine -- 14
		current = current + 1 -- 15
	end -- 15
	line = lineMap[line] or line -- 16
	return tostring(title) .. ":" .. tostring(line) .. ": " .. tostring(msg) -- 17
end -- 5
local YarnRunner -- 19
do -- 19
	local _class_0 -- 19
	local _base_0 = { -- 19
		gotoStory = function(self, title) -- 20
			local storyFunc = self.funcs[title] -- 21
			if not storyFunc then -- 22
				local yarnCode = self.codes[title] -- 23
				local luaCode, err = yarncompile(yarnCode) -- 24
				if not luaCode then -- 25
					if self.startTitle then -- 26
						return false, tostring(title) .. ":" .. tostring(err) -- 27
					else -- 29
						coroutine.yield("Error", tostring(title) .. ":" .. tostring(err)) -- 29
						return -- 30
					end -- 26
				end -- 25
				self.codes[title] = luaCode -- 31
				local luaFunc -- 32
				luaFunc, err = load(luaCode, title) -- 32
				if not luaFunc then -- 33
					err = rewriteError(err, luaCode, title) -- 34
					if self.startTitle then -- 35
						return false, err -- 36
					else -- 38
						coroutine.yield("Error", err) -- 38
						return -- 39
					end -- 35
				end -- 33
				storyFunc = luaFunc() -- 40
				self.funcs[title] = storyFunc -- 41
			end -- 22
			local visitedCount -- 42
			do -- 42
				local _exp_0 = self.visited[title] -- 42
				if _exp_0 ~= nil then -- 42
					visitedCount = _exp_0 -- 42
				else -- 42
					visitedCount = 0 -- 42
				end -- 42
			end -- 42
			self.visited[title] = 1 + visitedCount -- 43
			do -- 44
				local _obj_0 = self.stories -- 44
				_obj_0[#_obj_0 + 1] = { -- 44
					title, -- 44
					coroutine.create(function() -- 44
						return storyFunc(title, self.state, self.command, self.yarn, (function() -- 45
							local _base_1 = self -- 45
							local _fn_0 = _base_1.gotoStory -- 45
							return _fn_0 and function(...) -- 45
								return _fn_0(_base_1, ...) -- 45
							end -- 45
						end)()) -- 45
					end) -- 44
				} -- 44
			end -- 46
			return true -- 47
		end, -- 90
		advance = function(self, choice) -- 90
			if self.startTitle then -- 91
				local success, err = self:gotoStory(self.startTitle) -- 92
				self.startTitle = nil -- 93
				if not success then -- 94
					return "Error", err -- 94
				end -- 94
			end -- 91
			if choice then -- 95
				if not self.option then -- 96
					return "Error", "there is no option to choose" -- 97
				end -- 96
				local title, branches -- 98
				do -- 98
					local _obj_0 = self.option -- 98
					title, branches = _obj_0.title, _obj_0.branches -- 98
				end -- 98
				if not (1 <= choice and choice <= #branches) then -- 99
					return "Error", "choice " .. tostring(choice) .. " is out of range" -- 100
				end -- 99
				local optionBranch = branches[choice] -- 101
				self.option = nil -- 102
				do -- 103
					local _obj_0 = self.stories -- 103
					_obj_0[#_obj_0 + 1] = { -- 103
						title, -- 103
						coroutine.create(optionBranch) -- 103
					} -- 103
				end -- 103
			elseif self.option then -- 104
				return "Error", "required a choice to continue" -- 105
			end -- 95
			local title -- 106
			local success, resultType, body, branches -- 107
			do -- 107
				local storyItem = self.stories[#self.stories] -- 107
				if storyItem then -- 107
					local story -- 108
					title, story = storyItem[1], storyItem[2] -- 108
					success, resultType, body, branches = coroutine.resume(story) -- 109
				end -- 107
			end -- 107
			if not success and #self.stories > 0 then -- 110
				self.stories = { } -- 111
				local err = rewriteError(resultType, self.codes[title], title) -- 112
				return "Error", err -- 113
			end -- 110
			if not resultType then -- 114
				if #self.stories > 0 then -- 115
					self.stories[#self.stories] = nil -- 116
					return self:advance() -- 117
				end -- 115
			end -- 114
			if "Dialog" == resultType then -- 119
				return "Text", body -- 120
			elseif "Option" == resultType then -- 121
				self.option = { -- 122
					title = title, -- 122
					branches = branches -- 122
				} -- 122
				return "Option", body -- 123
			elseif "Goto" == resultType then -- 124
				return self:advance() -- 125
			elseif "Command" == resultType then -- 126
				return "Command", body -- 127
			elseif "Error" == resultType or "Stop" == resultType then -- 128
				self.stories = { } -- 129
				return "Error", body -- 130
			else -- 132
				return nil, "end of the story" -- 132
			end -- 132
		end -- 19
	} -- 19
	if _base_0.__index == nil then -- 19
		_base_0.__index = _base_0 -- 19
	end -- 132
	_class_0 = setmetatable({ -- 19
		__init = function(self, filename, startTitle, state, command, testing) -- 49
			if state == nil then -- 49
				state = { } -- 49
			end -- 49
			if command == nil then -- 49
				command = { } -- 49
			end -- 49
			if testing == nil then -- 49
				testing = false -- 49
			end -- 49
			local jsonCode = Content:load(filename) -- 50
			if not jsonCode then -- 51
				error("failed to read yarn file \"" .. tostring(filename) .. "\"") -- 51
			end -- 51
			local jsonObject = json.load(jsonCode) -- 52
			if not jsonObject then -- 53
				error("failed to load yarn json code") -- 53
			end -- 53
			self.codes = { } -- 55
			self.funcs = { } -- 56
			self.state = state -- 57
			do -- 59
				local _tab_0 = { -- 59
					stop = function() -- 59
						return coroutine.yield("Stop") -- 59
					end -- 59
				} -- 60
				local _idx_0 = 1 -- 60
				for _key_0, _value_0 in pairs(command) do -- 60
					if _idx_0 == _key_0 then -- 60
						_tab_0[#_tab_0 + 1] = _value_0 -- 60
						_idx_0 = _idx_0 + 1 -- 60
					else -- 60
						_tab_0[_key_0] = _value_0 -- 60
					end -- 60
				end -- 60
				self.command = _tab_0 -- 59
			end -- 59
			setmetatable(self.command, getmetatable(command)) -- 62
			self.stories = { } -- 63
			self.visited = { } -- 64
			self.yarn = { -- 66
				dice = function(num) -- 66
					return math.random(num) -- 66
				end, -- 66
				random = function() -- 67
					return math.random() -- 67
				end, -- 67
				random_range = function(start, stop) -- 68
					return math.random(start, stop) -- 68
				end, -- 68
				visited = function(name) -- 69
					return (self.visited[name] ~= nil) -- 69
				end, -- 69
				visited_count = function(name) -- 70
					local _exp_0 = self.visited[name] -- 70
					if _exp_0 ~= nil then -- 70
						return _exp_0 -- 70
					else -- 70
						return 0 -- 70
					end -- 70
				end -- 70
			} -- 65
			self.startTitle = startTitle -- 72
			if testing then -- 73
				do -- 74
					local variables -- 74
					do -- 74
						local _obj_0 = jsonObject.header -- 74
						if _obj_0 ~= nil then -- 74
							do -- 74
								local _obj_1 = _obj_0.pluginStorage -- 74
								if _obj_1 ~= nil then -- 74
									do -- 74
										local _obj_2 = _obj_1.Runner -- 74
										if _obj_2 ~= nil then -- 74
											variables = _obj_2.variables -- 74
										end -- 74
									end -- 74
								end -- 74
							end -- 74
						end -- 74
					end -- 74
					if variables then -- 74
						for _index_0 = 1, #variables do -- 75
							local _des_0 = variables[_index_0] -- 75
							local key, value = _des_0.key, _des_0.value -- 75
							if "true" == value then -- 76
								state[key] = true -- 77
							elseif "false" == value then -- 78
								state[key] = false -- 79
							else -- 81
								do -- 81
									local num = tonumber(value) -- 81
									if num then -- 81
										state[key] = num -- 82
									else -- 84
										state[key] = value -- 84
									end -- 81
								end -- 81
							end -- 84
						end -- 84
					end -- 74
				end -- 74
			end -- 73
			do -- 85
				local nodes = jsonObject.nodes -- 85
				if nodes then -- 85
					for _index_0 = 1, #nodes do -- 86
						local node = nodes[_index_0] -- 86
						local title, body = node.title, node.body -- 87
						self.codes[title] = body -- 88
					end -- 88
				end -- 85
			end -- 85
		end, -- 19
		__base = _base_0, -- 19
		__name = "YarnRunner" -- 19
	}, { -- 19
		__index = _base_0, -- 19
		__call = function(cls, ...) -- 19
			local _self_0 = setmetatable({ }, _base_0) -- 19
			cls.__init(_self_0, ...) -- 19
			return _self_0 -- 19
		end -- 19
	}) -- 19
	_base_0.__class = _class_0 -- 19
	YarnRunner = _class_0 -- 19
	_module_0 = _class_0 -- 19
end -- 132
return _module_0 -- 132
