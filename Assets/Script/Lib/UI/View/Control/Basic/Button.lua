-- [xml]: Script/Lib/UI/View/Control/Basic/Button.xml
local ButtonBase = require("UI.View.Control.Basic.ButtonBase") -- 3
local SolidRect = require("UI.View.Shape.SolidRect") -- 4
local LineRect = require("UI.View.Shape.LineRect") -- 5
return function(args) -- 1
local _ENV = Dora(args) -- 1
local item1 = ButtonBase{tag = tag, width = width, y = y, height = height, x = x} -- 7
local face = item1.face -- 8
local show = Action(Spawn(Show(),Opacity(0,0.6,0.6))) -- 10
item1.show = show -- 10
local hide = Action(Sequence(Show(),Opacity(0.8,0.6,0),Hide())) -- 14
item1.hide = hide -- 14
local node1 = Node() -- 21
node1.passColor3 = false -- 21
face:addChild(node1) -- 21
local item2 = SolidRect{renderOrder = 1, color = backColor or 0x66000000, height = height, width = width} -- 22
node1:addChild(item2) -- 22
if text then -- 25
local label = Label(fontName or 'sarasa-mono-sc-regular',math.floor((fontSize or 18) * App.devicePixelRatio)) -- 26
label.x = face.width*0.5 -- 26
label.y = face.height*0.5 -- 26
label.scaleX = 1 / App.devicePixelRatio -- 26
label.scaleY = 1 / App.devicePixelRatio -- 26
label.renderOrder = 2 -- 26
label.alignment = "Center" -- 26
label.text = text -- 26
face:addChild(label) -- 26
item1.label = label -- 26
end -- 27
local item3 = LineRect{renderOrder = 3, color = 0xffffffff, height = height, width = width} -- 29
face:addChild(item3) -- 29
local light = SolidRect{renderOrder = 4, color = App.themeColor:toARGB(), height = height, width = width} -- 30
face:addChild(light) -- 30
light.visible = false -- 31
item1:slot("TapBegan",function() -- 34
light:perform(show) -- 34
end) -- 34
item1:slot("TapEnded",function() -- 35
light:perform(hide) -- 35
end) -- 35
return item1 -- 35
end