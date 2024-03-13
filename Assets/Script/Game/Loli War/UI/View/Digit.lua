-- [xml]: Script/Game/Loli War/UI/View/Digit.xml
return function(args) -- 1
local _ENV = Dora(args) -- 1
local node1 = Node() -- 1
node1.x = x -- 1
node1.y = y -- 1
local sprite1 = Sprite("Model/misc.clip|9") -- 2
sprite1.anchor = Vec2(0,sprite1.anchor.y) -- 2
sprite1.x = 0 -- 2
node1:addChild(sprite1) -- 2
local sprite2 = Sprite("Model/misc.clip|9") -- 3
sprite2.anchor = Vec2(0,sprite2.anchor.y) -- 3
sprite2.x = 6 -- 3
node1:addChild(sprite2) -- 3
return node1 -- 3
end