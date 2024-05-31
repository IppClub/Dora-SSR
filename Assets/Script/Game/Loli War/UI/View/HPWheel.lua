-- [xml]: UI/View/HPWheel.xml
local Digit = require("UI.Control.Digit") -- 2
return function(args) -- 1
local _ENV = Dora(args) -- 1
local node1 = Node() -- 4
local hpShow = Playable("model:Model/hpshow") -- 5
hpShow.scaleX = 2 -- 5
hpShow.scaleY = 2 -- 5
hpShow.look = "8" -- 5
hpShow:play("idle",true) -- 5
node1:addChild(hpShow) -- 5
node1.hpShow = hpShow -- 5
local energy = Node() -- 6
energy.x = 75 -- 6
energy.y = 20 -- 6
energy.scaleX = 2 -- 6
energy.scaleY = 2 -- 6
node1:addChild(energy) -- 6
node1.energy = energy -- 6
local sprite1 = Sprite("Model/misc.clip|enegyframe") -- 7
sprite1.anchor = Vec2(0,sprite1.anchor.y) -- 7
energy:addChild(sprite1) -- 7
local fill = Sprite("Model/misc.clip|enegyfill") -- 8
fill.anchor = Vec2(0,fill.anchor.y) -- 8
fill.x = 1 -- 8
energy:addChild(fill) -- 8
node1.fill = fill -- 8
local sprite2 = Sprite("Model/misc.clip|vs") -- 9
sprite2.anchor = Vec2(0,sprite2.anchor.y) -- 9
sprite2.y = -20 -- 9
energy:addChild(sprite2) -- 9
local playerBlocks = Digit{y = -20, x = 20} -- 10
energy:addChild(playerBlocks) -- 10
node1.playerBlocks = playerBlocks -- 10
local enemyBlocks = Digit{y = -20, x = 37} -- 11
energy:addChild(enemyBlocks) -- 11
node1.enemyBlocks = enemyBlocks -- 11
return node1 -- 11
end