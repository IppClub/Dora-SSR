-- [yue]: Script/Test/TextInput.yue
local Class = Dora.Class -- 1
local Label = Dora.Label -- 1
local Vec2 = Dora.Vec2 -- 1
local Line = Dora.Line -- 1
local Color = Dora.Color -- 1
local loop = Dora.loop -- 1
local sleep = Dora.sleep -- 1
local math = _G.math -- 1
local ClipNode = Dora.ClipNode -- 1
local Size = Dora.Size -- 1
local Keyboard = Dora.Keyboard -- 1
local App = Dora.App -- 1
local Node = Dora.Node -- 1
local property = Dora.property -- 1
local LineRect = require("UI.View.Shape.LineRect") -- 3
local SolidRect = require("UI.View.Shape.SolidRect") -- 4
local utf8 = require("utf-8") -- 5
local TextInput = Class((function(args) -- 7
	local fontName, fontSize, width, height, hint, text = args.fontName, args.fontSize, args.width, args.height, args.hint, args.text -- 8
	if hint == nil then -- 13
		hint = "" -- 13
	end -- 13
	if text == nil then -- 14
		text = hint -- 14
	end -- 14
	local label -- 17
	do -- 17
		local _with_0 = Label(fontName, fontSize) -- 17
		_with_0.batched = false -- 18
		_with_0.text = text -- 19
		_with_0.y = height / 2 - fontSize / 2 -- 20
		_with_0.anchor = Vec2.zero -- 21
		_with_0.alignment = "Left" -- 22
		label = _with_0 -- 17
	end -- 17
	local cursor = Line({ -- 24
		Vec2.zero, -- 24
		Vec2(0, fontSize + 2) -- 24
	}, Color(0xffffffff)) -- 24
	local blink -- 25
	blink = function() -- 25
		return loop(function() -- 25
			cursor.visible = true -- 26
			sleep(0.5) -- 27
			cursor.visible = false -- 28
			return sleep(0.5) -- 29
		end) -- 29
	end -- 25
	cursor.y = label.y -- 31
	cursor.visible = false -- 32
	local updateText -- 34
	updateText = function(text) -- 34
		label.text = text -- 35
		local offsetX = math.max(label.width + 3 - width, 0) -- 36
		label.x = -offsetX -- 37
		cursor.x = label.width - offsetX - 10 -- 38
		return cursor:schedule(blink()) -- 39
	end -- 34
	local node -- 41
	do -- 41
		local _with_0 = ClipNode(SolidRect({ -- 41
			width = width, -- 41
			height = height -- 41
		})) -- 41
		local textEditing = "" -- 42
		local textDisplay = "" -- 43
		_with_0.size = Size(width, height) -- 45
		_with_0.position = Vec2(width, height) / 2 -- 46
		_with_0.hint = hint -- 47
		_with_0:addChild(label) -- 48
		_with_0:addChild(cursor) -- 49
		local updateIMEPos -- 51
		updateIMEPos = function() -- 51
			return _with_0:convertToWindowSpace(Vec2(-label.x + label.width, 0), function(pos) -- 52
				return Keyboard:updateIMEPosHint(pos) -- 53
			end) -- 52
		end -- 51
		local startEditing -- 54
		startEditing = function() -- 54
			if not _with_0.imeAttached then -- 55
				_with_0:attachIME() -- 56
				return updateIMEPos() -- 57
			end -- 55
		end -- 54
		_with_0.updateDisplayText = function(_self, text) -- 58
			textDisplay = text -- 59
			label.text = text -- 60
		end -- 58
		_with_0.imeAttached = false -- 62
		_with_0:onAttachIME(function() -- 63
			_with_0.imeAttached = true -- 64
			_with_0.keyboardEnabled = true -- 65
			return updateText(textDisplay) -- 66
		end) -- 63
		_with_0:onDetachIME(function() -- 68
			_with_0.imeAttached = false -- 69
			_with_0.keyboardEnabled = false -- 70
			cursor.visible = false -- 71
			cursor:unschedule() -- 72
			textEditing = "" -- 73
			label.x = 0 -- 74
			if textDisplay == "" then -- 75
				label.text = _with_0.hint -- 75
			end -- 75
		end) -- 68
		_with_0:onTapped(function(touch) -- 77
			if touch.first then -- 77
				return startEditing() -- 77
			end -- 77
		end) -- 77
		_with_0:onKeyPressed(function(key) -- 79
			if App.platform == "Android" and utf8.len(textEditing) == 1 then -- 80
				if key == "BackSpace" then -- 81
					textEditing = "" -- 81
				end -- 81
			else -- 83
				if textEditing ~= "" then -- 83
					return -- 83
				end -- 83
			end -- 80
			if "BackSpace" == key then -- 85
				if #textDisplay > 0 then -- 86
					textDisplay = utf8.sub(textDisplay, 1, -2) -- 87
					return updateText(textDisplay) -- 88
				end -- 86
			elseif "Return" == key then -- 89
				return _with_0:detachIME() -- 90
			end -- 90
		end) -- 79
		_with_0:onTextInput(function(text) -- 92
			textDisplay = utf8.sub(textDisplay, 1, -1 - utf8.len(textEditing)) .. text -- 93
			textEditing = "" -- 94
			updateText(textDisplay) -- 95
			return updateIMEPos() -- 96
		end) -- 92
		_with_0:onTextEditing(function(text, start) -- 98
			textDisplay = utf8.sub(textDisplay, 1, -1 - utf8.len(textEditing)) .. text -- 99
			textEditing = text -- 100
			label.text = textDisplay -- 101
			local offsetX = math.max(label.width + 3 - width, 0) -- 102
			label.x = -offsetX -- 103
			local charSprite = label:getCharacter(utf8.len(textDisplay) - utf8.len(textEditing) + start) -- 104
			if charSprite then -- 105
				cursor.x = charSprite.x + charSprite.width / 2 - offsetX + 1 -- 106
				cursor:schedule(blink()) -- 107
			else -- 109
				updateText(textDisplay) -- 109
			end -- 105
			return updateIMEPos() -- 110
		end) -- 98
		node = _with_0 -- 41
	end -- 41
	local _with_0 = Node() -- 112
	_with_0.content = node -- 113
	_with_0.cursor = cursor -- 114
	_with_0.label = label -- 115
	_with_0.size = Size(width, height) -- 116
	_with_0:addChild(node) -- 117
	return _with_0 -- 112
end), { -- 119
	text = property((function(self) -- 119
		return self.label.text -- 119
	end), function(self, value) -- 120
		if self.content.imeAttached then -- 121
			self.content:detachIME() -- 121
		end -- 121
		return self.content:updateDisplayText(value) -- 122
	end) -- 119
}) -- 7
local _with_0 = TextInput({ -- 126
	hint = "点这里进行输入", -- 126
	width = 300, -- 127
	height = 60, -- 128
	fontName = "sarasa-mono-sc-regular", -- 129
	fontSize = 40 -- 130
}) -- 125
local themeColor = App.themeColor:toARGB() -- 132
_with_0.label.color = Color(0xffff0080) -- 135
_with_0:addChild(LineRect({ -- 137
	x = -2, -- 137
	width = _with_0.width + 4, -- 138
	height = _with_0.height, -- 139
	color = themeColor -- 140
})) -- 136
return _with_0 -- 125
