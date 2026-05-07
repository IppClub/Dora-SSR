-- [ts]: Runtime.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local ClipNode = ____Dora.ClipNode -- 1
local Color = ____Dora.Color -- 1
local Director = ____Dora.Director -- 1
local DrawNode = ____Dora.DrawNode -- 1
local Label = ____Dora.Label -- 1
local Line = ____Dora.Line -- 1
local Node = ____Dora.Node -- 1
local Sprite = ____Dora.Sprite -- 1
local Vec2 = ____Dora.Vec2 -- 1
local ____Theme = require("Script.Tools.SceneEditor.Theme") -- 3
local greenAxisColor = ____Theme.greenAxisColor -- 3
local gridMajorColor = ____Theme.gridMajorColor -- 3
local gridMinorColor = ____Theme.gridMinorColor -- 3
local helperColor = ____Theme.helperColor -- 3
local redAxisColor = ____Theme.redAxisColor -- 3
local selectionColor = ____Theme.selectionColor -- 3
local viewportBgColor = ____Theme.viewportBgColor -- 3
local viewportFrameColor = ____Theme.viewportFrameColor -- 3
local viewportGameFrameColor = ____Theme.viewportGameFrameColor -- 3
local function worldPointFromScreen(screenX, screenY) -- 5
	local size = App.visualSize -- 6
	return {screenX - size.width / 2, size.height / 2 - screenY} -- 7
end -- 5
local function makeLine(points, color) -- 10
	return Line(points, color) -- 11
end -- 10
local function makeThickLine(a, b, color, horizontal) -- 14
	local node = Node() -- 15
	do -- 15
		local offset = -1 -- 16
		while offset <= 1 do -- 16
			if horizontal then -- 16
				node:addChild(makeLine( -- 18
					{ -- 18
						Vec2(a.x, a.y + offset), -- 18
						Vec2(b.x, b.y + offset) -- 18
					}, -- 18
					color -- 18
				)) -- 18
			else -- 18
				node:addChild(makeLine( -- 20
					{ -- 20
						Vec2(a.x + offset, a.y), -- 20
						Vec2(b.x + offset, b.y) -- 20
					}, -- 20
					color -- 20
				)) -- 20
			end -- 20
			offset = offset + 1 -- 16
		end -- 16
	end -- 16
	return node -- 23
end -- 14
local function makeSegmentRect(width, height, color, thickness) -- 26
	local hw = width / 2 -- 27
	local hh = height / 2 -- 28
	local rect = DrawNode() -- 29
	rect:drawSegment( -- 30
		Vec2(-hw, -hh), -- 30
		Vec2(hw, -hh), -- 30
		thickness, -- 30
		color -- 30
	) -- 30
	rect:drawSegment( -- 31
		Vec2(hw, -hh), -- 31
		Vec2(hw, hh), -- 31
		thickness, -- 31
		color -- 31
	) -- 31
	rect:drawSegment( -- 32
		Vec2(hw, hh), -- 32
		Vec2(-hw, hh), -- 32
		thickness, -- 32
		color -- 32
	) -- 32
	rect:drawSegment( -- 33
		Vec2(-hw, hh), -- 33
		Vec2(-hw, -hh), -- 33
		thickness, -- 33
		color -- 33
	) -- 33
	return rect -- 34
end -- 26
local function addCornerHandles(node, width, height, color) -- 37
	local hw = width / 2 -- 38
	local hh = height / 2 -- 39
	local size = 8 -- 40
	local points = { -- 41
		Vec2(-hw, -hh), -- 42
		Vec2(hw, -hh), -- 43
		Vec2(hw, hh), -- 44
		Vec2(-hw, hh) -- 45
	} -- 45
	for ____, point in ipairs(points) do -- 47
		local handle = DrawNode() -- 48
		handle:drawPolygon( -- 49
			{ -- 49
				Vec2(point.x - size / 2, point.y - size / 2), -- 50
				Vec2(point.x + size / 2, point.y - size / 2), -- 51
				Vec2(point.x + size / 2, point.y + size / 2), -- 52
				Vec2(point.x - size / 2, point.y + size / 2) -- 53
			}, -- 53
			color, -- 54
			0, -- 54
			Color() -- 54
		) -- 54
		node:addChild(handle) -- 55
	end -- 55
