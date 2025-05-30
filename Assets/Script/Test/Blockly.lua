local _ENV = setmetatable({}, {__index = _G})
local Node <const> = require("Node")
local Sprite <const> = require("Sprite")
local Vec2 <const> = require("Vec2")
local Size <const> = require("Size")
local Move <const> = require("Move")
local Ease <const> = require("Ease")
local nvg <const> = require("nvg")
local sleep <const> = require("sleep")
local threadLoop <const> = require("threadLoop")
local Audio <const> = require("Audio")
local emit <const> = require("emit")
local PhysicsWorld <const> = require("PhysicsWorld")
local BodyDef <const> = require("BodyDef")
local Body <const> = require("Body")
-- @preview-file on clear
local root = Node()
local sprite = Sprite('Image/logo.png')
sprite.size = Size(Vec2(200, 200))
root:onTapBegan(function(touch)
  sprite:perform(Move(1, sprite.position, touch.location, Ease.OutBack), false)
end)
local temp = Node()
temp:onRender(function()
  nvg.ApplyTransform(temp)
  nvg.BeginPath()
  nvg.RoundedRect(-150, 0, 300, 300, 20)
  nvg.FillColor(0x3c6ffa | math.floor(0.8 * 255 + 0.5) << 24)
  nvg.Fill()
end)
temp:gslot('MyEvent', function(arg0, arg1)
  p({arg0, arg1})
end)
threadLoop(function()
  sleep(1)
  p('abc')
end)
Audio:play('Audio/hero_win.wav', false)
Audio:playStream('Audio/Dismantlism Space.ogg', false, 0)
emit('MyEvent', 998, 'Hello')
temp.position = Vec2(0, 0)
local world = PhysicsWorld()
world.showDebug = true
local temp = (function()
  local bodyDef = BodyDef()
  bodyDef.type = 'Dynamic'
  bodyDef.fixedRotation = false
  bodyDef.group = 0
  bodyDef.linearAcceleration = Vec2(0, -9.8)
  bodyDef:attachPolygon(Vec2(0, 150), 80, 80, 0, 1, 0.4, 0)
  return Body(bodyDef, world, Vec2(0, 0), 0)
end)()
local temp = (function()
  local bodyDef2 = BodyDef()
  bodyDef2.type = 'Static'
  bodyDef2.fixedRotation = false
  bodyDef2.group = 0
  bodyDef2.linearAcceleration = Vec2(0, -9.8)
  bodyDef2:attachPolygon({Vec2(-100, -50), Vec2(-80, 0), Vec2(80, 0), Vec2(100, -50)}, 1, 0.4, 0.4)
  return Body(bodyDef2, world, Vec2(0, -200), 0)
end)()
return 123
