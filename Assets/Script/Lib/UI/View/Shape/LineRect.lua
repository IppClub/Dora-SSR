-- [xml]: Script/Lib/UI/View/Shape/LineRect.xml
return function(args) -- 1
local _ENV = Dora(args) -- 1
local line1 = Line() -- 3
line1.x = x or 0 -- 3
line1.y = y or 0 -- 3
line1.color3 = Color3(color or 0xffffff) -- 3
line1.opacity = color and Color(color).opacity or 1 -- 3
line1.renderOrder = renderOrder or 0 -- 3
line1:set({Vec2(0,0),Vec2(width,0),Vec2(width,height),Vec2(0,height),Vec2(0,0)},Color(0xffffffff)) -- 3
return line1 -- 8
end