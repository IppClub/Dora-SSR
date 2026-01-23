-- [yue]: Script/Lib/UI/Control/Basic/FixedLabel.yue
local _ENV = Dora -- 9
local utf8 = require("utf-8") -- 10
local Class <const> = Class -- 11
local Node <const> = Node -- 11
local Color <const> = Color -- 11
local Vec2 <const> = Vec2 -- 11
local Size <const> = Size -- 11
local Label <const> = Label -- 11
local property <const> = property -- 11
return Class(Node, { -- 14
	__init = function(self, args) -- 14
		local x, y, width, height, text, fontName, fontSize, textAlign, color3, renderOrder = args.x, args.y, args.width, args.height, args.text, args.fontName, args.fontSize, args.textAlign, args.color3, args.renderOrder -- 15
		if x == nil then -- 16
			x = 0 -- 16
		end -- 16
		if y == nil then -- 17
			y = 0 -- 17
		end -- 17
		if width == nil then -- 18
			width = 0 -- 18
		end -- 18
		if height == nil then -- 19
			height = 0 -- 19
		end -- 19
		if text == nil then -- 20
			text = "" -- 20
		end -- 20
		if fontName == nil then -- 21
			fontName = "sarasa-mono-sc-regular" -- 21
		end -- 21
		if fontSize == nil then -- 22
			fontSize = 25 -- 22
		end -- 22
		if textAlign == nil then -- 23
			textAlign = "Left" -- 23
		end -- 23
		if color3 == nil then -- 24
			color3 = Color(0xffffff) -- 24
		end -- 24
		if renderOrder == nil then -- 25
			renderOrder = 0 -- 25
		end -- 25
		self.position = Vec2(x, y) -- 27
		self.size = Size(width, height) -- 28
		local label -- 29
		do -- 29
			local _with_0 = Label(fontName, fontSize) -- 29
			_with_0.batched = false -- 30
			_with_0.alignment = textAlign -- 31
			_with_0.renderOrder = renderOrder -- 32
			_with_0.textWidth = width + 5 -- 33
			if "Center" == textAlign then -- 35
				_with_0.position = Vec2(0.5, 0.5) * self.size -- 36
			elseif "Left" == textAlign then -- 37
				_with_0.y = height / 2 -- 38
				_with_0.anchor = Vec2(0, 0.5) -- 39
			elseif "Right" == textAlign then -- 40
				_with_0.x = width -- 41
				_with_0.y = height / 2 -- 42
				_with_0.anchor = Vec2(1, 0.5) -- 43
			end -- 34
			label = _with_0 -- 29
		end -- 29
		self:addChild(label) -- 44
		self._label = label -- 45
		self.text = text -- 46
	end, -- 14
	text = property((function(self) -- 48
		return self._text -- 48
	end), function(self, value) -- 49
		self._text = value -- 50
		self._label.text = value -- 51
		local width, height = self.width, self.height -- 52
		local charCount = self._label.characterCount -- 53
		if charCount > 0 then -- 54
			local char = self._label:getCharacter(1) -- 55
			if not char then -- 56
				return -- 56
			end -- 56
			local left = char.x - char.width / 2 -- 57
			local top = char.y + char.height / 2 -- 58
			for i = 2, charCount do -- 59
				char = self._label:getCharacter(i) -- 60
				if not (char and char.visible) then -- 61
					goto _continue_0 -- 61
				end -- 61
				local right = char.x + char.width / 2 -- 62
				local bottom = char.y - char.height / 2 -- 63
				if (right - left) > width or (top - bottom) > height then -- 64
					local displayText = utf8.sub(value, 1, i - 4) -- 65
					displayText = displayText .. "..." -- 66
					self._label.text = displayText -- 67
					break -- 68
				end -- 64
				::_continue_0:: -- 60
			end -- 59
		end -- 54
	end) -- 48
}) -- 13
