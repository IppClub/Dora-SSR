-- [yue]: Script/Lib/UI/View/Shape/Star.yue
local _module_0 = nil -- 1
local _ENV = Dora -- 9
local math <const> = math -- 10
local Vec2 <const> = Vec2 -- 10
local Node <const> = Node -- 10
local DrawNode <const> = DrawNode -- 10
local Color <const> = Color -- 10
local Line <const> = Line -- 10
local StarVertices -- 12
StarVertices = function(radius, line) -- 12
	if line == nil then -- 12
		line = true -- 12
	end -- 12
	local a = math.rad(36) -- 13
	local c = math.rad(72) -- 14
	local f = math.sin(a) * math.tan(c) + math.cos(a) -- 15
	local R = radius -- 16
	local r = R / f -- 17
	local _accum_0 = { } -- 18
	local _len_0 = 1 -- 18
	for i = 9 + (line and 1 or 0), 0, -1 do -- 18
		local angle = i * a -- 19
		local cr = i % 2 == 1 and r or R -- 20
		_accum_0[_len_0] = Vec2(cr * math.sin(angle), cr * math.cos(angle)) -- 21
		_len_0 = _len_0 + 1 -- 19
	end -- 18
	return _accum_0 -- 18
end -- 12
local _anon_func_0 = function(StarVertices, _with_0, args) -- 27
	local _with_1 = DrawNode() -- 27
	_with_1:drawPolygon(StarVertices(args.size, false), Color(args.fillColor)) -- 28
	if args.fillOrder then -- 29
		_with_1.renderOrder = args.fillOrder -- 29
	end -- 29
	return _with_1 -- 27
end -- 27
local _anon_func_1 = function(StarVertices, _with_0, args) -- 31
	local _with_1 = Line(StarVertices(args.size), Color(args.borderColor)) -- 31
	if args.lineOrder then -- 32
		_with_1.renderOrder = args.lineOrder -- 32
	end -- 32
	return _with_1 -- 31
end -- 31
_module_0 = function(args) -- 23
	local _with_0 = Node() -- 24
	_with_0.position = Vec2(args.x or 0, args.y or 0) -- 25
	if args.fillColor then -- 26
		_with_0:addChild(_anon_func_0(StarVertices, _with_0, args)) -- 27
	end -- 26
	if args.borderColor then -- 30
		_with_0:addChild(_anon_func_1(StarVertices, _with_0, args)) -- 31
	end -- 30
	return _with_0 -- 24
end -- 23
return _module_0 -- 1
