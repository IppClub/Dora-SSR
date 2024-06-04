-- [xml]: UI/View/RightTouchPad.xml
local Button = require("UI.View.Button") -- 2
return function(args) -- 1
local _ENV = Dora(args) -- 1
local pad = Menu() -- 4
pad.anchor = Vec2(1,0) -- 4
pad.scaleX = 1.5 -- 4
pad.scaleY = 1.5 -- 4
pad.size = Size(114,52) -- 4
local item1 = Button{height = 52, width = 52, imageDown = 'keyf_down', imageUp = 'keyf_up'} -- 5
pad:addChild(item1) -- 5
item1:slot("TapBegan",function() -- 6
pad:emit("KeyFDown") -- 6
end) -- 6
item1:slot("TapEnded",function() -- 7
pad:emit("KeyFUp") -- 7
end) -- 7
local item2 = Button{width = 52, height = 52, x = 62, imageDown = 'keyup_down', imageUp = 'keyup_up'} -- 9
pad:addChild(item2) -- 9
item2:slot("TapBegan",function() -- 10
pad:emit("KeyUpDown") -- 10
end) -- 10
item2:slot("TapEnded",function() -- 11
pad:emit("KeyUpUp") -- 11
end) -- 11
return pad -- 11
end