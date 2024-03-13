-- [xml]: Script/Test/NestedClipping.xml
return function(args) -- 1
local _ENV = Dora(args) -- 1
local clipNode1 = ClipNode() -- 2
local sprite1 = Sprite("Image/logo.png") -- 4
clipNode1.stencil = sprite1 -- 4
local clipNode2 = ClipNode() -- 7
clipNode2.x = 400 -- 7
clipNode1:addChild(clipNode2) -- 7
local sprite2 = Sprite("Image/logo.png") -- 9
sprite2.scaleX = 0.5 -- 9
sprite2.scaleY = 0.5 -- 9
clipNode2.stencil = sprite2 -- 9
local sprite3 = Sprite("Image/logo.png") -- 11
clipNode2:addChild(sprite3) -- 11
return clipNode1 -- 11
end