-- [xml]: Script/Test/NestedClipping.xml
return function(args) -- 1
local _ENV = Dora(args) -- 1
local clipNode1 = ClipNode() -- 3
local sprite1 = Sprite("Image/logo.png") -- 5
clipNode1.stencil = sprite1 -- 5
local clipNode2 = ClipNode() -- 8
clipNode2.x = 400 -- 8
clipNode1:addChild(clipNode2) -- 8
local sprite2 = Sprite("Image/logo.png") -- 10
sprite2.scaleX = 0.5 -- 10
sprite2.scaleY = 0.5 -- 10
clipNode2.stencil = sprite2 -- 10
local sprite3 = Sprite("Image/logo.png") -- 12
clipNode2:addChild(sprite3) -- 12
return clipNode1 -- 12
end