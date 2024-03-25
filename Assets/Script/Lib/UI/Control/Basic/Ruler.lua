-- [yue]: Script/Lib/UI/Control/Basic/Ruler.yue
local Class = dora.Class -- 1
local View = dora.View -- 1
local math = _G.math -- 1
local Label = dora.Label -- 1
local string = _G.string -- 1
local Vec2 = dora.Vec2 -- 1
local tostring = _G.tostring -- 1
local table = _G.table -- 1
local tonumber = _G.tonumber -- 1
local Color = dora.Color -- 1
local ScaleX = dora.ScaleX -- 1
local Ease = dora.Ease -- 1
local once = dora.once -- 1
local cycle = dora.cycle -- 1
local App = dora.App -- 1
local Node = dora.Node -- 1
local Size = dora.Size -- 1
local pairs = _G.pairs -- 1
local Spawn = dora.Spawn -- 1
local Y = dora.Y -- 1
local Opacity = dora.Opacity -- 1
local Sequence = dora.Sequence -- 1
local Hide = dora.Hide -- 1
local _module_0 = nil -- 1
local Ruler = require("UI.View.Control.Basic.Ruler") -- 10
local Round = require("Utils").Round -- 11
_module_0 = Class(Ruler, { -- 14
	__init = function(self, args) -- 14
		local y, width, height, fontName, fontSize, fixed = args.y, args.width, args.height, args.fontName, args.fontSize, args.fixed -- 15
		local viewSize = View.size -- 16
		local halfW = width / 2 -- 17
		local halfH = height / 2 -- 18
		local interval = 10 -- 19
		local indent = 100 -- 20
		if fontSize == nil then -- 21
			fontSize = 12 -- 21
		end -- 21
		local vsCache = { } -- 22
		self.endPosY = y -- 23
		if fixed ~= nil then -- 24
			self.isFixed = fixed -- 24
		else -- 24
			self.isFixed = true -- 24
		end -- 24
		local labels = { } -- 26
		local labelList = { } -- 27
		local len = nil -- 28
		do -- 29
			local posX = self.intervalNode.anchor.x * width -- 30
			local center = Round(posX / 100) -- 31
			len = Round((posX + halfW) / 100 - center) -- 32
			len = 1 + math.max((center - Round((posX - halfW) / 100)), len) -- 33
			for i = center - len, center + len do -- 34
				local pos = i * 100 -- 35
				local label -- 36
				do -- 36
					local _with_0 = Label(fontName, fontSize) -- 36
					_with_0.text = string.format("%.0f", pos / 100 * indent) -- 37
					_with_0.scaleX = 1 / self.intervalNode.scaleX -- 38
					_with_0.position = Vec2(pos, halfH - 18 - fontSize) -- 39
					_with_0.tag = tostring(pos) -- 40
					label = _with_0 -- 36
				end -- 36
				self.intervalNode:addChild(label) -- 41
				labels[pos] = label -- 42
				table.insert(labelList, label) -- 43
			end -- 43
		end -- 43
		local moveLabel -- 45
		moveLabel = function(label, pos) -- 45
			labels[tonumber(label.tag)] = nil -- 46
			label.text = string.format("%.0f", pos / 100 * indent) -- 48
			label.scaleX = 1 / self.intervalNode.scaleX -- 49
			label.position = Vec2(pos, halfH - 18 - fontSize) -- 50
			label.tag = tostring(pos) -- 51
			labels[pos] = label -- 47
		end -- 45
		local updateLabels -- 53
		updateLabels = function() -- 53
			local posX = self.intervalNode.anchor.x * width -- 54
			local center = math.floor(posX / 100) -- 55
			local right = center + len -- 56
			local left = center - len -- 57
			local insertPos = 1 -- 58
			for i = left, right do -- 59
				local pos = i * 100 -- 60
				if labels[pos] then -- 61
					break -- 62
				else -- 64
					local label = table.remove(labelList) -- 64
					table.insert(labelList, insertPos, label) -- 65
					insertPos = insertPos + 1 -- 66
					moveLabel(label, pos) -- 67
				end -- 61
			end -- 67
			insertPos = #labelList -- 68
			for i = right, left, -1 do -- 69
				local pos = i * 100 -- 70
				if labels[pos] then -- 71
					break -- 72
				else -- 74
					local label = table.remove(labelList, 1) -- 74
					table.insert(labelList, insertPos, label) -- 75
					insertPos = insertPos - 1 -- 76
					moveLabel(label, pos) -- 77
				end -- 71
			end -- 77
			local scale = self.intervalNode.scaleX -- 79
			local current = Round(self.intervalNode.anchor.x * width / interval) -- 80
			local delta = 1 + math.ceil(halfW / scale / interval) -- 81
			local max = current + delta -- 82
			local min = current - delta -- 83
			local count = 1 -- 84
			local vs = { } -- 85
			for i = min, max do -- 86
				posX = i * interval -- 87
				local v = vsCache[count] -- 88
				if v then -- 89
					v = Vec2(posX, halfH) -- 89
				else -- 91
					v = Vec2(posX, halfH) -- 91
					vsCache[count] = v -- 92
				end -- 89
				vs[count] = v -- 93
				count = count + 1 -- 94
				v = vsCache[count] -- 95
				if v then -- 96
					v = Vec2(posX, halfH - (i % 10 == 0 and fontSize + 6 or fontSize - 2)) -- 96
				else -- 98
					v = Vec2(posX, halfH - (i % 10 == 0 and fontSize + 6 or fontSize - 2)) -- 98
					vsCache[count] = v -- 99
				end -- 96
				vs[count] = v -- 100
				count = count + 1 -- 101
				v = vsCache[count] -- 102
				if v then -- 103
					v = Vec2(posX, halfH) -- 103
				else -- 105
					v = Vec2(posX, halfH) -- 105
					vsCache[count] = v -- 106
				end -- 103
				vs[count] = v -- 107
				count = count + 1 -- 108
			end -- 108
			return self.intervalNode:set(vs, Color(0xffffffff)) -- 109
		end -- 53
		local updateIntervalTextScale -- 111
		updateIntervalTextScale = function(scale) -- 111
			return self.intervalNode:eachChild(function(child) -- 112
				child.scaleX = scale -- 113
			end) -- 113
		end -- 111
		self.makeScale = function(self, scale) -- 115
			scale = math.min(scale, 5) -- 116
			self.intervalNode.scaleX = scale -- 117
			updateIntervalTextScale(1 / scale) -- 119
			return updateLabels() -- 120
		end -- 115
		self.makeScaleTo = function(self, scale) -- 122
			do -- 123
				local _with_0 = self.intervalNode -- 123
				_with_0:perform(ScaleX(0.5, self.intervalNode.scaleX, scale, Ease.OutQuad)) -- 124
				_with_0:schedule(once(function() -- 126
					return cycle(0.5, function() -- 126
						return updateIntervalTextScale(1 / _with_0.scaleX) -- 126
					end) -- 126
				end)) -- 126
			end -- 123
			return updateLabels() -- 127
		end -- 122
		local _value = 0 -- 129
		local _max = 0 -- 130
		local _min = 0 -- 131
		do -- 133
			local _exp_0 = App.platform -- 133
			if "macOS" == _exp_0 or "Windows" == _exp_0 or "Linux" == _exp_0 then -- 134
				self:addChild((function() -- 135
					local _with_0 = Node() -- 135
					_with_0.size = Size(width, height) -- 136
					_with_0.touchEnabled = true -- 137
					_with_0.swallowMouseWheel = true -- 138
					_with_0:slot("MouseWheel", function(delta) -- 139
						local newVal = self:getValue() + delta.y * indent / 10 -- 140
						return self:setValue(_min < _max and math.min(math.max(_min, newVal), _max) or newVal) -- 141
					end) -- 139
					return _with_0 -- 135
				end)()) -- 135
			end -- 141
		end -- 141
		self.setIndent = function(self, ind) -- 143
			indent = ind -- 144
			for i, label in pairs(labels) do -- 145
				label.text = string.format("%.0f", ind * i / 100) -- 146
			end -- 146
		end -- 143
		self.getIndent = function(self) -- 147
			return indent -- 147
		end -- 147
		self.lastValue = nil -- 149
		self.setValue = function(self, v) -- 150
			_value = v -- 151
			local val = _min < _max and math.min(math.max(_value, _min), _max) or _value -- 152
			val = self.isFixed and Round(val / (indent / 10)) * (indent / 10) or val -- 153
			if val == -0 then -- 154
				val = 0 -- 154
			end -- 154
			if self.lastValue ~= val then -- 155
				self.lastValue = val -- 156
				self:emit("Changed", val) -- 157
			end -- 155
			local posX = v * 10 * interval / indent -- 158
			self.intervalNode.anchor = Vec2(posX / width, 0) -- 159
			return updateLabels() -- 160
		end -- 150
		self.getValue = function(self) -- 162
			return _value -- 162
		end -- 162
		self.getPos = function(self) -- 163
			return _value * 10 * interval / indent -- 163
		end -- 163
		self.setLimit = function(self, min, max) -- 165
			_max = max -- 166
			_min = min -- 167
		end -- 165
		local time = 0 -- 169
		local startPos = 0 -- 170
		local updateReset -- 171
		updateReset = function(deltaTime) -- 171
			if _min >= _max then -- 172
				return -- 172
			end -- 172
			local scale = self.intervalNode.scaleX -- 173
			time = time + deltaTime -- 174
			local t = time / 1 -- 175
			if scale < 1 then -- 176
				t = t / 0.1 -- 176
			end -- 176
			t = math.min(1, t) -- 177
			local yVal = nil -- 178
			if startPos < _min then -- 179
				yVal = startPos + (_min - startPos) * Ease:func(scale < 1 and Ease.Linear or Ease.OutElastic, t) -- 180
			elseif startPos > _max then -- 181
				yVal = startPos + (_max - startPos) * Ease:func(scale < 1 and Ease.Linear or Ease.OutElastic, t) -- 182
			end -- 179
			self:setValue(((yVal and yVal or 0) - _value) / scale + _value) -- 183
			if t == 1.0 then -- 184
				return self:unschedule() -- 184
			end -- 184
		end -- 171
		local isReseting -- 186
		isReseting = function() -- 186
			return _min < _max and (_value > _max or _value < _min) -- 187
		end -- 186
		local startReset -- 189
		startReset = function() -- 189
			startPos = _value -- 190
			time = 0 -- 191
			return self:schedule(updateReset) -- 192
		end -- 189
		local _v = 0 -- 194
		local _s = 0 -- 195
		local updateSpeed -- 196
		updateSpeed = function(deltaTime) -- 196
			if _s == 0 then -- 197
				return -- 197
			end -- 197
			_v = _s / deltaTime -- 198
			_s = 0 -- 199
		end -- 196
		local updatePos -- 201
		updatePos = function(deltaTime) -- 201
			local val = viewSize.height * 2 -- 202
			local a = _v > 0 and -val or val -- 203
			local yR = _v > 0 -- 204
			_v = _v + a * deltaTime -- 205
			if (_v < 0) == yR then -- 206
				_v = 0 -- 207
				a = 0 -- 208
			end -- 206
			local ds = _v * deltaTime + a * (0.5 * deltaTime * deltaTime) -- 209
			local newValue = _value - ds * indent / (interval * 10) -- 210
			self:setValue((newValue - _value) / self.intervalNode.scaleY + _value) -- 211
			if _v == 0 or isReseting() then -- 212
				if isReseting() then -- 213
					return startReset() -- 213
				else -- 214
					return self:unschedule() -- 214
				end -- 213
			end -- 212
		end -- 201
		self:slot("TapFilter", function(touch) -- 216
			if not touch.first then -- 217
				touch.enabled = false -- 217
			end -- 217
		end) -- 216
		self:slot("TapBegan", function() -- 219
			_s = 0 -- 220
			_v = 0 -- 221
			return self:schedule(updateSpeed) -- 222
		end) -- 219
		self:slot("TapMoved", function(touch) -- 224
			local deltaX = touch.delta.x -- 225
			local v = _value - deltaX * indent / (interval * 10) -- 226
			local padding = 0.5 * indent -- 227
			if _max > _min then -- 228
				local d = 1 -- 229
				if v > _max then -- 230
					d = (v - _max) * 3 / padding -- 231
				elseif v < _min then -- 232
					d = (_min - v) * 3 / padding -- 233
				end -- 230
				v = _value + (v - _value) / (d < 1 and 1 or d * d) -- 234
			end -- 228
			self:setValue((v - _value) / self.intervalNode.scaleX + _value) -- 235
			_s = _s + deltaX -- 236
		end) -- 224
		return self:slot("TapEnded", function() -- 238
			if isReseting() then -- 239
				return startReset() -- 240
			elseif _v ~= 0 then -- 241
				return self:schedule(updatePos) -- 242
			end -- 239
		end) -- 242
	end, -- 14
	show = function(self, default, min, max, ind, callback) -- 244
		self:setLimit(min, max) -- 245
		self:setIndent(ind) -- 246
		self:slot("Changed"):set(callback) -- 247
		self.lastValue = nil -- 248
		self:setValue(default) -- 249
		self.visible = true -- 250
		return self:perform(Spawn(Y(0.5, self.endPosY + 30, self.endPosY, Ease.OutBack), Opacity(0.3, self.opacity, 1))) -- 254
	end, -- 244
	hide = function(self) -- 256
		if not self.visible then -- 257
			return -- 257
		end -- 257
		self:slot("Changed", nil) -- 258
		self:unschedule() -- 259
		return self:perform(Sequence(Spawn(Y(0.5, self.y, self.endPosY + 30, Ease.InBack), Opacity(0.5, self.opacity, 0)), Hide())) -- 266
	end -- 256
}) -- 13
return _module_0 -- 266