end -- 37
local function selectionSize(item) -- 59
	if item.kind == "Camera" then -- 59
		return {320, 180} -- 60
	end -- 60
	if item.kind == "Sprite" then -- 60
		return {128, 96} -- 61
	end -- 61
	if item.kind == "Label" then -- 61
		return {180, 56} -- 62
	end -- 62
	return {72, 72} -- 63
end -- 59
local function addSelectionOverlay(state, item, node) -- 66
	local width, height = table.unpack( -- 67
		selectionSize(item), -- 67
		1, -- 67
		2 -- 67
	) -- 67
	local color = item.id == state.selectedId and selectionColor or helperColor -- 68
	node:addChild(makeSegmentRect(width, height, color, item.id == state.selectedId and 1.6 or 0.8)) -- 69
	if item.id == state.selectedId then -- 69
		addCornerHandles(node, width, height, color) -- 70
	end -- 70
end -- 66
local function makeClipStencil(width, height) -- 74
	local hw = width / 2 -- 75
	local hh = height / 2 -- 76
	local stencil = DrawNode() -- 77
	stencil:drawPolygon( -- 78
		{ -- 78
			Vec2(-hw, -hh), -- 79
			Vec2(hw, -hh), -- 80
			Vec2(hw, hh), -- 81
			Vec2(-hw, hh) -- 82
		}, -- 82
		Color(4294967295), -- 83
		0, -- 83
		Color() -- 83
	) -- 83
	return stencil -- 84
end -- 74
local function makeCanvasBackground(width, height) -- 87
	local hw = width / 2 -- 88
	local hh = height / 2 -- 89
	local bg = DrawNode() -- 90
	bg:drawPolygon( -- 91
		{ -- 91
			Vec2(-hw, -hh), -- 92
			Vec2(hw, -hh), -- 93
			Vec2(hw, hh), -- 94
			Vec2(-hw, hh) -- 95
		}, -- 95
		viewportBgColor, -- 96
		1, -- 96
		viewportFrameColor -- 96
	) -- 96
	return bg -- 97
end -- 87
local function makeGridLine(width, height) -- 100
	local grid = Node() -- 101
	local hw = width / 2 -- 102
	local hh = height / 2 -- 103
	local step = 32 -- 104
	local minor = DrawNode() -- 105
	local major = DrawNode() -- 106
	local i = 0 -- 107
	local x = -math.floor(hw / step) * step -- 108
	while x <= hw do -- 108
		if i % 5 == 0 then -- 108
			major:drawSegment( -- 111
				Vec2(x, -hh), -- 111
				Vec2(x, hh), -- 111
				0.55, -- 111
				gridMajorColor -- 111
			) -- 111
		else -- 111
			minor:drawSegment( -- 113
				Vec2(x, -hh), -- 113
				Vec2(x, hh), -- 113
				0.25, -- 113
				gridMinorColor -- 113
			) -- 113
		end -- 113
		x = x + step -- 115
		i = i + 1 -- 116
	end -- 116
	i = 0 -- 118
	local y = -math.floor(hh / step) * step -- 119
	while y <= hh do -- 119
		if i % 5 == 0 then -- 119
			major:drawSegment( -- 122
				Vec2(-hw, y), -- 122
				Vec2(hw, y), -- 122
				0.55, -- 122
				gridMajorColor -- 122
			) -- 122
		else -- 122
			minor:drawSegment( -- 124
				Vec2(-hw, y), -- 124
				Vec2(hw, y), -- 124
				0.25, -- 124
				gridMinorColor -- 124
			) -- 124
		end -- 124
		y = y + step -- 126
		i = i + 1 -- 127
	end -- 127
	grid:addChild(minor) -- 129
	grid:addChild(major) -- 130
	return grid -- 131
