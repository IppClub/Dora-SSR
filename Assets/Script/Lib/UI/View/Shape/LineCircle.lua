-- [yue]: Script/Lib/UI/View/Shape/LineCircle.yue
local _module_0 = nil -- 1
local _ENV = Dora -- 9
local math <const> = math -- 10
local Vec2 <const> = Vec2 -- 10
local Line <const> = Line -- 10
local Color <const> = Color -- 10
local num = 20 -- 12
local newP -- 14
newP = function(index, radius) -- 14
	local angle = 2 * math.pi * index / num -- 15
	return Vec2(radius * math.cos(angle), radius * math.sin(angle)) + Vec2(radius, radius) -- 16
end -- 14
local _anon_func_0 = function(args, newP, num) -- 19
	local _accum_0 = { } -- 19
	local _len_0 = 1 -- 19
	for index = 0, num do -- 19
		_accum_0[_len_0] = newP(index, args.radius) -- 19
		_len_0 = _len_0 + 1 -- 19
	end -- 19
	return _accum_0 -- 19
end -- 19
_module_0 = function(args) -- 18
	local _with_0 = Line(_anon_func_0(args, newP, num), args.color and Color(args.color or 0xffffffff)) -- 19
	_with_0.position = Vec2(args.x or 0, args.y or 0) -- 20
	_with_0.renderOrder = args.renderOrder or 0 -- 21
	return _with_0 -- 19
end -- 18
return _module_0 -- 1
