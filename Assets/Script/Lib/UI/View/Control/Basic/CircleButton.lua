-- [xml]: Script/Lib/UI/View/Control/Basic/CircleButton.xml
local ButtonBase = require("UI.View.Control.Basic.ButtonBase") -- 3
local SolidCircle = require("UI.View.Shape.SolidCircle") -- 4
local LineCircle = require("UI.View.Shape.LineCircle") -- 5
return function(args) -- 1
local _ENV = Dora(args) -- 1
local item1 = ButtonBase{width = radius*2, y = y, height = radius*2, x = x} -- 7
local face = item1.face -- 8
local show = Action(Spawn(Show(),Opacity(0,0.6,0.6))) -- 10
local hide = Action(Sequence(Show(),Opacity(0.8,0.6,0),Hide())) -- 14
local node1 = Node() -- 21
node1.passColor3 = false -- 21
face:addChild(node1) -- 21
local item2 = SolidCircle{color = backColor or 0x88000000, renderOrder = 1, radius = radius} -- 22
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
local item3 = LineCircle{color = 0xffffffff, renderOrder = 3, radius = radius} -- 29
face:addChild(item3) -- 29
local light = SolidCircle{color = App.themeColor:toARGB(), renderOrder = 4, radius = radius} -- 30
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