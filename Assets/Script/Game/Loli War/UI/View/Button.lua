-- [xml]: Script/Game/Loli War/UI/View/Button.xml
return function(args) -- 1
local _ENV = Dora(args) -- 1
local node1 = Node() -- 1
node1.anchor = Vec2(0,0) -- 1
node1.x = x or 0 -- 1
node1.y = y or 0 -- 1
node1.size = Size(width,height) -- 1
node1.touchEnabled = true -- 1
local up = Sprite('Model/items.clip|'..imageUp) -- 2
up.x = node1.width*0.5 -- 2
up.y = node1.height*0.5 -- 2
node1:addChild(up) -- 2
local down = Sprite('Model/items.clip|'..imageDown) -- 3
down.x = node1.width*0.5 -- 3
down.y = node1.height*0.5 -- 3
down.visible = false -- 3
node1:addChild(down) -- 3
local hide = Hide() -- 5
local show = Show() -- 6
node1:slot("TapBegan",function() -- 8
up:perform(hide) -- 8
end) -- 8
node1:slot("TapBegan",function() -- 9
down:perform(show) -- 9
end) -- 9
node1:slot("TapEnded",function() -- 10
up:perform(show) -- 10
end) -- 10
node1:slot("TapEnded",function() -- 11
down:perform(hide) -- 11
end) -- 11
return node1 -- 11
end