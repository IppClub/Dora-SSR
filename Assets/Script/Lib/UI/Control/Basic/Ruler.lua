-- [yue]: Script/Lib/UI/Control/Basic/Ruler.yue
local _module_0 = nil -- 1
local _ENV = Dora -- 9
local Ruler = require("UI.View.Control.Basic.Ruler") -- 10
local Round = require("Utils").Round -- 11
local Class <const> = Class -- 12
local View <const> = View -- 12
local math <const> = math -- 12
local Label <const> = Label -- 12
local string <const> = string -- 12
local Vec2 <const> = Vec2 -- 12
local tostring <const> = tostring -- 12
local table <const> = table -- 12
local tonumber <const> = tonumber -- 12
local Color <const> = Color -- 12
local ScaleX <const> = ScaleX -- 12
local Ease <const> = Ease -- 12
local once <const> = once -- 12
local cycle <const> = cycle -- 12
local App <const> = App -- 12
local Node <const> = Node -- 12
local Size <const> = Size -- 12
local pairs <const> = pairs -- 12
local property <const> = property -- 12
local Spawn <const> = Spawn -- 12
local Y <const> = Y -- 12
local Opacity <const> = Opacity -- 12
local Sequence <const> = Sequence -- 12
local Hide <const> = Hide -- 12
_module_0 = Class(Ruler, { -- 15
	__init = function(self, args) -- 15
		local y, width, height, fontName, fontSize, fixed = args.y, args.width, args.height, args.fontName, args.fontSize, args.fixed -- 16
		if y == nil then -- 17
			y = 0 -- 17
		end -- 17
		if fontName == nil then -- 20
			fontName = "sarasa-mono-sc-regular" -- 20
		end -- 20
		if fontSize == nil then -- 21
			fontSize = 30 -- 21
		end -- 21
		if fixed == nil then -- 22
			fixed = false -- 22
		end -- 22
		local viewSize = View.size -- 24
		local halfW = width / 2 -- 25
		local halfH = height / 2 -- 26
		local interval = 10 -- 27
		local indent = 100 -- 28
		if fontSize == nil then -- 29
			fontSize = 12 -- 29
		end -- 29
		fontSize = math.floor(fontSize) -- 30
		local vsCache = { } -- 31
		self.endPosY = y -- 32
		if fixed ~= nil then -- 33
			self.isFixed = fixed -- 33
		else -- 33
			self.isFixed = true -- 33
		end -- 33
		local labels = { } -- 35
		local labelList = { } -- 36
		local len = nil -- 37
		do -- 38
			local posX = self.intervalNode.anchor.x * width -- 39
			local center = Round(posX / 100) -- 40
			len = Round((posX + halfW) / 100 - center) -- 41
			len = 1 + math.max((center - Round((posX - halfW) / 100)), len) -- 42
			for i = center - len, center + len do -- 43
				local pos = i * 100 -- 44
				local label -- 45
				do -- 45
					local _with_0 = Label(fontName, fontSize) -- 45
					_with_0.text = string.format("%.0f", pos / 100 * indent) -- 46
					_with_0.scaleX = 1 / self.intervalNode.scaleX -- 47
					_with_0.position = Vec2(pos, halfH - 18 - fontSize) -- 48
					_with_0.tag = tostring(pos) -- 49
					label = _with_0 -- 45
				end -- 45
				self.intervalNode:addChild(label) -- 50
				labels[pos] = label -- 51
				table.insert(labelList, label) -- 52
			end -- 43
		end -- 38
		local moveLabel -- 54
		moveLabel = function(label, pos) -- 54
			labels[tonumber(label.tag)] = nil -- 55
			label.text = string.format("%.0f", pos / 100 * indent) -- 57
			label.scaleX = 1 / self.intervalNode.scaleX -- 58
			label.position = Vec2(pos, halfH - 18 - fontSize) -- 59
			label.tag = tostring(pos) -- 60
			labels[pos] = label -- 56
		end -- 54
		local updateLabels -- 62
		updateLabels = function() -- 62
			local posX = self.intervalNode.anchor.x * width -- 63
			local center = math.floor(posX / 100) -- 64
			local right = center + len -- 65
			local left = center - len -- 66
			local insertPos = 1 -- 67
			for i = left, right do -- 68
				local pos = i * 100 -- 69
				if labels[pos] then -- 70
					break -- 71
				else -- 73
					local label = table.remove(labelList) -- 73
					table.insert(labelList, insertPos, label) -- 74
					insertPos = insertPos + 1 -- 75
					moveLabel(label, pos) -- 76
				end -- 70
			end -- 68
			insertPos = #labelList -- 77
			for i = right, left, -1 do -- 78
				local pos = i * 100 -- 79
				if labels[pos] then -- 80
					break -- 81
				else -- 83
					local label = table.remove(labelList, 1) -- 83
					table.insert(labelList, insertPos, label) -- 84
					insertPos = insertPos - 1 -- 85
					moveLabel(label, pos) -- 86
				end -- 80
			end -- 78
			local scale = self.intervalNode.scaleX -- 88
			local current = Round(self.intervalNode.anchor.x * width / interval) -- 89
			local delta = 1 + math.ceil(halfW / scale / interval) -- 90
			local max = current + delta -- 91
			local min = current - delta -- 92
			local count = 1 -- 93
			local vs = { } -- 94
			for i = min, max do -- 95
				posX = i * interval -- 96
				local v = vsCache[count] -- 97
				if v then -- 98
					v = Vec2(posX, halfH) -- 98
				else -- 100
					v = Vec2(posX, halfH) -- 100
					vsCache[count] = v -- 101
				end -- 98
				vs[count] = v -- 102
				count = count + 1 -- 103
				v = vsCache[count] -- 104
				if v then -- 105
					v = Vec2(posX, halfH - (i % 10 == 0 and fontSize + 6 or fontSize - 2)) -- 105
				else -- 107
					v = Vec2(posX, halfH - (i % 10 == 0 and fontSize + 6 or fontSize - 2)) -- 107
					vsCache[count] = v -- 108
				end -- 105
				vs[count] = v -- 109
				count = count + 1 -- 110
				v = vsCache[count] -- 111
				if v then -- 112
					v = Vec2(posX, halfH) -- 112
				else -- 114
					v = Vec2(posX, halfH) -- 114
					vsCache[count] = v -- 115
				end -- 112
				vs[count] = v -- 116
				count = count + 1 -- 117
			end -- 95
			return self.intervalNode:set(vs, Color(0xffffffff)) -- 118
		end -- 62
		local updateIntervalTextScale -- 120
		updateIntervalTextScale = function(scale) -- 120
			return self.intervalNode:eachChild(function(child) -- 121
				child.scaleX = scale -- 122
			end) -- 121
		end -- 120
		self.makeScale = function(self, scale) -- 124
			scale = math.min(scale, 5) -- 125
			self.intervalNode.scaleX = scale -- 126
			updateIntervalTextScale(1 / scale) -- 128
			return updateLabels() -- 129
		end -- 124
		self.makeScaleTo = function(self, scale) -- 131
			do -- 132
				local _with_0 = self.intervalNode -- 132
				_with_0:perform(ScaleX(0.5, self.intervalNode.scaleX, scale, Ease.OutQuad)) -- 133
				_with_0:schedule(once(function() -- 135
					return cycle(0.5, function() -- 135
						return updateIntervalTextScale(1 / _with_0.scaleX) -- 135
					end) -- 135
				end)) -- 135
			end -- 132
			return updateLabels() -- 136
		end -- 131
		local _value = 0 -- 138
		local _max = 0 -- 139
		local _min = 0 -- 140
		do -- 142
			local _exp_0 = App.platform -- 142
			if "macOS" == _exp_0 or "Windows" == _exp_0 or "Linux" == _exp_0 then -- 143
				self:addChild((function() -- 144
					local _with_0 = Node() -- 144
					_with_0.size = Size(width, height) -- 145
					_with_0.touchEnabled = true -- 146
					_with_0.swallowMouseWheel = true -- 147
					_with_0:slot("MouseWheel", function(delta) -- 148
						local newVal = self:getValue() + delta.y * indent / 10 -- 149
						return self:setValue(_min < _max and math.min(math.max(_min, newVal), _max) or newVal) -- 150
					end) -- 148
					return _with_0 -- 144
				end)()) -- 144
			end -- 142
		end -- 142
		self.setIndent = function(_self, ind) -- 152
			indent = ind -- 153
			for i, label in pairs(labels) do -- 154
				label.text = string.format("%.0f", ind * i / 100) -- 155
			end -- 154
		end -- 152
		self.getIndent = function(_self) -- 156
			return indent -- 156
		end -- 156
		self.lastValue = nil -- 158
		self.setValue = function(self, v) -- 159
			_value = v -- 160
			local val = _min < _max and math.min(math.max(_value, _min), _max) or _value -- 161
			val = self.isFixed and Round(val / (indent / 10)) * math.floor(indent / 10) or val -- 162
			if val == -0 then -- 163
				val = 0 -- 163
			end -- 163
			if self.lastValue ~= val then -- 164
				self.lastValue = val -- 165
				self:emit("Changed", val) -- 166
			end -- 164
			local posX = v * 10 * interval / indent -- 167
			self.intervalNode.anchor = Vec2(posX / width, 0) -- 168
			return updateLabels() -- 169
		end -- 159
		self.getValue = function(_self) -- 171
			return _value -- 171
		end -- 171
		self.getPos = function(_self) -- 172
			return _value * 10 * interval / indent -- 172
		end -- 172
		self.setLimit = function(_self, min, max) -- 174
			_max = max -- 175
			_min = min -- 176
		end -- 174
		local time = 0 -- 178
		local startPos = 0 -- 179
		local updateReset -- 180
		updateReset = function(deltaTime) -- 180
			if _min >= _max then -- 181
				return -- 181
			end -- 181
			local scale = self.intervalNode.scaleX -- 182
			time = time + deltaTime -- 183
			local t = time / 1 -- 184
			if scale < 1 then -- 185
				t = t / 0.1 -- 185
			end -- 185
			t = math.min(1, t) -- 186
			local yVal = nil -- 187
			if startPos < _min then -- 188
				yVal = startPos + (_min - startPos) * Ease:func(scale < 1 and Ease.Linear or Ease.OutElastic, t) -- 189
			elseif startPos > _max then -- 190
				yVal = startPos + (_max - startPos) * Ease:func(scale < 1 and Ease.Linear or Ease.OutElastic, t) -- 191
			end -- 188
			self:setValue(((yVal and yVal or 0) - _value) / scale + _value) -- 192
			if t == 1.0 then -- 193
				return self:unschedule() -- 193
			end -- 193
		end -- 180
		local isReseting -- 195
		isReseting = function() -- 195
			return _min < _max and (_value > _max or _value < _min) -- 196
		end -- 195
		local startReset -- 198
		startReset = function() -- 198
			startPos = _value -- 199
			time = 0 -- 200
			return self:schedule(updateReset) -- 201
		end -- 198
		local _v = 0 -- 203
		local _s = 0 -- 204
		local updateSpeed -- 205
		updateSpeed = function(deltaTime) -- 205
			if _s == 0 then -- 206
				return -- 206
			end -- 206
			_v = _s / deltaTime -- 207
			_s = 0 -- 208
		end -- 205
		local updatePos -- 210
		updatePos = function(deltaTime) -- 210
			local val = viewSize.height * 2 -- 211
			local a = _v > 0 and -val or val -- 212
			local yR = _v > 0 -- 213
			_v = _v + a * deltaTime -- 214
			if (_v < 0) == yR then -- 215
				_v = 0 -- 216
				a = 0 -- 217
			end -- 215
			local ds = _v * deltaTime + a * (0.5 * deltaTime * deltaTime) -- 218
			local newValue = _value - ds * indent / (interval * 10) -- 219
			self:setValue((newValue - _value) / self.intervalNode.scaleY + _value) -- 220
			if _v == 0 or isReseting() then -- 221
				if isReseting() then -- 222
					return startReset() -- 222
				else -- 223
					return self:unschedule() -- 223
				end -- 222
			end -- 221
		end -- 210
		self:slot("TapFilter", function(touch) -- 225
			if not touch.first then -- 226
				touch.enabled = false -- 226
			end -- 226
		end) -- 225
		self:slot("TapBegan", function() -- 228
			_s = 0 -- 229
			_v = 0 -- 230
			return self:schedule(updateSpeed) -- 231
		end) -- 228
		self:slot("TapMoved", function(touch) -- 233
			local deltaX = touch.delta.x -- 234
			local v = _value - deltaX * indent / (interval * 10) -- 235
			local padding = 0.5 * indent -- 236
			if _max > _min then -- 237
				local d = 1 -- 238
				if v > _max then -- 239
					d = (v - _max) * 3 / padding -- 240
				elseif v < _min then -- 241
					d = (_min - v) * 3 / padding -- 242
				end -- 239
				v = _value + (v - _value) / (d < 1 and 1 or d * d) -- 243
			end -- 237
			self:setValue((v - _value) / self.intervalNode.scaleX + _value) -- 244
			_s = _s + deltaX -- 245
		end) -- 233
		return self:slot("TapEnded", function() -- 247
			if isReseting() then -- 248
				return startReset() -- 249
			elseif _v ~= 0 then -- 250
				return self:schedule(updatePos) -- 251
			end -- 248
		end) -- 247
	end, -- 15
	value = property(function(self) -- 253
		return self:getValue() -- 253
	end, function(self, v) -- 254
		return self:setValue(v) -- 254
	end), -- 253
	show = function(self, default, min, max, ind, callback) -- 256
		self:setLimit(min, max) -- 257
		self:setIndent(ind) -- 258
		self:slot("Changed"):set(callback) -- 259
		self.lastValue = nil -- 260
		self:setValue(default) -- 261
		self.visible = true -- 262
		return self:perform(Spawn(Y(0.5, self.endPosY + 30, self.endPosY, Ease.OutBack), Opacity(0.3, self.opacity, 1))) -- 263
	end, -- 256
	hide = function(self) -- 268
		if not self.visible then -- 269
			return -- 269
		end -- 269
		self:slot("Changed", nil) -- 270
		self:unschedule() -- 271
		return self:perform(Sequence(Spawn(Y(0.5, self.y, self.endPosY + 30, Ease.InBack), Opacity(0.5, self.opacity, 0)), Hide())) -- 272
	end -- 268
}) -- 14
return _module_0 -- 1
