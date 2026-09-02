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
local nvg = require("nvg") -- 2
____exports.inputLength = function(text) return (utf8.len(text)) or 0 end -- 4
____exports.inputSlice = function(text, start, ____end) -- 5
	if ____end == nil then -- 5
		____end = ____exports.inputLength(text) -- 5
	end -- 5
	local first = utf8.offset(text, start + 1) or #text + 1 -- 6
	local last = (utf8.offset(text, ____end + 1) or #text + 1) - 1 -- 7
	return string.sub(text, first, last) -- 8
end -- 5
____exports.insertInputText = function(text, at, inserted) return (____exports.inputSlice(text, 0, at) .. inserted) .. ____exports.inputSlice(text, at) end -- 10
function ____exports.layoutInput(text, width, advance) -- 14
	local x = 0 -- 15
	local row = 0 -- 15
	local stops = {{x = 0, row = 0}} -- 16
	local display = {} -- 17
	for ____, code in utf8.codes(text) do -- 18
		local char = utf8.char(code) -- 19
		if char == "\n" then -- 19
			display[#display + 1] = char -- 20
			row = row + 1 -- 20
			x = 0 -- 20
		else -- 20
			local step = advance(char) -- 22
			if x > 0 and x + step > width then -- 22
				display[#display + 1] = "\n" -- 24
				row = row + 1 -- 24
				x = 0 -- 24
				stops[#stops] = {x = x, row = row} -- 25
			end -- 25
			display[#display + 1] = char -- 27
			x = x + step -- 27
		end -- 27
		stops[#stops + 1] = {x = x, row = row} -- 29
	end -- 29
	return { -- 31
		text = table.concat(display, ""), -- 31
		stops = stops, -- 31
		rows = row + 1 -- 31
	} -- 31
end -- 14
function ____exports.createTextInputView(input, fontSize, singleLine, background) -- 34
	if singleLine == nil then -- 34
		singleLine = false -- 34
	end -- 34
	if background == nil then -- 34
		background = 4279704614 -- 34
	end -- 34
	local border = Node() -- 35
	border.tag = input.tag .. "-border" -- 35
	border.color3 = Color3(3423048) -- 36
	input:addChild(border, -1) -- 36
	input:onRender(function() -- 37
		nvg.Save() -- 38
		nvg.ApplyTransform(input) -- 38
		nvg.BeginPath() -- 39
		nvg.RoundedRect( -- 39
			0, -- 39
			0, -- 39
			input.width, -- 39
			input.height, -- 39
			12 -- 39
		) -- 39
		nvg.FillPaint(nvg.LinearGradient( -- 40
			0, -- 40
			input.height, -- 40
			0, -- 40
			0, -- 40
			Color(4280560955), -- 40
			Color(background) -- 40
		)) -- 40
		nvg.Fill() -- 41
		nvg.BeginPath() -- 42
		nvg.RoundedRect( -- 42
			0.75, -- 42
			0.75, -- 42
			input.width - 1.5, -- 42
			input.height - 1.5, -- 42
			11.25 -- 42
		) -- 42
		nvg.StrokeWidth(1.5) -- 43
		nvg.StrokeColor(Color(border.color3)) -- 43
		nvg.Stroke() -- 43
		nvg.Restore() -- 43
		return false -- 44
	end) -- 37
	local insetX = 12 -- 46
	local insetY = 8 -- 46
	local width = math.max(1, input.width - insetX * 2 - 2) -- 47
	local height = math.max(1, input.height - insetY * 2) -- 48
	local lineHeight = fontSize + 4 -- 49
	local function makeLabel() -- 50
		local label = Label("sarasa-mono-sc-regular", fontSize, true) -- 51
		if not label then -- 51
			error( -- 52
				__TS__New(Error, "Missing mobile input font"), -- 52
				0 -- 52
			) -- 52
		end -- 52
		label.alignment = "Left" -- 53
		label.anchor = Vec2(0, 1) -- 53
		label.textWidth = -1 -- 53
		return label -- 54
	end -- 50
	local measure = makeLabel() -- 58
	measure.tag = "remix-input-measure" -- 58
	measure.visible = false -- 58
	input:addChild(measure) -- 59
	measure.batched = false -- 60
	measure.text = "M" -- 60
	local ____opt_0 = measure:getCharacter(1) -- 60
	local markerX = ____opt_0 and ____opt_0.x or 0 -- 62
	local singleHeight = measure.height -- 63
	measure.text = "M\nM" -- 64
	local gap = measure.lineGap + lineHeight - (measure.height - singleHeight) -- 65
	local widths = {} -- 66
	local function advance(char) -- 67
		if widths[char] ~= nil then -- 67
			return widths[char] -- 68
		end -- 68
		measure.text = char .. "M" -- 69
		local ____math_max_4 = math.max -- 70
		local ____opt_2 = measure:getCharacter(2) -- 70
		local step = ____math_max_4(1, (____opt_2 and ____opt_2.x or markerX + fontSize) - markerX) -- 70
		widths[char] = step -- 71
		return step -- 72
	end -- 67
	local stencil = DrawNode() -- 74
	stencil:drawPolygon( -- 75
		{ -- 75
			Vec2.zero, -- 75
			Vec2(width + 2, 0), -- 75
			Vec2(width + 2, height), -- 75
			Vec2(0, height) -- 75
		}, -- 75
		Color(4294967295) -- 75
	) -- 75
	local clip = ClipNode(stencil) -- 76
	clip.tag = "remix-input-clip" -- 76
	clip.anchor = Vec2.zero -- 77
	clip.position = Vec2(insetX, insetY) -- 77
	clip.size = Size(width + 2, height) -- 77
	input:addChild(clip, 1) -- 78
	local content = Node() -- 79
	content.tag = "remix-input-content" -- 79
	clip:addChild(content) -- 79
	local label = makeLabel() -- 80
	label.tag = "remix-input-text" -- 80
	label.lineGap = gap -- 80
	label.color3 = Color3(16052712) -- 80
	content:addChild(label) -- 80
	local placeholder = makeLabel() -- 81
	placeholder.tag = "remix-input-placeholder" -- 81
	placeholder.lineGap = gap -- 81
	local textTop = singleLine and (height + singleHeight) / 2 or height -- 82
	placeholder.textWidth = singleLine and -1 or width -- 83
	placeholder.y = textTop -- 83
	placeholder.color3 = Color3(11055037) -- 83
	clip:addChild(placeholder) -- 83
	local caret = DrawNode() -- 84
	caret.tag = "remix-input-caret" -- 84
	caret:drawPolygon( -- 85
		{ -- 85
			Vec2.zero, -- 85
			Vec2(1, 0), -- 85
			Vec2(1, fontSize + 2), -- 85
			Vec2(0, fontSize + 2) -- 85
		}, -- 85
		Color(4294954035) -- 85
	) -- 85
	content:addChild(caret) -- 86
	local layout = ____exports.layoutInput("", width, advance) -- 87
	local lastText = "" -- 88
	local active = false -- 88
	local blink = 0 -- 88
	local offset = 0 -- 88
	local index = 0 -- 88
	local function maxOffset() -- 89
		return math.max(0, singleLine and layout.stops[#layout.stops].x - width or layout.rows * lineHeight - height) -- 89
	end -- 89
	local function position() -- 90
		content.x = singleLine and -offset or 0 -- 91
		content.y = singleLine and 0 or offset -- 92
		label.y = textTop -- 92
		local stop = layout.stops[index + 1] -- 93
		caret.position = Vec2( -- 94
			singleLine and stop.x or math.min(width, stop.x), -- 94
			singleLine and (height - fontSize - 2) / 2 or height - stop.row * lineHeight - fontSize - 2 -- 94
		) -- 94
	end -- 90
	local function follow() -- 96
		local stop = layout.stops[index + 1] -- 97
		if singleLine then -- 97
			if stop.x < offset then -- 97
				offset = stop.x -- 99
			end -- 99
			if stop.x > offset + width then -- 99
				offset = stop.x - width -- 100
			end -- 100
		else -- 100
			local top = stop.row * lineHeight -- 102
			if top < offset then -- 102
				offset = top -- 103
			end -- 103
			if top + lineHeight > offset + height then -- 103
				offset = top + lineHeight - height -- 104
			end -- 104
		end -- 104
		offset = math.max( -- 106
			0, -- 106
			math.min( -- 106
				maxOffset(), -- 106
				offset -- 106
			) -- 106
		) -- 106
		position() -- 106
	end -- 96
	caret:schedule(function(dt) -- 108
		blink = blink + dt -- 108
		caret.visible = active and (blink % 1 < 0.5 or App.reducedMotion) -- 108
		return false -- 108
	end) -- 108
	local function nearest(x, row) -- 109
		local closest = 0 -- 110
		local distance = math.huge -- 110
		__TS__ArrayForEach( -- 111
			layout.stops, -- 111
			function(____, stop, i) -- 111
				local d = math.abs(stop.row - row) * (width + 1) + math.abs(stop.x - x) -- 112
				if d < distance then -- 112
					distance = d -- 113
					closest = i -- 113
				end -- 113
			end -- 111
		) -- 111
		return closest -- 115
	end -- 109
	return { -- 117
		label = label, -- 118
		caret = caret, -- 118
		placeholder = placeholder, -- 118
		clip = clip, -- 118
		border = border, -- 118
		update = function(text, hint, focused, cursor) -- 119
			if singleLine then -- 119
				text = (string.gsub(text, "[\r\n]", "")) -- 120
			end -- 120
			if lastText ~= text then -- 120
				layout = ____exports.layoutInput(text, singleLine and math.huge or width, advance) -- 121
				label.text = layout.text -- 121
				lastText = text -- 121
			end -- 121
			placeholder.text = hint -- 122
			placeholder.visible = text == "" and not focused -- 122
			border.color3 = Color3(focused and 16763955 or 3423048) -- 123
			active = focused -- 124
			index = math.max( -- 124
				0, -- 124
				math.min(#layout.stops - 1, cursor) -- 124
			) -- 124
			blink = 0 -- 125
			caret.visible = active -- 125
			follow() -- 125
		end, -- 119
		caretPosition = function() return Vec2(insetX + caret.x + content.x, insetY + caret.y + content.y) end, -- 127
		indexAt = function(point) return nearest( -- 128
			point.x - insetX - content.x, -- 128
			singleLine and 0 or math.max( -- 128
				0, -- 128
				math.floor((height + offset - (point.y - insetY)) / lineHeight) -- 128
			) -- 128
		) end, -- 128
		verticalIndex = function(cursor, direction) -- 129
			local stop = layout.stops[math.min(cursor, #layout.stops - 1) + 1] -- 129
			return nearest(stop.x, stop.row + direction) -- 129
		end, -- 129
		scroll = function(delta) -- 130
			offset = math.max( -- 130
				0, -- 130
				math.min( -- 130
					maxOffset(), -- 130
					offset + delta -- 130
				) -- 130
			) -- 130
			position() -- 130
		end -- 130
	} -- 130
end -- 34
function ____exports.createTextInput(options) -- 148
	local node -- 149
	local view -- 150
	local focused = false -- 151
	local composition = "" -- 151
	local compositionCursor = 0 -- 151
	local cursor = 0 -- 151
	local revision = 0 -- 151
	local dragDistance = 0 -- 151
	local function normalize(text) -- 152
		return options.singleLine and (string.gsub(text, "[\r\n]", "")) or (string.gsub((string.gsub(text, "\r\n", "\n")), "\r", "\n")) -- 152
	end -- 152
	local function updateIMEPos(next) -- 154
		local target = node -- 155
		if not target or not view then -- 155
			return -- 156
		end -- 156
		local captured = revision -- 157
		local caret = view.caretPosition() -- 158
		target:convertToWindowSpace( -- 159
			Vec2( -- 159
				math.max( -- 159
					12, -- 159
					math.min(target.width - 12, caret.x) -- 159
				), -- 159
				math.max( -- 159
					8, -- 159
					math.min(target.height - 8, caret.y) -- 159
				) -- 159
			), -- 159
			function(pos) -- 159
				if node ~= target or captured ~= revision or not options.isEnabled() then -- 159
					return -- 160
				end -- 160
				Keyboard:updateIMEPosHint(pos) -- 161
				if next ~= nil then -- 161
					next() -- 161
				end -- 161
			end -- 159
		) -- 159
	end -- 154
	local function refresh() -- 164
		local text = options.getText() -- 165
		cursor = math.min( -- 166
			cursor, -- 166
			____exports.inputLength(text) -- 166
		) -- 166
		local editing = ____exports.insertInputText(text, cursor, composition) -- 167
		local ____this_8 -- 167
		____this_8 = options -- 168
		local ____opt_7 = ____this_8.isSecure -- 168
		local display = ____opt_7 and ____opt_7(____this_8) and string.rep( -- 168
			"•", -- 168
			____exports.inputLength(editing) -- 168
		) or editing -- 168
		if view ~= nil then -- 168
			view.update( -- 169
				display, -- 169
				options.getPlaceholder(), -- 169
				focused, -- 169
				cursor + compositionCursor -- 169
			) -- 169
		end -- 169
		if focused then -- 169
			updateIMEPos() -- 170
		end -- 170
	end -- 164
	local function clearFocus() -- 172
		revision = revision + 1 -- 173
		focused = false -- 173
		composition = "" -- 173
		compositionCursor = 0 -- 173
		if node then -- 173
			node.keyboardEnabled = false -- 174
		end -- 174
		refresh() -- 175
	end -- 172
	local function blur() -- 177
		if focused then -- 177
			if node ~= nil then -- 177
				node:detachIME() -- 177
			end -- 177
		end -- 177
		clearFocus() -- 177
	end -- 177
	local function focus(reopen) -- 178
		if reopen == nil then -- 178
			reopen = true -- 178
		end -- 178
		if not options.isEnabled() then -- 178
			return -- 179
		end -- 179
		revision = revision + 1 -- 180
		updateIMEPos(function() -- 181
			if reopen then -- 181
				if node ~= nil then -- 181
					node:detachIME() -- 182
				end -- 182
			end -- 182
			if node ~= nil then -- 182
				node:attachIME() -- 183
			end -- 183
			updateIMEPos() -- 183
		end) -- 181
	end -- 178
	local function setValue(text, at) -- 186
		options.setText(text) -- 186
		cursor = at -- 186
		refresh() -- 186
	end -- 186
	local function textInput(text) -- 187
		if not options.isEnabled() then -- 187
			return -- 188
		end -- 188
		composition = "" -- 189
		compositionCursor = 0 -- 189
		local value = normalize(text) -- 190
		setValue( -- 191
			____exports.insertInputText( -- 191
				options.getText(), -- 191
				cursor, -- 191
				value -- 191
			), -- 191
			cursor + ____exports.inputLength(value) -- 191
		) -- 191
	end -- 187
	local function keyInput(key) -- 193
		if not options.isEnabled() then -- 193
			return -- 194
		end -- 194
		if key == "Escape" then -- 194
			blur() -- 195
			return -- 195
		end -- 195
		if composition ~= "" then -- 195
			return -- 196
		end -- 196
		local value = options.getText() -- 197
		if key == "BackSpace" and cursor > 0 then -- 197
			setValue( -- 198
				____exports.inputSlice(value, 0, cursor - 1) .. ____exports.inputSlice(value, cursor), -- 198
				cursor - 1 -- 198
			) -- 198
		elseif key == "Delete" and cursor < ____exports.inputLength(value) then -- 198
			setValue( -- 199
				____exports.inputSlice(value, 0, cursor) .. ____exports.inputSlice(value, cursor + 1), -- 199
				cursor -- 199
			) -- 199
		elseif key == "Home" or key == "End" or key == "Left" or key == "Right" or key == "Up" or key == "Down" then -- 199
			cursor = key == "Home" and 0 or (key == "End" and ____exports.inputLength(value) or ((key == "Up" or key == "Down") and (view and view.verticalIndex(cursor, key == "Up" and -1 or 1) or cursor) or math.max( -- 201
				0, -- 203
				math.min( -- 203
					____exports.inputLength(value), -- 203
					cursor + (key == "Left" and -1 or 1) -- 203
				) -- 203
			))) -- 203
			refresh() -- 204
		elseif key == "Return" then -- 204
			local modified = Keyboard:isKeyPressed("LCtrl") or Keyboard:isKeyPressed("RCtrl") or Keyboard:isKeyPressed("LGui") or Keyboard:isKeyPressed("RGui") -- 206
			local ____opt_19 = options.onReturn -- 206
			if not (____opt_19 and ____opt_19(modified)) and not options.singleLine then -- 206
				textInput("\n") -- 207
			end -- 207
		end -- 207
	end -- 193
	local function unmount() -- 210
		blur() -- 210
		node = nil -- 210
		view = nil -- 210
	end -- 210
	return { -- 211
		refresh = refresh, -- 212
		focus = focus, -- 212
		blur = blur, -- 212
		unmount = unmount, -- 212
		pasteFromClipboard = function(replace) -- 213
			if replace == nil then -- 213
				replace = false -- 213
			end -- 213
			if not options.isEnabled() then -- 213
				return false -- 214
			end -- 214
			local value = normalize(App:getClipboardText()) -- 215
			if value == "" then -- 215
				return false -- 216
			end -- 216
			if replace then -- 216
				setValue( -- 217
					value, -- 217
					____exports.inputLength(value) -- 217
				) -- 217
			else -- 217
				textInput(value) -- 218
			end -- 218
			return true -- 219
		end, -- 213
		isFocused = function() return focused end, -- 221
		isComposing = function() return composition ~= "" end, -- 222
		deferFocus = function() -- 223
			local captured = revision -- 224
			thread(function() -- 225
				sleep(0) -- 225
				if captured == revision then -- 225
					focus() -- 225
				end -- 225
			end) -- 225
		end, -- 223
		mount = function(target) -- 227
			unmount() -- 228
			node = target -- 228
			view = ____exports.createTextInputView(target, options.fontSize, options.singleLine, options.background) -- 229
			target.touchEnabled = true -- 230
			target:slot("GamepadActivate", function() if options.isEnabled() then focus() end end)
			target.swallowTouches = true -- 230
			target:onAttachIME(function() -- 231
				focused = true -- 231
				composition = "" -- 231
				compositionCursor = 0 -- 231
				target.keyboardEnabled = true -- 231
				refresh() -- 231
			end) -- 231
			target:onDetachIME(clearFocus) -- 232
			target:onTextInput(textInput) -- 233
			target:onTextEditing(function(text, start) -- 234
				if not options.isEnabled() then -- 234
					return -- 235
				end -- 235
				composition = normalize(text) -- 236
				compositionCursor = math.max( -- 236
					0, -- 236
					math.min( -- 236
						____exports.inputLength(composition), -- 236
						start or ____exports.inputLength(composition) -- 236
					) -- 236
				) -- 236
				refresh() -- 236
			end) -- 234
			target:onKeyDown(keyInput) -- 238
			target.keyboardEnabled = false -- 238
			target:onTapBegan(function() -- 239
				dragDistance = 0 -- 239
			end) -- 239
			target:onTapMoved(function(touch) -- 240
				if not options.isEnabled() then -- 240
					return -- 241
				end -- 241
				dragDistance = dragDistance + (math.abs(touch.delta.x) + math.abs(touch.delta.y)) -- 242
				if view ~= nil then -- 242
					view.scroll(options.singleLine and -touch.delta.x or touch.delta.y) -- 243
				end -- 243
				if focused then -- 243
					updateIMEPos() -- 243
				end -- 243
			end) -- 240
			target:onMouseWheel(function(delta) -- 245
				if not options.isEnabled() then -- 245
					return -- 245
				end -- 245
				if view ~= nil then -- 245
					view.scroll(-delta.y * 20) -- 245
				end -- 245
				if focused then -- 245
					updateIMEPos() -- 245
				end -- 245
			end) -- 245
			target:onTapped(function(touch) -- 246
				if dragDistance > 5 or not options.isEnabled() then -- 246
					return -- 247
				end -- 247
				if touch ~= nil and composition == "" then -- 247
					cursor = view and view.indexAt(touch.location) or cursor -- 248
				end -- 248
				refresh() -- 249
				if not focused then -- 249
					focus() -- 249
				end -- 249
			end) -- 246
			target:onCleanup(function() -- 251
				if node == target then -- 251
					unmount() -- 251
				end -- 251
			end) -- 251
			refresh() -- 252
		end -- 227
	} -- 227
end -- 148
return ____exports -- 148
