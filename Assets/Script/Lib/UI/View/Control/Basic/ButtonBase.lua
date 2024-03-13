-- [xml]: Script/Lib/UI/View/Control/Basic/ButtonBase.xml
return function(args) -- 1
local _ENV = Dora(args) -- 1
local node1 = Node() -- 3
node1.x = x or 0 -- 3
node1.y = y or 0 -- 3
node1.color3 = Color3(App.themeColor:toARGB()) -- 3
node1.tag = tag or '' -- 3
node1.size = Size(width,height) -- 3
node1.touchEnabled = true -- 3
local scaleAction = Action(Sequence(Scale(0.08,1.0,0.3),Scale(0.3,0.3,1,Ease.OutBack))) -- 6
local face = Node() -- 13
face.x = node1.width*0.5 -- 13
face.y = node1.height*0.5 -- 13
face.size = Size(width,height) -- 13
node1:addChild(face) -- 13
node1.face = face -- 13
node1:slot("Tapped",function() -- 16
face:perform(scaleAction) -- 16
end) -- 16
return node1 -- 16
end