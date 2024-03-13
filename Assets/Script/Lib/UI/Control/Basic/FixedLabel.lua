-- [yue]: Script/Lib/UI/Control/Basic/FixedLabel.yue
local Class = dora.Class -- 1
local Node = dora.Node -- 1
local Color = dora.Color -- 1
local Vec2 = dora.Vec2 -- 1
local Size = dora.Size -- 1
local Label = dora.Label -- 1
local property = dora.property -- 1
local utf8 = require("utf-8") -- 2
return Class(Node, { -- 5
	__init = function(self, args) -- 5
		local x, y, width, height, text, fontName, fontSize, textAlign, color3, renderOrder = args.x, args.y, args.width, args.height, args.text, args.fontName, args.fontSize, args.textAlign, args.color3, args.renderOrder -- 6
		if x == nil then -- 7
			x = 0 -- 7
		end -- 7
		if y == nil then -- 8
			y = 0 -- 8
		end -- 8
		if width == nil then -- 9
			width = 0 -- 9
		end -- 9
		if height == nil then -- 10
			height = 0 -- 10
		end -- 10
		if text == nil then -- 11
			text = "" -- 11
		end -- 11
		if fontName == nil then -- 12
			fontName = "sarasa-mono-sc-regular" -- 12
		end -- 12
		if fontSize == nil then -- 13
			fontSize = 25 -- 13
		end -- 13
		if textAlign == nil then -- 14
			textAlign = "Left" -- 14
		end -- 14
		if color3 == nil then -- 15
			color3 = Color(0xffffff) -- 15
		end -- 15
		if renderOrder == nil then -- 16
			renderOrder = 0 -- 16
		end -- 16
		self.position = Vec2(x, y) -- 18
		self.size = Size(width, height) -- 19
		local label -- 20
		do -- 20
			local _with_0 = Label(fontName, fontSize) -- 20
			_with_0.batched = false -- 21
			_with_0.alignment = textAlign -- 22
			_with_0.renderOrder = renderOrder -- 23
			_with_0.textWidth = width + 5 -- 24
			if "Center" == textAlign then -- 26
				_with_0.position = Vec2(0.5, 0.5) * self.size -- 27
			elseif "Left" == textAlign then -- 28
				_with_0.y = height / 2 -- 29
				_with_0.anchor = Vec2(0, 0.5) -- 30
			elseif "Right" == textAlign then -- 31
				_with_0.x = width -- 32
				_with_0.y = height / 2 -- 33
				_with_0.anchor = Vec2(1, 0.5) -- 34
			end -- 34
			label = _with_0 -- 20
		end -- 20
		self:addChild(label) -- 35
		self._label = label -- 36
		self.text = text -- 37
	end, -- 5
	text = property((function(self) -- 39
		return self._text -- 39
	end), function(self, value) -- 40
		self._text = value -- 41
		self._label.text = value -- 42
		local width, height = self.width, self.height -- 43
		local charCount = self._label.characterCount -- 44
		if charCount > 0 then -- 45
			local char = self._label:getCharacter(1) -- 46
			if not char then -- 47
				return -- 47
			end -- 47
			local left = char.x - char.width / 2 -- 48
			local top = char.y + char.height / 2 -- 49
			for i = 2, charCount do -- 50
				char = self._label:getCharacter(i) -- 51
				if not (char and char.visible) then -- 52
					goto _continue_0 -- 52
				end -- 52
				local right = char.x + char.width / 2 -- 53
				local bottom = char.y - char.height / 2 -- 54
				if (right - left) > width or (top - bottom) > height then -- 55
					local displayText = utf8.sub(value, 1, i - 4) -- 56
					displayText = displayText .. "..." -- 57
					self._label.text = displayText -- 58
					break -- 59
				end -- 55
				::_continue_0:: -- 51
			end -- 59
		end -- 45
	end) -- 39
}) -- 59
