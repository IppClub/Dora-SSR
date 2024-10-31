-- [yue]: Script/Example/Particle.yue
local BlendFunc = Dora.BlendFunc -- 1
local Color = Dora.Color -- 1
local Vec2 = Dora.Vec2 -- 1
local Buffer = Dora.Buffer -- 1
local Rect = Dora.Rect -- 1
local tolua = Dora.tolua -- 1
local tostring = _G.tostring -- 1
local string = _G.string -- 1
local table = _G.table -- 1
local pairs = _G.pairs -- 1
local Cache = Dora.Cache -- 1
local Particle = Dora.Particle -- 1
local Node = Dora.Node -- 1
local _module_0 = Dora.ImGui -- 1
local DragFloat = _module_0.DragFloat -- 1
local DragInt = _module_0.DragInt -- 1
local math = _G.math -- 1
local Combo = _module_0.Combo -- 1
local PushItemWidth = _module_0.PushItemWidth -- 1
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
local SameLine = _module_0.SameLine -- 1
local InputTextMultiline = _module_0.InputTextMultiline -- 1
local blendFuncs = { -- 4
	"One", -- 4
	"Zero", -- 5
	"SrcAlpha", -- 6
	"DstAlpha", -- 7
	"InvSrcAlpha", -- 8
	"InvDstAlpha" -- 9
} -- 3
local blendFuncDst = 1 -- 11
local blendFuncSrc = 3 -- 12
local emitterTypes = { -- 15
	"Gravity", -- 15
	"Radius" -- 16
} -- 14
local emitterType = 1 -- 18
local Data = { -- 21
	Angle = { -- 21
		"B", -- 21
		"float", -- 21
		90 -- 21
	}, -- 21
	AngleVariance = { -- 22
		"C", -- 22
		"float", -- 22
		360 -- 22
	}, -- 22
	BlendFuncDestination = { -- 23
		"D", -- 23
		"BlendFunc", -- 23
		BlendFunc:get("One"), -- 23
		"One" -- 23
	}, -- 23
	BlendFuncSource = { -- 24
		"E", -- 24
		" BlendFunc", -- 24
		BlendFunc:get("SrcAlpha"), -- 24
		"SrcAlpha" -- 24
	}, -- 24
	Duration = { -- 25
		"F", -- 25
		"floatN", -- 25
		-1 -- 25
	}, -- 25
	EmissionRate = { -- 26
		"G", -- 26
		"float", -- 26
		350 -- 26
	}, -- 26
	FinishColor = { -- 27
		"H", -- 27
		"Color", -- 27
		Color(0xff000000) -- 27
	}, -- 27
	FinishColorVariance = { -- 28
		"I", -- 28
		"Color", -- 28
		Color(0x0) -- 28
	}, -- 28
	RotationStart = { -- 29
		"J", -- 29
		"float", -- 29
		0 -- 29
	}, -- 29
	RotationStartVariance = { -- 30
		"K", -- 30
		"float", -- 30
		0 -- 30
	}, -- 30
	RotationEnd = { -- 31
		"L", -- 31
		"float", -- 31
		0 -- 31
	}, -- 31
	RotationEndVariance = { -- 32
		"M", -- 32
		"float", -- 32
		0 -- 32
	}, -- 32
	FinishParticleSize = { -- 33
		"N", -- 33
		"floatN", -- 33
		-1 -- 33
	}, -- 33
	FinishParticleSizeVariance = { -- 34
		"O", -- 34
		"float", -- 34
		0 -- 34
	}, -- 34
	MaxParticles = { -- 35
		"P", -- 35
		"Uint32", -- 35
		100 -- 35
	}, -- 35
	ParticleLifespan = { -- 36
		"Q", -- 36
		"float", -- 36
		1 -- 36
	}, -- 36
	ParticleLifespanVariance = { -- 37
		"R", -- 37
		"float", -- 37
		0.5 -- 37
	}, -- 37
	StartPosition = { -- 38
		"S", -- 38
		"Vec2", -- 38
		Vec2(0, 0) -- 38
	}, -- 38
	StartPositionVariance = { -- 39
		"T", -- 39
		"Vec2", -- 39
		Vec2(0, 0) -- 39
	}, -- 39
	StartColor = { -- 40
		"U", -- 40
		"Color", -- 40
		Color(194, 64, 31, 255) -- 40
	}, -- 40
	StartColorVariance = { -- 41
		"V", -- 41
		"Color", -- 41
		Color(0x0) -- 41
	}, -- 41
	StartParticleSize = { -- 42
		"W", -- 42
		"float", -- 42
		30 -- 42
	}, -- 42
	StartParticleSizeVariance = { -- 43
		"X", -- 43
		"float", -- 43
		10 -- 43
	}, -- 43
	TextureName = { -- 44
		"Y", -- 44
		"string", -- 44
		"", -- 44
		Buffer(256) -- 44
	}, -- 44
	TextureRect = { -- 45
		"Z", -- 45
		"Rect", -- 45
		Rect(0, 0, 0, 0) -- 45
	}, -- 45
	EmitterType = { -- 46
		"a", -- 46
		"EmitterType", -- 46
		0 -- 46
	} -- 46
} -- 20
local Gravity = { -- 48
	RotationIsDir = { -- 48
		"b", -- 48
		"bool", -- 48
		false -- 48
	}, -- 48
	Gravity = { -- 49
		"c", -- 49
		"Vec2", -- 49
		Vec2(0, 100) -- 49
	}, -- 49
	Speed = { -- 50
		"d", -- 50
		"float", -- 50
		20 -- 50
	}, -- 50
	SpeedVariance = { -- 51
		"e", -- 51
		"float", -- 51
		5 -- 51
	}, -- 51
	RadialAcceleration = { -- 52
		"f", -- 52
		"float", -- 52
		0 -- 52
	}, -- 52
	RadialAccelVariance = { -- 53
		"g", -- 53
		"float", -- 53
		0 -- 53
	}, -- 53
	TangentialAcceleration = { -- 54
		"h", -- 54
		"float", -- 54
		0 -- 54
	}, -- 54
	TangentialAccelVariance = { -- 55
		"i", -- 55
		"float", -- 55
		0 -- 55
	} -- 55
} -- 47
local Radius = { -- 57
	StartRadius = { -- 57
		"j", -- 57
		"float", -- 57
		0 -- 57
	}, -- 57
	StartRadiusVariance = { -- 58
		"k", -- 58
		"float", -- 58
		0 -- 58
	}, -- 58
	FinishRadius = { -- 59
		"l", -- 59
		"floatN", -- 59
		-1 -- 59
	}, -- 59
	FinishRadiusVariance = { -- 60
		"m", -- 60
		"float", -- 60
		0 -- 60
	}, -- 60
	RotatePerSecond = { -- 61
		"n", -- 61
		"float", -- 61
		0 -- 61
	}, -- 61
	RotatePerSecondVariance = { -- 62
		"o", -- 62
		"float", -- 62
		0 -- 62
	} -- 62
} -- 56
local toString -- 64
toString = function(value) -- 64
	local _exp_0 = tolua.type(value) -- 65
	if "number" == _exp_0 then -- 66
		return tostring(value) -- 67
	elseif "string" == _exp_0 then -- 68
		return value -- 69
	elseif "Rect" == _exp_0 then -- 70
		return tostring(value.x) .. "," .. tostring(value.y) .. "," .. tostring(value.width) .. "," .. tostring(value.height) -- 71
	elseif "boolean" == _exp_0 then -- 72
		return value and "1" or "0" -- 73
	elseif "Vec2" == _exp_0 then -- 74
		return tostring(value.x) .. "," .. tostring(value.y) -- 75
	elseif "Color" == _exp_0 then -- 76
		return string.format("%.2f,%.2f,%.2f,%.2f", value.r / 255, value.g / 255, value.b / 255, value.a / 255) -- 77
	end -- 77
