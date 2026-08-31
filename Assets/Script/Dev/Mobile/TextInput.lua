-- [ts]: TextInput.ts
local ____lualib = require("lualib_bundle") -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local ClipNode = ____Dora.ClipNode -- 1
local Color = ____Dora.Color -- 1
local Color3 = ____Dora.Color3 -- 1
local DrawNode = ____Dora.DrawNode -- 1
local Keyboard = ____Dora.Keyboard -- 1
local Label = ____Dora.Label -- 1
local Node = ____Dora.Node -- 1
local Size = ____Dora.Size -- 1
local sleep = ____Dora.sleep -- 1
local thread = ____Dora.thread -- 1
local Vec2 = ____Dora.Vec2 -- 1
____exports.inputLength = function(text) return (utf8.len(text)) or 0 end -- 3
____exports.inputSlice = function(text, start, ____end) -- 4
	if ____end == nil then -- 4
		____end = ____exports.inputLength(text) -- 4
	end -- 4
	local first = utf8.offset(text, start + 1) or #text + 1 -- 5
	local last = (utf8.offset(text, ____end + 1) or #text + 1) - 1 -- 6
	return string.sub(text, first, last) -- 7
end -- 4
____exports.insertInputText = function(text, at, inserted) return (____exports.inputSlice(text, 0, at) .. inserted) .. ____exports.inputSlice(text, at) end -- 9
function ____exports.layoutInput(text, width, advance) -- 13
	local x = 0 -- 14
	local row = 0 -- 14
	local stops = {{x = 0, row = 0}} -- 15
	local display = {} -- 16
	for ____, code in utf8.codes(text) do -- 17
		local char = utf8.char(code) -- 18
		if char == "\n" then -- 18
			display[#display + 1] = char -- 19
			row = row + 1 -- 19
			x = 0 -- 19
		else -- 19
			local step = advance(char) -- 21
			if x > 0 and x + step > width then -- 21
				display[#display + 1] = "\n" -- 23
				row = row + 1 -- 23
				x = 0 -- 23
				stops[#stops] = {x = x, row = row} -- 24
			end -- 24
			display[#display + 1] = char -- 26
			x = x + step -- 26
		end -- 26
		stops[#stops + 1] = {x = x, row = row} -- 28
	end -- 28
	return { -- 30
		text = table.concat(display, ""), -- 30
		stops = stops, -- 30
		rows = row + 1 -- 30
	} -- 30
end -- 13
function ____exports.createTextInputView(input, fontSize, singleLine, background) -- 33
	if singleLine == nil then -- 33
		singleLine = false -- 33
	end -- 33
	if background == nil then -- 33
		background = 4279704614 -- 33
	end -- 33
	local bounds = { -- 34
		Vec2.zero, -- 34
		Vec2(input.width, 0), -- 34
		Vec2(input.width, input.height), -- 34
		Vec2(0, input.height) -- 34
	} -- 34
	local fill = DrawNode() -- 35
	fill:drawPolygon( -- 35
		bounds, -- 35
		Color(background) -- 35
	) -- 35
	input:addChild(fill, -2) -- 35
	local border = DrawNode() -- 36
	border.tag = input.tag .. "-border" -- 36
	border:drawPolygon( -- 37
		bounds, -- 37
		Color(0), -- 37
		1, -- 37
		Color(4294967295) -- 37
	) -- 37
	border.color3 = Color3(3423048) -- 38
	input:addChild(border, -1) -- 38
	local insetX = 12 -- 39
	local insetY = 8 -- 39
	local width = math.max(1, input.width - insetX * 2 - 2) -- 40
	local height = math.max(1, input.height - insetY * 2) -- 41
	local lineHeight = fontSize + 4 -- 42
	local function makeLabel() -- 43
		local label = Label("sarasa-mono-sc-regular", fontSize, true) -- 44
		if not label then -- 44
			error( -- 45
				__TS__New(Error, "Missing mobile input font"), -- 45
				0 -- 45
			) -- 45
		end -- 45
		label.alignment = "Left" -- 46
		label.anchor = Vec2(0, 1) -- 46
		label.textWidth = -1 -- 46
		return label -- 47
	end -- 43
	local measure = makeLabel() -- 51
	measure.tag = "remix-input-measure" -- 51
	measure.visible = false -- 51
	input:addChild(measure) -- 52
	measure.batched = false -- 53
	measure.text = "M" -- 53
	local ____opt_0 = measure:getCharacter(1) -- 53
	local markerX = ____opt_0 and ____opt_0.x or 0 -- 55
	local singleHeight = measure.height -- 56
	measure.text = "M\nM" -- 57
	local gap = measure.lineGap + lineHeight - (measure.height - singleHeight) -- 58
	local widths = {} -- 59
	local function advance(char) -- 60
		if widths[char] ~= nil then -- 60
			return widths[char] -- 61
		end -- 61
		measure.text = char .. "M" -- 62
		local ____math_max_4 = math.max -- 63
		local ____opt_2 = measure:getCharacter(2) -- 63
		local step = ____math_max_4(1, (____opt_2 and ____opt_2.x or markerX + fontSize) - markerX) -- 63
		widths[char] = step -- 64
		return step -- 65
	end -- 60
	local stencil = DrawNode() -- 67
	stencil:drawPolygon( -- 68
		{ -- 68
			Vec2.zero, -- 68
			Vec2(width + 2, 0), -- 68
			Vec2(width + 2, height), -- 68
			Vec2(0, height) -- 68
		}, -- 68
		Color(4294967295) -- 68
	) -- 68
	local clip = ClipNode(stencil) -- 69
	clip.tag = "remix-input-clip" -- 69
	clip.anchor = Vec2.zero -- 70
	clip.position = Vec2(insetX, insetY) -- 70
	clip.size = Size(width + 2, height) -- 70
	input:addChild(clip, 1) -- 71
	local content = Node() -- 72
	content.tag = "remix-input-content" -- 72
	clip:addChild(content) -- 72
	local label = makeLabel() -- 73
	label.tag = "remix-input-text" -- 73
	label.lineGap = gap -- 73
	label.color3 = Color3(16052712) -- 73
	content:addChild(label) -- 73
	local placeholder = makeLabel() -- 74
	placeholder.tag = "remix-input-placeholder" -- 74
	placeholder.lineGap = gap -- 74
	local textTop = singleLine and (height + singleHeight) / 2 or height -- 75
	placeholder.textWidth = singleLine and -1 or width -- 76
	placeholder.y = textTop -- 76
	placeholder.color3 = Color3(11055037) -- 76
	clip:addChild(placeholder) -- 76
	local caret = DrawNode() -- 77
	caret.tag = "remix-input-caret" -- 77
	caret:drawPolygon( -- 78
		{ -- 78
			Vec2.zero, -- 78
			Vec2(1, 0), -- 78
			Vec2(1, fontSize + 2), -- 78
			Vec2(0, fontSize + 2) -- 78
		}, -- 78
		Color(4294954035) -- 78
	) -- 78
	content:addChild(caret) -- 79
	local layout = ____exports.layoutInput("", width, advance) -- 80
	local lastText = "" -- 81
	local active = false -- 81
	local blink = 0 -- 81
	local offset = 0 -- 81
	local index = 0 -- 81
	local function maxOffset() -- 82
		return math.max(0, singleLine and layout.stops[#layout.stops].x - width or layout.rows * lineHeight - height) -- 82
	end -- 82
	local function position() -- 83
		content.x = singleLine and -offset or 0 -- 84
		content.y = singleLine and 0 or offset -- 85
		label.y = textTop -- 85
		local stop = layout.stops[index + 1] -- 86
		caret.position = Vec2( -- 87
			singleLine and stop.x or math.min(width, stop.x), -- 87
			singleLine and (height - fontSize - 2) / 2 or height - stop.row * lineHeight - fontSize - 2 -- 87
		) -- 87
	end -- 83
	local function follow() -- 89
		local stop = layout.stops[index + 1] -- 90
		if singleLine then -- 90
			if stop.x < offset then -- 90
				offset = stop.x -- 92
			end -- 92
			if stop.x > offset + width then -- 92
				offset = stop.x - width -- 93
			end -- 93
		else -- 93
			local top = stop.row * lineHeight -- 95
			if top < offset then -- 95
				offset = top -- 96
			end -- 96
			if top + lineHeight > offset + height then -- 96
				offset = top + lineHeight - height -- 97
			end -- 97
		end -- 97
		offset = math.max( -- 99
			0, -- 99
			math.min( -- 99
				maxOffset(), -- 99
				offset -- 99
			) -- 99
		) -- 99
		position() -- 99
	end -- 89
	caret:schedule(function(dt) -- 101
		blink = blink + dt -- 101
		caret.visible = active and (blink % 1 < 0.5 or App.reducedMotion) -- 101
		return false -- 101
	end) -- 101
	local function nearest(x, row) -- 102
		local closest = 0 -- 103
		local distance = math.huge -- 103
		__TS__ArrayForEach( -- 104
			layout.stops, -- 104
			function(____, stop, i) -- 104
				local d = math.abs(stop.row - row) * (width + 1) + math.abs(stop.x - x) -- 105
				if d < distance then -- 105
					distance = d -- 106
					closest = i -- 106
				end -- 106
			end -- 104
		) -- 104
		return closest -- 108
	end -- 102
	return { -- 110
		label = label, -- 111
		caret = caret, -- 111
		placeholder = placeholder, -- 111
		clip = clip, -- 111
		border = border, -- 111
		update = function(text, hint, focused, cursor) -- 112
			if singleLine then -- 112
				text = (string.gsub(text, "[\r\n]", "")) -- 113
			end -- 113
			if lastText ~= text then -- 113
				layout = ____exports.layoutInput(text, singleLine and math.huge or width, advance) -- 114
				label.text = layout.text -- 114
				lastText = text -- 114
			end -- 114
			placeholder.text = hint -- 115
			placeholder.visible = text == "" and not focused -- 115
			border.color3 = Color3(focused and 16763955 or 3423048) -- 116
			active = focused -- 117
			index = math.max( -- 117
				0, -- 117
				math.min(#layout.stops - 1, cursor) -- 117
			) -- 117
			blink = 0 -- 118
			caret.visible = active -- 118
			follow() -- 118
		end, -- 112
		caretPosition = function() return Vec2(insetX + caret.x + content.x, insetY + caret.y + content.y) end, -- 120
		indexAt = function(point) return nearest( -- 121
			point.x - insetX - content.x, -- 121
			singleLine and 0 or math.max( -- 121
				0, -- 121
				math.floor((height + offset - (point.y - insetY)) / lineHeight) -- 121
			) -- 121
		) end, -- 121
		verticalIndex = function(cursor, direction) -- 122
			local stop = layout.stops[math.min(cursor, #layout.stops - 1) + 1] -- 122
			return nearest(stop.x, stop.row + direction) -- 122
		end, -- 122
		scroll = function(delta) -- 123
			offset = math.max( -- 123
				0, -- 123
				math.min( -- 123
					maxOffset(), -- 123
					offset + delta -- 123
				) -- 123
			) -- 123
			position() -- 123
		end -- 123
	} -- 123
end -- 33
function ____exports.createTextInput(options) -- 140
	local node -- 141
	local view -- 142
	local focused = false -- 143
	local composition = "" -- 143
	local compositionCursor = 0 -- 143
	local cursor = 0 -- 143
	local revision = 0 -- 143
	local dragDistance = 0 -- 143
	local function normalize(text) -- 144
		return options.singleLine and (string.gsub(text, "[\r\n]", "")) or (string.gsub((string.gsub(text, "\r\n", "\n")), "\r", "\n")) -- 144
	end -- 144
	local function updateIMEPos(next) -- 146
		local target = node -- 147
		if not target or not view then -- 147
			return -- 148
		end -- 148
		local captured = revision -- 149
		local caret = view.caretPosition() -- 150
		target:convertToWindowSpace( -- 151
			Vec2( -- 151
				math.max( -- 151
					12, -- 151
					math.min(target.width - 12, caret.x) -- 151
				), -- 151
				math.max( -- 151
					8, -- 151
					math.min(target.height - 8, caret.y) -- 151
				) -- 151
			), -- 151
			function(pos) -- 151
				if node ~= target or captured ~= revision or not options.isEnabled() then -- 151
					return -- 152
				end -- 152
				Keyboard:updateIMEPosHint(pos) -- 153
				if next ~= nil then -- 153
					next() -- 153
				end -- 153
			end -- 151
		) -- 151
	end -- 146
	local function refresh() -- 156
		cursor = math.min( -- 157
			cursor, -- 157
			____exports.inputLength(options.getText()) -- 157
		) -- 157
		if view ~= nil then -- 157
			view.update( -- 158
				____exports.insertInputText( -- 158
					options.getText(), -- 158
					cursor, -- 158
					composition -- 158
				), -- 158
				options.getPlaceholder(), -- 158
				focused, -- 158
				cursor + compositionCursor -- 158
			) -- 158
		end -- 158
		if focused then -- 158
			updateIMEPos() -- 159
		end -- 159
	end -- 156
	local function clearFocus() -- 161
		revision = revision + 1 -- 162
		focused = false -- 162
		composition = "" -- 162
		compositionCursor = 0 -- 162
		if node then -- 162
			node.keyboardEnabled = false -- 163
		end -- 163
		refresh() -- 164
	end -- 161
	local function blur() -- 166
		if focused then -- 166
			if node ~= nil then -- 166
				node:detachIME() -- 166
			end -- 166
		end -- 166
		clearFocus() -- 166
	end -- 166
	local function focus(reopen) -- 167
		if reopen == nil then -- 167
			reopen = true -- 167
		end -- 167
		if not options.isEnabled() then -- 167
			return -- 168
		end -- 168
		revision = revision + 1 -- 169
		updateIMEPos(function() -- 170
			if reopen then -- 170
				if node ~= nil then -- 170
					node:detachIME() -- 171
				end -- 171
			end -- 171
			if node ~= nil then -- 171
				node:attachIME() -- 172
			end -- 172
			updateIMEPos() -- 172
		end) -- 170
	end -- 167
	local function setValue(text, at) -- 175
		options.setText(text) -- 175
		cursor = at -- 175
		refresh() -- 175
	end -- 175
	local function textInput(text) -- 176
		if not options.isEnabled() then -- 176
			return -- 177
		end -- 177
		composition = "" -- 178
		compositionCursor = 0 -- 178
		local value = normalize(text) -- 179
		setValue( -- 180
			____exports.insertInputText( -- 180
				options.getText(), -- 180
				cursor, -- 180
				value -- 180
			), -- 180
			cursor + ____exports.inputLength(value) -- 180
		) -- 180
	end -- 176
	local function keyInput(key) -- 182
		if not options.isEnabled() then -- 182
			return -- 183
		end -- 183
		if key == "Escape" then -- 183
			blur() -- 184
			return -- 184
		end -- 184
		if composition ~= "" then -- 184
			return -- 185
		end -- 185
		local value = options.getText() -- 186
		if key == "BackSpace" and cursor > 0 then -- 186
			setValue( -- 187
				____exports.inputSlice(value, 0, cursor - 1) .. ____exports.inputSlice(value, cursor), -- 187
				cursor - 1 -- 187
			) -- 187
		elseif key == "Delete" and cursor < ____exports.inputLength(value) then -- 187
			setValue( -- 188
				____exports.inputSlice(value, 0, cursor) .. ____exports.inputSlice(value, cursor + 1), -- 188
				cursor -- 188
			) -- 188
		elseif key == "Home" or key == "End" or key == "Left" or key == "Right" or key == "Up" or key == "Down" then -- 188
			cursor = key == "Home" and 0 or (key == "End" and ____exports.inputLength(value) or ((key == "Up" or key == "Down") and (view and view.verticalIndex(cursor, key == "Up" and -1 or 1) or cursor) or math.max( -- 190
				0, -- 192
				math.min( -- 192
					____exports.inputLength(value), -- 192
					cursor + (key == "Left" and -1 or 1) -- 192
				) -- 192
			))) -- 192
			refresh() -- 193
		elseif key == "Return" then -- 193
			local modified = Keyboard:isKeyPressed("LCtrl") or Keyboard:isKeyPressed("RCtrl") or Keyboard:isKeyPressed("LGui") or Keyboard:isKeyPressed("RGui") -- 195
			local ____opt_17 = options.onReturn -- 195
			if not (____opt_17 and ____opt_17(modified)) and not options.singleLine then -- 195
				textInput("\n") -- 196
			end -- 196
		end -- 196
	end -- 182
	local function unmount() -- 199
		blur() -- 199
		node = nil -- 199
		view = nil -- 199
	end -- 199
	return { -- 200
		refresh = refresh, -- 201
		focus = focus, -- 201
		blur = blur, -- 201
		unmount = unmount, -- 201
		isFocused = function() return focused end, -- 202
		isComposing = function() return composition ~= "" end, -- 203
		deferFocus = function() -- 204
			local captured = revision -- 205
			thread(function() -- 206
				sleep(0) -- 206
				if captured == revision then -- 206
					focus() -- 206
				end -- 206
			end) -- 206
		end, -- 204
		mount = function(target) -- 208
			unmount() -- 209
			node = target -- 209
			view = ____exports.createTextInputView(target, options.fontSize, options.singleLine, options.background) -- 210
			target.touchEnabled = true -- 211
			target.swallowTouches = true -- 211
			target:onAttachIME(function() -- 212
				focused = true -- 212
				composition = "" -- 212
				compositionCursor = 0 -- 212
				target.keyboardEnabled = true -- 212
				refresh() -- 212
			end) -- 212
			target:onDetachIME(clearFocus) -- 213
			target:onTextInput(textInput) -- 214
			target:onTextEditing(function(text, start) -- 215
				if not options.isEnabled() then -- 215
					return -- 216
				end -- 216
				composition = normalize(text) -- 217
				compositionCursor = math.max( -- 217
					0, -- 217
					math.min( -- 217
						____exports.inputLength(composition), -- 217
						start or ____exports.inputLength(composition) -- 217
					) -- 217
				) -- 217
				refresh() -- 217
			end) -- 215
			target:onKeyDown(keyInput) -- 219
			target.keyboardEnabled = false -- 219
			target:onTapBegan(function() -- 220
				dragDistance = 0 -- 220
			end) -- 220
			target:onTapMoved(function(touch) -- 221
				if not options.isEnabled() then -- 221
					return -- 222
				end -- 222
				dragDistance = dragDistance + (math.abs(touch.delta.x) + math.abs(touch.delta.y)) -- 223
				if view ~= nil then -- 223
					view.scroll(options.singleLine and -touch.delta.x or touch.delta.y) -- 224
				end -- 224
				if focused then -- 224
					updateIMEPos() -- 224
				end -- 224
			end) -- 221
			target:onMouseWheel(function(delta) -- 226
				if not options.isEnabled() then -- 226
					return -- 226
				end -- 226
				if view ~= nil then -- 226
					view.scroll(-delta.y * 20) -- 226
				end -- 226
				if focused then -- 226
					updateIMEPos() -- 226
				end -- 226
			end) -- 226
			target:onTapped(function(touch) -- 227
				if dragDistance > 5 or not options.isEnabled() then -- 227
					return -- 228
				end -- 228
				if touch ~= nil and composition == "" then -- 228
					cursor = view and view.indexAt(touch.location) or cursor -- 229
				end -- 229
				refresh() -- 230
				if not focused then -- 230
					focus() -- 230
				end -- 230
			end) -- 227
			target:onCleanup(function() -- 232
				if node == target then -- 232
					unmount() -- 232
				end -- 232
			end) -- 232
			refresh() -- 233
		end -- 208
	} -- 208
end -- 140
return ____exports -- 140