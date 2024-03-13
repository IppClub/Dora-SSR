-- [xml]: Script/Lib/UI/View/Shape/Circle.xml
local SolidCircle = require("UI.View.Shape.SolidCircle") -- 3
local LineCircle = require("UI.View.Shape.LineCircle") -- 4
return function(args) -- 1
local _ENV = Dora(args) -- 1
local node1 = Node() -- 6
node1.x = x or 0 -- 6
node1.y = y or 0 -- 6
node1.size = Size(radius * 2,radius * 2) -- 6
if fillColor then -- 7
local item1 = SolidCircle{color = fillColor, renderOrder = fillOrder or 0, radius = radius} -- 8
node1:addChild(item1) -- 8
end -- 9
if borderColor then -- 11
local item2 = LineCircle{color = borderColor, renderOrder = lineOrder or 0, radius = radius} -- 12
node1:addChild(item2) -- 12
end -- 13
return node1 -- 13
end