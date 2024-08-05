-- [yue]: Script/Example/Sprite.yue
local Sprite = Dora.Sprite -- 1
local Node = Dora.Node -- 1
local threadLoop = Dora.threadLoop -- 1
local App = Dora.App -- 1
local ImGui = Dora.ImGui -- 1
local Vec2 = Dora.Vec2 -- 1
local Size = Dora.Size -- 1
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
	"NoSavedSettings" -- 17
} -- 17
return threadLoop(function() -- 18
	local width -- 19
	width = App.visualSize.width -- 19
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "FirstUseEver", Vec2(1, 0)) -- 20
	ImGui.SetNextWindowSize(Vec2(240, 520), "FirstUseEver") -- 21
	return ImGui.Begin("Sprite", windowFlags, function() -- 22
		ImGui.Text("Sprite (Yuescript)") -- 23
		ImGui.BeginChild("SpriteSetting", Vec2(-1, -40), function() -- 24
			local z = sprite.z -- 25
			do -- 26
				local changed -- 26
				changed, z = ImGui.DragFloat("Z", z, 1, -1000, 1000, "%.2f") -- 26
				if changed then -- 26
					sprite.z = z -- 27
				end -- 26
			end -- 26
			local x, y -- 28
			do -- 28
				local _obj_0 = sprite.anchor -- 28
				x, y = _obj_0.x, _obj_0.y -- 28
			end -- 28
			do -- 29
				local changed -- 29
				changed, x, y = ImGui.DragFloat2("Anchor", x, y, 0.01, 0, 1, "%.2f") -- 29
				if changed then -- 29
					sprite.anchor = Vec2(x, y) -- 30
				end -- 29
			end -- 29
			local spriteW, height -- 31
			do -- 31
				local _obj_0 = sprite.size -- 31
				spriteW, height = _obj_0.width, _obj_0.height -- 31
			end -- 31
			do -- 32
				local changed -- 32
				changed, spriteW, height = ImGui.DragFloat2("Size", spriteW, height, 1, 0, 1500, "%.f") -- 32
				if changed then -- 32
					sprite.size = Size(spriteW, height) -- 33
				end -- 32
			end -- 32
			local scaleX, scaleY = sprite.scaleX, sprite.scaleY -- 34
			do -- 35
				local changed -- 35
				changed, scaleX, scaleY = ImGui.DragFloat2("Scale", scaleX, scaleY, 0.01, -2, 2, "%.2f") -- 35
				if changed then -- 35
					sprite.scaleX, sprite.scaleY = scaleX, scaleY -- 36
				end -- 35
			end -- 35
			ImGui.PushItemWidth(-60, function() -- 37
				local angle = sprite.angle -- 38
				local changed -- 39
				changed, angle = ImGui.DragInt("Angle", math.floor(angle), 1, -360, 360) -- 39
				if changed then -- 39
					sprite.angle = angle -- 40
				end -- 39
			end) -- 37
			ImGui.PushItemWidth(-60, function() -- 41
				local angleX = sprite.angleX -- 42
				local changed -- 43
				changed, angleX = ImGui.DragInt("AngleX", math.floor(angleX), 1, -360, 360) -- 43
				if changed then -- 43
					sprite.angleX = angleX -- 44
				end -- 43
			end) -- 41
			ImGui.PushItemWidth(-60, function() -- 45
				local angleY = sprite.angleY -- 46
				local changed -- 47
				changed, angleY = ImGui.DragInt("AngleY", math.floor(angleY), 1, -360, 360) -- 47
				if changed then -- 47
					sprite.angleY = angleY -- 48
				end -- 47
			end) -- 45
			local skewX, skewY = sprite.skewX, sprite.skewY -- 49
			do -- 50
				local changed -- 50
				changed, skewX, skewY = ImGui.DragInt2("Skew", math.floor(skewX), math.floor(skewY), 1, -360, 360) -- 50
				if changed then -- 50
					sprite.skewX, sprite.skewY = skewX, skewY -- 51
				end -- 50
			end -- 50
			ImGui.PushItemWidth(-70, function() -- 52
				local opacity = sprite.opacity -- 53
				local changed -- 54
				changed, opacity = ImGui.DragFloat("Opacity", opacity, 0.01, 0, 1, "%.2f") -- 54
				if changed then -- 54
					sprite.opacity = opacity -- 55
				end -- 54
			end) -- 52
			return ImGui.PushItemWidth(-1, function() -- 56
				local color3 = sprite.color3 -- 57
				ImGui.SetColorEditOptions({ -- 58
					"DisplayRGB" -- 58
				}) -- 58
				if ImGui.ColorEdit3("", color3) then -- 59
					sprite.color3 = color3 -- 60
				end -- 59
			end) -- 60
		end) -- 24
		if ImGui.Button("Reset", Vec2(140, 30)) then -- 61
			local _with_0 = sprite.parent -- 62
			_with_0:removeChild(sprite) -- 63
			do -- 64
				local _with_1 = Sprite("Image/logo.png") -- 64
				_with_1.scaleX = 0.5 -- 65
				_with_1.scaleY = 0.5 -- 65
				_with_1.showDebug = true -- 66
				sprite = _with_1 -- 64
			end -- 64
			_with_0:addChild(sprite) -- 67
			return _with_0 -- 62
		end -- 61
	end) -- 67
end) -- 67
