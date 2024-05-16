-- [yue]: Script/Lib/UI/View/Shape/LineCircle.yue
local math = _G.math -- 1
local Vec2 = Dora.Vec2 -- 1
local Line = Dora.Line -- 1
local Color = Dora.Color -- 1
local _module_0 = nil -- 1
local num = 20 -- 11
local newP -- 13
newP = function(index, radius) -- 13
	local angle = 2 * math.pi * index / num -- 14
	return Vec2(radius * math.cos(angle), radius * math.sin(angle)) + Vec2(radius, radius) -- 15
end -- 13
local _anon_func_0 = function(args, newP, num) -- 18
	local _accum_0 = { } -- 18
	local _len_0 = 1 -- 18
	for index = 0, num do -- 18
		_accum_0[_len_0] = newP(index, args.radius) -- 18
		_len_0 = _len_0 + 1 -- 18
	end -- 18
	return _accum_0 -- 18
end -- 18
_module_0 = function(args) -- 17
	local _with_0 = Line(_anon_func_0(args, newP, num), args.color and Color(args.color or 0xffffffff)) -- 18
	_with_0.position = Vec2(args.x or 0, args.y or 0) -- 19
	_with_0.renderOrder = args.renderOrder or 0 -- 20
	return _with_0 -- 18
end -- 17
return _module_0 -- 20
