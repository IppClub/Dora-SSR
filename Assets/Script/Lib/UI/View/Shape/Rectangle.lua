-- [xml]: Script/Lib/UI/View/Shape/Rectangle.xml
local SolidRect = require("UI.View.Shape.SolidRect") -- 3
local LineRect = require("UI.View.Shape.LineRect") -- 4
return function(args) -- 1
local _ENV = Dora(args) -- 1
local node1 = Node() -- 6
node1.x = x or 0 -- 6
node1.y = y or 0 -- 6
node1.size = Size(width,height) -- 6
if fillColor then -- 7
local item1 = SolidRect{renderOrder = fillOrder or 0, color = fillColor, height = height, width = width} -- 8
node1:addChild(item1) -- 8
end -- 9
if borderColor then -- 11
local item2 = LineRect{renderOrder = lineOrder or 0, color = borderColor, height = height, width = width} -- 12
node1:addChild(item2) -- 12
end -- 13
return node1 -- 13
end