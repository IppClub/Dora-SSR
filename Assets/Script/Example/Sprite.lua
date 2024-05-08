-- [yue]: Script/Example/Sprite.yue
local Sprite = dora.Sprite -- 1
local Node = dora.Node -- 1
local threadLoop = dora.threadLoop -- 1
local App = dora.App -- 1
local ImGui = dora.ImGui -- 1
local Vec2 = dora.Vec2 -- 1
local Size = dora.Size -- 1
local math = _G.math -- 1
local sprite -- 3
do -- 3
	local _with_0 = Sprite("Image/logo.png") -- 3
	_with_0.scaleX = 0.5 -- 4
	_with_0.scaleY = 0.5 -- 4
	_with_0.showDebug = true -- 5
	sprite = _with_0 -- 3
end -- 3
do -- 7
	local _with_0 = Node() -- 7
	_with_0.touchEnabled = true -- 8
	_with_0:slot("TapMoved", function(touch) -- 9
		if not touch.first then -- 10
			return -- 10
		end -- 10
		sprite.position = sprite.position + touch.delta -- 11
	end) -- 9
	_with_0:addChild(sprite) -- 12
end -- 7
local windowFlags = { -- 17
	"NoResize", -- 17
	"NoSavedSettings" -- 18
} -- 16
return threadLoop(function() -- 19
	local width -- 20
	width = App.visualSize.width -- 20
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 21
	ImGui.SetNextWindowSize(Vec2(240, 520), "FirstUseEver") -- 22
	return ImGui.Begin("Sprite", windowFlags, function() -- 23
		ImGui.Text("Sprite (Yuescript)") -- 24
		ImGui.BeginChild("SpriteSetting", Vec2(-1, -40), function() -- 25
			local z = sprite.z -- 26
			do -- 27
				local changed -- 27
				changed, z = ImGui.DragFloat("Z", z, 1, -1000, 1000, "%.2f") -- 27
				if changed then -- 27
					sprite.z = z -- 28
				end -- 27
			end -- 27
			local x, y -- 29
			do -- 29
				local _obj_0 = sprite.anchor -- 29
				x, y = _obj_0.x, _obj_0.y -- 29
			end -- 29
			do -- 30
				local changed -- 30
				changed, x, y = ImGui.DragFloat2("Anchor", x, y, 0.01, 0, 1, "%.2f") -- 30
				if changed then -- 30
					sprite.anchor = Vec2(x, y) -- 31
				end -- 30
			end -- 30
			local spriteW, height -- 32
			do -- 32
				local _obj_0 = sprite.size -- 32
				spriteW, height = _obj_0.width, _obj_0.height -- 32
			end -- 32
			do -- 33
				local changed -- 33
				changed, spriteW, height = ImGui.DragFloat2("Size", spriteW, height, 0.1, 0, 1500, "%.f") -- 33
				if changed then -- 33
					sprite.size = Size(spriteW, height) -- 34
				end -- 33
			end -- 33
			local scaleX, scaleY = sprite.scaleX, sprite.scaleY -- 35
			do -- 36
				local changed -- 36
				changed, scaleX, scaleY = ImGui.DragFloat2("Scale", scaleX, scaleY, 0.01, -2, 2, "%.2f") -- 36
				if changed then -- 36
					sprite.scaleX, sprite.scaleY = scaleX, scaleY -- 37
				end -- 36
			end -- 36
			ImGui.PushItemWidth(-60, function() -- 38
				local angle = sprite.angle -- 39
				local changed -- 40
				changed, angle = ImGui.DragInt("Angle", math.floor(angle), 1, -360, 360) -- 40
				if changed then -- 40
					sprite.angle = angle -- 41
				end -- 40
			end) -- 38
			ImGui.PushItemWidth(-60, function() -- 42
				local angleX = sprite.angleX -- 43
				local changed -- 44
				changed, angleX = ImGui.DragInt("AngleX", math.floor(angleX), 1, -360, 360) -- 44
				if changed then -- 44
					sprite.angleX = angleX -- 45
				end -- 44
			end) -- 42
			ImGui.PushItemWidth(-60, function() -- 46
				local angleY = sprite.angleY -- 47
				local changed -- 48
				changed, angleY = ImGui.DragInt("AngleY", math.floor(angleY), 1, -360, 360) -- 48
				if changed then -- 48
					sprite.angleY = angleY -- 49
				end -- 48
			end) -- 46
			local skewX, skewY = sprite.skewX, sprite.skewY -- 50
			do -- 51
				local changed -- 51
				changed, skewX, skewY = ImGui.DragInt2("Skew", math.floor(skewX), math.floor(skewY), 1, -360, 360) -- 51
				if changed then -- 51
					sprite.skewX, sprite.skewY = skewX, skewY -- 52
				end -- 51
			end -- 51
			ImGui.PushItemWidth(-70, function() -- 53
				local opacity = sprite.opacity -- 54
				local changed -- 55
				changed, opacity = ImGui.DragFloat("Opacity", opacity, 0.01, 0, 1, "%.2f") -- 55
				if changed then -- 55
					sprite.opacity = opacity -- 56
				end -- 55
			end) -- 53
			return ImGui.PushItemWidth(-1, function() -- 57
				local color3 = sprite.color3 -- 58
				ImGui.SetColorEditOptions({ -- 59
					"DisplayRGB" -- 59
				}) -- 59
				if ImGui.ColorEdit3("", color3) then -- 60
					sprite.color3 = color3 -- 61
				end -- 60
			end) -- 61
		end) -- 25
		if ImGui.Button("Reset", Vec2(140, 30)) then -- 62
			local _with_0 = sprite.parent -- 63
			_with_0:removeChild(sprite) -- 64
			do -- 65
				local _with_1 = Sprite("Image/logo.png") -- 65
				_with_1.scaleX = 0.5 -- 66
				_with_1.scaleY = 0.5 -- 66
				_with_1.showDebug = true -- 67
				sprite = _with_1 -- 65
			end -- 65
			_with_0:addChild(sprite) -- 68
			return _with_0 -- 63
		end -- 62
	end) -- 68
end) -- 68
