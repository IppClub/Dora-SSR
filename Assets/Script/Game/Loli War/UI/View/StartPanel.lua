-- [xml]: Script/Game/Loli War/UI/View/StartPanel.xml
local AlignNode = require("UI.Control.Basic.AlignNode") -- 2
local ButtonGlow = require("UI.Control.ButtonGlow") -- 3
return function(args) -- 1
local _ENV = Dora(args) -- 1
local item1 = AlignNode{hAlign = 'Center', vAlign = 'Center'} -- 5
local node1 = Node() -- 6
node1.scaleX = 2 * App.devicePixelRatio -- 6
node1.scaleY = 2 * App.devicePixelRatio -- 6
item1:addChild(node1) -- 6
local node = Node() -- 7
node.touchEnabled = true -- 7
node.swallowTouches = true -- 7
node1:addChild(node) -- 7
item1.node = node -- 7
local sprite1 = Sprite("Model/misc.clip|startboard") -- 8
node:addChild(sprite1) -- 8
local scaleOut = Action(Sequence(Spawn(Scale(1,1,0.3,Ease.InBack),Opacity(1,1,0)),Event("PanelHide"))) -- 10
local fButton = ButtonGlow{height = 167, width = 118, y = sprite1.height*0.5, x = sprite1.width/3-30, glow = 'weaponfl', normal = 'weaponf'} -- 18
sprite1:addChild(fButton) -- 18
item1.fButton = fButton -- 18
fButton:slot("Tapped",function() -- 19
node:perform(scaleOut) -- 19
end) -- 19
local vButton = ButtonGlow{height = 68, width = 82, y = sprite1.height*0.5, x = sprite1.width*0.5, glow = 'weaponvl', normal = 'weaponv'} -- 21
sprite1:addChild(vButton) -- 21
item1.vButton = vButton -- 21
vButton:slot("Tapped",function() -- 22
node:perform(scaleOut) -- 22
end) -- 22
local dButton = ButtonGlow{height = 97, width = 57, y = sprite1.height*0.5, x = sprite1.width-sprite1.width/3+30, glow = 'weapondl', normal = 'weapond'} -- 24
sprite1:addChild(dButton) -- 24
item1.dButton = dButton -- 24
dButton:slot("Tapped",function() -- 25
node:perform(scaleOut) -- 25
end) -- 25
local scaleIn = Action(Scale(1,0,1,Ease.OutBack)) -- 31
local fadeIn = Sequence(Hide(),Delay(1),Show(),Opacity(0.5,0,1)) -- 32
item1:slot("Enter",function() -- 39
node:perform(scaleIn) -- 39
fButton:perform(fadeIn) -- 41
vButton:perform(fadeIn) -- 42
dButton:perform(fadeIn) -- 43
end) -- 43
return item1 -- 43
end