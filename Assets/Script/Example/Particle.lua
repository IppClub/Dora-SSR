-- [yue]: Script/Example/Particle.yue
local BlendFunc = Dora.BlendFunc -- 1
local Color = Dora.Color -- 1
local Vec2 = Dora.Vec2 -- 1
local Buffer = Dora.Buffer -- 1
local Rect = Dora.Rect -- 1
local tolua = Dora.tolua -- 1
local tostring = _G.tostring -- 1
local string = _G.string -- 1
local Cache = Dora.Cache -- 1
local table = _G.table -- 1
local pairs = _G.pairs -- 1
local Particle = Dora.Particle -- 1
local Node = Dora.Node -- 1
local _module_0 = Dora.ImGui -- 1
local PushItemWidth = _module_0.PushItemWidth -- 1
local DragFloat = _module_0.DragFloat -- 1
local DragInt = _module_0.DragInt -- 1
local math = _G.math -- 1
local LabelText = _module_0.LabelText -- 1
local DragInt2 = _module_0.DragInt2 -- 1
local SetColorEditOptions = _module_0.SetColorEditOptions -- 1
local ColorEdit4 = _module_0.ColorEdit4 -- 1
local Checkbox = _module_0.Checkbox -- 1
local InputText = _module_0.InputText -- 1
local coroutine = _G.coroutine -- 1
local sleep = Dora.sleep -- 1
local threadLoop = Dora.threadLoop -- 1
local App = Dora.App -- 1
local SetNextWindowPos = _module_0.SetNextWindowPos -- 1
local SetNextWindowSize = _module_0.SetNextWindowSize -- 1
local Begin = _module_0.Begin -- 1
local Button = _module_0.Button -- 1
local print = _G.print -- 1
local Data = { -- 4
	Angle = { -- 4
		"B", -- 4
		"float", -- 4
		90 -- 4
	}, -- 4
	AngleVariance = { -- 5
		"C", -- 5
		"float", -- 5
		360 -- 5
	}, -- 5
	BlendFuncDestination = { -- 6
		"D", -- 6
		"BlendFunc", -- 6
		BlendFunc:get("One") -- 6
	}, -- 6
	BlendFuncSource = { -- 7
		"E", -- 7
		" BlendFunc", -- 7
		BlendFunc:get("SrcAlpha") -- 7
	}, -- 7
	Duration = { -- 8
		"F", -- 8
		"floatN", -- 8
		-1 -- 8
	}, -- 8
	EmissionRate = { -- 9
		"G", -- 9
		"float", -- 9
		350 -- 9
	}, -- 9
	FinishColor = { -- 10
		"H", -- 10
		"Color", -- 10
		Color(0xff000000) -- 10
	}, -- 10
	FinishColorVariance = { -- 11
		"I", -- 11
		"Color", -- 11
		Color(0x0) -- 11
	}, -- 11
	RotationStart = { -- 12
		"J", -- 12
		"float", -- 12
		0 -- 12
	}, -- 12
	RotationStartVariance = { -- 13
		"K", -- 13
		"float", -- 13
		0 -- 13
	}, -- 13
	RotationEnd = { -- 14
		"L", -- 14
		"float", -- 14
		0 -- 14
	}, -- 14
	RotationEndVariance = { -- 15
		"M", -- 15
		"float", -- 15
		0 -- 15
	}, -- 15
	FinishParticleSize = { -- 16
		"N", -- 16
		"floatN", -- 16
		-1 -- 16
	}, -- 16
	FinishParticleSizeVariance = { -- 17
		"O", -- 17
		"float", -- 17
		0 -- 17
	}, -- 17
	MaxParticles = { -- 18
		"P", -- 18
		"Uint32", -- 18
		100 -- 18
	}, -- 18
	ParticleLifespan = { -- 19
		"Q", -- 19
		"float", -- 19
		1 -- 19
	}, -- 19
	ParticleLifespanVariance = { -- 20
		"R", -- 20
		"float", -- 20
		0.5 -- 20
	}, -- 20
	StartPosition = { -- 21
		"S", -- 21
		"Vec2", -- 21
		Vec2(0, 0) -- 21
	}, -- 21
	StartPositionVariance = { -- 22
		"T", -- 22
		"Vec2", -- 22
		Vec2(0, 0) -- 22
	}, -- 22
	StartColor = { -- 23
		"U", -- 23
		"Color", -- 23
		Color(194, 64, 31, 255) -- 23
	}, -- 23
	StartColorVariance = { -- 24
		"V", -- 24
		"Color", -- 24
		Color(0x0) -- 24
	}, -- 24
	StartParticleSize = { -- 25
		"W", -- 25
		"float", -- 25
		30 -- 25
	}, -- 25
	StartParticleSizeVariance = { -- 26
		"X", -- 26
		"float", -- 26
		10 -- 26
	}, -- 26
	TextureName = { -- 27
		"Y", -- 27
		"string", -- 27
		"", -- 27
		Buffer(256) -- 27
	}, -- 27
	TextureRect = { -- 28
		"Z", -- 28
		"Rect", -- 28
		Rect(0, 0, 0, 0) -- 28
	}, -- 28
	EmitterType = { -- 29
		"a", -- 29
		"EmitterType", -- 29
		0 -- 29
	}, -- 29
	RotationIsDir = { -- 31
		"b", -- 31
		"bool", -- 31
		false -- 31
	}, -- 31
	Gravity = { -- 32
		"c", -- 32
		"Vec2", -- 32
		Vec2(0, 100) -- 32
	}, -- 32
	Speed = { -- 33
		"d", -- 33
		"float", -- 33
		20 -- 33
	}, -- 33
	SpeedVariance = { -- 34
		"e", -- 34
		"float", -- 34
		5 -- 34
	}, -- 34
	RadialAcceleration = { -- 35
		"f", -- 35
		"float", -- 35
		0 -- 35
	}, -- 35
	RadialAccelVariance = { -- 36
		"g", -- 36
		"float", -- 36
		0 -- 36
	}, -- 36
	TangentialAcceleration = { -- 37
		"h", -- 37
		"float", -- 37
		0 -- 37
	}, -- 37
	TangentialAccelVariance = { -- 38
		"i", -- 38
		"float", -- 38
		0 -- 38
	} -- 38
} -- 3
local toString -- 48
toString = function(value) -- 48
	local _exp_0 = tolua.type(value) -- 49
	if "number" == _exp_0 then -- 50
		return tostring(value) -- 51
	elseif "string" == _exp_0 then -- 52
		return value -- 53
	elseif "Rect" == _exp_0 then -- 54
		return tostring(value.x) .. "," .. tostring(value.y) .. "," .. tostring(value.width) .. "," .. tostring(value.height) -- 55
	elseif "boolean" == _exp_0 then -- 56
		return value and "1" or "0" -- 57
	elseif "Vec2" == _exp_0 then -- 58
		return tostring(value.x) .. "," .. tostring(value.y) -- 59
	elseif "Color" == _exp_0 then -- 60
		return string.format("%.2f,%.2f,%.2f,%.2f", value.r / 255, value.g / 255, value.b / 255, value.a / 255) -- 61
	end -- 61
