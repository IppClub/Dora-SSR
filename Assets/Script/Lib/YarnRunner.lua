-- [yue]: Script/Lib/YarnRunner.yue
local tonumber = _G.tonumber -- 1
local tostring = _G.tostring -- 1
local print = _G.print -- 1
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
		print(line) -- 31
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
	end -- 42
	if next(current_var) ~= nil then -- 43
		variables[#variables + 1] = current_var -- 44
	end -- 43
	return variables -- 44
end -- 26
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
	end -- 57
	return nodes -- 57
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
			end -- 93
			return true -- 94
		end, -- 136
		advance = function(self, choice) -- 136
			if self.startTitle then -- 137
				local success, err = self:gotoStory(self.startTitle) -- 138
				self.startTitle = nil -- 139
				if not success then -- 140
					return "Error", err -- 140
				end -- 140
			end -- 137
			if choice then -- 141
				if not self.option then -- 142
					return "Error", "there is no option to choose" -- 143
				end -- 142
				local title, branches -- 144
				do -- 144
					local _obj_0 = self.option -- 144
					title, branches = _obj_0.title, _obj_0.branches -- 144
				end -- 144
				if not (1 <= choice and choice <= #branches) then -- 145
					return "Error", "choice " .. tostring(choice) .. " is out of range" -- 146
				end -- 145
				local optionBranch = branches[choice] -- 147
				self.option = nil -- 148
				local _obj_0 = self.stories -- 149
				_obj_0[#_obj_0 + 1] = { -- 149
					title, -- 149
					coroutine.create(optionBranch) -- 149
				} -- 149
			elseif self.option then -- 150
				return "Error", "required a choice to continue" -- 151
			end -- 141
			local title -- 152
			local success, resultType, body, branches -- 153
			do -- 153
				local storyItem = self.stories[#self.stories] -- 153
				if storyItem then -- 153
					local story -- 154
					title, story = storyItem[1], storyItem[2] -- 154
					success, resultType, body, branches = coroutine.resume(story) -- 155
				end -- 153
			end -- 153
			if not success and #self.stories > 0 then -- 156
				self.stories = { } -- 157
				local err = rewriteError(resultType, self.codes[title], title) -- 158
				return "Error", err -- 159
			end -- 156
			if not resultType then -- 160
				if #self.stories > 0 then -- 161
					self.stories[#self.stories] = nil -- 162
					return self:advance() -- 163
				end -- 161
			end -- 160
			if "Dialog" == resultType then -- 165
				return "Text", body -- 166
			elseif "Option" == resultType then -- 167
				self.option = { -- 168
					title = title, -- 168
					branches = branches -- 168
				} -- 168
				return "Option", body -- 169
			elseif "Goto" == resultType then -- 170
				return self:advance() -- 171
			elseif "Command" == resultType then -- 172
				return "Command", body -- 173
			elseif "Error" == resultType or "Stop" == resultType then -- 174
				self.stories = { } -- 175
				return "Error", body -- 176
			else -- 178
				return nil, "end of the story" -- 178
			end -- 178
		end -- 59
	} -- 59
	if _base_0.__index == nil then -- 59
		_base_0.__index = _base_0 -- 59
	end -- 178
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
						end -- 131
					end -- 131
				end -- 121
			end -- 120
			for _index_0 = 1, #nodes do -- 132
				local node = nodes[_index_0] -- 132
				local title, body = node.title, node.body -- 133
				self.codes[title] = body -- 134
			end -- 134
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
end -- 178
_module_0 = YarnRunner -- 180
return _module_0 -- 180
