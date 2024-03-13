-- [xml]: Script/Game/Loli War/UI/View/HPWheel.xml
local AlignNode = require("UI.Control.Basic.AlignNode") -- 2
local Digit = require("UI.Control.Digit") -- 3
return function(args) -- 1
local _ENV = Dora(args) -- 1
local item1 = AlignNode{alignOffset = Vec2(75,75), vAlign = "Top", hAlign = "Left"} -- 5
local node1 = Node() -- 6
node1.scaleX = 1 -- 6
node1.scaleY = 1 -- 6
item1:addChild(node1) -- 6
local hpShow = Playable("model:Model/hpshow") -- 7
hpShow.scaleX = 2 -- 7
hpShow.scaleY = 2 -- 7
hpShow.look = "8" -- 7
hpShow:play("idle",true) -- 7
node1:addChild(hpShow) -- 7
item1.hpShow = hpShow -- 7
local energy = Node() -- 8
energy.x = 75 -- 8
energy.y = 20 -- 8
energy.scaleX = 2 -- 8
energy.scaleY = 2 -- 8
node1:addChild(energy) -- 8
item1.energy = energy -- 8
local sprite1 = Sprite("Model/misc.clip|enegyframe") -- 9
sprite1.anchor = Vec2(0,sprite1.anchor.y) -- 9
energy:addChild(sprite1) -- 9
local fill = Sprite("Model/misc.clip|enegyfill") -- 10
fill.anchor = Vec2(0,fill.anchor.y) -- 10
fill.x = 1 -- 10
energy:addChild(fill) -- 10
item1.fill = fill -- 10
local sprite2 = Sprite("Model/misc.clip|vs") -- 11
sprite2.anchor = Vec2(0,sprite2.anchor.y) -- 11
sprite2.y = -20 -- 11
energy:addChild(sprite2) -- 11
local playerBlocks = Digit{y = -20, x = 20} -- 12
energy:addChild(playerBlocks) -- 12
item1.playerBlocks = playerBlocks -- 12
local enemyBlocks = Digit{y = -20, x = 37} -- 13
energy:addChild(enemyBlocks) -- 13
item1.enemyBlocks = enemyBlocks -- 13
return item1 -- 13
end