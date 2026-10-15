-- [xml]: Script/Lib/UI/View/Control/Basic/Ruler.xml
local LineRect = require("UI.View.Shape.LineRect") -- 3
local SolidRect = require("UI.View.Shape.SolidRect") -- 4
return function(args) -- 1
local _ENV = Dora(args) -- 1
local ruler = Node() -- 6
ruler.x = x or 0 -- 6
ruler.y = y or 0 -- 6
ruler.opacity = 0 -- 6
ruler.visible = false -- 6
ruler.touchEnabled = true -- 6
ruler.swallowTouches = true -- 6
local item1 = SolidRect{color = 0xcc000000, width = width, y = -height / 2, height = height, x = -width / 2} -- 7
ruler:addChild(item1) -- 7
local clipNode1 = ClipNode() -- 9
ruler:addChild(clipNode1) -- 9
local item2 = SolidRect{width = width, y = -height / 2, height = height, x = -width / 2} -- 11
clipNode1.stencil = item2 -- 11
local intervalNode = Line() -- 13
intervalNode.size = Size(width,height) -- 13
clipNode1:addChild(intervalNode) -- 13
ruler.intervalNode = intervalNode -- 13
intervalNode:set({},Color(0xffffffff)) -- 13
local border = LineRect{width = width, y = -height / 2, height = height, x = -width / 2} -- 16
ruler:addChild(border) -- 16
local cursor = Line() -- 18
ruler:addChild(cursor) -- 18
cursor:set({Vec2(0,-height / 2),Vec2(0,height / 2)},Color(0xffffffff)) -- 18
return ruler -- 20
end