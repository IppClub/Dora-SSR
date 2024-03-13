-- [xml]: Script/Lib/UI/View/Control/Basic/ScrollArea.xml
local SolidRect = require("UI.View.Shape.SolidRect") -- 3
return function(args) -- 1
local _ENV = Dora(args) -- 1
local panel = Node() -- 5
panel.x = x or 0 -- 5
panel.y = y or 0 -- 5
panel.visible = visible == nil or visible -- 5
panel.touchEnabled = true -- 5
panel.swallowTouches = true -- 5
if clipping or clipping == nil then -- 6
local area = ClipNode() -- 7
area.size = Size(width or 0,height or 0) -- 7
area.touchEnabled = true -- 7
area.swallowMouseWheel = true -- 7
panel:addChild(area) -- 7
panel.area = area -- 7
local item1 = SolidRect{height = height or 0, width = width or 0} -- 9
area.stencil = item1 -- 9
local view = Menu() -- 11
view.anchor = Vec2(0,0) -- 11
view.size = Size(width or 0,height or 0) -- 11
view.renderGroup = true -- 11
area:addChild(view) -- 11
panel.view = view -- 11
else -- 13
local area = Node() -- 14
area.size = Size(width or 0,height or 0) -- 14
area.touchEnabled = true -- 14
area.swallowMouseWheel = true -- 14
panel:addChild(area) -- 14
panel.area = area -- 14
local view = Menu() -- 15
view.anchor = Vec2(0,0) -- 15
view.size = Size(width or 0,height or 0) -- 15
view.renderGroup = true -- 15
area:addChild(view) -- 15
panel.view = view -- 15
end -- 17
return panel -- 17
end