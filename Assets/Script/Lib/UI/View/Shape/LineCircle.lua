-- [yue]: Script/Lib/UI/View/Shape/LineCircle.yue
local math = _G.math -- 1
local Vec2 = dora.Vec2 -- 1
local Line = dora.Line -- 1
local Color = dora.Color -- 1
local _module_0 = nil -- 1
local num = 20 -- 3
local newP -- 5
newP = function(index, radius) -- 5
	local angle = 2 * math.pi * index / num -- 6
	return Vec2(radius * math.cos(angle), radius * math.sin(angle)) + Vec2(radius, radius) -- 7
end -- 5
local _anon_func_0 = function(args, newP, num) -- 10
	local _accum_0 = { } -- 10
	local _len_0 = 1 -- 10
	for index = 0, num do -- 10
		_accum_0[_len_0] = newP(index, args.radius) -- 10
		_len_0 = _len_0 + 1 -- 10
	end -- 10
	return _accum_0 -- 10
end -- 10
_module_0 = function(args) -- 9
	local _with_0 = Line(_anon_func_0(args, newP, num), args.color and Color(args.color or 0xffffffff)) -- 10
	_with_0.position = Vec2(args.x or 0, args.y or 0) -- 11
	_with_0.renderOrder = args.renderOrder or 0 -- 12
	return _with_0 -- 10
end -- 9
return _module_0 -- 12