end -- 48
Cache:update("__test__.par", "<A>" .. table.concat((function() -- 63
	local _accum_0 = { } -- 63
	local _len_0 = 1 -- 63
	for k, v in pairs(Data) do -- 63
		_accum_0[_len_0] = "<" .. tostring(v[1]) .. " A=\"" .. tostring(toString(v[3])) .. "\"/>" -- 63
		_len_0 = _len_0 + 1 -- 63
	end -- 63
	return _accum_0 -- 63
end)()) .. "</A>") -- 63
local particle -- 65
do -- 65
	local _with_0 = Particle("__test__.par") -- 65
	_with_0:start() -- 66
	particle = _with_0 -- 65
end -- 65
local root -- 68
do -- 68
	local _with_0 = Node() -- 68
	_with_0.scaleX = 2 -- 69
	_with_0.scaleY = 2 -- 70
	_with_0:addChild(particle) -- 71
	_with_0.touchEnabled = true -- 72
	_with_0:slot("TapMoved", function(touch) -- 73
		if not touch.first then -- 74
			return -- 74
		end -- 74
		particle.position = particle.position + (touch.delta / 2) -- 75
	end) -- 73
	root = _with_0 -- 68
end -- 68
local DataDirty = false -- 79
local Item -- 81
Item = function(name) -- 81
	return PushItemWidth(-180, function() -- 82
		local _exp_0 = Data[name][2] -- 83
		if "float" == _exp_0 then -- 84
			local changed -- 85
			changed, Data[name][3] = DragFloat(name, Data[name][3], 0.1, -1000, 1000, "%.1f") -- 85
			if changed then -- 86
				DataDirty = true -- 86
			end -- 86
		elseif "floatN" == _exp_0 then -- 87
			local changed -- 88
			changed, Data[name][3] = DragFloat(name, Data[name][3], 0.1, -1, 1000, "%.1f") -- 88
			if changed then -- 89
				DataDirty = true -- 89
			end -- 89
		elseif "Uint32" == _exp_0 then -- 90
			local changed -- 91
			changed, Data[name][3] = DragInt(name, math.floor(Data[name][3]), 1, 0, 1000) -- 91
			if changed then -- 92
				DataDirty = true -- 92
			end -- 92
		elseif "EmitterType" == _exp_0 then -- 93
			return LabelText("EmitterType", "Gravity") -- 94
		elseif "BlendFunc" == _exp_0 then -- 95
			return LabelText("BlendFunc", "Additive") -- 96
		elseif "Vec2" == _exp_0 then -- 97
			local x, y -- 98
			do -- 98
				local _obj_0 = Data[name][3] -- 98
				x, y = _obj_0.x, _obj_0.y -- 98
			end -- 98
			local changed -- 99
			changed, x, y = DragInt2(name, math.floor(x), math.floor(y), 1, -1000, 1000) -- 99
			if changed then -- 100
				DataDirty, Data[name][3] = true, Vec2(x, y) -- 100
			end -- 100
		elseif "Color" == _exp_0 then -- 101
			return PushItemWidth(-150, function() -- 102
				SetColorEditOptions({ -- 103
					"DisplayRGB" -- 103
				}) -- 103
				local changed = ColorEdit4(name, Data[name][3]) -- 104
				if changed then -- 105
					DataDirty = true -- 105
				end -- 105
			end) -- 105
		elseif "bool" == _exp_0 then -- 106
			local changed -- 107
			changed, Data[name][3] = Checkbox(name, Data[name][3]) -- 107
			if changed then -- 108
				DataDirty = true -- 108
			end -- 108
		elseif "string" == _exp_0 then -- 109
			local buffer = Data[name][4] -- 110
			local changed = InputText(name, buffer) -- 111
			if changed then -- 112
				DataDirty = true -- 113
				Data[name][3] = buffer:toString() -- 114
			end -- 112
		end -- 114
	end) -- 114