end -- 64
local _anon_func_1 = function(Data, Gravity, Radius, emitterType, pairs) -- 80
	local _tab_0 = { } -- 80
	local _idx_0 = 1 -- 80
	for _key_0, _value_0 in pairs(Data) do -- 80
		if _idx_0 == _key_0 then -- 80
			_tab_0[#_tab_0 + 1] = _value_0 -- 80
			_idx_0 = _idx_0 + 1 -- 80
		else -- 80
			_tab_0[_key_0] = _value_0 -- 80
		end -- 80
	end -- 80
	local _obj_0 = (emitterType == 1 and Gravity or Radius) -- 80
	local _idx_1 = 1 -- 80
	for _key_0, _value_0 in pairs(_obj_0) do -- 80
		if _idx_1 == _key_0 then -- 80
			_tab_0[#_tab_0 + 1] = _value_0 -- 80
			_idx_1 = _idx_1 + 1 -- 80
		else -- 80
			_tab_0[_key_0] = _value_0 -- 80
		end -- 80
	end -- 80
	return _tab_0 -- 80
end -- 80
local _anon_func_0 = function(Data, Gravity, Radius, emitterType, pairs, toString, tostring) -- 80
	local _accum_0 = { } -- 80
	local _len_0 = 1 -- 80
	for k, v in pairs(_anon_func_1(Data, Gravity, Radius, emitterType, pairs)) do -- 80
		_accum_0[_len_0] = "\n\t<" .. tostring(v[1]) .. " A=\"" .. tostring(toString(v[3])) .. "\"/>" -- 80
		_len_0 = _len_0 + 1 -- 80
	end -- 80
	return _accum_0 -- 80
end -- 80
local getParticle -- 79
getParticle = function() -- 79
	return "<A>" .. table.concat(_anon_func_0(Data, Gravity, Radius, emitterType, pairs, toString, tostring)) .. "\n</A>" -- 80
end -- 79
Cache:update("__test__.par", getParticle()) -- 82
local particle -- 84
do -- 84
	local _with_0 = Particle("__test__.par") -- 84
	_with_0:start() -- 85
	particle = _with_0 -- 84
end -- 84
local root -- 87
do -- 87
	local _with_0 = Node() -- 87
	_with_0.scaleX = 2 -- 88
	_with_0.scaleY = 2 -- 89
	_with_0:addChild(particle) -- 90
	_with_0:onTapMoved(function(touch) -- 91
		if not touch.first then -- 92
			return -- 92
		end -- 92
		particle.position = particle.position + (touch.delta / 2) -- 93
	end) -- 91
	root = _with_0 -- 87
end -- 87
local DataDirty = false -- 97
local Item -- 99
Item = function(name, data) -- 99
	local _with_0 = data[name] -- 99
	local _exp_0 = _with_0[2] -- 99
	if "float" == _exp_0 then -- 100
		local changed -- 101
		changed, _with_0[3] = DragFloat(name, _with_0[3], 0.1, -1000, 1000, "%.1f") -- 101
		if changed then -- 101
			DataDirty = true -- 102
		end -- 101
	elseif "floatN" == _exp_0 then -- 103
		local changed -- 104
		changed, _with_0[3] = DragFloat(name, _with_0[3], 0.1, -1, 1000, "%.1f") -- 104
		if changed then -- 104
			DataDirty = true -- 105
		end -- 104
	elseif "Uint32" == _exp_0 then -- 106
		local changed -- 107
		changed, _with_0[3] = DragInt(name, math.floor(_with_0[3]), 1, 0, 1000) -- 107
		if changed then -- 107
			DataDirty = true -- 108
		end -- 107
	elseif "EmitterType" == _exp_0 then -- 109
		do -- 110
			local changed -- 110
			changed, emitterType = Combo("EmitterType", emitterType, emitterTypes) -- 110
			if changed then -- 110
				_with_0[3] = emitterType == 1 and 0 or 1 -- 111
			end -- 110
		end -- 110
		PushItemWidth(-180, function() -- 112
			if emitterType == 1 then -- 113
				for k in pairs(Gravity) do -- 114
					Item(k, Gravity) -- 114
				end -- 114
			else -- 116
				for k in pairs(Radius) do -- 116
					Item(k, Radius) -- 116
				end -- 116
			end -- 113
		end) -- 112
	elseif "BlendFunc" == _exp_0 then -- 117
		if name == "BlendFuncDestination" then -- 118
			local changed -- 119
			changed, blendFuncDst = Combo("BlendFuncDestination", blendFuncDst, blendFuncs) -- 119
			if changed then -- 119
				_with_0[3] = BlendFunc:get(blendFuncs[blendFuncDst]) -- 120
				_with_0[4] = blendFuncs[blendFuncDst] -- 121
			end -- 119
		elseif name == "BlendFuncSource" then -- 122
			local changed -- 123
			changed, blendFuncSrc = Combo("BlendFuncSource", blendFuncSrc, blendFuncs) -- 123
			if changed then -- 123
				_with_0[3] = BlendFunc:get(blendFuncs[blendFuncSrc]) -- 124
				_with_0[4] = blendFuncs[blendFuncSrc] -- 125
			end -- 123
		end -- 118
	elseif "Vec2" == _exp_0 then -- 126
		local x, y -- 127
		do -- 127
			local _obj_0 = _with_0[3] -- 127
			x, y = _obj_0.x, _obj_0.y -- 127
		end -- 127
		local changed -- 128
		changed, x, y = DragInt2(name, math.floor(x), math.floor(y), 1, -1000, 1000) -- 128
		if changed then -- 128
			DataDirty, _with_0[3] = true, Vec2(x, y) -- 129
		end -- 128
	elseif "Color" == _exp_0 then -- 130
		PushItemWidth(-150, function() -- 131
			SetColorEditOptions({ -- 132
				"DisplayRGB" -- 132
			}) -- 132
			local changed = ColorEdit4(name, _with_0[3]) -- 133
			if changed then -- 133
				DataDirty = true -- 134
			end -- 133
		end) -- 131
	elseif "bool" == _exp_0 then -- 135
		local changed -- 136
		changed, _with_0[3] = Checkbox(name, _with_0[3]) -- 136
		if changed then -- 136
			DataDirty = true -- 137
		end -- 136
	elseif "string" == _exp_0 then -- 138
		local buffer = _with_0[4] -- 139
		local changed = InputText(name, buffer) -- 140
		if changed then -- 140
			DataDirty = true -- 141
			_with_0[3] = buffer.text -- 142
		end -- 140
	end -- 142
	return _with_0 -- 99
end -- 99
local refresh = coroutine.wrap(function() -- 144
	while true do -- 144
		sleep(1) -- 145
		if DataDirty then -- 146
			DataDirty = false -- 147
			Cache:update("__test__.par", getParticle()) -- 148
			particle:removeFromParent() -- 149
			local _with_0 = Particle("__test__.par") -- 150
			_with_0:start() -- 151
			_with_0:addTo(particle) -- 152
			particle = _with_0 -- 150
		end -- 146
	end -- 152
end) -- 144
local buffer = Buffer(5000) -- 155
local windowFlags = { -- 156
	"NoResize", -- 156
	"NoSavedSettings" -- 156
} -- 156
return threadLoop(function() -- 157
	local width, height -- 158
	do -- 158
		local _obj_0 = App.visualSize -- 158
		width, height = _obj_0.width, _obj_0.height -- 158
	end -- 158
	SetNextWindowPos(Vec2(width - 400, 10), "FirstUseEver") -- 159
	SetNextWindowSize(Vec2(390, height - 80), "FirstUseEver") -- 160
	Begin("Particle", windowFlags, function() -- 161
		PushItemWidth(-180, function() -- 162
			for k in pairs(Data) do -- 163
				Item(k, Data) -- 164
			end -- 164
		end) -- 162
		if Button("Export") then -- 165
			buffer.text = getParticle() -- 166
		end -- 165
		SameLine() -- 167
		return PushItemWidth(-1, function() -- 168
			return InputTextMultiline("###Edited", buffer) -- 169
		end) -- 169
	end) -- 161
	return refresh() -- 170
end) -- 170
