-- [yue]: Script/Lib/UI/Control/Basic/Ruler.yue
local Class = Dora.Class -- 1
local View = Dora.View -- 1
local math = _G.math -- 1
local Label = Dora.Label -- 1
local string = _G.string -- 1
local Vec2 = Dora.Vec2 -- 1
local tostring = _G.tostring -- 1
local table = _G.table -- 1
local tonumber = _G.tonumber -- 1
local Color = Dora.Color -- 1
local ScaleX = Dora.ScaleX -- 1
local Ease = Dora.Ease -- 1
local once = Dora.once -- 1
local cycle = Dora.cycle -- 1
local App = Dora.App -- 1
local Node = Dora.Node -- 1
local Size = Dora.Size -- 1
local pairs = _G.pairs -- 1
local property = Dora.property -- 1
local Spawn = Dora.Spawn -- 1
local Y = Dora.Y -- 1
local Opacity = Dora.Opacity -- 1
local Sequence = Dora.Sequence -- 1
local Hide = Dora.Hide -- 1
local _module_0 = nil -- 1
local Ruler = require("UI.View.Control.Basic.Ruler") -- 10
local Round = require("Utils").Round -- 11
_module_0 = Class(Ruler, { -- 14
	__init = function(self, args) -- 14
		local y, width, height, fontName, fontSize, fixed = args.y, args.width, args.height, args.fontName, args.fontSize, args.fixed -- 15
		if y == nil then -- 16
			y = 0 -- 16
		end -- 16
		if fontName == nil then -- 19
			fontName = "sarasa-mono-sc-regular" -- 19
		end -- 19
		if fontSize == nil then -- 20
			fontSize = 30 -- 20
		end -- 20
		if fixed == nil then -- 21
			fixed = false -- 21
		end -- 21
		local viewSize = View.size -- 23
		local halfW = width / 2 -- 24
		local halfH = height / 2 -- 25
		local interval = 10 -- 26
		local indent = 100 -- 27
		if fontSize == nil then -- 28
			fontSize = 12 -- 28
		end -- 28
		fontSize = math.floor(fontSize) -- 29
		local vsCache = { } -- 30
		self.endPosY = y -- 31
		if fixed ~= nil then -- 32
			self.isFixed = fixed -- 32
		else -- 32
			self.isFixed = true -- 32
		end -- 32
		local labels = { } -- 34
		local labelList = { } -- 35
		local len = nil -- 36
		do -- 37
			local posX = self.intervalNode.anchor.x * width -- 38
			local center = Round(posX / 100) -- 39
			len = Round((posX + halfW) / 100 - center) -- 40
			len = 1 + math.max((center - Round((posX - halfW) / 100)), len) -- 41
			for i = center - len, center + len do -- 42
				local pos = i * 100 -- 43
				local label -- 44
				do -- 44
					local _with_0 = Label(fontName, fontSize) -- 44
					_with_0.text = string.format("%.0f", pos / 100 * indent) -- 45
					_with_0.scaleX = 1 / self.intervalNode.scaleX -- 46
					_with_0.position = Vec2(pos, halfH - 18 - fontSize) -- 47
					_with_0.tag = tostring(pos) -- 48
					label = _with_0 -- 44
				end -- 44
				self.intervalNode:addChild(label) -- 49
				labels[pos] = label -- 50
				table.insert(labelList, label) -- 51
			end -- 42
		end -- 37
		local moveLabel -- 53
		moveLabel = function(label, pos) -- 53
			labels[tonumber(label.tag)] = nil -- 54
			label.text = string.format("%.0f", pos / 100 * indent) -- 56
			label.scaleX = 1 / self.intervalNode.scaleX -- 57
			label.position = Vec2(pos, halfH - 18 - fontSize) -- 58
			label.tag = tostring(pos) -- 59
			labels[pos] = label -- 55
		end -- 53
		local updateLabels -- 61
		updateLabels = function() -- 61
			local posX = self.intervalNode.anchor.x * width -- 62
			local center = math.floor(posX / 100) -- 63
			local right = center + len -- 64
			local left = center - len -- 65
			local insertPos = 1 -- 66
			for i = left, right do -- 67
				local pos = i * 100 -- 68
				if labels[pos] then -- 69
					break -- 70
				else -- 72
					local label = table.remove(labelList) -- 72
					table.insert(labelList, insertPos, label) -- 73
					insertPos = insertPos + 1 -- 74
					moveLabel(label, pos) -- 75
				end -- 69
			end -- 67
			insertPos = #labelList -- 76
			for i = right, left, -1 do -- 77
				local pos = i * 100 -- 78
				if labels[pos] then -- 79
					break -- 80
				else -- 82
					local label = table.remove(labelList, 1) -- 82
					table.insert(labelList, insertPos, label) -- 83
					insertPos = insertPos - 1 -- 84
					moveLabel(label, pos) -- 85
				end -- 79
			end -- 77
			local scale = self.intervalNode.scaleX -- 87
			local current = Round(self.intervalNode.anchor.x * width / interval) -- 88
			local delta = 1 + math.ceil(halfW / scale / interval) -- 89
			local max = current + delta -- 90
			local min = current - delta -- 91
			local count = 1 -- 92
			local vs = { } -- 93
			for i = min, max do -- 94
				posX = i * interval -- 95
				local v = vsCache[count] -- 96
				if v then -- 97
					v = Vec2(posX, halfH) -- 97
				else -- 99
					v = Vec2(posX, halfH) -- 99
					vsCache[count] = v -- 100
				end -- 97
				vs[count] = v -- 101
				count = count + 1 -- 102
				v = vsCache[count] -- 103
				if v then -- 104
					v = Vec2(posX, halfH - (i % 10 == 0 and fontSize + 6 or fontSize - 2)) -- 104
				else -- 106
					v = Vec2(posX, halfH - (i % 10 == 0 and fontSize + 6 or fontSize - 2)) -- 106
					vsCache[count] = v -- 107
				end -- 104
				vs[count] = v -- 108
				count = count + 1 -- 109
				v = vsCache[count] -- 110
				if v then -- 111
					v = Vec2(posX, halfH) -- 111
				else -- 113
					v = Vec2(posX, halfH) -- 113
					vsCache[count] = v -- 114
				end -- 111
				vs[count] = v -- 115
				count = count + 1 -- 116
			end -- 94
			return self.intervalNode:set(vs, Color(0xffffffff)) -- 117
		end -- 61
		local updateIntervalTextScale -- 119
		updateIntervalTextScale = function(scale) -- 119
			return self.intervalNode:eachChild(function(child) -- 120
				child.scaleX = scale -- 121
			end) -- 120
		end -- 119
		self.makeScale = function(self, scale) -- 123
			scale = math.min(scale, 5) -- 124
			self.intervalNode.scaleX = scale -- 125
			updateIntervalTextScale(1 / scale) -- 127
			return updateLabels() -- 128
		end -- 123
		self.makeScaleTo = function(self, scale) -- 130
			do -- 131
				local _with_0 = self.intervalNode -- 131
				_with_0:perform(ScaleX(0.5, self.intervalNode.scaleX, scale, Ease.OutQuad)) -- 132
				_with_0:schedule(once(function() -- 134
					return cycle(0.5, function() -- 134
						return updateIntervalTextScale(1 / _with_0.scaleX) -- 134
					end) -- 134
				end)) -- 134
			end -- 131
			return updateLabels() -- 135
		end -- 130
		local _value = 0 -- 137
		local _max = 0 -- 138
		local _min = 0 -- 139
		do -- 141
			local _exp_0 = App.platform -- 141
			if "macOS" == _exp_0 or "Windows" == _exp_0 or "Linux" == _exp_0 then -- 142
				self:addChild((function() -- 143
					local _with_0 = Node() -- 143
					_with_0.size = Size(width, height) -- 144
					_with_0.touchEnabled = true -- 145
					_with_0.swallowMouseWheel = true -- 146
					_with_0:slot("MouseWheel", function(delta) -- 147
						local newVal = self:getValue() + delta.y * indent / 10 -- 148
						return self:setValue(_min < _max and math.min(math.max(_min, newVal), _max) or newVal) -- 149
					end) -- 147
					return _with_0 -- 143
				end)()) -- 143
			end -- 141
		end -- 141
		self.setIndent = function(_self, ind) -- 151
			indent = ind -- 152
			for i, label in pairs(labels) do -- 153
				label.text = string.format("%.0f", ind * i / 100) -- 154
			end -- 153
		end -- 151
		self.getIndent = function(_self) -- 155
			return indent -- 155
		end -- 155
		self.lastValue = nil -- 157
		self.setValue = function(self, v) -- 158
			_value = v -- 159
			local val = _min < _max and math.min(math.max(_value, _min), _max) or _value -- 160
			val = self.isFixed and Round(val / (indent / 10)) * math.floor(indent / 10) or val -- 161
			if val == -0 then -- 162
				val = 0 -- 162
			end -- 162
			if self.lastValue ~= val then -- 163
				self.lastValue = val -- 164
				self:emit("Changed", val) -- 165
			end -- 163
			local posX = v * 10 * interval / indent -- 166
			self.intervalNode.anchor = Vec2(posX / width, 0) -- 167
			return updateLabels() -- 168
		end -- 158
		self.getValue = function(_self) -- 170
			return _value -- 170
		end -- 170
		self.getPos = function(_self) -- 171
			return _value * 10 * interval / indent -- 171
		end -- 171
		self.setLimit = function(_self, min, max) -- 173
			_max = max -- 174
			_min = min -- 175
		end -- 173
		local time = 0 -- 177
		local startPos = 0 -- 178
		local updateReset -- 179
		updateReset = function(deltaTime) -- 179
			if _min >= _max then -- 180
				return -- 180
			end -- 180
			local scale = self.intervalNode.scaleX -- 181
			time = time + deltaTime -- 182
			local t = time / 1 -- 183
			if scale < 1 then -- 184
				t = t / 0.1 -- 184
			end -- 184
			t = math.min(1, t) -- 185
			local yVal = nil -- 186
			if startPos < _min then -- 187
				yVal = startPos + (_min - startPos) * Ease:func(scale < 1 and Ease.Linear or Ease.OutElastic, t) -- 188
			elseif startPos > _max then -- 189
				yVal = startPos + (_max - startPos) * Ease:func(scale < 1 and Ease.Linear or Ease.OutElastic, t) -- 190
			end -- 187
			self:setValue(((yVal and yVal or 0) - _value) / scale + _value) -- 191
			if t == 1.0 then -- 192
				return self:unschedule() -- 192
			end -- 192
		end -- 179
		local isReseting -- 194
		isReseting = function() -- 194
			return _min < _max and (_value > _max or _value < _min) -- 195
		end -- 194
		local startReset -- 197
		startReset = function() -- 197
			startPos = _value -- 198
			time = 0 -- 199
			return self:schedule(updateReset) -- 200
		end -- 197
		local _v = 0 -- 202
		local _s = 0 -- 203
		local updateSpeed -- 204
		updateSpeed = function(deltaTime) -- 204
			if _s == 0 then -- 205
				return -- 205
			end -- 205
			_v = _s / deltaTime -- 206
			_s = 0 -- 207
		end -- 204
		local updatePos -- 209
		updatePos = function(deltaTime) -- 209
			local val = viewSize.height * 2 -- 210
			local a = _v > 0 and -val or val -- 211
			local yR = _v > 0 -- 212
			_v = _v + a * deltaTime -- 213
			if (_v < 0) == yR then -- 214
				_v = 0 -- 215
				a = 0 -- 216
			end -- 214
			local ds = _v * deltaTime + a * (0.5 * deltaTime * deltaTime) -- 217
			local newValue = _value - ds * indent / (interval * 10) -- 218
			self:setValue((newValue - _value) / self.intervalNode.scaleY + _value) -- 219
			if _v == 0 or isReseting() then -- 220
				if isReseting() then -- 221
					return startReset() -- 221
				else -- 222
					return self:unschedule() -- 222
				end -- 221
			end -- 220
		end -- 209
		self:slot("TapFilter", function(touch) -- 224
			if not touch.first then -- 225
				touch.enabled = false -- 225
			end -- 225
		end) -- 224
		self:slot("TapBegan", function() -- 227
			_s = 0 -- 228
			_v = 0 -- 229
			return self:schedule(updateSpeed) -- 230
		end) -- 227
		self:slot("TapMoved", function(touch) -- 232
			local deltaX = touch.delta.x -- 233
			local v = _value - deltaX * indent / (interval * 10) -- 234
			local padding = 0.5 * indent -- 235
			if _max > _min then -- 236
				local d = 1 -- 237
				if v > _max then -- 238
					d = (v - _max) * 3 / padding -- 239
				elseif v < _min then -- 240
					d = (_min - v) * 3 / padding -- 241
				end -- 238
				v = _value + (v - _value) / (d < 1 and 1 or d * d) -- 242
			end -- 236
			self:setValue((v - _value) / self.intervalNode.scaleX + _value) -- 243
			_s = _s + deltaX -- 244
		end) -- 232
		return self:slot("TapEnded", function() -- 246
			if isReseting() then -- 247
				return startReset() -- 248
			elseif _v ~= 0 then -- 249
				return self:schedule(updatePos) -- 250
			end -- 247
		end) -- 246
	end, -- 14
	value = property(function(self) -- 252
		return self:getValue() -- 252
	end, function(self, v) -- 253
		return self:setValue(v) -- 253
	end), -- 252
	show = function(self, default, min, max, ind, callback) -- 255
		self:setLimit(min, max) -- 256
		self:setIndent(ind) -- 257
		self:slot("Changed"):set(callback) -- 258
		self.lastValue = nil -- 259
		self:setValue(default) -- 260
		self.visible = true -- 261
		return self:perform(Spawn(Y(0.5, self.endPosY + 30, self.endPosY, Ease.OutBack), Opacity(0.3, self.opacity, 1))) -- 262
	end, -- 255
	hide = function(self) -- 267
		if not self.visible then -- 268
			return -- 268
		end -- 268
		self:slot("Changed", nil) -- 269
		self:unschedule() -- 270
		return self:perform(Sequence(Spawn(Y(0.5, self.y, self.endPosY + 30, Ease.InBack), Opacity(0.5, self.opacity, 0)), Hide())) -- 271
	end -- 267
}) -- 13
return _module_0 -- 1