end -- 100
local function makeAxisLine(width, height) -- 134
	local hw = width / 2 -- 135
	local hh = height / 2 -- 136
	local axis = Node() -- 137
	local xAxis = DrawNode() -- 138
	xAxis:drawSegment( -- 139
		Vec2(-hw, 0), -- 139
		Vec2(hw, 0), -- 139
		1.2, -- 139
		redAxisColor -- 139
	) -- 139
	local yAxis = DrawNode() -- 140
	yAxis:drawSegment( -- 141
		Vec2(0, -hh), -- 141
		Vec2(0, hh), -- 141
		1.2, -- 141
		greenAxisColor -- 141
	) -- 141
	axis:addChild(xAxis) -- 142
	axis:addChild(yAxis) -- 143
	return axis -- 144
end -- 134
local function makeSpritePlaceholder() -- 147
	local node = Node() -- 148
	node:addChild(makeSegmentRect(128, 96, helperColor, 1.1)) -- 149
	local cross = DrawNode() -- 150
	cross:drawSegment( -- 151
		Vec2(-64, -48), -- 151
		Vec2(64, 48), -- 151
		0.6, -- 151
		helperColor -- 151
	) -- 151
	cross:drawSegment( -- 152
		Vec2(-64, 48), -- 152
		Vec2(64, -48), -- 152
		0.6, -- 152
		helperColor -- 152
	) -- 152
	node:addChild(cross) -- 153
	return node -- 154
end -- 147
local function makeCameraShape() -- 157
	local node = Node() -- 158
	node:addChild(makeSegmentRect(320, 180, viewportGameFrameColor, 1.1)) -- 159
	return node -- 160
end -- 157
local function createRuntimeVisual(state, item) -- 163
	local wrapper = Node() -- 164
	if item.kind == "Sprite" then -- 164
		local visual = nil -- 166
		if item.texture ~= "" then -- 166
			visual = Sprite(item.texture) -- 168
		end -- 168
		wrapper:addChild(visual ~= nil and visual or makeSpritePlaceholder()) -- 170
		addSelectionOverlay(state, item, wrapper) -- 171
	elseif item.kind == "Label" then -- 171
		local label = Label("sarasa-mono-sc-regular", 32) -- 173
		if label ~= nil then -- 173
			label.text = item.text or "Label" -- 175
			state.runtimeLabels[item.id] = label -- 176
			wrapper:addChild(label) -- 177
		else -- 177
			wrapper:addChild(makeSegmentRect( -- 179
				180, -- 179
				56, -- 179
				Color(4294967295), -- 179
				3 -- 179
			)) -- 179
		end -- 179
		addSelectionOverlay(state, item, wrapper) -- 181
	elseif item.kind == "Camera" then -- 181
		wrapper:addChild(makeCameraShape()) -- 183
		addSelectionOverlay(state, item, wrapper) -- 184
	else -- 184
		wrapper:addChild(makeThickLine( -- 186
			Vec2(-20, 0), -- 186
			Vec2(20, 0), -- 186
			helperColor, -- 186
			true -- 186
		)) -- 186
		wrapper:addChild(makeThickLine( -- 187
			Vec2(0, -20), -- 187
			Vec2(0, 20), -- 187
			helperColor, -- 187
			false -- 187
		)) -- 187
		addSelectionOverlay(state, item, wrapper) -- 188
	end -- 188
	return wrapper -- 190
