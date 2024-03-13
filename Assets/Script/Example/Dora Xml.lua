-- [xml]: Script/Example/Dora Xml.xml
return function(args) -- 1
local _ENV = Dora(args) -- 1
local root = Node() -- 1
local rotate = Action(Spawn(Sequence(Move(1,Vec2(0,0),Vec2(200,0),Ease.InSine),Move(2,Vec2(200,0),Vec2(0,200),Ease.OutSine),Move(2,Vec2(0,200),Vec2(0,0),Ease.InSine)),Angle(6,0,360,Ease.OutQuad))) -- 3
local scale = Action(Sequence(Scale(0.2,1,1.3,Ease.OutBack),Scale(0.2,1.3,1,Ease.OutQuad))) -- 11
local sprite1 = Sprite("Image/logo.png") -- 16
sprite1.touchEnabled = true -- 16
root:addChild(sprite1) -- 16
sprite1:slot("TapBegan",function() -- 17
sprite1:perform(scale) -- 17
end) -- 17
root:slot("Enter",function() -- 19
root:perform(rotate) -- 19
end) -- 19
do -- 21
	local _ENV = Dora() -- 23
	local xmlCodes = Content:load("Example/Dora Xml.xml") -- 24
	local luaCodes = xml.tolua(xmlCodes) -- 25
	print("[Xml Codes]\n\n" .. tostring(xmlCodes) .. "\n[Compiled Lua Codes]\n\n" .. tostring(luaCodes)) -- 26
	local windowFlags = { -- 28
		"NoDecoration", -- 28
		"AlwaysAutoResize", -- 29
		"NoSavedSettings", -- 30
		"NoFocusOnAppearing", -- 31
		"NoNav", -- 32
		"NoMove" -- 33
	} -- 27
	root:schedule(function() -- 34
		local width = App.visualSize.width -- 35
		ImGui.SetNextWindowBgAlpha(0.35) -- 36
		ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 37
		ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 38
		return ImGui.Begin("Dora Xml", windowFlags, function() -- 39
			ImGui.Text("Dora Xml") -- 40
			ImGui.Separator() -- 41
			return ImGui.TextWrapped("View related codes in log window!") -- 42
		end) -- 42
	end) -- 34
end -- 42
return root -- 22
end