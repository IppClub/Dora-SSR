-- [yue]: Script/Lib/YarnRunner.yue
local tonumber = _G.tonumber -- 1
local tostring = _G.tostring -- 1
local next = _G.next -- 1
local error = _G.error -- 1
local setmetatable = _G.setmetatable -- 1
local coroutine = _G.coroutine -- 1
local load = _G.load -- 1
local pairs = _G.pairs -- 1
local getmetatable = _G.getmetatable -- 1
local math = _G.math -- 1
local _module_0 = nil -- 1
local yarncompile = require("yarncompile") -- 9
local Content = require("Content") -- 10
local rewriteError -- 12
rewriteError = function(err, luaCode, title) -- 12
	local line, msg = err:match(".*:(%d+):%s*(.*)") -- 13
	line = tonumber(line) -- 14
	local current = 1 -- 15
	local lastLine = 1 -- 16
	local lineMap = { } -- 17
	for lineCode in luaCode:gmatch("([^\r\n]*)\r?\n?") do -- 18
		local num = lineCode:match("--%s*(%d+)%s*$") -- 19
		if num then -- 20
			lastLine = tonumber(num) -- 20
		end -- 20
		lineMap[current] = lastLine -- 21
		current = current + 1 -- 22
	end -- 22
	line = lineMap[line] or line -- 23
	return tostring(title) .. ":" .. tostring(line) .. ": " .. tostring(msg) -- 24
