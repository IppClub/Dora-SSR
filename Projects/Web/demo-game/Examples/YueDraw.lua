-- [yue]: Examples/YueDraw.yue
local _ENV = Dora -- 2
local draw = DrawNode() -- 4
draw:drawPolygon({ -- 6
	Vec2(-35, -35), -- 6
	Vec2(35, -35), -- 7
	Vec2(35, 35), -- 8
	Vec2(-35, 35) -- 9
}, Color(0xff18a0fb)) -- 5
draw.x = -340 -- 11
draw.y = -280 -- 12
Director.ui:addChild(draw) -- 13
return print("Dora Web example YueScript DrawNode verified") -- 15
