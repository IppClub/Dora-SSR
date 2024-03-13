-- [yue]: Script/Example/Spine.yue
local Spine = dora.Spine -- 1
local p = _G.p -- 1
local print = _G.print -- 1
local tostring = _G.tostring -- 1
local Label = dora.Label -- 1
local App = dora.App -- 1
local Sequence = dora.Sequence -- 1
local Spawn = dora.Spawn -- 1
local Scale = dora.Scale -- 1
local Ease = dora.Ease -- 1
local Delay = dora.Delay -- 1
local Opacity = dora.Opacity -- 1
local Event = dora.Event -- 1
local Vec2 = dora.Vec2 -- 1
local threadLoop = dora.threadLoop -- 1
local ImGui = dora.ImGui -- 1
local spineStr = "Spine/dragon-ess" -- 3
local animations = Spine:getAnimations(spineStr) -- 5
local looks = Spine:getLooks(spineStr) -- 6
p(animations, looks) -- 8
local spine -- 10
do -- 10
	local _with_0 = Spine(spineStr) -- 10
	_with_0.look = looks[1] -- 11
	_with_0:play(animations[1], true) -- 12
	_with_0:slot("AnimationEnd", function(name) -- 13
		return print(tostring(name) .. " end!") -- 13
	end) -- 13
	_with_0.touchEnabled = true -- 14
	_with_0:slot("TapBegan", function(touch) -- 15
		local x, y -- 16
		do -- 16
			local _obj_0 = touch.location -- 16
			x, y = _obj_0.x, _obj_0.y -- 16
		end -- 16
		do -- 17
			local name = _with_0:containsPoint(x, y) -- 17
			if name then -- 17
				return _with_0:addChild((function() -- 18
					local _with_1 = Label("sarasa-mono-sc-regular", 30) -- 18
					_with_1.text = name -- 19
					_with_1.color = App.themeColor -- 20
					_with_1:perform(Sequence(Spawn(Scale(1, 0, 2, Ease.OutQuad), Sequence(Delay(0.5), Opacity(0.5, 1, 0))), Event("Stop"))) -- 21
					_with_1.position = Vec2(x, y) -- 28
					_with_1:slot("Stop", function() -- 29
						return _with_1:removeFromParent() -- 29
					end) -- 29
					return _with_1 -- 18
				end)()) -- 29
			end -- 17
		end -- 17
	end) -- 15
	spine = _with_0 -- 10
end -- 10
local windowFlags = { -- 34
	"NoDecoration", -- 34
	"AlwaysAutoResize", -- 35
	"NoSavedSettings", -- 36
	"NoFocusOnAppearing", -- 37
	"NoNav", -- 38
	"NoMove" -- 39
} -- 33
local showDebug = spine.showDebug -- 40
return threadLoop(function() -- 41
	local width -- 42
	width = App.visualSize.width -- 42
	ImGui.SetNextWindowBgAlpha(0.35) -- 43
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 44
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 45
	return ImGui.Begin("Spine", windowFlags, function() -- 46
		ImGui.Text("Spine") -- 47
		ImGui.Separator() -- 48
		ImGui.TextWrapped("Basic usage to create spine! Tap it for a hit test.") -- 49
		do -- 50
			local changed -- 50
			changed, showDebug = ImGui.Checkbox("BoundingBox", showDebug) -- 50
			if changed then -- 50
				spine.showDebug = showDebug -- 51
			end -- 50
		end -- 50
	end) -- 51
end) -- 51
