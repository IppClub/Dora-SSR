-- [yue]: Script/Lib/UI/Control/Basic/FixedLabel.yue
local Class = Dora.Class -- 1
local Node = Dora.Node -- 1
local Color = Dora.Color -- 1
local Vec2 = Dora.Vec2 -- 1
local Size = Dora.Size -- 1
local Label = Dora.Label -- 1
local property = Dora.property -- 1
local utf8 = require("utf-8") -- 10
return Class(Node, { -- 13
	__init = function(self, args) -- 13
		local x, y, width, height, text, fontName, fontSize, textAlign, color3, renderOrder = args.x, args.y, args.width, args.height, args.text, args.fontName, args.fontSize, args.textAlign, args.color3, args.renderOrder -- 14
		if x == nil then -- 15
			x = 0 -- 15
		end -- 15
		if y == nil then -- 16
			y = 0 -- 16
		end -- 16
		if width == nil then -- 17
			width = 0 -- 17
		end -- 17
		if height == nil then -- 18
			height = 0 -- 18
		end -- 18
		if text == nil then -- 19
			text = "" -- 19
		end -- 19
		if fontName == nil then -- 20
			fontName = "sarasa-mono-sc-regular" -- 20
		end -- 20
		if fontSize == nil then -- 21
			fontSize = 25 -- 21
		end -- 21
		if textAlign == nil then -- 22
			textAlign = "Left" -- 22
		end -- 22
		if color3 == nil then -- 23
			color3 = Color(0xffffff) -- 23
		end -- 23
		if renderOrder == nil then -- 24
			renderOrder = 0 -- 24
		end -- 24
		self.position = Vec2(x, y) -- 26
		self.size = Size(width, height) -- 27
		local label -- 28
		do -- 28
			local _with_0 = Label(fontName, fontSize) -- 28
			_with_0.batched = false -- 29
			_with_0.alignment = textAlign -- 30
			_with_0.renderOrder = renderOrder -- 31
			_with_0.textWidth = width + 5 -- 32
			if "Center" == textAlign then -- 34
				_with_0.position = Vec2(0.5, 0.5) * self.size -- 35
			elseif "Left" == textAlign then -- 36
				_with_0.y = height / 2 -- 37
				_with_0.anchor = Vec2(0, 0.5) -- 38
			elseif "Right" == textAlign then -- 39
				_with_0.x = width -- 40
				_with_0.y = height / 2 -- 41
				_with_0.anchor = Vec2(1, 0.5) -- 42
			end -- 42
			label = _with_0 -- 28
		end -- 28
		self:addChild(label) -- 43
		self._label = label -- 44
		self.text = text -- 45
	end, -- 13
	text = property((function(self) -- 47
		return self._text -- 47
	end), function(self, value) -- 48
		self._text = value -- 49
		self._label.text = value -- 50
		local width, height = self.width, self.height -- 51
		local charCount = self._label.characterCount -- 52
		if charCount > 0 then -- 53
			local char = self._label:getCharacter(1) -- 54
			if not char then -- 55
				return -- 55
			end -- 55
			local left = char.x - char.width / 2 -- 56
			local top = char.y + char.height / 2 -- 57
			for i = 2, charCount do -- 58
				char = self._label:getCharacter(i) -- 59
				if not (char and char.visible) then -- 60
					goto _continue_0 -- 60
				end -- 60
				local right = char.x + char.width / 2 -- 61
				local bottom = char.y - char.height / 2 -- 62
				if (right - left) > width or (top - bottom) > height then -- 63
					local displayText = utf8.sub(value, 1, i - 4) -- 64
					displayText = displayText .. "..." -- 65
					self._label.text = displayText -- 66
					break -- 67
				end -- 63
				::_continue_0:: -- 59
			end -- 67
		end -- 53
	end) -- 47
}) -- 67
