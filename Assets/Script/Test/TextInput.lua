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
		updateIMEPos = function(next) -- 51
			return _with_0:convertToWindowSpace(Vec2(-label.x + label.width, 0), function(pos) -- 52
				Keyboard:updateIMEPosHint(pos) -- 53
				if next then -- 54
					return next() -- 54
				end -- 54
			end) -- 52
		end -- 51
		local startEditing -- 55
		startEditing = function() -- 55
			return updateIMEPos(function() -- 56
				_with_0:detachIME() -- 57
				return _with_0:attachIME() -- 58
			end) -- 56
		end -- 55
		_with_0.updateDisplayText = function(_self, text) -- 59
			textDisplay = text -- 60
			label.text = text -- 61
		end -- 59
		_with_0:onAttachIME(function() -- 63
			_with_0.keyboardEnabled = true -- 64
			return updateText(textDisplay) -- 65
		end) -- 63
		_with_0:onDetachIME(function() -- 67
			_with_0.keyboardEnabled = false -- 68
			cursor.visible = false -- 69
			cursor:unschedule() -- 70
			textEditing = "" -- 71
			label.x = 0 -- 72
			if textDisplay == "" then -- 73
				label.text = _with_0.hint -- 73
			end -- 73
		end) -- 67
		_with_0:onTapped(function(touch) -- 75
			if touch.first then -- 75
				return startEditing() -- 75
			end -- 75
		end) -- 75
		_with_0:onKeyPressed(function(key) -- 77
			if App.platform == "Android" and utf8.len(textEditing) == 1 then -- 78
				if key == "BackSpace" then -- 79
					textEditing = "" -- 79
				end -- 79
			else -- 81
				if textEditing ~= "" then -- 81
					return -- 81
				end -- 81
			end -- 78
			if "BackSpace" == key then -- 83
				if #textDisplay > 0 then -- 84
					textDisplay = utf8.sub(textDisplay, 1, -2) -- 85
					return updateText(textDisplay) -- 86
				end -- 84
			elseif "Return" == key then -- 87
				return _with_0:detachIME() -- 88
			end -- 88
		end) -- 77
		_with_0:onTextInput(function(text) -- 90
			textDisplay = utf8.sub(textDisplay, 1, -1 - utf8.len(textEditing)) .. text -- 91
			textEditing = "" -- 92
			updateText(textDisplay) -- 93
			return updateIMEPos() -- 94
		end) -- 90
		_with_0:onTextEditing(function(text, start) -- 96
			textDisplay = utf8.sub(textDisplay, 1, -1 - utf8.len(textEditing)) .. text -- 97
			textEditing = text -- 98
			label.text = textDisplay -- 99
			local offsetX = math.max(label.width + 3 - width, 0) -- 100
			label.x = -offsetX -- 101
			local charSprite = label:getCharacter(utf8.len(textDisplay) - utf8.len(textEditing) + start) -- 102
			if charSprite then -- 103
				cursor.x = charSprite.x + charSprite.width / 2 - offsetX + 1 -- 104
				cursor:schedule(blink()) -- 105
			else -- 107
				updateText(textDisplay) -- 107
			end -- 103
			return updateIMEPos() -- 108
		end) -- 96
		node = _with_0 -- 41
	end -- 41
	local _with_0 = Node() -- 110
	_with_0.content = node -- 111
	_with_0.cursor = cursor -- 112
	_with_0.label = label -- 113
	_with_0.size = Size(width, height) -- 114
	_with_0:addChild(node) -- 115
	return _with_0 -- 110
end), { -- 117
	text = property((function(self) -- 117
		return self.label.text -- 117
	end), function(self, value) -- 118
		self.content:detachIME() -- 119
		return self.content:updateDisplayText(value) -- 120
	end) -- 117
}) -- 7
local _with_0 = TextInput({ -- 124
	hint = "点这里进行输入", -- 124
	width = 300, -- 125
	height = 60, -- 126
	fontName = "sarasa-mono-sc-regular", -- 127
	fontSize = 40 -- 128
}) -- 123
local themeColor = App.themeColor:toARGB() -- 130
_with_0.label.color = Color(0xffff0080) -- 133
_with_0:addChild(LineRect({ -- 135
	x = -2, -- 135
	width = _with_0.width + 4, -- 136
	height = _with_0.height, -- 137
	color = themeColor -- 138
})) -- 134
return _with_0 -- 123