end -- 163
function ____exports.rebuildPreviewRuntime(state) -- 193
	if state.previewRoot == nil then -- 193
		state.previewRoot = Node() -- 195
		state.previewRoot.tag = "__DoraImGuiEditorViewport__" -- 196
		Director.entry:addChild(state.previewRoot) -- 197
	end -- 197
	state.previewRoot:removeAllChildren(true) -- 199
	state.runtimeNodes = {} -- 200
	state.runtimeLabels = {} -- 201
	local renderScale = App.devicePixelRatio or 1 -- 203
	local width = math.max(160, state.preview.width * renderScale) -- 204
	local height = math.max(120, state.preview.height * renderScale) -- 205
	local scale = math.max(0.25, state.zoom / 100) -- 206
	local worldWidth = math.max(8192, width / scale * 6) -- 207
	local worldHeight = math.max(8192, height / scale * 6) -- 208
	local clip = ClipNode(makeClipStencil(width, height)) -- 209
	clip.alphaThreshold = 0.01 -- 210
	state.previewRoot:addChild(clip) -- 211
	clip:addChild(makeCanvasBackground(width, height)) -- 212
	local world = Node() -- 214
	world.x = state.viewportPanX -- 215
	world.y = state.viewportPanY -- 216
	world.scaleX = scale -- 217
	world.scaleY = scale -- 218
	state.previewWorld = world -- 219
	clip:addChild(world) -- 220
	if state.showGrid then -- 220
		world:addChild(makeGridLine(worldWidth, worldHeight)) -- 222
	end -- 222
	world:addChild(makeAxisLine(worldWidth, worldHeight)) -- 224
	clip:addChild(makeSegmentRect(width, height, viewportGameFrameColor, 0.9)) -- 225
	local content = Node() -- 227
	state.previewContent = content -- 228
	world:addChild(content) -- 229
	state.runtimeNodes.root = content -- 230
	for ____, id in ipairs(state.order) do -- 232
		local item = state.nodes[id] -- 233
		if item ~= nil and id ~= "root" then -- 233
			local runtime = createRuntimeVisual(state, item) -- 235
			state.runtimeNodes[id] = runtime -- 236
			local parent = state.runtimeNodes[item.parentId or "root"] or content -- 237
			parent:addChild(runtime) -- 238
		end -- 238
	end -- 238
	state.previewDirty = false -- 241
end -- 193
function ____exports.updatePreviewRuntime(state) -- 244
	if state.previewDirty or state.previewRoot == nil then -- 244
		____exports.rebuildPreviewRuntime(state) -- 246
	end -- 246
	local p = state.preview -- 248
	local cx, cy = table.unpack( -- 249
		worldPointFromScreen(p.x + p.width / 2, p.y + p.height / 2), -- 249
		1, -- 249
		2 -- 249
	) -- 249
	local previewRoot = state.previewRoot -- 250
	if previewRoot == nil then -- 250
		return -- 251
	end -- 251
	previewRoot.x = cx -- 252
	previewRoot.y = cy -- 253
	if state.previewWorld ~= nil then -- 253
		local scale = math.max(0.25, state.zoom / 100) -- 255
		state.previewWorld.x = state.viewportPanX -- 256
		state.previewWorld.y = state.viewportPanY -- 257
		state.previewWorld.scaleX = scale -- 258
		state.previewWorld.scaleY = scale -- 259
	end -- 259
	for ____, id in ipairs(state.order) do -- 261
		local item = state.nodes[id] -- 262
		local runtime = state.runtimeNodes[id] -- 263
		if item ~= nil and runtime ~= nil then -- 263
			runtime.x = item.x -- 265
			runtime.y = item.y -- 266
			runtime.scaleX = item.scaleX -- 267
			runtime.scaleY = item.scaleY -- 268
			runtime.angle = item.rotation -- 269
			runtime.visible = item.visible -- 270
			local label = state.runtimeLabels[id] -- 271
			if label ~= nil then -- 271
				label.text = item.text or "Label" -- 272
			end -- 272
		end -- 272
	end -- 272
end -- 244
return ____exports -- 244