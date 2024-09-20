-- [ts]: CameraTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 3
local ____Dora = require("Dora") -- 4
local App = ____Dora.App -- 4
local Director = ____Dora.Director -- 4
local Ease = ____Dora.Ease -- 4
local Model = ____Dora.Model -- 4
local Node = ____Dora.Node -- 4
local Sprite = ____Dora.Sprite -- 4
local Vec2 = ____Dora.Vec2 -- 4
local cycle = ____Dora.cycle -- 4
local once = ____Dora.once -- 4
local threadLoop = ____Dora.threadLoop -- 4
local tolua = ____Dora.tolua -- 4
local node = Node() -- 6
local model = Model("Model/xiaoli.model") -- 8
if model ~= nil then -- 8
	model.look = "happy" -- 10
	model:play("idle", true) -- 11
	node:addChild(model) -- 12
end -- 12
local sprite = Sprite("Image/logo.png") -- 15
if sprite ~= nil then -- 15
	sprite.scaleX = 0.4 -- 17
	sprite.scaleY = 0.4 -- 18
	sprite.position = Vec2(200, -100) -- 19
	sprite.angleY = 45 -- 20
	sprite.z = -300 -- 21
	node:addChild(sprite) -- 22
end -- 22
node:schedule(once(function() -- 25
	local camera = tolua.cast(Director.currentCamera, "Camera2D") -- 26
	if camera == nil then -- 26
		return -- 27
	end -- 27
	cycle( -- 28
		1.5, -- 28
		function(dt) -- 28
			camera.position = Vec2( -- 29
				200 * Ease:func(Ease.InOutQuad, dt), -- 29
				0 -- 29
			) -- 29
		end -- 28
	) -- 28
	cycle( -- 31
		0.1, -- 31
		function(dt) -- 31
			camera.rotation = 25 * Ease:func(Ease.OutSine, dt) -- 32
		end -- 31
	) -- 31
	cycle( -- 34
		0.2, -- 34
		function(dt) -- 34
			camera.rotation = 25 - 50 * Ease:func(Ease.InOutQuad, dt) -- 35
		end -- 34
	) -- 34
	cycle( -- 37
		0.1, -- 37
		function(dt) -- 37
			camera.rotation = -25 + 25 * Ease:func(Ease.OutSine, dt) -- 38
		end -- 37
	) -- 37
	cycle( -- 40
		1.5, -- 40
		function(dt) -- 40
			camera.position = Vec2( -- 41
				200 * Ease:func(Ease.InOutQuad, 1 - dt), -- 41
				0 -- 41
			) -- 41
		end -- 40
	) -- 40
	local zoom = camera.zoom -- 40
	cycle( -- 44
		2.5, -- 44
		function(dt) -- 44
			camera.zoom = zoom + Ease:func(Ease.InOutQuad, dt) -- 45
		end -- 44
	) -- 44
end)) -- 25
local windowFlags = { -- 49
	"NoDecoration", -- 50
	"AlwaysAutoResize", -- 51
	"NoSavedSettings", -- 52
	"NoFocusOnAppearing", -- 53
	"NoNav", -- 54
	"NoMove" -- 55
} -- 55
threadLoop(function() -- 57
	local ____App_visualSize_0 = App.visualSize -- 58
	local width = ____App_visualSize_0.width -- 58
	ImGui.SetNextWindowPos( -- 59
		Vec2(width - 10, 10), -- 59
		"Always", -- 59
		Vec2(1, 0) -- 59
	) -- 59
	ImGui.SetNextWindowSize( -- 60
		Vec2(240, 0), -- 60
		"FirstUseEver" -- 60
	) -- 60
	ImGui.Begin( -- 61
		"Camera", -- 61
		windowFlags, -- 61
		function() -- 61
			ImGui.Text("Camera (Typescript)") -- 62
			ImGui.Separator() -- 63
			ImGui.TextWrapped("View camera motions, use 3D camera as default!") -- 64
		end -- 61
	) -- 61
	return false -- 66
end) -- 57
return ____exports -- 57