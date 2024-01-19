local Director <const> = require("Director")
local Node <const> = require("Node")
local Model <const> = require("Model")
local once <const> = require("once")
local cycle <const> = require("cycle")
local Sprite <const> = require("Sprite")
local Vec2 <const> = require("Vec2")
local Ease <const> = require("Ease")
local Camera2D <const> = require("Camera2D")
local threadLoop <const> = require("threadLoop")

local node = Node()

local model = Model("Model/xiaoli.model")
model.look = "happy"
model:play("idle", true)
node:addChild(model)

local sprite = Sprite("Image/logo.png")
if sprite is nil then
	return
end
sprite.scaleX = 0.4
sprite.scaleY = 0.4
sprite.position = Vec2(200, -100)
sprite.angleY = 45
sprite.z = -300
node:addChild(sprite)

node:schedule(once(function(): boolean
	local camera = Director.currentCamera as Camera2D.Type
	cycle(1.5, function(dt: number)
		camera.position = Vec2(200 * Ease:func(Ease.InOutQuad, dt), 0)
	end)
	cycle(0.1, function(dt: number)
		camera.rotation = 25 * Ease:func(Ease.OutSine, dt)
	end)
	cycle(0.2, function(dt: number)
		camera.rotation = 25 - 50 * Ease:func(Ease.InOutQuad, dt)
	end)
	cycle(0.1, function(dt: number)
		camera.rotation = -25 + 25 * Ease:func(Ease.OutSine, dt)
	end)
	cycle(1.5, function(dt: number)
		camera.position = Vec2(200 * Ease:func(Ease.InOutQuad, 1 - dt), 0)
	end)
	local zoom = camera.zoom
	cycle(2.5, function(dt: number)
		camera.zoom = zoom + Ease:func(Ease.InOutQuad, dt)
	end)
end))

-- example codes ends here, some test ui below --

local App <const> = require("App")
local ImGui <const> = require("ImGui")

local windowFlags = {
	"NoDecoration",
	"AlwaysAutoResize",
	"NoSavedSettings",
	"NoFocusOnAppearing",
	"NoNav",
	"NoMove"
}
threadLoop(function(): boolean
	local width = App.visualSize.width
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0))
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver")
	ImGui.Begin("Camera", windowFlags, function()
		ImGui.Text("Camera")
		ImGui.Separator()
		ImGui.TextWrapped("View camera motions, use 3D camera as default!")
	end)
end)
