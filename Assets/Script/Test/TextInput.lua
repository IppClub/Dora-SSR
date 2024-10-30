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
				_with_0:attachIME() -- 58
				return updateIMEPos() -- 59
			end) -- 56
		end -- 55
		_with_0.updateDisplayText = function(_self, text) -- 60
			textDisplay = text -- 61
			label.text = text -- 62
		end -- 60
		_with_0:onAttachIME(function() -- 64
			_with_0.keyboardEnabled = true -- 65
			return updateText(textDisplay) -- 66
		end) -- 64
		_with_0:onDetachIME(function() -- 68
			_with_0.keyboardEnabled = false -- 69
			cursor.visible = false -- 70
			cursor:unschedule() -- 71
			textEditing = "" -- 72
			label.x = 0 -- 73
			if textDisplay == "" then -- 74
				label.text = _with_0.hint -- 74
			end -- 74
		end) -- 68
		_with_0:onTapped(function(touch) -- 76
			if touch.first then -- 76
				return startEditing() -- 76
			end -- 76
		end) -- 76
		_with_0:onKeyPressed(function(key) -- 78
			if App.platform == "Android" and utf8.len(textEditing) == 1 then -- 79
				if key == "BackSpace" then -- 80
					textEditing = "" -- 80
				end -- 80
			else -- 82
				if textEditing ~= "" then -- 82
					return -- 82
				end -- 82
			end -- 79
			if "BackSpace" == key then -- 84
				if #textDisplay > 0 then -- 85
					textDisplay = utf8.sub(textDisplay, 1, -2) -- 86
					return updateText(textDisplay) -- 87
				end -- 85
			elseif "Return" == key then -- 88
				return _with_0:detachIME() -- 89
			end -- 89
		end) -- 78
		_with_0:onTextInput(function(text) -- 91
			textDisplay = utf8.sub(textDisplay, 1, -1 - utf8.len(textEditing)) .. text -- 92
			textEditing = "" -- 93
			updateText(textDisplay) -- 94
			return updateIMEPos() -- 95
		end) -- 91
		_with_0:onTextEditing(function(text, start) -- 97
			textDisplay = utf8.sub(textDisplay, 1, -1 - utf8.len(textEditing)) .. text -- 98
			textEditing = text -- 99
			label.text = textDisplay -- 100
			local offsetX = math.max(label.width + 3 - width, 0) -- 101
			label.x = -offsetX -- 102
			local charSprite = label:getCharacter(utf8.len(textDisplay) - utf8.len(textEditing) + start) -- 103
			if charSprite then -- 104
				cursor.x = charSprite.x + charSprite.width / 2 - offsetX + 1 -- 105
				cursor:schedule(blink()) -- 106
			else -- 108
				updateText(textDisplay) -- 108
			end -- 104
			return updateIMEPos() -- 109
		end) -- 97
		node = _with_0 -- 41
	end -- 41
	local _with_0 = Node() -- 111
	_with_0.content = node -- 112
	_with_0.cursor = cursor -- 113
	_with_0.label = label -- 114
	_with_0.size = Size(width, height) -- 115
	_with_0:addChild(node) -- 116
	return _with_0 -- 111
end), { -- 118
	text = property((function(self) -- 118
		return self.label.text -- 118
	end), function(self, value) -- 119
		self.content:detachIME() -- 120
		return self.content:updateDisplayText(value) -- 121
	end) -- 118
}) -- 7
local _with_0 = TextInput({ -- 125
	hint = "点这里进行输入", -- 125
	width = 300, -- 126
	height = 60, -- 127
	fontName = "sarasa-mono-sc-regular", -- 128
	fontSize = 40 -- 129
}) -- 124
local themeColor = App.themeColor:toARGB() -- 131
_with_0.label.color = Color(0xffff0080) -- 134
_with_0:addChild(LineRect({ -- 136
	x = -2, -- 136
	width = _with_0.width + 4, -- 137
	height = _with_0.height, -- 138
	color = themeColor -- 139
})) -- 135
return _with_0 -- 124
