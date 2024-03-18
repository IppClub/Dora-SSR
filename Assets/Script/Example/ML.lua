-- [yue]: Script/Example/ML.yue
local App = dora.App -- 1
local table = _G.table -- 1
local ML = dora.ML -- 1
local math = _G.math -- 1
local pairs = _G.pairs -- 1
local threadLoop = dora.threadLoop -- 1
local _module_0 = dora.ImGui -- 1
local SetNextWindowPos = _module_0.SetNextWindowPos -- 1
local Vec2 = dora.Vec2 -- 1
local SetNextWindowSize = _module_0.SetNextWindowSize -- 1
local Begin = _module_0.Begin -- 1
local TextWrapped = _module_0.TextWrapped -- 1
local tostring = _G.tostring -- 1
local Button = _module_0.Button -- 1
local SameLine = _module_0.SameLine -- 1
local Separator = _module_0.Separator -- 1
local Checkbox = _module_0.Checkbox -- 1
local thread = dora.thread -- 1
local string = _G.string -- 1
local actions = { -- 3
	"观察", -- 3
	"侦查", -- 3
	"攀爬", -- 3
	"挥舞", -- 3
	"攻击", -- 3
	"破坏", -- 3
	"投掷", -- 3
	"采集", -- 3
	"挖掘", -- 3
	"采收", -- 3
	"沟通", -- 3
	"鼓舞", -- 3
	"恐吓" -- 3
} -- 3
local relationTags = { -- 5
	"友善", -- 5
	"中立", -- 5
	"敌对" -- 5
} -- 5
local bodyTypes = { -- 7
	"大型", -- 7
	"巨型" -- 7
} -- 7
local skills = { -- 9
	"迅速Lv1", -- 9
	"迅速Lv2" -- 9
} -- 9
local unitTags = { -- 11
	"生物", -- 11
	"挖掘资源", -- 11
	"采集资源", -- 11
	"可破坏", -- 11
	"可攀爬", -- 11
	"飞行" -- 11
} -- 11
local effectNames = { -- 13
	"揭示", -- 13
	"伤害", -- 13
	"破坏", -- 13
	"采集", -- 13
	"擒抱", -- 13
	"攀爬", -- 13
	"交涉", -- 13
	"恐吓" -- 13
} -- 13
local actionEffects = { -- 16
	["观察"] = { -- 17
		["生物"] = { -- 17
			"揭示", -- 17
			0, -- 17
			1 -- 17
		}, -- 17
		["友善"] = { -- 18
			"揭示", -- 18
			0, -- 18
			1 -- 18
		}, -- 18
		["中立"] = { -- 19
			"揭示", -- 19
			0, -- 19
			1 -- 19
		}, -- 19
		["敌对"] = { -- 20
			"揭示", -- 20
			0, -- 20
			1 -- 20
		}, -- 20
		["挖掘资源"] = { -- 21
			"揭示", -- 21
			0, -- 21
			1 -- 21
		}, -- 21
		["采集资源"] = { -- 22
			"揭示", -- 22
			0, -- 22
			1 -- 22
		}, -- 22
		["可破坏"] = { -- 23
			"揭示", -- 23
			0, -- 23
			1 -- 23
		}, -- 23
		["可攀爬"] = { -- 24
			"揭示", -- 24
			0, -- 24
			1 -- 24
		}, -- 24
		["巨型"] = { -- 25
			"揭示", -- 25
			0, -- 25
			0 -- 25
		}, -- 25
		["迅速Lv2"] = { -- 26
			"揭示", -- 26
			0, -- 26
			0 -- 26
		} -- 26
	}, -- 16
	["侦查"] = { -- 29
		["生物"] = { -- 29
			"揭示", -- 29
			1, -- 29
			1 -- 29
		}, -- 29
		["挖掘资源"] = { -- 30
			"揭示", -- 30
			1, -- 30
			1 -- 30
		}, -- 30
		["采集资源"] = { -- 31
			"揭示", -- 31
			1, -- 31
			1 -- 31
		}, -- 31
		["可破坏"] = { -- 32
			"揭示", -- 32
			1, -- 32
			1 -- 32
		}, -- 32
		["可攀爬"] = { -- 33
			"揭示", -- 33
			1, -- 33
			1 -- 33
		}, -- 33
		["飞行"] = { -- 34
			"揭示", -- 34
			1, -- 34
			1 -- 34
		}, -- 34
		["大型"] = { -- 35
			"揭示", -- 35
			1, -- 35
			1 -- 35
		}, -- 35
		["巨型"] = { -- 36
			"揭示", -- 36
			1, -- 36
			1 -- 36
		}, -- 36
		["迅速Lv1"] = { -- 37
			"揭示", -- 37
			1, -- 37
			1 -- 37
		}, -- 37
		["迅速Lv2"] = { -- 38
			"揭示", -- 38
			1, -- 38
			1 -- 38
		} -- 38
	}, -- 28
	["攀爬"] = { -- 41
		["友善"] = { -- 41
			"擒抱", -- 41
			0, -- 41
			1 -- 41
		}, -- 41
		["中立"] = { -- 42
			"擒抱", -- 42
			0, -- 42
			1 -- 42
		}, -- 42
		["可攀爬"] = { -- 43
			"攀爬", -- 43
			1, -- 43
			1 -- 43
		}, -- 43
		["大型"] = { -- 44
			"攀爬", -- 44
			1, -- 44
			1 -- 44
		}, -- 44
		["巨型"] = { -- 45
			"攀爬", -- 45
			1, -- 45
			1 -- 45
		} -- 45
	}, -- 40
	["挥舞"] = { -- 48
		["生物"] = { -- 48
			"伤害", -- 48
			0, -- 48
			1 -- 48
		}, -- 48
		["友善"] = { -- 49
			"取消伤害" -- 49
		}, -- 49
		["中立"] = { -- 50
			"取消伤害" -- 50
		}, -- 50
		["敌对"] = { -- 51
			"伤害", -- 51
			0, -- 51
			1 -- 51
		}, -- 51
		["挖掘资源"] = { -- 52
			"采集", -- 52
			0, -- 52
			1 -- 52
		}, -- 52
		["采集资源"] = { -- 53
			"采集", -- 53
			0, -- 53
			1 -- 53
		}, -- 53
		["可破坏"] = { -- 54
			"破坏", -- 54
			0, -- 54
			1 -- 54
		}, -- 54
		["可攀爬"] = { -- 55
			"破坏", -- 55
			0, -- 55
			1 -- 55
		}, -- 55
		["飞行"] = { -- 56
			"伤害", -- 56
			-1, -- 56
			1 -- 56
		}, -- 56
		["大型"] = { -- 57
			"伤害", -- 57
			0, -- 57
			1 -- 57
		}, -- 57
		["巨型"] = { -- 58
			"伤害", -- 58
			0, -- 58
			1 -- 58
		}, -- 58
		["迅速Lv1"] = { -- 59
			"伤害", -- 59
			0, -- 59
			0 -- 59
		}, -- 59
		["迅速Lv2"] = { -- 60
			"伤害", -- 60
			0, -- 60
			0 -- 60
		} -- 60
	}, -- 47
	["攻击"] = { -- 63
		["生物"] = { -- 63
			"伤害", -- 63
			1, -- 63
			1 -- 63
		}, -- 63
		["友善"] = { -- 64
			"取消伤害" -- 64
		}, -- 64
		["中立"] = { -- 65
			"伤害", -- 65
			0, -- 65
			1 -- 65
		}, -- 65
		["敌对"] = { -- 66
			"伤害", -- 66
			1, -- 66
			1 -- 66
		}, -- 66
		["挖掘资源"] = { -- 67
			"破坏", -- 67
			0, -- 67
			1 -- 67
		}, -- 67
		["采集资源"] = { -- 68
			"采集", -- 68
			0, -- 68
			1 -- 68
		}, -- 68
		["可破坏"] = { -- 69
			"破坏", -- 69
			1, -- 69
			1 -- 69
		}, -- 69
		["飞行"] = { -- 70
			"伤害", -- 70
			-1, -- 70
			1 -- 70
		}, -- 70
		["大型"] = { -- 71
			"伤害", -- 71
			1, -- 71
			1 -- 71
		}, -- 71
		["巨型"] = { -- 72
			"伤害", -- 72
			1, -- 72
			1 -- 72
		}, -- 72
		["迅速Lv1"] = { -- 73
			"伤害", -- 73
			0, -- 73
			1 -- 73
		}, -- 73
		["迅速Lv2"] = { -- 74
			"伤害", -- 74
			0, -- 74
			1 -- 74
		} -- 74
	}, -- 62
	["破坏"] = { -- 77
		["生物"] = { -- 77
			"伤害", -- 77
			0, -- 77
			1 -- 77
		}, -- 77
		["友善"] = { -- 78
			"取消伤害" -- 78
		}, -- 78
		["中立"] = { -- 79
			"伤害", -- 79
			0, -- 79
			1 -- 79
		}, -- 79
		["敌对"] = { -- 80
			"伤害", -- 80
			0, -- 80
			1 -- 80
		}, -- 80
		["挖掘资源"] = { -- 81
			"采集", -- 81
			0, -- 81
			1 -- 81
		}, -- 81
		["采集资源"] = { -- 82
			"破坏", -- 82
			1, -- 82
			1 -- 82
		}, -- 82
		["可破坏"] = { -- 83
			"破坏", -- 83
			1, -- 83
			1 -- 83
		}, -- 83
		["巨型"] = { -- 84
			"伤害", -- 84
			1, -- 84
			1 -- 84
		}, -- 84
		["迅速Lv1"] = { -- 85
			"伤害", -- 85
			0, -- 85
			0 -- 85
		}, -- 85
		["迅速Lv2"] = { -- 86
			"伤害", -- 86
			0, -- 86
			0 -- 86
		} -- 86
	}, -- 76
	["投掷"] = { -- 89
		["生物"] = { -- 89
			"伤害", -- 89
			1, -- 89
			1 -- 89
		}, -- 89
		["友善"] = { -- 90
			"取消伤害" -- 90
		}, -- 90
		["中立"] = { -- 91
			"伤害", -- 91
			0, -- 91
			1 -- 91
		}, -- 91
		["敌对"] = { -- 92
			"伤害", -- 92
			1, -- 92
			1 -- 92
		}, -- 92
		["可破坏"] = { -- 93
			"破坏", -- 93
			1, -- 93
			1 -- 93
		}, -- 93
		["飞行"] = { -- 94
			"伤害", -- 94
			1, -- 94
			1 -- 94
		}, -- 94
		["大型"] = { -- 95
			"伤害", -- 95
			1, -- 95
			1 -- 95
		}, -- 95
		["巨型"] = { -- 96
			"伤害", -- 96
			1, -- 96
			1 -- 96
		}, -- 96
		["迅速Lv1"] = { -- 97
			"伤害", -- 97
			0, -- 97
			1 -- 97
		}, -- 97
		["迅速Lv2"] = { -- 98
			"伤害", -- 98
			0, -- 98
			1 -- 98
		} -- 98
	}, -- 88
	["采集"] = { -- 101
		["生物"] = { -- 101
			"伤害", -- 101
			0, -- 101
			1 -- 101
		}, -- 101
		["友善"] = { -- 102
			"伤害", -- 102
			0, -- 102
			1 -- 102
		}, -- 102
		["中立"] = { -- 103
			"伤害", -- 103
			0, -- 103
			1 -- 103
		}, -- 103
		["敌对"] = { -- 104
			"伤害", -- 104
			0, -- 104
			1 -- 104
		}, -- 104
		["挖掘资源"] = { -- 105
			"采集", -- 105
			0, -- 105
			1 -- 105
		}, -- 105
		["采集资源"] = { -- 106
			"采集", -- 106
			0, -- 106
			1 -- 106
		}, -- 106
		["可破坏"] = { -- 107
			"揭示", -- 107
			0, -- 107
			1 -- 107
		}, -- 107
		["可攀爬"] = { -- 108
			"揭示", -- 108
			0, -- 108
			1 -- 108
		}, -- 108
		["大型"] = { -- 109
			"伤害", -- 109
			0, -- 109
			1 -- 109
		} -- 109
	}, -- 100
	["挖掘"] = { -- 112
		["挖掘资源"] = { -- 112
			"采集", -- 112
			1, -- 112
			1 -- 112
		}, -- 112
		["采集资源"] = { -- 113
			"采集", -- 113
			0, -- 113
			1 -- 113
		}, -- 113
		["可破坏"] = { -- 114
			"破坏", -- 114
			1, -- 114
			1 -- 114
		}, -- 114
		["可攀爬"] = { -- 115
			"破坏", -- 115
			0, -- 115
			1 -- 115
		} -- 115
	}, -- 111
	["采收"] = { -- 118
		["友善"] = { -- 118
			"采集", -- 118
			0, -- 118
			1 -- 118
		}, -- 118
		["挖掘资源"] = { -- 119
			"采集", -- 119
			0, -- 119
			1 -- 119
		}, -- 119
		["采集资源"] = { -- 120
			"采集", -- 120
			1, -- 120
			1 -- 120
		} -- 120
	}, -- 117
	["沟通"] = { -- 123
		["生物"] = { -- 123
			"揭示", -- 123
			0, -- 123
			1 -- 123
		}, -- 123
		["友善"] = { -- 124
			"交涉", -- 124
			0, -- 124
			1 -- 124
		}, -- 124
		["中立"] = { -- 125
			"交涉", -- 125
			0, -- 125
			1 -- 125
		}, -- 125
		["敌对"] = { -- 126
			"揭示", -- 126
			0, -- 126
			1 -- 126
		}, -- 126
		["挖掘资源"] = { -- 127
			"揭示", -- 127
			0, -- 127
			1 -- 127
		}, -- 127
		["采集资源"] = { -- 128
			"揭示", -- 128
			0, -- 128
			1 -- 128
		}, -- 128
		["巨型"] = { -- 129
			"交涉", -- 129
			0, -- 129
			0 -- 129
		} -- 129
	}, -- 122
	["鼓舞"] = { -- 132
		["友善"] = { -- 132
			"交涉", -- 132
			0, -- 132
			1 -- 132
		}, -- 132
		["中立"] = { -- 133
			"交涉", -- 133
			0, -- 133
			1 -- 133
		} -- 133
	}, -- 131
	["恐吓"] = { -- 136
		["生物"] = { -- 136
			"恐吓", -- 136
			1, -- 136
			1 -- 136
		}, -- 136
		["友善"] = { -- 137
			"恐吓", -- 137
			1, -- 137
			1 -- 137
		}, -- 137
		["中立"] = { -- 138
			"恐吓", -- 138
			1, -- 138
			1 -- 138
		}, -- 138
		["敌对"] = { -- 139
			"恐吓", -- 139
			1, -- 139
			1 -- 139
		}, -- 139
		["飞行"] = { -- 140
			"恐吓", -- 140
			1, -- 140
			1 -- 140
		}, -- 140
		["大型"] = { -- 141
			"恐吓", -- 141
			0, -- 141
			1 -- 141
		} -- 141
	} -- 135
} -- 15
local newCreature -- 145
newCreature = function() -- 145
	local hints = { } -- 146
	local values = { } -- 147
	local tags = { } -- 148
	local record = { } -- 149
	local relationIndex = App.rand % #relationTags -- 150
	tags[#tags + 1] = relationTags[relationIndex + 1] -- 151
	hints[#hints + 1] = #relationTags -- 152
	values[#values + 1] = relationIndex -- 153
	record[#record + 1] = relationTags[relationIndex + 1] -- 154
	local bodyTypeIndex = App.rand % (#bodyTypes + 1) -- 155
	if bodyTypeIndex ~= 0 then -- 156
		tags[#tags + 1] = bodyTypes[bodyTypeIndex] -- 157
		record[#record + 1] = bodyTypes[bodyTypeIndex] -- 158
	else -- 160
		record[#record + 1] = "无" -- 160
	end -- 156
	hints[#hints + 1] = #bodyTypes + 1 -- 161
	values[#values + 1] = bodyTypeIndex -- 162
	local skillIndex = App.rand % (#skills + 1) -- 163
	if skillIndex ~= 0 then -- 164
		tags[#tags + 1] = skills[skillIndex] -- 165
		record[#record + 1] = skills[skillIndex] -- 166
	else -- 168
		record[#record + 1] = "无" -- 168
	end -- 164
	hints[#hints + 1] = #skills + 1 -- 169
	values[#values + 1] = skillIndex -- 170
	for i = 1, #unitTags do -- 171
		hints[#hints + 1] = 2 -- 172
		if App.rand % 2 == 1 then -- 173
			tags[#tags + 1] = unitTags[i] -- 174
			values[#values + 1] = 1 -- 175
			record[#record + 1] = "有" -- 176
		else -- 178
			values[#values + 1] = 0 -- 178
			record[#record + 1] = "无" -- 179
		end -- 173
	end -- 179
	return { -- 181
		name = table.concat(tags, ","), -- 181
		tags = tags, -- 182
		hints = hints, -- 183
		values = values, -- 184
		record = record -- 185
	} -- 186
end -- 145
local ql = ML.QLearner() -- 188
local getEffect -- 190
getEffect = function(tags, action) -- 190
	local effects = actionEffects[actions[action]] -- 191
	local cancelHarm = false -- 192
	local eset = { } -- 193
	for _index_0 = 1, #tags do -- 194
		local tag = tags[_index_0] -- 194
		local eff = effects[tag] -- 195
		if not eff then -- 196
			goto _continue_0 -- 196
		end -- 196
		if eff[1] == "取消伤害" then -- 197
			cancelHarm = true -- 198
		else -- 200
			do -- 200
				local e = eset[eff[1]] -- 200
				if e then -- 200
					local _update_0 = 1 -- 201
					e[_update_0] = e[_update_0] + eff[2] -- 201
					e[2] = math.max(e[2], eff[3]) -- 202
				else -- 204
					eset[eff[1]] = { -- 204
						eff[2], -- 204
						eff[3] -- 204
					} -- 204
				end -- 200
			end -- 200
		end -- 197
		::_continue_0:: -- 195
	end -- 204
	if cancelHarm then -- 205
		eset["伤害"] = nil -- 206
	end -- 205
	local _accum_0 = { } -- 207
	local _len_0 = 1 -- 207
	for k, v in pairs(eset) do -- 207
		local p = math.min(100, 50 + 20 * v[1]) -- 208
		if (1 + App.rand % 100) <= p then -- 209
			_accum_0[_len_0] = { -- 210
				k, -- 210
				v[2] -- 210
			} -- 210
		else -- 211
			goto _continue_1 -- 211
		end -- 209
		_len_0 = _len_0 + 1 -- 211
		::_continue_1:: -- 208
	end -- 211
	return _accum_0 -- 211
end -- 190
local newRoundTraining -- 213
newRoundTraining = function() -- 213
	local result = { } -- 214
	while #result == 0 do -- 215
		local unit = newCreature() -- 216
		local state = ML.QLearner:pack(unit.hints, unit.values) -- 217
		local action = ql:getBestAction(state) -- 218
		local randomAction = false -- 219
		if action == 0 then -- 220
			randomAction = true -- 221
			action = App.rand % #actions + 1 -- 222
		end -- 220
		do -- 223
			local _obj_0 = unit.record -- 223
			_obj_0[#_obj_0 + 1] = actions[action] -- 223
		end -- 223
		result = getEffect(unit.tags, action) -- 224
		if #result > 0 then -- 225
			return { -- 227
				name = unit.name, -- 227
				state = state, -- 228
				action = action, -- 229
				result = result, -- 230
				rand = randomAction, -- 231
				record = unit.record -- 232
			} -- 233
		else -- 235
			ql:update(state, action, -1) -- 235
		end -- 225
	end -- 235
end -- 213
local training = nil -- 237
local laborResult = nil -- 238
local effectFlags -- 239
do -- 239
	local _accum_0 = { } -- 239
	local _len_0 = 1 -- 239
	for i = 1, #effectNames do -- 239
		_accum_0[_len_0] = false -- 239
		_len_0 = _len_0 + 1 -- 239
	end -- 239
	effectFlags = _accum_0 -- 239
end -- 239
local manualOp = 0 -- 240
local selfTrained = false -- 241
local records = { -- 243
	{ -- 243
		"关系", -- 243
		"体型", -- 243
		"技能", -- 243
		"生物", -- 243
		"挖掘资源", -- 243
		"采集资源", -- 243
		"可破坏", -- 243
		"可攀爬", -- 243
		"飞行", -- 243
		"行动" -- 243
	}, -- 243
	{ -- 244
		"C", -- 244
		"C", -- 244
		"C", -- 244
		"C", -- 244
		"C", -- 244
		"C", -- 244
		"C", -- 244
		"C", -- 244
		"C", -- 244
		"C" -- 244
	} -- 244
} -- 242
local decisionStr = nil -- 246
local windowFlags = { -- 247
	"NoResize", -- 247
	"NoSavedSettings" -- 247
} -- 247
local _anon_func_0 = function(tostring, training) -- 256
	local _accum_0 = { } -- 256
	local _len_0 = 1 -- 256
	local _list_0 = training.result -- 256
	for _index_0 = 1, #_list_0 do -- 256
		local item = _list_0[_index_0] -- 256
		_accum_0[_len_0] = tostring(item[1]) .. ":" .. tostring(item[2]) -- 256
		_len_0 = _len_0 + 1 -- 256
	end -- 256
	return _accum_0 -- 256
end -- 256
local _anon_func_1 = function(tostring, result) -- 292
	local _accum_0 = { } -- 292
	local _len_0 = 1 -- 292
	for _index_0 = 1, #result do -- 292
		local _des_0 = result[_index_0] -- 292
		local k, v = _des_0[1], _des_0[2] -- 292
		_accum_0[_len_0] = tostring(k) .. ":" .. tostring(v) -- 292
		_len_0 = _len_0 + 1 -- 292
	end -- 292
	return _accum_0 -- 292
end -- 292
local _anon_func_2 = function(effectNames, effectFlags) -- 298
	local _accum_0 = { } -- 298
	local _len_0 = 1 -- 298
	for i = 1, #effectFlags do -- 298
		if effectFlags[i] then -- 298
			_accum_0[_len_0] = effectNames[i] -- 298
			_len_0 = _len_0 + 1 -- 298
		end -- 298
	end -- 298
	return _accum_0 -- 298
end -- 298
local _anon_func_3 = function(table, records) -- 351
	local _accum_0 = { } -- 351
	local _len_0 = 1 -- 351
	for _index_0 = 1, #records do -- 351
		local r = records[_index_0] -- 351
		_accum_0[_len_0] = table.concat(r, ",") -- 351
		_len_0 = _len_0 + 1 -- 351
	end -- 351
	return _accum_0 -- 351
end -- 351
local _anon_func_4 = function(name, tostring, op, value) -- 355
	if name ~= "" then -- 355
		return "if " .. tostring(name) .. " " .. tostring(op) .. " " .. tostring(op == '==' and "\"" .. tostring(value) .. "\"" or value) -- 356
	else -- 358
		return tostring(op) .. " \"" .. tostring(value) .. "\"" -- 358
	end -- 355
end -- 355
return threadLoop(function() -- 248
	local width, height -- 249
	do -- 249
		local _obj_0 = App.visualSize -- 249
		width, height = _obj_0.width, _obj_0.height -- 249
	end -- 249
	SetNextWindowPos(Vec2(width / 2 - 300, height / 2 - 300), "FirstUseEver") -- 250
	SetNextWindowSize(Vec2(600, 600), "FirstUseEver") -- 251
	return Begin("Fairy", windowFlags, function() -- 252
		if training then -- 253
			TextWrapped("生物: " .. tostring(training.name)) -- 254
			TextWrapped("执行动作: " .. tostring(actions[training.action])) -- 255
			TextWrapped("取得效果: " .. tostring(table.concat(_anon_func_0(tostring, training), ", "))) -- 256
			TextWrapped("手工训练记录数: " .. tostring(manualOp)) -- 257
			if training.rand then -- 258
				TextWrapped("[执行了随机动作]") -- 259
			else -- 261
				TextWrapped("[执行了已习得动作]") -- 261
			end -- 258
			if Button("表扬") then -- 262
				manualOp = manualOp + 1 -- 263
				ql:update(training.state, training.action, 1) -- 264
				training = newRoundTraining() -- 265
				records[#records + 1] = training.record -- 266
			end -- 262
			SameLine() -- 267
			if Button("批评") then -- 268
				manualOp = manualOp + 1 -- 269
				ql:update(training.state, training.action, -1) -- 270
				training = newRoundTraining() -- 271
			end -- 268
			SameLine() -- 272
			if Button("跳过") then -- 273
				training = newRoundTraining() -- 274
			end -- 273
		else -- 276
			if Button("开始人工训练") then -- 276
				training = newRoundTraining() -- 277
			end -- 276
		end -- 253
		Separator() -- 278
		if Button("对付100个随机生物") then -- 279
			local result = { } -- 280
			local validAction = 0 -- 281
			for i = 1, 100 do -- 282
				local res = newRoundTraining() -- 283
				if not res.rand then -- 284
					validAction = validAction + 1 -- 284
				end -- 284
				local _list_0 = res.result -- 285
				for _index_0 = 1, #_list_0 do -- 285
					local item = _list_0[_index_0] -- 285
					if result[item[1]] then -- 286
						local _update_0 = item[1] -- 287
						result[_update_0] = result[_update_0] + item[2] -- 287
					else -- 289
						result[item[1]] = item[2] -- 289
					end -- 286
				end -- 289
			end -- 289
			do -- 290
				local _accum_0 = { } -- 290
				local _len_0 = 1 -- 290
				for k, v in pairs(result) do -- 290
					_accum_0[_len_0] = { -- 290
						k, -- 290
						v -- 290
					} -- 290
					_len_0 = _len_0 + 1 -- 290
				end -- 290
				result = _accum_0 -- 290
			end -- 290
			table.sort(result, function(a, b) -- 291
				return b[2] < a[2] -- 291
			end) -- 291
			laborResult = table.concat(_anon_func_1(tostring, result), ", ") -- 292
			laborResult = laborResult .. "\n习得动作生效次数: " .. tostring(validAction) .. "/100" -- 293
		end -- 279
		if laborResult then -- 294
			TextWrapped(laborResult) -- 294
		end -- 294
		Separator() -- 295
		local doSelfTraining = false -- 296
		if selfTrained then -- 297
			local target = table.concat(_anon_func_2(effectNames, effectFlags), ", ") -- 298
			TextWrapped("已完成自我训练, 目标: " .. tostring(target)) -- 299
			if Button("遗忘") then -- 300
				selfTrained = false -- 301
				ql = ML.QLearner() -- 302
			end -- 300
		else -- 304
			TextWrapped("选择训练目标") -- 304
			for i = 1, #effectFlags do -- 305
				local _ -- 306
				_, effectFlags[i] = Checkbox(effectNames[i], effectFlags[i]) -- 306
			end -- 306
			doSelfTraining = Button("进行自我训练") -- 307
		end -- 297
		if doSelfTraining then -- 308
			selfTrained = true -- 309
			ql = ML.QLearner() -- 310
			local targetEffects -- 311
			do -- 311
				local _tbl_0 = { } -- 311
				for i = 1, #effectFlags do -- 311
					if effectFlags[i] then -- 311
						_tbl_0[effectNames[i]] = true -- 311
					end -- 311
				end -- 311
				targetEffects = _tbl_0 -- 311
			end -- 311
			local hints = { -- 313
				#relationTags, -- 313
				#bodyTypes + 1, -- 314
				#skills + 1 -- 315
			} -- 312
			for i = 1, #unitTags do -- 317
				hints[#hints + 1] = 2 -- 318
			end -- 318
			local values = { } -- 319
			local l1 = #relationTags - 1 -- 320
			local l2 = #bodyTypes -- 321
			local l3 = #skills -- 322
			for i1 = 0, l1 do -- 323
				for i2 = 0, l2 do -- 323
					for i3 = 0, l3 do -- 323
						for i4 = 0, 1 do -- 324
							for i5 = 0, 1 do -- 324
								for i6 = 0, 1 do -- 324
									for i7 = 0, 1 do -- 325
										for i8 = 0, 1 do -- 325
											for i9 = 0, 1 do -- 325
												local tags = { } -- 326
												tags[#tags + 1] = relationTags[i1 + 1] -- 327
												local bodyTypeIndex = i2 -- 328
												if bodyTypeIndex ~= 0 then -- 329
													tags[#tags + 1] = bodyTypes[bodyTypeIndex] -- 330
												end -- 329
												local skillIndex = i3 -- 331
												if skillIndex ~= 0 then -- 332
													tags[#tags + 1] = skills[skillIndex] -- 333
												end -- 332
												if i4 ~= 0 then -- 334
													tags[#tags + 1] = unitTags[1] -- 334
												end -- 334
												if i5 ~= 0 then -- 335
													tags[#tags + 1] = unitTags[2] -- 335
												end -- 335
												if i6 ~= 0 then -- 336
													tags[#tags + 1] = unitTags[3] -- 336
												end -- 336
												if i7 ~= 0 then -- 337
													tags[#tags + 1] = unitTags[4] -- 337
												end -- 337
												if i8 ~= 0 then -- 338
													tags[#tags + 1] = unitTags[5] -- 338
												end -- 338
												if i9 ~= 0 then -- 339
													tags[#tags + 1] = unitTags[6] -- 339
												end -- 339
												local state = ML.QLearner:pack(hints, { -- 340
													i1, -- 340
													i2, -- 340
													i3, -- 340
													i4, -- 340
													i5, -- 340
													i6, -- 340
													i7, -- 340
													i8, -- 340
													i9 -- 340
												}) -- 340
												for action = 1, #actions do -- 341
													local result = getEffect(tags, action) -- 342
													local r = 0 -- 343
													for _index_0 = 1, #result do -- 344
														local _des_0 = result[_index_0] -- 344
														local k, v = _des_0[1], _des_0[2] -- 344
														if targetEffects[k] then -- 345
															r = r + v -- 346
														end -- 345
													end -- 346
													ql:update(state, action, r == 0 and -1 or r) -- 347
												end -- 347
											end -- 347
										end -- 347
									end -- 347
								end -- 347
							end -- 347
						end -- 347
					end -- 347
				end -- 347
			end -- 347
		end -- 308
		Separator() -- 348
		TextWrapped("总结人工训练思维逻辑") -- 349
		if Button("开始总结") and #records > 2 then -- 350
			local dataStr = table.concat(_anon_func_3(table, records), "\n") -- 351
			thread(function() -- 352
				local lines = { } -- 353
				ML.BuildDecisionTreeAsync(dataStr, 0, function(depth, name, op, value) -- 354
					local line = string.rep("\t", depth) .. _anon_func_4(name, tostring, op, value) -- 355
					lines[#lines + 1] = line -- 359
				end) -- 354
				decisionStr = table.concat(lines, "\n") -- 360
			end) -- 352
		end -- 350
		if decisionStr then -- 361
			return TextWrapped(decisionStr) -- 361
		end -- 361
	end) -- 361
end) -- 361