end -- 12
local parseVariables -- 26
parseVariables = function(yarnText) -- 26
	local variables = { } -- 27
	local in_variables = false -- 28
	local current_var = { } -- 29
	for line in yarnText:gmatch("([^\r\n]*)\r?\n?") do -- 30
		if not line:match("^%s*//") then -- 31
			break -- 31
		end -- 31
		local raw = line:gsub("^%s*//%s*", ""):gsub("%s+$", "") -- 32
		if raw == "variables:" then -- 33
			in_variables = true -- 34
		elseif in_variables and raw:match("^%-%s*key:") then -- 35
			if next(current_var) ~= nil then -- 36
				variables[#variables + 1] = current_var -- 37
				current_var = { } -- 38
			end -- 36
			current_var.key = raw:match("^%-%s*key:%s*(.+)") -- 39
		elseif in_variables and raw:match("^value:") then -- 40
			current_var.value = raw:match("^value:%s*(.+)") -- 41
		end -- 33
	end -- 41
	if next(current_var) ~= nil then -- 42
		variables[#variables + 1] = current_var -- 43
	end -- 42
	return variables -- 43
end -- 26
local extractYarnText -- 45
extractYarnText = function(yarnCode) -- 45
	local nodes = { } -- 46
	local count = 1 -- 47
	for body in yarnCode:gmatch("(.-)%s*===%s*[\n$]") do -- 48
		local meta, nodeBody = body:match("(.-)%s*---%s*\n(.*)") -- 49
		if meta and nodeBody then -- 50
			local title = meta:match("title%s*:%s*(%S+)") -- 51
			local node = { -- 52
				title = title, -- 52
				body = nodeBody:match("^%s*(.-)%s*$") -- 52
			} -- 52
			nodes[#nodes + 1] = node -- 53
		else -- 55
			error("missing title for node " .. tostring(count)) -- 55
		end -- 50
		count = count + 1 -- 56
	end -- 56
	return nodes -- 56
end -- 45
local YarnRunner -- 58
do -- 58
	local _class_0 -- 58
	local _base_0 = { -- 58
		gotoStory = function(self, title) -- 59
			local storyFunc = self.funcs[title] -- 60
			if not storyFunc then -- 61
				local yarnCode = self.codes[title] -- 62
				if not yarnCode then -- 63
					local err = "node \"" .. tostring(title) .. "\" is not exist" -- 64
					if self.startTitle then -- 65
						return false, err -- 66
					else -- 68
						coroutine.yield("Error", err) -- 68
						return -- 69
					end -- 65
				end -- 63
				local luaCode, err = yarncompile(yarnCode) -- 70
				if not luaCode then -- 71
					if self.startTitle then -- 72
						return false, tostring(title) .. ":" .. tostring(err) -- 73
					else -- 75
						coroutine.yield("Error", tostring(title) .. ":" .. tostring(err)) -- 75
						return -- 76
					end -- 72
				end -- 71
				self.codes[title] = luaCode -- 77
				local luaFunc -- 78
				luaFunc, err = load(luaCode, title) -- 78
				if not luaFunc then -- 79
					err = rewriteError(err, luaCode, title) -- 80
					if self.startTitle then -- 81
						return false, err -- 82
					else -- 84
						coroutine.yield("Error", err) -- 84
						return -- 85
					end -- 81
				end -- 79
				storyFunc = luaFunc() -- 86
				self.funcs[title] = storyFunc -- 87
			end -- 61
			local visitedCount -- 88
			do -- 88
				local _exp_0 = self.visited[title] -- 88
				if _exp_0 ~= nil then -- 88
					visitedCount = _exp_0 -- 88
				else -- 88
					visitedCount = 0 -- 88
				end -- 88
			end -- 88
			self.visited[title] = 1 + visitedCount -- 89
			do -- 90
				local _obj_0 = self.stories -- 90
				_obj_0[#_obj_0 + 1] = { -- 90
					title, -- 90
					coroutine.create(function() -- 90
						return storyFunc(title, self.state, self.command, self.yarn, (function() -- 91
							local _base_1 = self -- 91
							local _fn_0 = _base_1.gotoStory -- 91
							return _fn_0 and function(...) -- 91
								return _fn_0(_base_1, ...) -- 91
							end -- 91
						end)()) -- 91
					end) -- 90
				} -- 90
			end -- 92
			return true -- 93
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
				local storyItem = self.stories[#self.stories] -- 152
				if storyItem then -- 152
					local story -- 153
					title, story = storyItem[1], storyItem[2] -- 153
					success, resultType, body, branches = coroutine.resume(story) -- 154
				end -- 152
			end -- 152
			if not success and #self.stories > 0 then -- 155
				self.stories = { } -- 156
				local err = rewriteError(resultType, self.codes[title], title) -- 157
				return "Error", err -- 158
			end -- 155
			if not resultType then -- 159
				if #self.stories > 0 then -- 160
					self.stories[#self.stories] = nil -- 161
					return self:advance() -- 162
				end -- 160
			end -- 159
			if "Dialog" == resultType then -- 164
				return "Text", body -- 165
			elseif "Option" == resultType then -- 166
				self.option = { -- 167
					title = title, -- 167
					branches = branches -- 167
				} -- 167
				return "Option", body -- 168
			elseif "Goto" == resultType then -- 169
				return self:advance() -- 170
			elseif "Command" == resultType then -- 171
				return "Command", body -- 172
			elseif "Error" == resultType or "Stop" == resultType then -- 173
				self.stories = { } -- 174
				return "Error", body -- 175
			else -- 177
				return nil, "end of the story" -- 177
			end -- 177
		end -- 58
	} -- 58
	if _base_0.__index == nil then -- 58
		_base_0.__index = _base_0 -- 58
	end -- 177
	_class_0 = setmetatable({ -- 58
		__init = function(self, filename, startTitle, state, command, testing) -- 95
			if state == nil then -- 95
				state = { } -- 95
			end -- 95
			if command == nil then -- 95
				command = { } -- 95
			end -- 95
			if testing == nil then -- 95
				testing = false -- 95
			end -- 95
			local yarnCode = Content:load(filename) -- 96
			if not yarnCode then -- 97
				error("failed to read yarn file \"" .. tostring(filename) .. "\"") -- 97
			end -- 97
			local nodes = extractYarnText(yarnCode) -- 98
			if not (#nodes > 0) then -- 99
				error("failed to load yarn code") -- 99
			end -- 99
			self.codes = { } -- 101
			self.funcs = { } -- 102
			self.state = state -- 103
			do -- 105
				local _tab_0 = { -- 105
					stop = function() -- 105
						return coroutine.yield("Stop") -- 105
					end -- 105
				} -- 106
				local _idx_0 = 1 -- 106
				for _key_0, _value_0 in pairs(command) do -- 106
					if _idx_0 == _key_0 then -- 106
						_tab_0[#_tab_0 + 1] = _value_0 -- 106
						_idx_0 = _idx_0 + 1 -- 106
					else -- 106
						_tab_0[_key_0] = _value_0 -- 106
					end -- 106
				end -- 106
				self.command = _tab_0 -- 105
			end -- 105
			setmetatable(self.command, getmetatable(command)) -- 108
			self.stories = { } -- 109
			self.visited = { } -- 110
			self.yarn = { -- 112
				dice = function(num) -- 112
					return math.random(num) -- 112
				end, -- 112
				random = function() -- 113
					return math.random() -- 113
				end, -- 113
				random_range = function(start, stop) -- 114
					return math.random(start, stop) -- 114
				end, -- 114
				visited = function(name) -- 115
					return (self.visited[name] ~= nil) -- 115
				end, -- 115
				visited_count = function(name) -- 116
					local _exp_0 = self.visited[name] -- 116
					if _exp_0 ~= nil then -- 116
						return _exp_0 -- 116
					else -- 116
						return 0 -- 116
					end -- 116
				end -- 116
			} -- 111
			self.startTitle = startTitle -- 118
			if testing then -- 119
				local variables = parseVariables(yarnCode) -- 120
				if variables then -- 120
					for _index_0 = 1, #variables do -- 121
						local _des_0 = variables[_index_0] -- 121
						local key, value = _des_0.key, _des_0.value -- 121
						if "true" == value then -- 122
							state[key] = true -- 123
						elseif "false" == value then -- 124
							state[key] = false -- 125
						else -- 127
							local num = tonumber(value) -- 127
							if num then -- 127
								state[key] = num -- 128
							else -- 130
								state[key] = value -- 130
							end -- 127
						end -- 130
					end -- 130
				end -- 120
			end -- 119
			for _index_0 = 1, #nodes do -- 131
				local node = nodes[_index_0] -- 131
				local title, body = node.title, node.body -- 132
				self.codes[title] = body -- 133
			end -- 133
		end, -- 58
		__base = _base_0, -- 58
		__name = "YarnRunner" -- 58
	}, { -- 58
		__index = _base_0, -- 58
		__call = function(cls, ...) -- 58
			local _self_0 = setmetatable({ }, _base_0) -- 58
			cls.__init(_self_0, ...) -- 58
			return _self_0 -- 58
		end -- 58
	}) -- 58
	_base_0.__class = _class_0 -- 58
	YarnRunner = _class_0 -- 58
end -- 177
_module_0 = YarnRunner -- 179
return _module_0 -- 179
