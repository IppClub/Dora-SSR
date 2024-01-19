local Sprite = require("Sprite")
local type Touch = require("TouchType")

local sprite = Sprite("Image/logo.png")
if sprite is nil then
	return
end
sprite.scaleX = 0.5
sprite.scaleY = 0.5
sprite.touchEnabled = true
sprite:slot("TapMoved", function(touch: Touch)
	if not touch.first then
		return
	end
	sprite.position = sprite.position + touch.delta
end)

local ImGui = require("ImGui")
local Vec2 = require("Vec2")
local Size = require("Size")
local App = require("App")
local threadLoop = require("threadLoop")

local windowFlags = {
	"NoResize",
	"NoSavedSettings"
}
threadLoop(function(): boolean
	local width = App.visualSize.width
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0))
	ImGui.SetNextWindowSize(Vec2(240, 520), "FirstUseEver")
	ImGui.Begin("Sprite", windowFlags, function()
		ImGui.BeginChild("SpriteSetting", Vec2(-1, -40), function()
			if sprite is nil then
				return
			end
			local changed = false
			local z = sprite.z
			changed, z = ImGui.DragFloat("Z", z, 1, -1000, 1000, "%.2f")
			if changed then
				sprite.z = z
			end
			local anchor = sprite.anchor
			local x, y = anchor.x, anchor.y
			changed, x, y = ImGui.DragFloat2("Anchor", x, y, 0.01, 0, 1, "%.2f")
			if changed then
				sprite.anchor = Vec2(x, y)
			end
			local size = sprite.size
			local spriteW, height = size.width, size.height
			changed, spriteW, height = ImGui.DragFloat2("Size", spriteW, height, 0.1, 0, 1000, "%.f")
			if changed then
				sprite.size = Size(spriteW, height)
			end
			local scaleX, scaleY = sprite.scaleX, sprite.scaleY
			changed, scaleX, scaleY = ImGui.DragFloat2("Scale", scaleX, scaleY, 0.01, -2, 2, "%.2f")
			if changed then
				sprite.scaleX, sprite.scaleY = scaleX, scaleY
			end
			ImGui.PushItemWidth(-60, function()
				local angle = sprite.angle
				changed, angle = ImGui.DragInt("Angle", math.floor(angle), 1, -360, 360)
				if changed then
					sprite.angle = angle
				end
			end)
			ImGui.PushItemWidth(-60, function()
				local angleX = sprite.angleX
				changed, angleX = ImGui.DragInt("AngleX", math.floor(angleX), 1, -360, 360)
				if changed then
					sprite.angleX = angleX
				end
			end)
			ImGui.PushItemWidth(-60, function()
				local angleY = sprite.angleY
				changed, angleY = ImGui.DragInt("AngleY", math.floor(angleY), 1, -360, 360)
				if changed then
					sprite.angleY = angleY
				end
			end)
			local skewX, skewY = sprite.skewX, sprite.skewY
			changed, skewX, skewY = ImGui.DragInt2("Skew", math.floor(skewX), math.floor(skewY), 1, -360, 360)
			if changed then
				sprite.skewX, sprite.skewY = skewX, skewY
			end
			ImGui.PushItemWidth(-70, function()
				local opacity = sprite.opacity
				changed, opacity = ImGui.DragFloat("Opacity", opacity, 0.01, 0, 1, "%.2f")
				if changed then
					sprite.opacity = opacity
				end
			end)
			ImGui.PushItemWidth(-1, function()
				local color3 = sprite.color3
				ImGui.SetColorEditOptions("RGB")
				if ImGui.ColorEdit3("", color3) then
					sprite.color3 = color3
				end
			end)
		end)
		if ImGui.Button("Reset", Vec2(140, 30)) then
			if sprite is nil then
				return
			end
			local parent = sprite.parent
			parent:removeChild(sprite)
			sprite = Sprite("Image/logo.png")
			parent:addChild(sprite)
		end
	end)
end)

