-- [yue]: Script/Test/TextInput.yue
local Class = dora.Class -- 1
local Label = dora.Label -- 1
local Vec2 = dora.Vec2 -- 1
local Line = dora.Line -- 1
local Color = dora.Color -- 1
local loop = dora.loop -- 1
local sleep = dora.sleep -- 1
local math = _G.math -- 1
local ClipNode = dora.ClipNode -- 1
local Size = dora.Size -- 1
local Keyboard = dora.Keyboard -- 1
local App = dora.App -- 1
local Node = dora.Node -- 1
local property = dora.property -- 1
local LineRect = require("UI.View.Shape.LineRect") -- 2
local SolidRect = require("UI.View.Shape.SolidRect") -- 3
local utf8 = require("utf-8") -- 4
local TextInput = Class((function(args) -- 6
	local fontName, fontSize, width, height, hint, text = args.fontName, args.fontSize, args.width, args.height, args.hint, args.text -- 7
	if hint == nil then -- 12
		hint = "" -- 12
	end -- 12
	if text == nil then -- 13
		text = hint -- 13
	end -- 13
	local label -- 16
	do -- 16
		local _with_0 = Label(fontName, fontSize) -- 16
		_with_0.batched = false -- 17
		_with_0.text = text -- 18
		_with_0.y = height / 2 - fontSize / 2 -- 19
		_with_0.anchor = Vec2.zero -- 20
		_with_0.alignment = "Left" -- 21
		label = _with_0 -- 16
	end -- 16
	local cursor = Line({ -- 23
		Vec2.zero, -- 23
		Vec2(0, fontSize + 2) -- 23
	}, Color(0xffffffff)) -- 23
	local blink -- 24
	blink = function() -- 24
		return loop(function() -- 24
			cursor.visible = true -- 25
			sleep(0.5) -- 26
			cursor.visible = false -- 27
			return sleep(0.5) -- 28
		end) -- 28
	end -- 24
	cursor.y = label.y -- 30
	cursor.visible = false -- 31
	local updateText -- 33
	updateText = function(text) -- 33
		label.text = text -- 34
		local offsetX = math.max(label.width + 3 - width, 0) -- 35
		label.x = -offsetX -- 36
		cursor.x = label.width - offsetX - 10 -- 37
		return cursor:schedule(blink()) -- 38
	end -- 33
	local node -- 40
	do -- 40
		local _with_0 = ClipNode(SolidRect({ -- 40
			width = width, -- 40
			height = height -- 40
		})) -- 40
		local textEditing = "" -- 41
		local textDisplay = "" -- 42
		_with_0.size = Size(width, height) -- 44
		_with_0.position = Vec2(width, height) / 2 -- 45
		_with_0.hint = hint -- 46
		_with_0:addChild(label) -- 47
		_with_0:addChild(cursor) -- 48
		local updateIMEPos -- 50
		updateIMEPos = function() -- 50
			return _with_0:convertToWindowSpace(Vec2(-label.x + label.width, 0), function(pos) -- 51
				return Keyboard:updateIMEPosHint(pos) -- 52
			end) -- 51
		end -- 50
		local startEditing -- 53
		startEditing = function() -- 53
			if not _with_0.imeAttached then -- 54
				_with_0:attachIME() -- 55
				return updateIMEPos() -- 56
			end -- 54
		end -- 53
		_with_0.updateDisplayText = function(self, text) -- 57
			textDisplay = text -- 58
			label.text = text -- 59
		end -- 57
		_with_0.imeAttached = false -- 61
		_with_0:slot("AttachIME", function() -- 62
			_with_0.imeAttached = true -- 63
			_with_0.keyboardEnabled = true -- 64
			return updateText(textDisplay) -- 65
		end) -- 62
		_with_0:slot("DetachIME", function() -- 67
			_with_0.imeAttached = false -- 68
			_with_0.keyboardEnabled = false -- 69
			cursor.visible = false -- 70
			cursor:unschedule() -- 71
			textEditing = "" -- 72
			label.x = 0 -- 73
			if textDisplay == "" then -- 74
				label.text = _with_0.hint -- 74
			end -- 74
		end) -- 67
		_with_0.touchEnabled = true -- 76
		_with_0:slot("Tapped", function(touch) -- 77
			if touch.first then -- 77
				return startEditing() -- 77
			end -- 77
		end) -- 77
		_with_0:slot("KeyPressed", function(key) -- 79
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
		_with_0:slot("TextInput", function(text) -- 92
			textDisplay = utf8.sub(textDisplay, 1, -1 - utf8.len(textEditing)) .. text -- 93
			textEditing = "" -- 94
			updateText(textDisplay) -- 95
			return updateIMEPos() -- 96
		end) -- 92
		_with_0:slot("TextEditing", function(text, start) -- 98
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
		node = _with_0 -- 40
	end -- 40
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
}) -- 6
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
