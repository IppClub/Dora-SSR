-- [xml]: UI/View/EPHint.xml
return function(args) -- 1
local _ENV = Dora(args) -- 1
local node1 = Node() -- 1
node1.x = 55+(index-1)*25 -- 1
node1.visible = false -- 1
local sprite1 = Sprite('Model/misc.clip|'..clip) -- 2
sprite1.anchor = Vec2(0,sprite1.anchor.y) -- 2
node1:addChild(sprite1) -- 2
local show = Action(Sequence(Show(),Spawn(Opacity(0.5,0,1),Sequence(Scale(0.3,0,1.5,Ease.OutQuad),Scale(0.2,1.5,1,Ease.InQuad))),Delay(0.8),Opacity(0.3,1,0),Hide(),Event("DisplayEnd"))) -- 4
node1:slot("Enter",function() -- 19
node1:perform(show) -- 19
end) -- 19
return node1 -- 19
end