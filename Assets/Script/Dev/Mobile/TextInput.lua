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
local ____Surface = require("Dev.Mobile.Surface") -- 1
local paintSurface = ____Surface.paintSurface -- 1
local roundedSurfaceVertices = ____Surface.roundedSurfaceVertices -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local ClipNode = ____Dora.ClipNode -- 2
local Color = ____Dora.Color -- 2
local Color3 = ____Dora.Color3 -- 2
local DrawNode = ____Dora.DrawNode -- 2
local Keyboard = ____Dora.Keyboard -- 2
local Label = ____Dora.Label -- 2
local Node = ____Dora.Node -- 2
local Size = ____Dora.Size -- 2
local sleep = ____Dora.sleep -- 2
local thread = ____Dora.thread -- 2
local Vec2 = ____Dora.Vec2 -- 2
local nvg = require("nvg") -- 4
____exports.inputLength = function(text) return (utf8.len(text)) or 0 end -- 6
____exports.inputSlice = function(text, start, ____end) -- 7
	if ____end == nil then -- 7
		____end = ____exports.inputLength(text) -- 7
	end -- 7
	local first = utf8.offset(text, start + 1) or #text + 1 -- 8
	local last = (utf8.offset(text, ____end + 1) or #text + 1) - 1 -- 9
	return string.sub(text, first, last) -- 10
end -- 7
____exports.insertInputText = function(text, at, inserted) return (____exports.inputSlice(text, 0, at) .. inserted) .. ____exports.inputSlice(text, at) end -- 12
function ____exports.layoutInput(text, width, advance) -- 16
	local x = 0 -- 17
	local row = 0 -- 17
	local stops = {{x = 0, row = 0}} -- 18
	local display = {} -- 19
	for ____, code in utf8.codes(text) do -- 20
		local char = utf8.char(code) -- 21
		if char == "\n" then -- 21
			display[#display + 1] = char -- 22
			row = row + 1 -- 22
			x = 0 -- 22
		else -- 22
			local step = advance(char) -- 24
			if x > 0 and x + step > width then -- 24
				display[#display + 1] = "\n" -- 26
				row = row + 1 -- 26
				x = 0 -- 26
				stops[#stops] = {x = x, row = row} -- 27
			end -- 27
			display[#display + 1] = char -- 29
			x = x + step -- 29
		end -- 29
		stops[#stops + 1] = {x = x, row = row} -- 31
	end -- 31
	return { -- 33
		text = table.concat(display, ""), -- 33
		stops = stops, -- 33
		rows = row + 1 -- 33
	} -- 33
end -- 16
function ____exports.createTextInputView(input, fontSize, singleLine, background, nativeSurface) -- 36
	if singleLine == nil then -- 36
		singleLine = false -- 36
	end -- 36
	if background == nil then -- 36
		background = 4279704614 -- 36
	end -- 36
	if nativeSurface == nil then -- 36
		nativeSurface = false -- 36
	end -- 36
	local border = Node() -- 37
	border.tag = input.tag .. "-border" -- 37
	border.color3 = Color3(3423048) -- 38
	input:addChild(border, -1) -- 38
	if nativeSurface then -- 38
		local w = input.width -- 42
		local h = input.height -- 42
		local r = math.min(12, w / 2, h / 2) -- 42
		local verts = roundedSurfaceVertices(w, h, r) -- 43
		local fill = DrawNode() -- 44
		paintSurface( -- 45
			fill, -- 45
			w, -- 45
			h, -- 45
			r, -- 45
			{topColor = 4280560955, bottomColor = background} -- 45
		) -- 45
		input:addChild(fill, -2) -- 46
		local outline = DrawNode() -- 47
		outline:drawPolygon( -- 47
			verts, -- 47
			Color(0), -- 47
			1.5, -- 47
			Color(4294967295) -- 47
		) -- 47
		border:addChild(outline) -- 47
	else -- 47
		input:onRender(function() -- 48
			nvg.Save() -- 49
			nvg.ApplyTransform(input) -- 49
			nvg.BeginPath() -- 50
			nvg.RoundedRect( -- 50
				0, -- 50
				0, -- 50
				input.width, -- 50
				input.height, -- 50
				12 -- 50
			) -- 50
			nvg.FillPaint(nvg.LinearGradient( -- 51
				0, -- 51
				input.height, -- 51
				0, -- 51
				0, -- 51
				Color(4280560955), -- 51
				Color(background) -- 51
			)) -- 51
			nvg.Fill() -- 52
			nvg.BeginPath() -- 53
			nvg.RoundedRect( -- 53
				0.75, -- 53
				0.75, -- 53
				input.width - 1.5, -- 53
				input.height - 1.5, -- 53
				11.25 -- 53
			) -- 53
			nvg.StrokeWidth(1.5) -- 54
			nvg.StrokeColor(Color(border.color3)) -- 54
			nvg.Stroke() -- 54
			nvg.Restore() -- 54
			return false -- 55
		end) -- 48
	end -- 48
	local insetX = 12 -- 57
	local insetY = 8 -- 57
	local width = math.max(1, input.width - insetX * 2 - 2) -- 58
	local height = math.max(1, input.height - insetY * 2) -- 59
	local lineHeight = fontSize + 4 -- 60
	local function makeLabel() -- 61
		local label = Label("sarasa-mono-sc-regular", fontSize, true) -- 62
		if not label then -- 62
			error( -- 63
				__TS__New(Error, "Missing mobile input font"), -- 63
				0 -- 63
			) -- 63
		end -- 63
		label.alignment = "Left" -- 64
		label.anchor = Vec2(0, 1) -- 64
		label.textWidth = -1 -- 64
		return label -- 65
	end -- 61
	local measure = makeLabel() -- 69
	measure.tag = "remix-input-measure" -- 69
	measure.visible = false -- 69
	input:addChild(measure) -- 70
	measure.batched = false -- 71
	measure.text = "M" -- 71
	local ____opt_0 = measure:getCharacter(1) -- 71
	local markerX = ____opt_0 and ____opt_0.x or 0 -- 73
	local singleHeight = measure.height -- 74
	measure.text = "M\nM" -- 75
	local gap = measure.lineGap + lineHeight - (measure.height - singleHeight) -- 76
	local widths = {} -- 77
	local function advance(char) -- 78
		if widths[char] ~= nil then -- 78
			return widths[char] -- 79
		end -- 79
		measure.text = char .. "M" -- 80
		local ____math_max_4 = math.max -- 81
		local ____opt_2 = measure:getCharacter(2) -- 81
		local step = ____math_max_4(1, (____opt_2 and ____opt_2.x or markerX + fontSize) - markerX) -- 81
		widths[char] = step -- 82
		return step -- 83
	end -- 78
	local stencil = DrawNode() -- 85
	stencil:drawPolygon( -- 86
		{ -- 86
			Vec2.zero, -- 86
			Vec2(width + 2, 0), -- 86
			Vec2(width + 2, height), -- 86
			Vec2(0, height) -- 86
		}, -- 86
		Color(4294967295) -- 86
	) -- 86
	local clip = ClipNode(stencil) -- 87
	clip.tag = "remix-input-clip" -- 87
	clip.anchor = Vec2.zero -- 88
	clip.position = Vec2(insetX, insetY) -- 88
	clip.size = Size(width + 2, height) -- 88
	input:addChild(clip, 1) -- 89
	local content = Node() -- 90
	content.tag = "remix-input-content" -- 90
	clip:addChild(content) -- 90
	local label = makeLabel() -- 91
	label.tag = "remix-input-text" -- 91
	label.lineGap = gap -- 91
	label.color3 = Color3(16052712) -- 91
	content:addChild(label) -- 91
	local placeholder = makeLabel() -- 92
	placeholder.tag = "remix-input-placeholder" -- 92
	placeholder.lineGap = gap -- 92
	local textTop = singleLine and (height + singleHeight) / 2 or height -- 93
	placeholder.textWidth = singleLine and -1 or width -- 94
	placeholder.y = textTop -- 94
	placeholder.color3 = Color3(11055037) -- 94
	clip:addChild(placeholder) -- 94
	local caret = DrawNode() -- 95
	caret.tag = "remix-input-caret" -- 95
	caret:drawPolygon( -- 96
		{ -- 96
			Vec2.zero, -- 96
			Vec2(1, 0), -- 96
			Vec2(1, fontSize + 2), -- 96
			Vec2(0, fontSize + 2) -- 96
		}, -- 96
		Color(4294954035) -- 96
	) -- 96
	content:addChild(caret) -- 97
	local layout = ____exports.layoutInput("", width, advance) -- 98
	local lastText = "" -- 99
	local active = false -- 99
	local blink = 0 -- 99
	local offset = 0 -- 99
	local index = 0 -- 99
	local function maxOffset() -- 100
		return math.max(0, singleLine and layout.stops[#layout.stops].x - width or layout.rows * lineHeight - height) -- 100
	end -- 100
	local function position() -- 101
		content.x = singleLine and -offset or 0 -- 102
		content.y = singleLine and 0 or offset -- 103
		label.y = textTop -- 103
		local stop = layout.stops[index + 1] -- 104
		caret.position = Vec2( -- 105
			singleLine and stop.x or math.min(width, stop.x), -- 105
			singleLine and (height - fontSize - 2) / 2 or height - stop.row * lineHeight - fontSize - 2 -- 105
		) -- 105
	end -- 101
	local function follow() -- 107
		local stop = layout.stops[index + 1] -- 108
		if singleLine then -- 108
			if stop.x < offset then -- 108
				offset = stop.x -- 110
			end -- 110
			if stop.x > offset + width then -- 110
				offset = stop.x - width -- 111
			end -- 111
		else -- 111
			local top = stop.row * lineHeight -- 113
			if top < offset then -- 113
				offset = top -- 114
			end -- 114
			if top + lineHeight > offset + height then -- 114
				offset = top + lineHeight - height -- 115
			end -- 115
		end -- 115
		offset = math.max( -- 117
			0, -- 117
			math.min( -- 117
				maxOffset(), -- 117
				offset -- 117
			) -- 117
		) -- 117
		position() -- 117
	end -- 107
	caret:schedule(function(dt) -- 119
		blink = blink + dt -- 119
		caret.visible = active and (blink % 1 < 0.5 or App.reducedMotion) -- 119
		return false -- 119
	end) -- 119
	local function nearest(x, row) -- 120
		local closest = 0 -- 121
		local distance = math.huge -- 121
		__TS__ArrayForEach( -- 122
			layout.stops, -- 122
			function(____, stop, i) -- 122
				local d = math.abs(stop.row - row) * (width + 1) + math.abs(stop.x - x) -- 123
				if d < distance then -- 123
					distance = d -- 124
					closest = i -- 124
				end -- 124
			end -- 122
		) -- 122
		return closest -- 126
	end -- 120
	return { -- 128
		label = label, -- 129
		caret = caret, -- 129
		placeholder = placeholder, -- 129
		clip = clip, -- 129
		border = border, -- 129
		update = function(text, hint, focused, cursor) -- 130
			if singleLine then -- 130
				text = (string.gsub(text, "[\r\n]", "")) -- 131
			end -- 131
			if lastText ~= text then -- 131
				layout = ____exports.layoutInput(text, singleLine and math.huge or width, advance) -- 132
				label.text = layout.text -- 132
				lastText = text -- 132
			end -- 132
			placeholder.text = hint -- 133
			placeholder.visible = text == "" and not focused -- 133
			border.color3 = Color3(focused and 16763955 or 3423048) -- 134
			active = focused -- 135
			index = math.max( -- 135
				0, -- 135
				math.min(#layout.stops - 1, cursor) -- 135
			) -- 135
			blink = 0 -- 136
			caret.visible = active -- 136
			follow() -- 136
		end, -- 130
		caretPosition = function() return Vec2(insetX + caret.x + content.x, insetY + caret.y + content.y) end, -- 138
		indexAt = function(point) return nearest( -- 139
			point.x - insetX - content.x, -- 139
			singleLine and 0 or math.max( -- 139
				0, -- 139
				math.floor((height + offset - (point.y - insetY)) / lineHeight) -- 139
			) -- 139
		) end, -- 139
		verticalIndex = function(cursor, direction) -- 140
			local stop = layout.stops[math.min(cursor, #layout.stops - 1) + 1] -- 140
			return nearest(stop.x, stop.row + direction) -- 140
		end, -- 140
		scroll = function(delta) -- 141
			offset = math.max( -- 141
				0, -- 141
				math.min( -- 141
					maxOffset(), -- 141
					offset + delta -- 141
				) -- 141
			) -- 141
			position() -- 141
		end -- 141
	} -- 141
end -- 36
function ____exports.createTextInput(options) -- 160
	local node -- 161
	local view -- 162
	local focused = false -- 163
	local composition = "" -- 163
	local compositionCursor = 0 -- 163
	local cursor = 0 -- 163
	local revision = 0 -- 163
	local dragDistance = 0 -- 163
	local function normalize(text) -- 164
		return options.singleLine and (string.gsub(text, "[\r\n]", "")) or (string.gsub((string.gsub(text, "\r\n", "\n")), "\r", "\n")) -- 164
	end -- 164
	local function updateIMEPos(next) -- 166
		local target = node -- 167
		if not target or not view then -- 167
			return -- 168
		end -- 168
		local captured = revision -- 169
		local caret = view.caretPosition() -- 170
		target:convertToWindowSpace( -- 171
			Vec2( -- 171
				math.max( -- 171
					12, -- 171
					math.min(target.width - 12, caret.x) -- 171
				), -- 171
				math.max( -- 171
					8, -- 171
					math.min(target.height - 8, caret.y) -- 171
				) -- 171
			), -- 171
			function(pos) -- 171
				if node ~= target or captured ~= revision or not options.isEnabled() then -- 171
					return -- 172
				end -- 172
				Keyboard:updateIMEPosHint(pos) -- 173
				if next ~= nil then -- 173
					next() -- 173
				end -- 173
			end -- 171
		) -- 171
	end -- 166
	local function refresh() -- 176
		local text = options.getText() -- 177
		cursor = math.min( -- 178
			cursor, -- 178
			____exports.inputLength(text) -- 178
		) -- 178
		local editing = ____exports.insertInputText(text, cursor, composition) -- 179
		local ____this_8 -- 179
		____this_8 = options -- 180
		local ____opt_7 = ____this_8.isSecure -- 180
		local display = ____opt_7 and ____opt_7(____this_8) and string.rep( -- 180
			"•", -- 180
			____exports.inputLength(editing) -- 180
		) or editing -- 180
		if view ~= nil then -- 180
			view.update( -- 181
				display, -- 181
				options.getPlaceholder(), -- 181
				focused, -- 181
				cursor + compositionCursor -- 181
			) -- 181
		end -- 181
		if focused then -- 181
			updateIMEPos() -- 182
		end -- 182
	end -- 176
	local function clearFocus() -- 184
		revision = revision + 1 -- 185
		focused = false -- 185
		composition = "" -- 185
		compositionCursor = 0 -- 185
		if node then -- 185
			node.keyboardEnabled = false -- 186
		end -- 186
		refresh() -- 187
	end -- 184
	local function blur() -- 189
		if focused then -- 189
			if node ~= nil then -- 189
				node:detachIME() -- 189
			end -- 189
		end -- 189
		clearFocus() -- 189
	end -- 189
	local function focus(reopen) -- 190
		if reopen == nil then -- 190
			reopen = true -- 190
		end -- 190
		if not options.isEnabled() then -- 190
			return -- 191
		end -- 191
		revision = revision + 1 -- 192
		updateIMEPos(function() -- 193
			if reopen then -- 193
				if node ~= nil then -- 193
					node:detachIME() -- 194
				end -- 194
			end -- 194
			if node ~= nil then -- 194
				node:attachIME() -- 195
			end -- 195
			updateIMEPos() -- 195
		end) -- 193
	end -- 190
	local function setValue(text, at) -- 198
		options.setText(text) -- 198
		cursor = at -- 198
		refresh() -- 198
	end -- 198
	local function textInput(text) -- 199
		if not options.isEnabled() then -- 199
			return -- 200
		end -- 200
		composition = "" -- 201
		compositionCursor = 0 -- 201
		local value = normalize(text) -- 202
		setValue( -- 203
			____exports.insertInputText( -- 203
				options.getText(), -- 203
				cursor, -- 203
				value -- 203
			), -- 203
			cursor + ____exports.inputLength(value) -- 203
		) -- 203
	end -- 199
	local function keyInput(key) -- 205
		if not options.isEnabled() then -- 205
			return -- 206
		end -- 206
		if key == "Escape" then -- 206
			blur() -- 207
			return -- 207
		end -- 207
		if composition ~= "" then -- 207
			return -- 208
		end -- 208
		local value = options.getText() -- 209
		if key == "BackSpace" and cursor > 0 then -- 209
			setValue( -- 210
				____exports.inputSlice(value, 0, cursor - 1) .. ____exports.inputSlice(value, cursor), -- 210
				cursor - 1 -- 210
			) -- 210
		elseif key == "Delete" and cursor < ____exports.inputLength(value) then -- 210
			setValue( -- 211
				____exports.inputSlice(value, 0, cursor) .. ____exports.inputSlice(value, cursor + 1), -- 211
				cursor -- 211
			) -- 211
		elseif key == "Home" or key == "End" or key == "Left" or key == "Right" or key == "Up" or key == "Down" then -- 211
			cursor = key == "Home" and 0 or (key == "End" and ____exports.inputLength(value) or ((key == "Up" or key == "Down") and (view and view.verticalIndex(cursor, key == "Up" and -1 or 1) or cursor) or math.max( -- 213
				0, -- 215
				math.min( -- 215
					____exports.inputLength(value), -- 215
					cursor + (key == "Left" and -1 or 1) -- 215
				) -- 215
			))) -- 215
			refresh() -- 216
		elseif key == "Return" then -- 216
			local modified = Keyboard:isKeyPressed("LCtrl") or Keyboard:isKeyPressed("RCtrl") or Keyboard:isKeyPressed("LGui") or Keyboard:isKeyPressed("RGui") -- 218
			local ____opt_19 = options.onReturn -- 218
			if not (____opt_19 and ____opt_19(modified)) and not options.singleLine then -- 218
				textInput("\n") -- 219
			end -- 219
		end -- 219
	end -- 205
	local function unmount() -- 222
		blur() -- 222
		node = nil -- 222
		view = nil -- 222
	end -- 222
	return { -- 223
		refresh = refresh, -- 224
		focus = focus, -- 224
		blur = blur, -- 224
		unmount = unmount, -- 224
		pasteFromClipboard = function(replace) -- 225
			if replace == nil then -- 225
				replace = false -- 225
			end -- 225
			if not options.isEnabled() then -- 225
				return false -- 226
			end -- 226
			local value = normalize(App:getClipboardText()) -- 227
			if value == "" then -- 227
				return false -- 228
			end -- 228
			if replace then -- 228
				setValue( -- 229
					value, -- 229
					____exports.inputLength(value) -- 229
				) -- 229
			else -- 229
				textInput(value) -- 230
			end -- 230
			return true -- 231
		end, -- 225
		isFocused = function() return focused end, -- 233
		isComposing = function() return composition ~= "" end, -- 234
		deferFocus = function() -- 235
			local captured = revision -- 236
			thread(function() -- 237
				sleep(0) -- 237
				if captured == revision then -- 237
					focus() -- 237
				end -- 237
			end) -- 237
		end, -- 235
		mount = function(target) -- 239
			unmount() -- 240
			node = target -- 240
			view = ____exports.createTextInputView( -- 241
				target, -- 241
				options.fontSize, -- 241
				options.singleLine, -- 241
				options.background, -- 241
				options.nativeSurface -- 241
			) -- 241
			target.touchEnabled = true -- 242
			target.swallowTouches = true -- 242
			target:slot( -- 243
				"GamepadActivate", -- 243
				function() -- 243
					if options.isEnabled() then -- 243
						focus() -- 243
					end -- 243
				end -- 243
			) -- 243
			target:onAttachIME(function() -- 244
				focused = true -- 244
				composition = "" -- 244
				compositionCursor = 0 -- 244
				target.keyboardEnabled = true -- 244
				refresh() -- 244
			end) -- 244
			target:onDetachIME(clearFocus) -- 245
			target:onTextInput(textInput) -- 246
			target:onTextEditing(function(text, start) -- 247
				if not options.isEnabled() then -- 247
					return -- 248
				end -- 248
				composition = normalize(text) -- 249
				compositionCursor = math.max( -- 249
					0, -- 249
					math.min( -- 249
						____exports.inputLength(composition), -- 249
						start or ____exports.inputLength(composition) -- 249
					) -- 249
				) -- 249
				refresh() -- 249
			end) -- 247
			target:onKeyDown(keyInput) -- 251
			target.keyboardEnabled = false -- 251
			target:onTapBegan(function() -- 252
				dragDistance = 0 -- 252
			end) -- 252
			target:onTapMoved(function(touch) -- 253
				if not options.isEnabled() then -- 253
					return -- 254
				end -- 254
				dragDistance = dragDistance + (math.abs(touch.delta.x) + math.abs(touch.delta.y)) -- 255
				if view ~= nil then -- 255
					view.scroll(options.singleLine and -touch.delta.x or touch.delta.y) -- 256
				end -- 256
				if focused then -- 256
					updateIMEPos() -- 256
				end -- 256
			end) -- 253
			target:onMouseWheel(function(delta) -- 258
				if not options.isEnabled() then -- 258
					return -- 258
				end -- 258
				if view ~= nil then -- 258
					view.scroll(-delta.y * 20) -- 258
				end -- 258
				if focused then -- 258
					updateIMEPos() -- 258
				end -- 258
			end) -- 258
			target:onTapped(function(touch) -- 259
				if dragDistance > 5 or not options.isEnabled() then -- 259
					return -- 260
				end -- 260
				if touch ~= nil and composition == "" then -- 260
					cursor = view and view.indexAt(touch.location) or cursor -- 261
				end -- 261
				refresh() -- 262
				if not focused then -- 262
					focus() -- 262
				end -- 262
			end) -- 259
			target:onCleanup(function() -- 264
				if node == target then -- 264
					unmount() -- 264
				end -- 264
			end) -- 264
			refresh() -- 265
		end -- 239
	} -- 239
end -- 160
return ____exports -- 160