-- [xml]: UI/View/LeftTouchPad.xml
local Button = require("UI.View.Button") -- 2
return function(args) -- 1
local _ENV = Dora(args) -- 1
local pad = Menu() -- 4
pad.anchor = Vec2(0,0) -- 4
pad.scaleX = 2 -- 4
pad.scaleY = 2 -- 4
pad.size = Size(114,52) -- 4
local item1 = Button{height = 52, width = 52, imageDown = 'keyleft_down', imageUp = 'keyleft_up'} -- 5
pad:addChild(item1) -- 5
item1:slot("TapBegan",function() -- 6
pad:emit("KeyLeftDown") -- 6
end) -- 6
item1:slot("TapEnded",function() -- 7
pad:emit("KeyLeftUp") -- 7
end) -- 7
local item2 = Button{width = 52, height = 52, x = 62, imageDown = 'keyright_down', imageUp = 'keyright_up'} -- 9
pad:addChild(item2) -- 9
item2:slot("TapBegan",function() -- 10
pad:emit("KeyRightDown") -- 10
end) -- 10
item2:slot("TapEnded",function() -- 11
pad:emit("KeyRightUp") -- 11
end) -- 11
return pad -- 11
end