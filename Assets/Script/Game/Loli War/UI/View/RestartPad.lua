-- [xml]: Script/Game/Loli War/UI/View/RestartPad.xml
local AlignNode = require("UI.Control.Basic.AlignNode") -- 2
local Button = require("UI.View.Button") -- 3
return function(args) -- 1
local _ENV = Dora(args) -- 1
local pad = AlignNode{alignOffset = Vec2(20,20), vAlign = "Top", hAlign = "Right"} -- 5
local menu = Menu() -- 6
menu.anchor = Vec2(1,1) -- 6
menu.scaleX = 2 -- 6
menu.scaleY = 2 -- 6
menu.size = Size(52,52) -- 6
pad:addChild(menu) -- 6
local item1 = Button{height = 52, width = 52, imageDown = 'esc_down', imageUp = 'esc_up'} -- 7
menu:addChild(item1) -- 7
item1:slot("Tapped",function() -- 8
pad:emit("Tapped") -- 10
Audio:play("Audio/choose.wav") -- 11
end) -- 11
return pad -- 11
end