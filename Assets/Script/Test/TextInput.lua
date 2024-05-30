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
		_with_0:slot("AttachIME", function() -- 63
			_with_0.imeAttached = true -- 64
			_with_0.keyboardEnabled = true -- 65
			return updateText(textDisplay) -- 66
		end) -- 63
		_with_0:slot("DetachIME", function() -- 68
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
		_with_0.touchEnabled = true -- 77
		_with_0:slot("Tapped", function(touch) -- 78
			if touch.first then -- 78
				return startEditing() -- 78
			end -- 78
		end) -- 78
		_with_0:slot("KeyPressed", function(key) -- 80
			if App.platform == "Android" and utf8.len(textEditing) == 1 then -- 81
				if key == "BackSpace" then -- 82
					textEditing = "" -- 82
				end -- 82
			else -- 84
				if textEditing ~= "" then -- 84
					return -- 84
				end -- 84
			end -- 81
			if "BackSpace" == key then -- 86
				if #textDisplay > 0 then -- 87
					textDisplay = utf8.sub(textDisplay, 1, -2) -- 88
					return updateText(textDisplay) -- 89
				end -- 87
			elseif "Return" == key then -- 90
				return _with_0:detachIME() -- 91
			end -- 91
		end) -- 80
		_with_0:slot("TextInput", function(text) -- 93
			textDisplay = utf8.sub(textDisplay, 1, -1 - utf8.len(textEditing)) .. text -- 94
			textEditing = "" -- 95
			updateText(textDisplay) -- 96
			return updateIMEPos() -- 97
		end) -- 93
		_with_0:slot("TextEditing", function(text, start) -- 99
			textDisplay = utf8.sub(textDisplay, 1, -1 - utf8.len(textEditing)) .. text -- 100
			textEditing = text -- 101
			label.text = textDisplay -- 102
			local offsetX = math.max(label.width + 3 - width, 0) -- 103
			label.x = -offsetX -- 104
			local charSprite = label:getCharacter(utf8.len(textDisplay) - utf8.len(textEditing) + start) -- 105
			if charSprite then -- 106
				cursor.x = charSprite.x + charSprite.width / 2 - offsetX + 1 -- 107
				cursor:schedule(blink()) -- 108
			else -- 110
				updateText(textDisplay) -- 110
			end -- 106
			return updateIMEPos() -- 111
		end) -- 99
		node = _with_0 -- 41
	end -- 41
	local _with_0 = Node() -- 113
	_with_0.content = node -- 114
	_with_0.cursor = cursor -- 115
	_with_0.label = label -- 116
	_with_0.size = Size(width, height) -- 117
	_with_0:addChild(node) -- 118
	return _with_0 -- 113
end), { -- 120
	text = property((function(self) -- 120
		return self.label.text -- 120
	end), function(self, value) -- 121
		if self.content.imeAttached then -- 122
			self.content:detachIME() -- 122
		end -- 122
		return self.content:updateDisplayText(value) -- 123
	end) -- 120
}) -- 7
local _with_0 = TextInput({ -- 127
	hint = "点这里进行输入", -- 127
	width = 300, -- 128
	height = 60, -- 129
	fontName = "sarasa-mono-sc-regular", -- 130
	fontSize = 40 -- 131
}) -- 126
local themeColor = App.themeColor:toARGB() -- 133
_with_0.label.color = Color(0xffff0080) -- 136
_with_0:addChild(LineRect({ -- 138
	x = -2, -- 138
	width = _with_0.width + 4, -- 139
	height = _with_0.height, -- 140
	color = themeColor -- 141
})) -- 137
return _with_0 -- 126