end -- 81
local _anon_func_0 = function(Data, pairs, toString, tostring) -- 121
	local _accum_0 = { } -- 121
	local _len_0 = 1 -- 121
	for k, v in pairs(Data) do -- 121
		_accum_0[_len_0] = "<" .. tostring(v[1]) .. " A=\"" .. tostring(toString(v[3])) .. "\"/>" -- 121
		_len_0 = _len_0 + 1 -- 121
	end -- 121
	return _accum_0 -- 121
end -- 121
local work = coroutine.wrap(function() -- 116
	while true do -- 117
		sleep(1) -- 118
		if DataDirty then -- 119
			DataDirty = false -- 120
			Cache:update("__test__.par", "<A>" .. table.concat(_anon_func_0(Data, pairs, toString, tostring)) .. "</A>") -- 121
			particle:removeFromParent() -- 122
			do -- 123
				local _with_0 = Particle("__test__.par") -- 123
				_with_0:start() -- 124
				particle = _with_0 -- 123
			end -- 123
			root:addChild(particle) -- 125
		end -- 119
	end -- 125
end) -- 116
local _anon_func_1 = function(Data, pairs, toString, tostring) -- 135
	local _accum_0 = { } -- 135
	local _len_0 = 1 -- 135
	for k, v in pairs(Data) do -- 135
		_accum_0[_len_0] = "<" .. tostring(v[1]) .. " A=\"" .. tostring(toString(v[3])) .. "\"/>" -- 135
		_len_0 = _len_0 + 1 -- 135
	end -- 135
	return _accum_0 -- 135
end -- 135
return threadLoop(function() -- 127
	local width, height -- 128
	do -- 128
		local _obj_0 = App.visualSize -- 128
		width, height = _obj_0.width, _obj_0.height -- 128
	end -- 128
	SetNextWindowPos(Vec2(width - 400, 10), "FirstUseEver") -- 129
	SetNextWindowSize(Vec2(390, height - 80), "FirstUseEver") -- 130
	Begin("Particle", { -- 131
		"NoResize", -- 131
		"NoSavedSettings" -- 131
	}, function() -- 131
		for k in pairs(Data) do -- 132
			Item(k) -- 133
		end -- 133
		if Button("Export") then -- 134
			return print("<A>" .. table.concat(_anon_func_1(Data, pairs, toString, tostring)) .. "</A>") -- 135
		end -- 134
	end) -- 131
	return work() -- 136
end) -- 136
