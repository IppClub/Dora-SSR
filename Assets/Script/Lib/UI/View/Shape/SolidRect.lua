-- [xml]: Script/Lib/UI/View/Shape/SolidRect.xml
return function(args) -- 1
local _ENV = Dora(args) -- 1
local drawNode1 = DrawNode() -- 3
drawNode1.x = x or 0 -- 3
drawNode1.y = y or 0 -- 3
drawNode1.renderOrder = renderOrder or 0 -- 3
drawNode1:drawPolygon({Vec2(0,0),Vec2(width,0),Vec2(width,height),Vec2(0,height)},Color(color or 0xffffffff),0,Color()) -- 4
return drawNode1 -- 8
end