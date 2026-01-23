-- [yue]: Script/Lib/YarnRunner.yue
local _module_0 = nil -- 1
local yarncompile = require("yarncompile") -- 9
local Content = require("Content") -- 10
local tonumber <const> = tonumber -- 11
local tostring <const> = tostring -- 11
local next <const> = next -- 11
local error <const> = error -- 11
local coroutine <const> = coroutine -- 11
local load <const> = load -- 11
local pairs <const> = pairs -- 11
local getmetatable <const> = getmetatable -- 11
local setmetatable <const> = setmetatable -- 11
local math <const> = math -- 11
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
	end -- 19
	line = lineMap[line] or line -- 24
	return tostring(title) .. ":" .. tostring(line) .. ": " .. tostring(msg) -- 25
end -- 13
local parseVariables -- 27
parseVariables = function(yarnText) -- 27
	local variables = { } -- 28
	local in_variables = false -- 29
	local current_var = { -- 30
		key = nil, -- 30
		value = nil -- 30
	} -- 30
	for line in yarnText:gmatch("([^\r\n]*)\r?\n?") do -- 31
		if not line:match("^%s*//") then -- 32
			break -- 32
		end -- 32
		local raw = line:gsub("^%s*//%s*", ""):gsub("%s+$", "") -- 33
		if raw == "variables:" then -- 34
			in_variables = true -- 35
		elseif in_variables and raw:match("^%-%s*key:") then -- 36
			if next(current_var) ~= nil then -- 37
				variables[#variables + 1] = current_var -- 38
				current_var = { } -- 39
			end -- 37
			current_var.key = raw:match("^%-%s*key:%s*(.+)") -- 40
		elseif in_variables and raw:match("^value:") then -- 41
			current_var.value = raw:match("^value:%s*(.+)") -- 42
		end -- 34
	end -- 31
	if next(current_var) ~= nil then -- 43
		variables[#variables + 1] = current_var -- 44
	end -- 43
	return variables -- 27
end -- 27
local extractYarnText -- 46
extractYarnText = function(yarnCode) -- 46
	local nodes = { } -- 47
	local count = 1 -- 48
	for body in yarnCode:gmatch("(.-)%s*===%s*[\n$]") do -- 49
		local meta, nodeBody = body:match("(.-)%s*---%s*\n(.*)") -- 50
		if meta and nodeBody then -- 51
			local title = meta:match("title%s*:%s*(%S+)") -- 52
			local node = { -- 53
				title = title, -- 53
				body = nodeBody:match("^%s*(.-)%s*$") -- 53
			} -- 53
			nodes[#nodes + 1] = node -- 54
		else -- 56
			error("missing title for node " .. tostring(count)) -- 56
		end -- 51
		count = count + 1 -- 57
	end -- 49
	return nodes -- 46
end -- 46
local YarnRunner -- 59
do -- 59
	local _class_0 -- 59
	local _base_0 = { -- 59
		gotoStory = function(self, title) -- 60
			local storyFunc = self.funcs[title] -- 61
			if not storyFunc then -- 62
				local yarnCode = self.codes[title] -- 63
				if not yarnCode then -- 64
					local err = "node \"" .. tostring(title) .. "\" is not exist" -- 65
					if self.startTitle then -- 66
						return false, err -- 67
					else -- 69
						coroutine.yield("Error", err) -- 69
						return -- 70
					end -- 66
				end -- 64
				local luaCode, err = yarncompile(yarnCode) -- 71
				if not luaCode then -- 72
					if self.startTitle then -- 73
						return false, tostring(title) .. ":" .. tostring(err) -- 74
					else -- 76
						coroutine.yield("Error", tostring(title) .. ":" .. tostring(err)) -- 76
						return -- 77
					end -- 73
				end -- 72
				self.codes[title] = luaCode -- 78
				local luaFunc -- 79
				luaFunc, err = load(luaCode, title) -- 79
				if not luaFunc then -- 80
					err = rewriteError(err, luaCode, title) -- 81
					if self.startTitle then -- 82
						return false, err -- 83
					else -- 85
						coroutine.yield("Error", err) -- 85
						return -- 86
					end -- 82
				end -- 80
				storyFunc = luaFunc() -- 87
				self.funcs[title] = storyFunc -- 88
			end -- 62
			local visitedCount -- 89
			do -- 89
				local _exp_0 = self.visited[title] -- 89
				if _exp_0 ~= nil then -- 89
					visitedCount = _exp_0 -- 89
				else -- 89
					visitedCount = 0 -- 89
				end -- 89
			end -- 89
			self.visited[title] = 1 + visitedCount -- 90
			do -- 91
				local _obj_0 = self.stories -- 91
				_obj_0[#_obj_0 + 1] = { -- 91
					title, -- 91
					coroutine.create(function() -- 91
						return storyFunc(title, self.state, self.command, self.yarn, (function() -- 92
							local _base_1 = self -- 92
							local _fn_0 = _base_1.gotoStory -- 92
							return _fn_0 and function(...) -- 92
								return _fn_0(_base_1, ...) -- 92
							end -- 92
						end)()) -- 92
					end) -- 91
				} -- 91
			end -- 91
			return true -- 94
		end, -- 135
		advance = function(self, choice) -- 135
			if self.startTitle then -- 136
				local success, err = self:gotoStory(self.startTitle) -- 137
				self.startTitle = nil -- 138
				if not success then -- 139
					return "Error", err -- 139
				end -- 139
			end -- 136
			if choice then -- 140
				if not self.option then -- 141
					return "Error", "there is no option to choose" -- 142
				end -- 141
				local title, branches -- 143
				do -- 143
					local _obj_0 = self.option -- 143
					title, branches = _obj_0.title, _obj_0.branches -- 143
				end -- 143
				if not (1 <= choice and choice <= #branches) then -- 144
					return "Error", "choice " .. tostring(choice) .. " is out of range" -- 145
				end -- 144
				local optionBranch = branches[choice] -- 146
				self.option = nil -- 147
				local _obj_0 = self.stories -- 148
				_obj_0[#_obj_0 + 1] = { -- 148
					title, -- 148
					coroutine.create(optionBranch) -- 148
				} -- 148
			elseif self.option then -- 149
				return "Error", "required a choice to continue" -- 150
			end -- 140
			local title -- 151
			local success, resultType, body, branches -- 152
			do -- 152
				local _des_0 = self.stories[#self.stories] -- 152
				if _des_0 then -- 152
					local story -- 152
					title, story = _des_0[1], _des_0[2] -- 152
					success, resultType, body, branches = coroutine.resume(story) -- 153
				end -- 152
			end -- 152
			if not success and #self.stories > 0 then -- 154
				self.stories = { } -- 155
				local err = rewriteError(resultType, self.codes[title], title) -- 156
				return "Error", err -- 157
			end -- 154
			if not resultType then -- 158
				if #self.stories > 0 then -- 159
					self.stories[#self.stories] = nil -- 160
					return self:advance() -- 161
				end -- 159
			end -- 158
			if "Dialog" == resultType then -- 163
				return "Text", body -- 164
			elseif "Option" == resultType then -- 165
				self.option = { -- 166
					title = title, -- 166
					branches = branches -- 166
				} -- 166
				return "Option", body -- 167
			elseif "Goto" == resultType then -- 168
				return self:advance() -- 169
			elseif "Command" == resultType then -- 170
				return "Command", body -- 171
			elseif "Error" == resultType or "Stop" == resultType then -- 172
				self.stories = { } -- 173
				return "Error", body -- 174
			else -- 176
				return nil, "end of the story" -- 176
			end -- 162
		end -- 59
	} -- 59
	if _base_0.__index == nil then -- 59
		_base_0.__index = _base_0 -- 59
	end -- 59
	_class_0 = setmetatable({ -- 59
		__init = function(self, filename, startTitle, state, command, testing) -- 96
			if state == nil then -- 96
				state = { } -- 96
			end -- 96
			if command == nil then -- 96
				command = { } -- 96
			end -- 96
			if testing == nil then -- 96
				testing = false -- 96
			end -- 96
			local yarnCode = Content:load(filename) -- 97
			if not yarnCode then -- 98
				error("failed to read yarn file \"" .. tostring(filename) .. "\"") -- 98
			end -- 98
			local nodes = extractYarnText(yarnCode) -- 99
			if not (#nodes > 0) then -- 100
				error("failed to load yarn code") -- 100
			end -- 100
			self.codes = { } -- 102
			self.funcs = { } -- 103
			self.state = state -- 104
			do -- 106
				local _tab_0 = { -- 106
					stop = function() -- 106
						return coroutine.yield("Stop") -- 106
					end -- 106
				} -- 107
				local _idx_0 = 1 -- 107
				for _key_0, _value_0 in pairs(command) do -- 107
					if _idx_0 == _key_0 then -- 107
						_tab_0[#_tab_0 + 1] = _value_0 -- 107
						_idx_0 = _idx_0 + 1 -- 107
					else -- 107
						_tab_0[_key_0] = _value_0 -- 107
					end -- 107
				end -- 107
				self.command = _tab_0 -- 106
			end -- 106
			setmetatable(self.command, getmetatable(command)) -- 109
			self.stories = { } -- 110
			self.visited = { } -- 111
			self.yarn = { -- 113
				dice = function(num) -- 113
					return math.random(num) -- 113
				end, -- 113
				random = function() -- 114
					return math.random() -- 114
				end, -- 114
				random_range = function(start, stop) -- 115
					return math.random(start, stop) -- 115
				end, -- 115
				visited = function(name) -- 116
					return (self.visited[name] ~= nil) -- 116
				end, -- 116
				visited_count = function(name) -- 117
					local _exp_0 = self.visited[name] -- 117
					if _exp_0 ~= nil then -- 117
						return _exp_0 -- 117
					else -- 117
						return 0 -- 117
					end -- 117
				end -- 117
			} -- 112
			self.startTitle = startTitle -- 119
			if testing then -- 120
				local variables = parseVariables(yarnCode) -- 121
				if variables then -- 121
					for _index_0 = 1, #variables do -- 122
						local _des_0 = variables[_index_0] -- 122
						local key, value = _des_0.key, _des_0.value -- 122
						if "true" == value then -- 123
							state[key] = true -- 124
						elseif "false" == value then -- 125
							state[key] = false -- 126
						else -- 128
							local num = tonumber(value) -- 128
							if num then -- 128
								state[key] = num -- 129
							else -- 131
								state[key] = value -- 131
							end -- 128
						end -- 123
					end -- 122
				end -- 121
			end -- 120
			for _index_0 = 1, #nodes do -- 132
				local _des_0 = nodes[_index_0] -- 132
				local title, body = _des_0.title, _des_0.body -- 132
				self.codes[title] = body -- 133
			end -- 132
		end, -- 59
		__base = _base_0, -- 59
		__name = "YarnRunner" -- 59
	}, { -- 59
		__index = _base_0, -- 59
		__call = function(cls, ...) -- 59
			local _self_0 = setmetatable({ }, _base_0) -- 59
			cls.__init(_self_0, ...) -- 59
			return _self_0 -- 59
		end -- 59
	}) -- 59
	_base_0.__class = _class_0 -- 59
	YarnRunner = _class_0 -- 59
end -- 59
_module_0 = YarnRunner -- 178
return _module_0 -- 1
