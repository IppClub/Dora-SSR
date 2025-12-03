-- [yue]: Script/Lib/UI/View/Shape/Star.yue
local math = _G.math -- 1
local Vec2 = Dora.Vec2 -- 1
local Node = Dora.Node -- 1
local Color = Dora.Color -- 1
local DrawNode = Dora.DrawNode -- 1
local Line = Dora.Line -- 1
local _module_0 = nil -- 1
local StarVertices -- 11
StarVertices = function(radius, line) -- 11
	if line == nil then -- 11
		line = true -- 11
	end -- 11
	local a = math.rad(36) -- 12
	local c = math.rad(72) -- 13
	local f = math.sin(a) * math.tan(c) + math.cos(a) -- 14
	local R = radius -- 15
	local r = R / f -- 16
	local _accum_0 = { } -- 17
	local _len_0 = 1 -- 17
	for i = 9 + (line and 1 or 0), 0, -1 do -- 17
		local angle = i * a -- 18
		local cr = i % 2 == 1 and r or R -- 19
		_accum_0[_len_0] = Vec2(cr * math.sin(angle), cr * math.cos(angle)) -- 20
		_len_0 = _len_0 + 1 -- 18
	end -- 17
	return _accum_0 -- 17
end -- 11
local _anon_func_0 = function(Color, DrawNode, StarVertices, _with_0, args) -- 26
	local _with_1 = DrawNode() -- 26
	_with_1:drawPolygon(StarVertices(args.size, false), Color(args.fillColor)) -- 27
	if args.fillOrder then -- 28
		_with_1.renderOrder = args.fillOrder -- 28
	end -- 28
	return _with_1 -- 26
end -- 26
local _anon_func_1 = function(Color, Line, StarVertices, _with_0, args) -- 30
	local _with_1 = Line(StarVertices(args.size), Color(args.borderColor)) -- 30
	if args.lineOrder then -- 31
		_with_1.renderOrder = args.lineOrder -- 31
	end -- 31
	return _with_1 -- 30
end -- 30
_module_0 = function(args) -- 22
	local _with_0 = Node() -- 23
	_with_0.position = Vec2(args.x or 0, args.y or 0) -- 24
	if args.fillColor then -- 25
		_with_0:addChild(_anon_func_0(Color, DrawNode, StarVertices, _with_0, args)) -- 26
	end -- 25
	if args.borderColor then -- 29
		_with_0:addChild(_anon_func_1(Color, Line, StarVertices, _with_0, args)) -- 30
	end -- 29
	return _with_0 -- 23
end -- 22
return _module_0 -- 1
