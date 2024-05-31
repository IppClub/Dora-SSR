-- [xml]: UI/View/RestartPad.xml
local Button = require("UI.View.Button") -- 2
return function(args) -- 1
local _ENV = Dora(args) -- 1
local menu = Menu() -- 4
menu.anchor = Vec2(1,1) -- 4
menu.size = Size(52,52) -- 4
local item1 = Button{height = 52, width = 52, imageDown = 'esc_down', imageUp = 'esc_up'} -- 5
menu:addChild(item1) -- 5
item1:slot("Tapped",function() -- 6
Audio:play("Audio/choose.wav") -- 8
end) -- 8
return menu -- 8
end