-- [xml]: Script/Lib/UI/View/Shape/SolidCircle.xml
return function(args) -- 1
local _ENV = Dora(args) -- 1
local drawNode1 = DrawNode() -- 3
drawNode1.x = x or 0 -- 3
drawNode1.y = y or 0 -- 3
drawNode1.renderOrder = renderOrder or 0 -- 3
drawNode1:drawDot(Vec2(radius,radius),radius,Color(color or 0xffffffff)) -- 4
return drawNode1 -- 4
end