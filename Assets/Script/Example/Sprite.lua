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
	_with_0:onTapMoved(function(touch) -- 8
		if not touch.first then -- 9
			return -- 9
		end -- 9
		sprite.position = sprite.position + touch.delta -- 10
	end) -- 8
	_with_0:addChild(sprite) -- 11
end -- 7
local windowFlags = { -- 16
	"NoResize", -- 16
	"NoSavedSettings" -- 16
} -- 16
return threadLoop(function() -- 17
	local width -- 18
	width = App.visualSize.width -- 18
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "FirstUseEver", Vec2(1, 0)) -- 19
	ImGui.SetNextWindowSize(Vec2(240, 520), "FirstUseEver") -- 20
	return ImGui.Begin("Sprite", windowFlags, function() -- 21
		ImGui.Text("Sprite (Yuescript)") -- 22
		ImGui.BeginChild("SpriteSetting", Vec2(-1, -40), function() -- 23
			local z = sprite.z -- 24
			do -- 25
				local changed -- 25
				changed, z = ImGui.DragFloat("Z", z, 1, -1000, 1000, "%.2f") -- 25
				if changed then -- 25
					sprite.z = z -- 26
				end -- 25
			end -- 25
			local x, y -- 27
			do -- 27
				local _obj_0 = sprite.anchor -- 27
				x, y = _obj_0.x, _obj_0.y -- 27
			end -- 27
			do -- 28
				local changed -- 28
				changed, x, y = ImGui.DragFloat2("Anchor", x, y, 0.01, 0, 1, "%.2f") -- 28
				if changed then -- 28
					sprite.anchor = Vec2(x, y) -- 29
				end -- 28
			end -- 28
			local spriteW, height -- 30
			do -- 30
				local _obj_0 = sprite.size -- 30
				spriteW, height = _obj_0.width, _obj_0.height -- 30
			end -- 30
			do -- 31
				local changed -- 31
				changed, spriteW, height = ImGui.DragFloat2("Size", spriteW, height, 1, 0, 1500, "%.f") -- 31
				if changed then -- 31
					sprite.size = Size(spriteW, height) -- 32
				end -- 31
			end -- 31
			local scaleX, scaleY = sprite.scaleX, sprite.scaleY -- 33
			do -- 34
				local changed -- 34
				changed, scaleX, scaleY = ImGui.DragFloat2("Scale", scaleX, scaleY, 0.01, -2, 2, "%.2f") -- 34
				if changed then -- 34
					sprite.scaleX, sprite.scaleY = scaleX, scaleY -- 35
				end -- 34
			end -- 34
			ImGui.PushItemWidth(-60, function() -- 36
				local angle = sprite.angle -- 37
				local changed -- 38
				changed, angle = ImGui.DragInt("Angle", math.floor(angle), 1, -360, 360) -- 38
				if changed then -- 38
					sprite.angle = angle -- 39
				end -- 38
			end) -- 36
			ImGui.PushItemWidth(-60, function() -- 40
				local angleX = sprite.angleX -- 41
				local changed -- 42
				changed, angleX = ImGui.DragInt("AngleX", math.floor(angleX), 1, -360, 360) -- 42
				if changed then -- 42
					sprite.angleX = angleX -- 43
				end -- 42
			end) -- 40
			ImGui.PushItemWidth(-60, function() -- 44
				local angleY = sprite.angleY -- 45
				local changed -- 46
				changed, angleY = ImGui.DragInt("AngleY", math.floor(angleY), 1, -360, 360) -- 46
				if changed then -- 46
					sprite.angleY = angleY -- 47
				end -- 46
			end) -- 44
			local skewX, skewY = sprite.skewX, sprite.skewY -- 48
			do -- 49
				local changed -- 49
				changed, skewX, skewY = ImGui.DragInt2("Skew", math.floor(skewX), math.floor(skewY), 1, -360, 360) -- 49
				if changed then -- 49
					sprite.skewX, sprite.skewY = skewX, skewY -- 50
				end -- 49
			end -- 49
			ImGui.PushItemWidth(-70, function() -- 51
				local opacity = sprite.opacity -- 52
				local changed -- 53
				changed, opacity = ImGui.DragFloat("Opacity", opacity, 0.01, 0, 1, "%.2f") -- 53
				if changed then -- 53
					sprite.opacity = opacity -- 54
				end -- 53
			end) -- 51
			return ImGui.PushItemWidth(-1, function() -- 55
				local color3 = sprite.color3 -- 56
				ImGui.SetColorEditOptions({ -- 57
					"DisplayRGB" -- 57
				}) -- 57
				if ImGui.ColorEdit3("", color3) then -- 58
					sprite.color3 = color3 -- 59
				end -- 58
			end) -- 59
		end) -- 23
		if ImGui.Button("Reset", Vec2(140, 30)) then -- 60
			local _with_0 = sprite.parent -- 61
			_with_0:removeChild(sprite) -- 62
			do -- 63
				local _with_1 = Sprite("Image/logo.png") -- 63
				_with_1.scaleX = 0.5 -- 64
				_with_1.scaleY = 0.5 -- 64
				_with_1.showDebug = true -- 65
				sprite = _with_1 -- 63
			end -- 63
			_with_0:addChild(sprite) -- 66
			return _with_0 -- 61
		end -- 60
	end) -- 66
end) -- 66
