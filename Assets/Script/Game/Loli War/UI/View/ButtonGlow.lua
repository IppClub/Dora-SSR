-- [xml]: Script/Game/Loli War/UI/View/ButtonGlow.xml
return function(args) -- 1
local _ENV = Dora(args) -- 1
local node1 = Node() -- 1
node1.x = x or 0 -- 1
node1.y = y or 0 -- 1
node1.size = Size(width,height) -- 1
node1.touchEnabled = true -- 1
local up = Sprite('Model/misc.clip|'..normal) -- 2
up.x = node1.width*0.5 -- 2
up.y = node1.height*0.5 -- 2
node1:addChild(up) -- 2
node1.up = up -- 2
local down = Sprite('Model/misc.clip|'..glow) -- 3
down.x = node1.width*0.5 -- 3
down.y = node1.height*0.5 -- 3
down.visible = false -- 3
node1:addChild(down) -- 3
node1.down = down -- 3
return node1 -- 3
end