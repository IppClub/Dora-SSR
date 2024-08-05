-- [xml]: Script/Example/Dora Xml.xml
local Path = require("Path") -- 3
local selfPath = Path(Path:getScriptPath(...), "Dora Xml.xml") -- 4
return function(args) -- 1
local _ENV = Dora(args) -- 1
local root = Node() -- 6
local rotate = Action(Spawn(Sequence(Move(1,Vec2(0,0),Vec2(200,0),Ease.InSine),Move(2,Vec2(200,0),Vec2(0,200),Ease.OutSine),Move(2,Vec2(0,200),Vec2(0,0),Ease.InSine)),Angle(6,0,360,Ease.OutQuad))) -- 8
local scale = Action(Sequence(Scale(0.2,1,1.3,Ease.OutBack),Scale(0.2,1.3,1,Ease.OutQuad))) -- 16
local sprite1 = Sprite("Image/logo.png") -- 21
sprite1.touchEnabled = true -- 21
root:addChild(sprite1) -- 21
sprite1:slot("TapBegan",function() -- 22
sprite1:perform(scale) -- 22
end) -- 22
root:slot("Enter",function() -- 24
root:perform(rotate) -- 24
end) -- 24
do -- 26
	local _ENV = Dora -- 28
	local xmlCodes = Content:load(selfPath) -- 29
	local luaCodes = xml.tolua(xmlCodes) -- 30
	print("[Xml Codes]\n\n" .. tostring(xmlCodes) .. "\n[Compiled Lua Codes]\n\n" .. tostring(luaCodes)) -- 31
	local windowFlags = { -- 33
		"NoDecoration", -- 33
		"AlwaysAutoResize", -- 33
		"NoSavedSettings", -- 33
		"NoFocusOnAppearing", -- 33
		"NoNav", -- 33
		"NoMove" -- 33
	} -- 33
	root:schedule(function() -- 41
		local width = App.visualSize.width -- 42
		ImGui.SetNextWindowBgAlpha(0.35) -- 43
		ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0)) -- 44
		ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver") -- 45
		return ImGui.Begin("Dora Xml", windowFlags, function() -- 46
			ImGui.Text("Dora Xml (Xml)") -- 47
			ImGui.Separator() -- 48
			return ImGui.TextWrapped("View related codes in log window!") -- 49
		end) -- 49
	end) -- 41
end -- 49
return root -- 27
end