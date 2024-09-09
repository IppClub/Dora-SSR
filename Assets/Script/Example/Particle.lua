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
	_with_0:onTapMoved(function(touch) -- 72
		if not touch.first then -- 73
			return -- 73
		end -- 73
		particle.position = particle.position + (touch.delta / 2) -- 74
	end) -- 72
	root = _with_0 -- 68
end -- 68
local DataDirty = false -- 78
local Item -- 80
Item = function(name) -- 80
	return PushItemWidth(-180, function() -- 81
		local _exp_0 = Data[name][2] -- 82
		if "float" == _exp_0 then -- 83
			local changed -- 84
			changed, Data[name][3] = DragFloat(name, Data[name][3], 0.1, -1000, 1000, "%.1f") -- 84
			if changed then -- 85
				DataDirty = true -- 85
			end -- 85
		elseif "floatN" == _exp_0 then -- 86
			local changed -- 87
			changed, Data[name][3] = DragFloat(name, Data[name][3], 0.1, -1, 1000, "%.1f") -- 87
			if changed then -- 88
				DataDirty = true -- 88
			end -- 88
		elseif "Uint32" == _exp_0 then -- 89
			local changed -- 90
			changed, Data[name][3] = DragInt(name, math.floor(Data[name][3]), 1, 0, 1000) -- 90
			if changed then -- 91
				DataDirty = true -- 91
			end -- 91
		elseif "EmitterType" == _exp_0 then -- 92
			return LabelText("EmitterType", "Gravity") -- 93
		elseif "BlendFunc" == _exp_0 then -- 94
			return LabelText("BlendFunc", "Additive") -- 95
		elseif "Vec2" == _exp_0 then -- 96
			local x, y -- 97
			do -- 97
				local _obj_0 = Data[name][3] -- 97
				x, y = _obj_0.x, _obj_0.y -- 97
			end -- 97
			local changed -- 98
			changed, x, y = DragInt2(name, math.floor(x), math.floor(y), 1, -1000, 1000) -- 98
			if changed then -- 99
				DataDirty, Data[name][3] = true, Vec2(x, y) -- 99
			end -- 99
		elseif "Color" == _exp_0 then -- 100
			return PushItemWidth(-150, function() -- 101
				SetColorEditOptions({ -- 102
					"DisplayRGB" -- 102
				}) -- 102
				local changed = ColorEdit4(name, Data[name][3]) -- 103
				if changed then -- 104
					DataDirty = true -- 104
				end -- 104
			end) -- 104
		elseif "bool" == _exp_0 then -- 105
			local changed -- 106
			changed, Data[name][3] = Checkbox(name, Data[name][3]) -- 106
			if changed then -- 107
				DataDirty = true -- 107
			end -- 107
		elseif "string" == _exp_0 then -- 108
			local buffer = Data[name][4] -- 109
			local changed = InputText(name, buffer) -- 110
			if changed then -- 111
				DataDirty = true -- 112
				Data[name][3] = buffer:toString() -- 113
			end -- 111
		end -- 113
	end) -- 113
end -- 80
local _anon_func_0 = function(Data, pairs, toString, tostring) -- 120
	local _accum_0 = { } -- 120
	local _len_0 = 1 -- 120
	for k, v in pairs(Data) do -- 120
		_accum_0[_len_0] = "<" .. tostring(v[1]) .. " A=\"" .. tostring(toString(v[3])) .. "\"/>" -- 120
		_len_0 = _len_0 + 1 -- 120
	end -- 120
	return _accum_0 -- 120
end -- 120
local work = coroutine.wrap(function() -- 115
	while true do -- 116
		sleep(1) -- 117
		if DataDirty then -- 118
			DataDirty = false -- 119
			Cache:update("__test__.par", "<A>" .. table.concat(_anon_func_0(Data, pairs, toString, tostring)) .. "</A>") -- 120
			particle:removeFromParent() -- 121
			do -- 122
				local _with_0 = Particle("__test__.par") -- 122
				_with_0:start() -- 123
				particle = _with_0 -- 122
			end -- 122
			root:addChild(particle) -- 124
		end -- 118
	end -- 124
end) -- 115
local windowFlags = { -- 127
	"NoResize", -- 127
	"NoSavedSettings" -- 127
} -- 127
local _anon_func_1 = function(Data, pairs, toString, tostring) -- 136
	local _accum_0 = { } -- 136
	local _len_0 = 1 -- 136
	for k, v in pairs(Data) do -- 136
		_accum_0[_len_0] = "<" .. tostring(v[1]) .. " A=\"" .. tostring(toString(v[3])) .. "\"/>" -- 136
		_len_0 = _len_0 + 1 -- 136
	end -- 136
	return _accum_0 -- 136
end -- 136
return threadLoop(function() -- 128
	local width, height -- 129
	do -- 129
		local _obj_0 = App.visualSize -- 129
		width, height = _obj_0.width, _obj_0.height -- 129
	end -- 129
	SetNextWindowPos(Vec2(width - 400, 10), "FirstUseEver") -- 130
	SetNextWindowSize(Vec2(390, height - 80), "FirstUseEver") -- 131
	Begin("Particle", windowFlags, function() -- 132
		for k in pairs(Data) do -- 133
			Item(k) -- 134
		end -- 134
		if Button("Export") then -- 135
			return print("<A>" .. table.concat(_anon_func_1(Data, pairs, toString, tostring)) .. "</A>") -- 136
		end -- 135
	end) -- 132
	return work() -- 137
end) -- 137
