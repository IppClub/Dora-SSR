local Director = require("Director")
local Node = require("Node")
local Model = require("Model")
local once = require("once")
local cycle = require("cycle")
local Sprite = require("Sprite")
local Vec2 = require("Vec2")
local Ease = require("Ease")
local Camera2D = require("Camera2D")
local threadLoop = require("threadLoop")

local node = Node()

local model = Model("Model/xiaoli.model")
model.look = "happy"
model:play("idle", true)
node:addChild(model)

local sprite = Sprite("Image/logo.png")
if sprite == nil then
	return
end
sprite.scaleX = 0.4
sprite.scaleY = 0.4
sprite.position = Vec2(200, -100)
sprite.angleY = 45
sprite.z = -300
node:addChild(sprite)

node:schedule(once(function()
	local camera = Director.currentCamera
	cycle(1.5, function(dt)
		camera.position = Vec2(200 * Ease:func(Ease.InOutQuad, dt), 0)
	end)
	cycle(0.1, function(dt)
		camera.rotation = 25 * Ease:func(Ease.OutSine, dt)
	end)
	cycle(0.2, function(dt)
		camera.rotation = 25 - 50 * Ease:func(Ease.InOutQuad, dt)
	end)
	cycle(0.1, function(dt)
		camera.rotation = -25 + 25 * Ease:func(Ease.OutSine, dt)
	end)
	cycle(1.5, function(dt)
		camera.position = Vec2(200 * Ease:func(Ease.InOutQuad, 1 - dt), 0)
	end)
	local zoom = camera.zoom
	cycle(2.5, function(dt)
		camera.zoom = zoom + Ease:func(Ease.InOutQuad, dt)
	end)
end))



local App = require("App")
local ImGui = require("ImGui")

local windowFlags = {
	"NoDecoration",
	"AlwaysAutoResize",
	"NoSavedSettings",
	"NoFocusOnAppearing",
	"NoNav",
	"NoMove",
}
threadLoop(function()
	local width = App.visualSize.width
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0))
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver")
	ImGui.Begin("Camera", windowFlags, function()
		ImGui.Text("Camera")
		ImGui.Separator()
		ImGui.TextWrapped("View camera motions, use 3D camera as default!")
	end)
end)