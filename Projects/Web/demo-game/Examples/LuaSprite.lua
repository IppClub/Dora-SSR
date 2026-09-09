local _ENV = Dora

local sprite = assert(Sprite("Image/logo.png"), "Lua Sprite example failed to create")
sprite.x = 500
sprite.y = 280
sprite.scaleX = 0.16
sprite.scaleY = 0.16
Director.ui:addChild(sprite)

print("Dora Web example Lua Sprite verified")
