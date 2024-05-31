-- [xml]: UI/View/StartPanel.xml
local ButtonGlow = require("UI.Control.ButtonGlow") -- 2
return function(args) -- 1
local _ENV = Dora(args) -- 1
local node1 = Node() -- 4
node1.touchEnabled = true -- 4
node1.swallowTouches = true -- 4
local node = Sprite("Model/misc.clip|startboard") -- 5
node1:addChild(node) -- 5
node1.node = node -- 5
local scaleOut = Action(Sequence(Spawn(Scale(1,1,0.3,Ease.InBack),Opacity(1,1,0)),Event("PanelHide"))) -- 7
local fButton = ButtonGlow{height = 167, width = 118, y = node.height*0.5, x = node.width/3-30, glow = 'weaponfl', normal = 'weaponf'} -- 15
node:addChild(fButton) -- 15
node1.fButton = fButton -- 15
fButton:slot("Tapped",function() -- 16
node:perform(scaleOut) -- 16
end) -- 16
local vButton = ButtonGlow{height = 68, width = 82, y = node.height*0.5, x = node.width*0.5, glow = 'weaponvl', normal = 'weaponv'} -- 18
node:addChild(vButton) -- 18
node1.vButton = vButton -- 18
vButton:slot("Tapped",function() -- 19
node:perform(scaleOut) -- 19
end) -- 19
local dButton = ButtonGlow{height = 97, width = 57, y = node.height*0.5, x = node.width-node.width/3+30, glow = 'weapondl', normal = 'weapond'} -- 21
node:addChild(dButton) -- 21
node1.dButton = dButton -- 21
dButton:slot("Tapped",function() -- 22
node:perform(scaleOut) -- 22
end) -- 22
local scaleIn = Action(Scale(1,0,1,Ease.OutBack)) -- 25
local fadeIn = Sequence(Hide(),Delay(1),Show(),Opacity(0.5,0,1)) -- 26
node:slot("Enter",function() -- 33
node:perform(scaleIn) -- 33
fButton:perform(fadeIn) -- 35
vButton:perform(fadeIn) -- 36
dButton:perform(fadeIn) -- 37
end) -- 37
return node1 -- 37
end