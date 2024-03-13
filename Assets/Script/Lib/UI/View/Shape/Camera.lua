-- [xml]: Script/Lib/UI/View/Shape/Camera.xml
local LineCircle = require("UI.View.Shape.LineCircle") -- 3
local LineRect = require("UI.View.Shape.LineRect") -- 4
return function(args) -- 1
local _ENV = Dora(args) -- 1
local node1 = Node() -- 6
node1.x = x or 0 -- 6
node1.y = y or 0 -- 6
node1.scaleX = scale or 1 -- 6
node1.scaleY = scale or 1 -- 6
local drawNode1 = DrawNode() -- 7
drawNode1.opacity = 0.5 -- 7
drawNode1.renderOrder = fillOrder or 0 -- 7
node1:addChild(drawNode1) -- 7
drawNode1:drawPolygon({Vec2(-20,-10),Vec2(20,-10),Vec2(20,10),Vec2(-20,10)},Color(color),0,Color()) -- 8
drawNode1:drawPolygon({Vec2(20,3),Vec2(32,10),Vec2(32,-10),Vec2(20,-3)},Color(color),0,Color()) -- 14
drawNode1:drawDot(Vec2(-11,20),10,Color(color)) -- 20
drawNode1:drawDot(Vec2(11,20),10,Color(color)) -- 21
local item1 = LineRect{color = color, width = 40, y = -10, lineOrder = lineOrder or 0, height = 20, x = -20} -- 23
node1:addChild(item1) -- 23
local item2 = LineCircle{lineOrder = lineOrder or 0, color = color, radius = 10, y = 10, x = -21} -- 24
node1:addChild(item2) -- 24
local item3 = LineCircle{lineOrder = lineOrder or 0, color = color, radius = 10, y = 10, x = 1} -- 25
node1:addChild(item3) -- 25
local line1 = Line() -- 26
node1:addChild(line1) -- 26
line1:set({Vec2(20,3),Vec2(32,10),Vec2(32,-10),Vec2(20,-3)},Color(0xffffffff)) -- 26
return node1 -- 30
end