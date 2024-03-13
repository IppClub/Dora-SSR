-- [xml]: Script/Game/Loli War/UI/View/RightTouchPad.xml
local AlignNode = require("UI.Control.Basic.AlignNode") -- 2
local Button = require("UI.View.Button") -- 3
return function(args) -- 1
local _ENV = Dora(args) -- 1
local pad = AlignNode{alignOffset = Vec2(20,60), vAlign = "Bottom", hAlign = "Right"} -- 5
local menu1 = Menu() -- 6
menu1.anchor = Vec2(1,0) -- 6
menu1.scaleX = 2 * App.devicePixelRatio -- 6
menu1.scaleY = 2 * App.devicePixelRatio -- 6
menu1.size = Size(114,52) -- 6
pad:addChild(menu1) -- 6
local item1 = Button{height = 52, width = 52, imageDown = 'keyf_down', imageUp = 'keyf_up'} -- 7
menu1:addChild(item1) -- 7
item1:slot("TapBegan",function() -- 8
pad:emit("KeyFDown") -- 8
end) -- 8
item1:slot("TapEnded",function() -- 9
pad:emit("KeyFUp") -- 9
end) -- 9
local item2 = Button{width = 52, height = 52, x = 62, imageDown = 'keyup_down', imageUp = 'keyup_up'} -- 11
menu1:addChild(item2) -- 11
item2:slot("TapBegan",function() -- 12
pad:emit("KeyUpDown") -- 12
end) -- 12
item2:slot("TapEnded",function() -- 13
pad:emit("KeyUpUp") -- 13
end) -- 13
return pad -- 13
end