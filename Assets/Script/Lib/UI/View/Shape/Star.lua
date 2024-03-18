-- [yue]: Script/Lib/UI/View/Shape/Star.yue
local math = _G.math -- 1
local Vec2 = dora.Vec2 -- 1
local Node = dora.Node -- 1
local Color = dora.Color -- 1
local DrawNode = dora.DrawNode -- 1
local Line = dora.Line -- 1
local _module_0 = nil -- 1
local StarVertices -- 3
StarVertices = function(radius, line) -- 3
	if line == nil then -- 3
		line = true -- 3
	end -- 3
	local a = math.rad(36) -- 4
	local c = math.rad(72) -- 5
	local f = math.sin(a) * math.tan(c) + math.cos(a) -- 6
	local R = radius -- 7
	local r = R / f -- 8
	local _accum_0 = { } -- 9
	local _len_0 = 1 -- 9
	for i = 9 + (line and 1 or 0), 0, -1 do -- 9
		local angle = i * a -- 10
		local cr = i % 2 == 1 and r or R -- 11
		_accum_0[_len_0] = Vec2(cr * math.sin(angle), cr * math.cos(angle)) -- 12
		_len_0 = _len_0 + 1 -- 12
	end -- 12
	return _accum_0 -- 12
end -- 3
local _anon_func_0 = function(_with_0, DrawNode, StarVertices, args, Color) -- 20
	local _with_1 = DrawNode() -- 18
	_with_1:drawPolygon(StarVertices(args.size, false), Color(args.fillColor)) -- 19
	if args.fillOrder then -- 20
		_with_1.renderOrder = args.fillOrder -- 20
	end -- 20
	return _with_1 -- 18
end -- 18
local _anon_func_1 = function(_with_0, Line, StarVertices, args, Color) -- 23
	local _with_1 = Line(StarVertices(args.size), Color(args.borderColor)) -- 22
	if args.lineOrder then -- 23
		_with_1.renderOrder = args.lineOrder -- 23
	end -- 23
	return _with_1 -- 22
end -- 22
_module_0 = function(args) -- 14
	local _with_0 = Node() -- 15
	_with_0.position = Vec2(args.x or 0, args.y or 0) -- 16
	if args.fillColor then -- 17
		_with_0:addChild(_anon_func_0(_with_0, DrawNode, StarVertices, args, Color)) -- 18
	end -- 17
	if args.borderColor then -- 21
		_with_0:addChild(_anon_func_1(_with_0, Line, StarVertices, args, Color)) -- 22
	end -- 21
	return _with_0 -- 15
end -- 14
return _module_0 -- 23
