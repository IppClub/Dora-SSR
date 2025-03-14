_ENV = Dora
-- @preview-file on clear
local root = Node()
local sprite = Sprite('Image/logo.png')
sprite.size = Size(Vec2(200, 200))
root:onTapBegan(function(touch)
  sprite:perform(Move(1, sprite.position, touch.location, Ease.OutBack), false)
end)
local temp = Node()
temp:onUpdate(function()
  nvg.ApplyTransform(temp)
  nvg.BeginPath()
  nvg.RoundedRect((-150), 0, 300, 300, 20)
  nvg.FillColor(Color(Color3(0x3c6ffa), math.floor(0.8 * 255 + 0.5)))
  nvg.Fill()
end)
temp:gslot('MyEvent', function(...)
  local args = {...}
  p(({'Got message', args}))
end)
threadLoop(function()
  sleep(1)
  p('abc')
end)
Audio:play('Audio/hero_win.wav', false)
Audio:playStream('Audio/Dismantlism Space.ogg', false, 0)
emit('MyEvent', table.unpack({123, 'xyz'}))
return 123
